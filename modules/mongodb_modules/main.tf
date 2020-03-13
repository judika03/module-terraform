locals {
    ## control the number of shards ##
    number_of_shards = var.number_of_shards

    # to decide whether arbiter is needed or not
    number_of_arbiter = var.number_of_backup %  2

}

## create router(config server included) ##
resource "google_compute_instance" "vm_instance" {
    name = each.key
    machine_type = var.machine_type
    zone = "asia-southeast1-a"
    tags = ["firewall"]
    

    boot_disk {
        initialize_params {
            image = var.ubuntu_mongo_image
        }
    }

    network_interface {
        network = var.network
        network_ip = each.value["network_ip"] 
        access_config{
            nat_ip = each.value["external_ip"]
        }
    }

    metadata = {
        startup-script =  each.value["startup"] 
    }


    for_each = {
        default-router = {
            startup = templatefile("${path.module}/ssh_templates/router_mongo.sh.tmpl", 
             {config_internalIp = google_compute_address.router_internal_ip.address, 
             config_port = var.config_port,
             router_port = var.router_port
             config_replicaSetName = "config-replica", 
             externalIp = google_compute_address.external_router.address,
             username = var.username,
             password = var.password
             })       

            external_ip = google_compute_address.external_router.address
            network_ip = google_compute_address.router_internal_ip.address
            
        }
    }
}



## create shards ##
resource "google_compute_instance" "shards" {
    name = "${var.shard_name}-${count.index}"
    machine_type = var.machine_type
    zone = "asia-southeast1-a"
    tags = ["firewall"]
    count = local.number_of_shards
    boot_disk {
        initialize_params {
            image = var.ubuntu_mongo_image
        }
    }

    service_account {
        email = data.google_service_account.service_account.email
        scopes = ["cloud-platform"]
    }
    # provisioner "remote-exec" {
    #     when = destroy
    #     inline = [templatefile("${path.module}/ssh_templates/scaling_out.sh.tmpl",
    #         {router_ip = google_compute_address.external_router.address,
    #          router_port = 27020,
    #          replicaset_name = "replicaset-${count.index}",
    #          index = count.index})]
    #     connection {
    #         type = "ssh"
    #         user = "sre"
    #         password = "shopee1234"
    #         host = google_compute_address.external_router.address
    #     }
    # }
    metadata = {
        startup-script =  templatefile("${path.module}/ssh_templates/create_shard.sh.tmpl",
            {internalIp = google_compute_address.shards_ip[count.index].address,
             port = var.shard_port, replicaSetName = "replicaset-${count.index}",
             router_internal_ip = google_compute_address.router_internal_ip.address,
             router_port = var.router_port,
             username = var.username,
             password = var.password})
        
    }


    network_interface{
        network = var.network
        network_ip = google_compute_address.shards_ip[count.index].address
        access_config{
            nat_ip = null
        }
    }
    ## router have to be created first before shard is created ##
    depends_on = [
        google_compute_instance.vm_instance,
    ]
}

## create backup shards ##
resource "google_compute_instance" "backup_shards" {
    name = "backup-${var.shard_name}-${(count.index - (count.index % var.number_of_backup)) / var.number_of_backup}-${count.index}"
    machine_type = var.machine_type
    zone = "asia-southeast1-a"
    tags = ["firewall"]
    count = var.number_of_backup * local.number_of_shards
    boot_disk {
        initialize_params {
            image = var.ubuntu_mongo_image
        }
    }
    service_account {
        email = data.google_service_account.service_account.email
        scopes = ["cloud-platform"]
    }


    provisioner "file" {
        content = templatefile("${path.module}/ssh_templates/scaling_out_backup.sh.tmpl",
            {
                local_ip = google_compute_address.backup_shards_ip[count.index].address,
                port = var.shard_port,
                primary_ip = google_compute_instance.shards[(count.index - (count.index % var.number_of_backup)) / var.number_of_backup].network_interface.0.network_ip
            })
        destination = "/home/sre/scaling_out_backup.sh"

        connection {
            type = "ssh"
            user = "sre"
            password = "shopee1234"
            host = google_compute_address.backup_shards_ip[count.index].address
        }
    }

    # # add rs.remove() when  destroying backup
    # provisioner "remote-exec" {
    #     when = destroy
    #     inline = [
    #         "chmod +x /home/sre/scaling_out_backup.sh",
    #         "/home/sre/scaling_out_backup.sh"
    #     ]
    #     connection {
    #         type = "ssh"
    #         user = "sre"
    #         password = "shopee1234"
    #         host = google_compute_address.backup_shards_ip[count.index].address
    #     }
    # }


    metadata = {
        startup-script = templatefile("${path.module}/ssh_templates/backup_replica.sh.tmpl",
            {internalIp = google_compute_address.backup_shards_ip[count.index].address,
             port = var.shard_port,
             replicaSetName = "replicaset-${(count.index - (count.index % var.number_of_backup)) / var.number_of_backup}",
             primary_ip = google_compute_instance.shards[(count.index - (count.index % var.number_of_backup)) / var.number_of_backup].network_interface.0.network_ip,
             username = var.username,
             password = var.password})
        
    }
    # integer division  of count.index // var.number_of_backup (count.index - (count.index % var.number_of_backup)) / var.number_of_backup


    network_interface{
        network = var.network
        network_ip = google_compute_address.backup_shards_ip[count.index].address #google_compute_address.internal_ip[each.key].address
        access_config{
            nat_ip = null
        }
    }
    ## router have to be created first before shard is created ##
    depends_on = [
        google_compute_instance.shards
    ]
}

# null resource to create arbiter from shard's vm 
resource "null_resource" "create_arbiter" {
    count = local.number_of_shards * local.number_of_arbiter

    ## create arbiter
    provisioner "file" {
        content = templatefile("${path.module}/ssh_templates/create_arbiter.sh.tmpl",
             {
                arbiter_port = var.shard_port,
                replicaSetName = "replicaset-${count.index}",
                primary_ip = google_compute_instance.shards[count.index].network_interface.0.network_ip,
                port = var.shard_port,
                index = count.index,
                load_balancer = "10.148.10.76",
                username = var.username,
                password = var.password
            })
        destination = "/tmp/create_arbiter.sh"
        connection {
            type = "ssh"
            user = "sre"
            password = "shopee1234"
            host = google_compute_instance.shards[count.index].network_interface.0.network_ip
        }
    }
    provisioner "remote-exec" {
        inline = [
            "chmod +x /tmp/create_arbiter.sh",
            "/tmp/create_arbiter.sh"
        ]
        connection {
            type = "ssh"
            user = "sre"
            password = "shopee1234"
            host = google_compute_instance.shards[count.index].network_interface.0.network_ip
        }
    }
    # provisioner "remote-exec" {
    #     when = destroy
    #     scripts =
    # }
    
}

## static internal ip for shards ##
resource "google_compute_address" "shards_ip" {
    name = "${var.shard_name}-ip-${count.index}"
    count = local.number_of_shards
    address_type = "INTERNAL"
    purpose      = "GCE_ENDPOINT"
}

## static internal ip for backup shard ##
resource "google_compute_address" "backup_shards_ip" {
    name = "backup-${var.shard_name}-ip-${count.index}"
    count = var.number_of_backup * local.number_of_shards
    address_type = "INTERNAL"
    purpose = "GCE_ENDPOINT"
}


## create internal ip for router ##
resource "google_compute_address" "router_internal_ip" {
    name         = var.router_name
    address_type = "INTERNAL"
    purpose      = "GCE_ENDPOINT"
}
## create external ip for the router ##
resource "google_compute_address" "external_router" {
    name         = "mongo-${var.router_name}"
    address_type = "EXTERNAL"
    description = "for external ip of router mongo"
}

## firewall ##
resource "google_compute_firewall" "ssh" {
  name    = "firewall"
  network = var.network
  allow {
    protocol = "tcp"
    ports    = var.ports
  }

  target_tags   = ["firewall"]
  source_ranges = var.source_ranges
}


data "google_service_account" "service_account" {
    account_id = "gitlab-ci"
}
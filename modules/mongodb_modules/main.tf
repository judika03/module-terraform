locals {
    ## control the number of shards ##
    number_of_shards = var.additional_shards

    remove_shard = "db.adminCommand({'removeShard': 'replicaset-1'})"
}

## create router(config server included) and first shards ##
resource "google_compute_instance" "vm_instance" {
    name = each.key
    machine_type = var.machine_type
    zone = "asia-southeast1-a"
    tags = ["firewall-ssh"]
    

    boot_disk {
        initialize_params {
            image = var.ubuntu_mongo_image
        }
    }

    network_interface {
        network = var.network
        network_ip = each.value["network_ip"] #google_compute_address.internal_ip[each.key].address
        access_config{
            nat_ip = each.value["external_ip"]
        }
    }

    metadata = {
        startup-script =  each.value["startup"] #var.startup-script # each.value["template_file"]
    }


    for_each = {
        default-shard = {
            startup = templatefile("${path.module}/ssh_templates/config_mongo.sh.tmpl", 
            {port = var.shard_port ,
             internalIp = google_compute_address.internal_ip["first-shard"].address,
             replicaSetName = "replica1",
             databaseName = var.database_name, 
             collectionName = var.collection_name})

            external_ip = null
            network_ip = google_compute_address.internal_ip["first-shard"].address

        }
        router = {
            startup = templatefile("${path.module}/ssh_templates/router_mongo.sh.tmpl", 
             {config_internalIp = google_compute_address.internal_ip["router"].address, 
             config_port = 27010,
             config_replicaSetName = "config-replica", 
             externalIp = google_compute_address.external_router.address, 
             shard_address = "replica1/${google_compute_address.internal_ip["first-shard"].address}:${var.shard_port}",
             databaseName = var.database_name,
             collectionName = var.collection_name,
             shard_key = var.shard_key,
             index_type = var.index_type
             })       

            external_ip = google_compute_address.external_router.address
            network_ip = google_compute_address.internal_ip["router"].address
            
        }
    }
}



## create additional shards ##
resource "google_compute_instance" "shards" {
    name = "shard-${count.index}"
    machine_type = var.machine_type
    zone = "asia-southeast1-a"
    tags = ["firewall-ssh"]
    count = local.number_of_shards
    boot_disk {
        initialize_params {
            image = var.ubuntu_mongo_image
        }
    }
    provisioner "remote-exec" {
        when = destroy
        inline = [templatefile("${path.module}/ssh_templates/scaling_out.sh.tmpl",
            {router_ip = google_compute_address.external_router.address,
             router_port = 27020,
             replicaset_name = "replicaset-${count.index}",
             index = count.index})]
        connection {
            type = "ssh"
            user = "stevenalvin1999"
            password = "123456"
            host = google_compute_address.external_router.address
        }
    }
    metadata = {
        startup-script =  templatefile("${path.module}/ssh_templates/create_shard.sh.tmpl",
            {internalIp = google_compute_address.shards_ip[count.index].address,
             port = var.shard_port, replicaSetName = "replicaset-${count.index}",
             router_internal_ip = google_compute_address.internal_ip["router"].address,
             router_port = 27020})
        
    }

    network_interface{
        network = var.network
        network_ip = google_compute_address.shards_ip[count.index].address #google_compute_address.internal_ip[each.key].address
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
    name = "backup-shard-${(count.index - (count.index % 2)) / 2}-${count.index}"
    machine_type = var.machine_type
    zone = "asia-southeast1-a"
    tags = ["firewall-ssh"]
    count = 2 * local.number_of_shards
    boot_disk {
        initialize_params {
            image = var.ubuntu_mongo_image
        }
    }
    metadata = {
        startup-script =  templatefile("${path.module}/ssh_templates/backup_replica.sh.tmpl",
            {internalIp = google_compute_address.backup_shards_ip[count.index].address,
             port = var.shard_port,
             replicaSetName = "replicaset-${(count.index - (count.index % 2)) / 2}",
             primary_ip = google_compute_address.shards_ip[(count.index - (count.index % 2)) / 2].address})
        
    }

    network_interface{
        network = var.network
        network_ip = google_compute_address.backup_shards_ip[count.index].address #google_compute_address.internal_ip[each.key].address
        access_config{
            nat_ip = null
        }
    }
    ## router have to be created first before shard is created ##
    depends_on = [
        google_compute_instance.shards,
    ]
}



## static internal ip for shards ##
resource "google_compute_address" "shards_ip" {
    name = "shards-ip-${count.index}"
    count = local.number_of_shards
    address_type = "INTERNAL"
    purpose      = "GCE_ENDPOINT"
}

## static internal ip for backup shard ##
resource "google_compute_address" "backup_shards_ip" {
    name = "backup-shards-ip-${count.index}"
    count = 2 * local.number_of_shards
    address_type = "INTERNAL"
    purpose = "GCE_ENDPOINT"
}


## create internal ip for first shard and router ##
resource "google_compute_address" "internal_ip" {
    for_each = toset(["first-shard", "router"])
    #for_each = module.create_vm_instance2_mongo.instances_map
    name         = each.key
    address_type = "INTERNAL"
    purpose      = "GCE_ENDPOINT"
}
## create external ip for the router ##
resource "google_compute_address" "external_router" {
    name         = "mongo-router"
    address_type = "EXTERNAL"
    description = "for external ip of router mongo"
}

## firewall ##
resource "google_compute_firewall" "ssh" {
  name    = "firewall-ssh"
  network = var.network
  allow {
    protocol = "tcp"
    ports    = var.ports
  }

  target_tags   = ["firewall-ssh"]
  source_ranges = var.source_ranges
}
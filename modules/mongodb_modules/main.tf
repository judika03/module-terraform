locals {
    ## control the number of shards ##
    number_of_shards = var.number_of_shards
}

## create router and first shards ##
resource "google_compute_instance" "vm_instance" {
    name = each.key
    machine_type = "n1-standard-1"
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
        first-shard = {
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
             shard_key = "name",
             index_type = 1})       

            external_ip = google_compute_address.external_router.address
            network_ip = google_compute_address.internal_ip["router"].address
            
        }
    }
}



## create shards##
resource "google_compute_instance" "shards" {
    name = "shard-${count.index}"
    machine_type = "n1-standard-1"
    zone = "asia-southeast1-a"
    tags = ["firewall-ssh"]
    count = local.number_of_shards
    boot_disk {
        initialize_params {
            image = var.ubuntu_mongo_image
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


## static internal ip for shards ##
resource "google_compute_address" "shards_ip" {
    name = "shards-ip-${count.index}"
    count = local.number_of_shards
    address_type = "INTERNAL"
    purpose      = "GCE_ENDPOINT"
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
provider "google" {
  credentials = "data-storage-serviceaccount.json"
  project     = "mongo-terraform-project"
  region      = "asia-southeast1"
}

data "google_compute_image" "test_image"{
    name = "image-ubuntu-mongo"
    project = "mongo-terraform-project"
}


module "mongo" {
    source = "../../../modules/mongodb_modules"
    database_name = "mydbss"
    collection_name = "first-collection"
    machine_type = "n1-standard-1"
    network = "default"

    # default port #
    config_port = 27010
    shard_port = 27017
    router_port = 27020

    ## firewall ##
    ports = ["27010", "27020", "27017"]
    source_ranges = ["0.0.0.0/0"]

    # image (must use ubuntu and mongodb)
    ubuntu_mongo_image = data.google_compute_image.test_image.self_link

    number_of_shards = 4
}





# locals {
#     number_of_shards = 5
# }
# resource "google_compute_firewall" "ssh" {
#   name    = "firewall-ssh"
#   network = "default"
#   allow {
#     protocol = "tcp"
#     ports    = ["22", "27020", "27017"]
#   }

#   target_tags   = ["firewall-ssh"]
#   source_ranges = ["0.0.0.0/0"]
# }



# module "create_vm_instance_mongo" {
#     source = "/Users/steven.alvin/Desktop/mongo_terraform/modules/compute_instance"
#     instance_name = "vm-1"
#     network = "default"
#     startup-script = templatefile("./create-mongo-template.sh.tmpl",{})
#     tags         = ["firewall-ssh"]
#     instance_count = 2
# }

# module "create_vm_instance2_mongo" {
#     source = "../../../modules/compute_instance"
#     network = "default"
#     # startup-script = templatefile("./create-mongo-template.sh.tmpl",{})
#     tags         = ["firewall-ssh"]
#     boot_image =  data.google_compute_image.test_image.self_link#"gce-uefi-images/ubuntu-1804-lts"
#     instances_map = {
#         vm-1 = {
#             startup = templatefile("ssh_template/config_mongo.sh.tmpl", 
#             {port = 27017 ,
#              internalIp = google_compute_address.internal_with_gce_endpoint["vm-1"].address,
#              replicaSetName = "replica1",
#              databaseName = "mydbss", 
#              collectionName = "collection1"})

#             external_ip = null
#             network_ip = google_compute_address.internal_with_gce_endpoint["vm-1"].address

#         }
#         vm-2 = {
#             startup = templatefile("ssh_template/router_mongo.sh.tmpl", 
#              {config_internalIp = google_compute_address.internal_with_gce_endpoint["vm-2"].address, 
#              config_port = 27010,
#              config_replicaSetName = "config-replica", 
#              externalIp = google_compute_address.external_router.address, 
#              shard_address = "replica1/${google_compute_address.internal_with_gce_endpoint["vm-1"].address}:27017",
#              databaseName = "mydbss", collectionName = "collection1", shard_key = "name", index_type = 1})       

#             external_ip = google_compute_address.external_router.address
#             network_ip = google_compute_address.internal_with_gce_endpoint["vm-2"].address
            
#         }
        # vm-3 = {
        #     startup = templatefile("ssh_template/create_shard.sh.tmpl",
        #     {internalIp = google_compute_address.internal_with_gce_endpoint["vm-3"].address,
        #      port = 27017, replicaSetName = "replicaset2",
        #      router_internal_ip = google_compute_address.internal_with_gce_endpoint["vm-2"].address,
        #      router_port = 27020})

        #     external_ip = null
        #     network_ip = google_compute_address.internal_with_gce_endpoint["vm-3"].address
        # }
        # vm-4 = {
        #     startup = templatefile("ssh_template/create_shard.sh.tmpl",
        #     {internalIp = google_compute_address.internal_with_gce_endpoint["vm-4"].address,
        #      port = 27017,
        #      replicaSetName = "replicaset3",
        #      router_internal_ip = google_compute_address.internal_with_gce_endpoint["vm-2"].address,
        #      router_port = 27020})

        #     external_ip = null
        #     network_ip = google_compute_address.internal_with_gce_endpoint["vm-4"].address
        # }
        # vm-5 = {
        #     startup = templatefile("ssh_template/create_shard.sh.tmpl",
        #     {internalIp = google_compute_address.internal_with_gce_endpoint["vm-5"].address,
        #      port = 27017,
        #      replicaSetName = "replicaset4",
        #      router_internal_ip = google_compute_address.internal_with_gce_endpoint["vm-2"].address,
        #      router_port = 27020})
            
        #     external_ip = null
        #     network_ip = google_compute_address.internal_with_gce_endpoint["vm-5"].address
        # }
        
#     }
# }


# resource "google_compute_instance" "shards" {
#     name = "shard-${count.index}"
#     machine_type = "n1-standard-1"
#     zone = "asia-southeast1-a"
#     tags = ["firewall-ssh"]
#     count = local.number_of_shards
#     boot_disk {
#         initialize_params {
#             image = data.google_compute_image.test_image.self_link
#         }
#     }
#     metadata = {
#         startup-script =  templatefile("ssh_template/create_shard.sh.tmpl",
#             {internalIp = google_compute_address.shards_ip[count.index].address,
#              port = 27017, replicaSetName = "replicaset-${count.index}",
#              router_internal_ip = google_compute_address.internal_with_gce_endpoint["vm-2"].address,
#              router_port = 27020})
        
#     }

#     network_interface{
#         network = "default"
#         network_ip = google_compute_address.shards_ip[count.index].address #google_compute_address.internal_with_gce_endpoint[each.key].address
#         access_config{
#             nat_ip = null
#         }
#     }
#     depends_on = [
#         module.create_vm_instance2_mongo,
#     ]
# }






# resource "google_compute_address" "internal_with_gce_endpoint" {
#     for_each = toset(["vm-1", "vm-2", "vm-3", "router-internal", "vm-4", "vm-5"])
#     #for_each = module.create_vm_instance2_mongo.instances_map
#     name         = each.key
#     address_type = "INTERNAL"
#     purpose      = "GCE_ENDPOINT"
# }
# resource "google_compute_address" "external_router" {
#     name         = "router"
#     address_type = "EXTERNAL"
#     description = "for external ip of router mongo"
# }


# resource "google_compute_address" "shards_ip" {
#     name = "shard-ip-${count.index}"
#     count = local.number_of_shards
#     address_type = "INTERNAL"
#     purpose      = "GCE_ENDPOINT"
# }


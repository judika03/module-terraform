

provider "google" {

  project = var.project_id
  version = "~> 2.7.0"
}

module "single_compute_instance" {
  source            = "../../../modules/single_compute_instance"
  name              = "spid-"
  zone              = var.zone
  email             = module.service_accounts.email
  subnetwork        = var.subnetwork
  service_account = var.service_account
  instances_list ={
     redis-1 = {
        startup="${data.template_file.config1.rendered}"
        network_ip= google_compute_address.internal["redis-1"].address
        machine_type= "n1-standard-2"
    }
     redis-2 = {
        startup="${data.template_file.config2.rendered}"
        network_ip= google_compute_address.internal["redis-2"].address
        machine_type= "n1-standard-1"
    }
     redis-3 = {
        startup="${data.template_file.config3.rendered}"
        network_ip= google_compute_address.internal["redis-3"].address
        machine_type= "n1-standard-2"
    }
  }
}

resource "google_compute_address" "internal"{
    for_each =toset(["redis-1","redis-2","redis-3"])
    name =each.key
    address_type= "INTERNAL"
    region       = "${var.region}"
    project      = "${var.project_id}"
}



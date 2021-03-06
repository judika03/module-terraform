

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
  ports = ["22", "2181", "2888"]
  source_ranges = ["0.0.0.0/0"]
  instances_list ={
    kafka-1 = {
        startup=templatefile("template/kafka.sh.tpl",{})
        network_ip= null
        machine_type= "n1-standard-2"
    }
     kdhhdhddn = {
        startup=templatefile("template/kafka.sh.tpl",{})
        network_ip= null
        machine_type= "n1-standard-2"
    }
  }
  
}

resource "google_compute_address" "internal"{
    for_each =toset(["kafka"])
    name =each.key
    address_type= "INTERNAL"
     region       = "${var.region}"
    project      = "${var.project_id}"
}



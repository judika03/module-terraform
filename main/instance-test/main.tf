

provider "google" {

  project = var.project_id
  version = "~> 2.7.0"
}

module "single_compute_instance" {
  source            = "../../modules/single_compute_instance"
  name              = "spid-"
  zone              = var.zone
  email             = module.service_accounts.email
  subnetwork        = var.subnetwork
  service_account = var.service_account
  instances_list ={
     redis-1 = {
        startup="${data.template_file.startup1.rendered}"
        network_ip= google_compute_address.internal["redis-1"].address
        machine_type= "n1-standard-2"
    }
     redis-2 = {
        startup="${data.template_file.startup2.rendered}"
        network_ip= google_compute_address.internal["redis-2"].address
        machine_type= "n1-standard-1"
    }
     redis-3 = {
        startup="${data.template_file.startup3.rendered}"
        network_ip= google_compute_address.internal["redis-3"].address
        machine_type= "n1-standard-2"
    }
     kibana = {
        startup=templatefile("config/kibana/kibana.sh.tpl",{})
        network_ip= null
        machine_type= "n1-standard-2"
    }
  }
}

resource "google_compute_address" "internal"{
    for_each =toset(["redis-1","redis-2","redis-3","redis-5"])
    name =each.key
    address_type= "INTERNAL"
    region       = "${var.region}"
    project      = "${var.project_id}"
}


module "instance_template" {
  source          = "../../modules/instance_template"
  region          = var.region
  subnetwork      = var.subnetwork
  service_account = var.service_account
  machine_type         =var.master_machine_type
  project_id = var.project_id
  startup_script="${data.template_file.startup3.rendered}"
}

module "instance_template-es-master" {
  source               = "../../modules/instance_template"
  region               = var.region
  project_id = var.project_id
  subnetwork           = var.subnetwork
  machine_type         =var.master_machine_type
  email                = module.service_accounts.email
  startup_script=data.template_file.instance_startup_script.rendered
}

module "instance_template-es-data" {
  source               = "../../modules/instance_template"
  region               = var.region
  project_id = var.project_id
  machine_type         =var.master_machine_type
  subnetwork           = var.subnetwork
  email                = module.service_accounts.email
  startup_script=data.template_file.instance_startup_script1.rendered
}

module "managed_instance_group-master" {
  source            = "../../modules/manager_instance_group"
  region            = var.region
  project_id = var.project_id

  target_size       = 2
  hostname          = "elastic-master-spid"
  instance_template = module.instance_template-es-master.self_link
  named_ports = [{
    name = "elasticsearch"
    port = 9200
  }]
}

module "managed_instance_group-data" {
  source            = "../../modules/manager_instance_group"
  region            = var.region
  project_id = var.project_id
  target_size       = 2
  hostname          = "elastic-data-spid"
  instance_template = module.instance_template-es-data.self_link
  named_ports = [{
    name = "elasticsearch"
    port = 9200
  }]
}


module "compute_instance" {
  source            = "../../modules/compute_instance"
  region            = var.region
  zone              = var.zone
  subnetwork        = var.subnetwork
  num_instances     = var.num_instances
  hostname          = "instance-simple"
  instance_template = module.instance_template.self_link
}


module "umig" {
  source            = "../../modules/unmanaged_instance_group"
  project_id        = var.project_id
  subnetwork        = var.subnetwork
  hostname          = "umig-judika"
  instance_template = module.instance_template.self_link
  region            = var.region
  zone              = var.zone
  instances         = module.compute_instance.instances_self_links
}


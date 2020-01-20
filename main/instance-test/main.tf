

provider "google" {

  project = var.project_id
  version = "~> 2.7.0"
}


resource "google_compute_address" "redis-1" {
  project      = "${var.project_id}"
  name         = "redis-1"
  subnetwork   = "default"
  address_type = "INTERNAL"
  region       = "${var.region}"
}

resource "google_compute_address" "redis-2" {
  project      = "${var.project_id}"
  name         = "redis-2"
  subnetwork   = "default"
  address_type = "INTERNAL"
  region       = "${var.region}"
}

resource "google_compute_address" "redis-3" {
  project      = "${var.project_id}"
  name         = "redis-3"
  subnetwork   = "default"
  address_type = "INTERNAL"
  region       = "${var.region}"
}
resource "google_compute_address" "redis-4" {
  project      = "${var.project_id}"
  name         = "redis-4"
  subnetwork   = "default"
  address_type = "INTERNAL"
  region       = "${var.region}"
}

module "service_accounts" {
  source        = "../../modules/service_account"
  project_id    = var.project_id
  prefix        = var.prefix
  names         = ["redis-cluster"]
  project_roles = ["${var.project_id}=>roles/viewer","${var.project_id}=>roles/compute.admin",
]
}



module "single_compute_instance_redis-1" {
  source            = "../../modules/compute_instance-redis"
  name              = "redis-1"
  zone              = var.zone
  email             = module.service_accounts.email
  subnetwork        = var.subnetwork
  service_account = var.service_account
  network_ip = "${google_compute_address.redis-1.address}"
  startup_script=  "${data.template_file.startup1.rendered}"

}

  module "single_compute_instance_redis-2" {
  source            = "../../modules/compute_instance-redis"
  name              = "redis-2"
  zone              = var.zone
  email             = module.service_accounts.email
  subnetwork        = var.subnetwork
  service_account = var.service_account
  network_ip = "${google_compute_address.redis-2.address}"
    startup_script=  "${data.template_file.startup2.rendered}"

  }

  module "single_compute_instance_redis-3" {
  source            = "../../modules/compute_instance-redis"
  name              = "redis-3"
  zone              = var.zone
  email             = module.service_accounts.email
  subnetwork        = var.subnetwork
  service_account = var.service_account
  network_ip = "${google_compute_address.redis-3.address}"
  startup_script=  "${data.template_file.startup3.rendered}"
  }





module "single_compute_instance" {
  source            = "../../modules/single_compute_instance"
  name              = "redis-1"
  zone              = var.zone
  email             = module.service_accounts.email
  subnetwork        = var.subnetwork
  service_account = var.service_account
  instances_list ={
    vm-1 = {
        startup="${data.template_file.startup1.rendered}"
        ipName = "ip_redis1"
        network_ip= google_compute_address.internal["vm1"].address
    }
    vm-2 = {
        startup="${data.template_file.startup1.rendered}"
        ipName = "ip_redis1"
        network_ip= google_compute_address.internal["vm2"].address
    }
  }
}

resource "google_compute_address" "internal"{
    for_each =toset(["vm1","vm2"])
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


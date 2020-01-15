

provider "google" {

  project = var.project_id
  version = "~> 2.7.0"
}
resource "google_compute_address" "redis-spid-11" {
  project      = "${var.project_id}"
  name         = "redis-1"
  subnetwork   = "default"
  address_type = "INTERNAL"
  region       = "${var.region}"
}

module "service_accounts" {
  source        = "../../modules/service_account"
  project_id    = var.project_id
  prefix        = var.prefix
  names         = ["single-account"]
  project_roles = ["${var.project_id}=>roles/viewer","${var.project_id}=>roles/compute.admin",
]
}

data "template_file" "config1" {
  template = "${file("config/redis1.sh.tpl")}"
  vars = {
  redis1 = "192.168.2.1:7001"
  redis2 = "192.168.2.2:7001"
  redis3 = "192.168.2.3:7001"
  }
}
module "instance_template" {
  source          = "../../modules/instance_template"
  region          = var.region
  subnetwork      = var.subnetwork
  service_account = var.service_account
  project_id = var.project_id
  network_ip = "${google_compute_address.redis-spid-11.address}"
  startup_script="${data.template_file.config1.rendered}"
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

module "compute_instance-redis" {
  source            = "../../modules/compute_instance"
  region            = var.region
  zone              = var.zone
  subnetwork        = var.subnetwork
  num_instances     = var.num_instances
  hostname          = "redis"
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


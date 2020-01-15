

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

module "instance_template" {
  source          = "../../modules/instance_template"
  region          = var.region
  subnetwork      = var.subnetwork
  service_account = module.service_accounts.service_account
  project_id = var.project_id
  network_ip = "${google_compute_address.redis-spid-11.address}"
  startup_script="${data.template_file.config1.rendered}"
}

data "template_file" "config1" {
  template = "${file("config/redis1.sh.tpl")}"
  vars = {
    redis1 = "${google_compute_address.redis-spid-11.address}:7001"
  }
}

module "compute_instance" {
  source            = "../../modules/compute_instance"
  region            = var.region
  subnetwork        = var.subnetwork
  num_instances     = var.num_instances
  hostname          = "instance-simple"
  instance_template = module.instance_template.self_link
}

module "mig" {
  source            = "../../modules/manager_instance_group"
  project_id        = var.project_id
  region            = var.region
  target_size       = var.target_size
  hostname          = "mig-simple"
  instance_template = module.instance_template.self_link
}

module "umig" {
  source            = "../../modules/unmanaged_instance_group"
  project_id        = var.project_id
  subnetwork        = var.subnetwork
  num_instances     = var.num_instances
  hostname          = "umig-simple"
  instance_template = module.instance_template.self_link
  region            = var.region
}



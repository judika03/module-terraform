provider "google" {
  project     = "spid-non-prod"
  region      = "asia-southeast1"
}

module "graylog_slave" {
    source = "../../../modules/graylog_slave/"
    num_instances = "1"
    ansible_user = "wilbert.cargeson"
    machine_type = "n1-standard-1"
}

module "graylog_master" {
  source = "../../../modules/graylog_master/"
  ansible_user = "wilbert.cargeson"
  machine_type = "n1-standard-1"
}

# Update Ansible inventory 
resource "local_file" "ansible_inventory" {
    content   = join("\n",concat(module.graylog_master.master_self_links,module.graylog_slave.instances_self_links))
    filename = "graylog.ini"
} 

# Library for Load Balancer
module "gce-ilb" {
  source       = "github.com/judika03/module-terraform/modules/lb-internal"
  project      = var.project_id
  network      = var.network
  subnetwork   = var.subnetwork
  region       = var.region
  name         = "graylog-lb-terraform"
  health_check = local.health_check
  source_tags  = ["allow-group1"]
  ports        = ["9000"]
  target_tags  = ["allow-lb-service"]
    backends = [
    {
      group       = "${module.graylog_slave.instance_group_url}" 
      description = "Load balancer for the slave nodes"
    }
    ]
}




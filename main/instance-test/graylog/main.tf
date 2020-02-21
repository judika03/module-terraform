provider "google" {
  project     = "spid-non-prod"
  region      = "asia-southeast1"
}

data "google_compute_image" "test_image"{
    name = "image-ubuntu-mongo"
    project = "spid-non-prod"
}

module "graylog" {
    source = "../../../modules/graylog/"
    num_instances = "1"
    ansible_user = "wilbert.cargeson"
    machine_type = "n1-standard-1"
}


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
      group       = "${module.graylog.instance_group_url}" 
      description = ""
    }
    ]
}

resource "local_file" "ansible_inventory" {
    content   = join("\n",concat(module.graylog.master_self_links,module.graylog.instances_self_links))
    filename = "graylog.ini"

} 



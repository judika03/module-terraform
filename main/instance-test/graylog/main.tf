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


resource "local_file" "ansible_inventory" {
    # 10.148.10.81 is the IP address of the master node 
    content   = join("\n",concat(["10.148.10.81"],module.graylog.instances_self_links))
    filename = "graylog.ini"

} 



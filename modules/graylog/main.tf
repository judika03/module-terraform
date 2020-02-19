data "google_compute_image" "test_image"{
    name = "graylog-node"
    project = "spid-non-prod"
}

provider "google" {
  project     = "spid-non-prod"
  region      = "asia-southeast1"
}

resource "google_compute_instance" "shards" {
    name = "graylog-tf-${count.index}"
    project ="spid-non-prod"
    machine_type = var.machine_type
    zone = "asia-southeast1-a"
    tags = ["firewall-ssh","graylog-spid","udp-graylog"]
    count = var.num_instances
    boot_disk {
        initialize_params {
            image = data.google_compute_image.test_image.name
        }
    }
    metadata = {
        startup-script = templatefile("${path.module}/template/graylog.sh.tpl",{})
    }

    network_interface{
        network = var.network
        network_ip = google_compute_address.graylog-spid[count.index].address #google_compute_address.internal_ip[each.key].address
        access_config{
            nat_ip = null
        }
    }
    ## router have to be created first before shard is created ##

#     provisioner "local-exec" {
#     command = <<EOT
#       sleep 40;
# 	  echo ${google_compute_address.graylog-spid[count.index].address} | tee -a  ansible-graylog/graylog.ini;
#       export ANSIBLE_HOST_KEY_CHECKING=False;
# 	  ansible-playbook -u ${var.ansible_user} -i ansible-graylog/graylog.ini ansible-graylog/graylog_mongo.yaml
#     EOT
#   }
}

## static internal ip for shards ##
resource "google_compute_address" "graylog-spid" {
    name = "graylog-tf-${count.index}"
    project = "spid-non-prod"
    count = var.num_instances
    address_type = "INTERNAL"
    purpose      = "GCE_ENDPOINT"
}

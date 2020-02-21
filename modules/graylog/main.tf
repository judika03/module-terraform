data "google_compute_image" "test_image"{
    name = "graylog-node"
    project = "spid-non-prod"
}

provider "google" {
  project     = "spid-non-prod"
  region      = "asia-southeast1"
}

resource "google_compute_instance" "nodes" {
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
        network_ip = google_compute_address.graylog-spid[count.index].address 
        access_config{
            nat_ip = null
        }
    }
}

# Instance group for the load balancer
resource "google_compute_instance_group" "graylog-ig2" {
  name = "graylog-ig2"  
  instances = google_compute_instance.nodes.*.self_link
  zone = "asia-southeast1-a"
}

## Static internal ip for.nodes ##
resource "google_compute_address" "graylog-spid" {
    name = "graylog-tf-${count.index}"
    project = "spid-non-prod"
    count = var.num_instances
    address_type = "INTERNAL"
    purpose      = "GCE_ENDPOINT"

    
}

# Runs the ansible command when a node is created/destroyed
resource "null_resource" "ansible" {
    triggers = {
        addresses = "${join(",",google_compute_instance.nodes.*.self_link)}"
    }
    provisioner "local-exec" {
        command = "echo ${join(",",google_compute_address.graylog-spid.*.address)} nodes; sleep 40; export ANSIBLE_HOST_KEY_CHECKING=False; ansible-playbook -u ${var.ansible_user} -i graylog.ini --ssh-extra-args '-o StrictHostKeyChecking=no'  ansible_graylog.yaml "
    }
}

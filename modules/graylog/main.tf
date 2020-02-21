data "google_compute_image" "test_image"{
    name = "graylog-node-1"
    project = "spid-non-prod"
}

provider "google" {
  project     = "spid-non-prod"
  region      = "asia-southeast1"
}

data "template_file" "master" {
    template = "${file("template/graylog_master.sh.tpl")}"
    vars = {
        ipaddress = "${join("",google_compute_address.graylog-spid-master.*.address)}"
    }
}

resource "google_compute_instance" "master" {
    name = "graylog-master"
    project ="spid-non-prod"
    machine_type = var.machine_type
    zone = "asia-southeast1-a"
    tags = ["firewall-ssh","graylog-spid","udp-graylog"]
    boot_disk {
        initialize_params {
            image = data.google_compute_image.test_image.name
        }
    }
    metadata = {
        startup-script = data.template_file.master.rendered
    }

    network_interface{
        network = var.network
        network_ip = google_compute_address.graylog-spid-master.address
        access_config{
            nat_ip = null
        }
    }
    provisioner "local-exec" {
        command = "echo ${join(",",google_compute_address.graylog-spid.*.address)} nodes; sleep 40; export ANSIBLE_HOST_KEY_CHECKING=False; ansible-playbook -u ${var.ansible_user} -i graylog.ini --ssh-extra-args '-o StrictHostKeyChecking=no'  ansible_graylog.yaml "
    }
}

resource "google_compute_instance" "nodes" {
    name = "graylog-slave-${count.index}"
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
resource "google_compute_instance_group" "graylog-ig" {
  name = "graylog-ig"  
  instances = google_compute_instance.nodes.*.self_link 
  zone = "asia-southeast1-a"
}


## Static internal ip for.nodes ##
resource "google_compute_address" "graylog-spid" {
    name = "graylog-slave-${count.index}"
    project = "spid-non-prod"
    count = var.num_instances
    address_type = "INTERNAL"
    purpose      = "GCE_ENDPOINT"    
}

## Static internal ip for master ##
resource "google_compute_address" "graylog-spid-master" {
    name = "graylog-tf-master"
    project = "spid-non-prod"
    address_type = "INTERNAL"
    purpose      = "GCE_ENDPOINT"    
}
# resource "google_compute_address" "graylog-spid-master" {
#     name = "graylog-tf-master"
#     project = "spid-non-prod"
#     address_type = "EXTERNAL"
#     purpose      = "GCE_ENDPOINT"    
# }

# Runs the ansible command when a node is created/destroyed
resource "null_resource" "ansible" {
    triggers = {
        addresses = "${join(",",google_compute_instance.nodes.*.self_link)}"
    }
    provisioner "local-exec" {
        command = "sleep 40;export ANSIBLE_HOST_KEY_CHECKING=False;ansible-playbook -u ${var.ansible_user} -i graylog.ini --ssh-extra-args '-o StrictHostKeyChecking=no'  ansible_graylog.yaml"
    }
}
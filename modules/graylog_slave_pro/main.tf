data "google_compute_image" "test_image"{
    name = "graylog-node-1"
    project = var.project_id_image
}

resource "google_compute_instance" "nodes" {
    name = "graylog-slave-${count.index}"
    project = var.project_id_nodes
    machine_type = var.machine_type
    zone = "asia-southeast1-a"
    tags = ["firewall-ssh","graylog-spid","udp-graylog"]
    count = var.num_instances
    allow_stopping_for_update = true
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
    project = var.project_id_address
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
        command = "sleep 40;export ANSIBLE_HOST_KEY_CHECKING=False;ansible-playbook -u ${var.ansible_user} -i graylog.ini --ssh-extra-args '-o StrictHostKeyChecking=no'  ansible_graylog.yaml"
    }
}

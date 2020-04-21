data "google_compute_image" "test_image"{
    name = "graylog-node-1"
    project = "spid-non-prod"
}

provider "google" {
  project     = "spid-non-prod"
  region      = "asia-southeast1"
} 

# Initialize master configurations
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
    tags = ["firewall-ssh","graylog-spid","udp-graylog","http-server"]
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
}

resource "google_compute_address" "graylog-spid-master" {
    name = "graylog-tf-master"
    project = "spid-non-prod"
    address_type = "INTERNAL"
    purpose      = "GCE_ENDPOINT"    
}
data "template_file" "instance_startup_script" {
  template = "${file("template/elastic.sh.tpl")}"
  vars = {
    PROXY_PATH = ""
    project_id             = "${var.project_id}"
    cluster_name           = "${var.cluster_name}"
    zones                  = "${join(",", var.zones)}"
    master                 = "${var.master_node}"
    data                   = "${var.data_node}" 
    minimum_master_nodes   = "${var.minimum_master_nodes}"
    heap_size              = "${var.heap_size}"

  }
}

data "template_file" "instance_startup_script1" {
  template = "${file("template/elastic.sh.tpl")}"
  vars = {
    PROXY_PATH = ""
    project_id             = "${var.project_id}"
    cluster_name           = "${var.cluster_name}"
    zones                  = "${join(",", var.zones)}"
    master                 = "${var.master_node1}"
    data                   = "${var.data_node1}" 
    minimum_master_nodes   = "${var.minimum_master_nodes}"
    heap_size              = "${var.heap_size}"

  }
}



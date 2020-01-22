data "template_file" "config1" {
  template = "${file("config/redis/redis1.sh.tpl")}"
  vars = {
    redis1 = "${google_compute_address.internal["redis-1"].address}"
    redis2 = "${google_compute_address.internal["redis-2"].address}"
    redis3 = "${google_compute_address.internal["redis-3"].address}"
  }
}

data "template_file" "config2" {
  template = "${file("config/redis/redis2.sh.tpl")}"
  vars = {
   redis1 = "${google_compute_address.internal["redis-1"].address}"
    redis2 = "${google_compute_address.internal["redis-2"].address}"
    redis3 = "${google_compute_address.internal["redis-3"].address}"
  
  }
}
data "template_file" "config3" {
  template = "${file("config/redis/redis3.sh.tpl")}"
  vars = {
       redis1 = "${google_compute_address.internal["redis-1"].address}"
    redis2 = "${google_compute_address.internal["redis-2"].address}"
    redis3 = "${google_compute_address.internal["redis-3"].address}"
  
  }
}

data "template_file" "instance_startup_script" {
  template = "${file("config/elastic/elastic.sh.tpl")}"
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
  template = "${file("config/elastic/elastic.sh.tpl")}"
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

resource "google_storage_bucket" "redis1" {
  project       = "${var.project_id}"
  name          = "redis-spid-1"
  storage_class = "REGIONAL"
  location      = "${var.region}"
  force_destroy= true
}
resource "google_storage_bucket" "redis2" {
  project       = "${var.project_id}"
  name          = "redis-spid-2"
  storage_class = "REGIONAL"
  location      = "${var.region}"
  force_destroy= true
}
resource "google_storage_bucket" "redis3" {
  project       = "${var.project_id}"
  name          = "redis-spid-3"
  storage_class = "REGIONAL"
  location      = "${var.region}"
  force_destroy= true
}

resource "google_storage_bucket_object" "config1" {
  name    = "redis_1.sh"
  content = "${data.template_file.config1.rendered}"
  bucket  = "${google_storage_bucket.redis1.name}"
}

resource "google_storage_bucket_object" "config2" {
  name    = "redis_2.sh"
  content = "${data.template_file.config2.rendered}"
  bucket  = "${google_storage_bucket.redis2.name}"
 
}
resource "google_storage_bucket_object" "config3" {
  name    = "redis_3.sh"
  content = "${data.template_file.config3.rendered}"
  bucket  = "${google_storage_bucket.redis3.name}"
}

data "template_file" "startup1" {
  template = "${file("config/startup/startup.sh.tpl")}"
  vars = {
    script_path = "gs://${google_storage_bucket.redis1.name}/${google_storage_bucket_object.config1.name}"
  }
}
data "template_file" "startup2" {
  template = "${file("config/startup/startup.sh.tpl")}"
  vars = {
    script_path = "gs://${google_storage_bucket.redis2.name}/${google_storage_bucket_object.config2.name}"
  }
}
data "template_file" "startup3" {
  template = "${file("config/startup/startup.sh.tpl")}"
  vars = {
    script_path = "gs://${google_storage_bucket.redis3.name}/${google_storage_bucket_object.config3.name}"
  }
}


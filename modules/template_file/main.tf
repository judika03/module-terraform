

data "template_file" "config-redis" {
  template = each.value["template"]
  vars={
    redis1 = each.value["redis1"]
    redis2 = each.value["redis2"]
    redis3 = each.value["redis3"]
  }
  for_each={
      
      config1= {
      template= "${file("config/redis/redis1.sh.tpl")}"
      redis1 = "${google_compute_address.redis-1.address}"
      redis2 = "${google_compute_address.redis-2.address}"
      redis3 = "${google_compute_address.redis-3.address}"
      }
      config2= {
      template= "${file("config/redis/redis2.sh.tpl")}"
      redis1 = "${google_compute_address.redis-1.address}"
      redis2 = "${google_compute_address.redis-2.address}"
      redis3 = "${google_compute_address.redis-3.address}"
      }
      
      config3= {
      template= "${file("config/redis/redis2.sh.tpl")}"
      redis1 = "${google_compute_address.redis-1.address}"
      redis2 = "${google_compute_address.redis-2.address}"
      redis3 = "${google_compute_address.redis-3.address}"
      }
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



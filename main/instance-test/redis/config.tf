data "template_file" "config1" {
  template = "${file("template/redis1.sh.tpl")}"
  vars = {
    redis1 = "${google_compute_address.internal["redis-1"].address}"
    redis2 = "${google_compute_address.internal["redis-2"].address}"
    redis3 = "${google_compute_address.internal["redis-3"].address}"
  }
}

data "template_file" "config2" {
  template = "${file("template/redis2.sh.tpl")}"
  vars = {
   redis1 = "${google_compute_address.internal["redis-1"].address}"
    redis2 = "${google_compute_address.internal["redis-2"].address}"
    redis3 = "${google_compute_address.internal["redis-3"].address}"
  
  }
}
data "template_file" "config3" {
  template = "${file("template/redis3.sh.tpl")}"
  vars = {
    redis1 = "${google_compute_address.internal["redis-1"].address}"
    redis2 = "${google_compute_address.internal["redis-2"].address}"
    redis3 = "${google_compute_address.internal["redis-3"].address}"
  
  }
}
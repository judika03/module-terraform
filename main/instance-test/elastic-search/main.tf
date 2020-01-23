
module "instance_template-es-master" {
  source               = "../../../modules/instance_template"
  region               = var.region
  project_id = var.project_id
  subnetwork           = var.subnetwork
  machine_type         =var.master_machine_type
  subnetwork_project           = var.subnetwork_project
  email                = module.service_accounts.email
  startup_script=data.template_file.instance_startup_script.rendered
}

module "instance_template-es-data" {
  source               = "../../../modules/instance_template"
  region               = var.region
  project_id = var.project_id
  machine_type         =var.master_machine_type
  subnetwork           = var.subnetwork
 subnetwork_project           = var.subnetwork_project
  email                = module.service_accounts.email
  startup_script=data.template_file.instance_startup_script1.rendered
}

module "managed_instance_group-master" {
  source            = "../../../modules/manager_instance_group"
  region            = var.region
  project_id = var.project_id

  target_size       = 2
  hostname          = "elastic-master-spid"
  instance_template = module.instance_template-es-master.self_link
  named_ports = [{
    name = "elasticsearch"
    port = 9200
  }]
}

module "managed_instance_group-data" {
  source            = "../../../modules/manager_instance_group"
  region            = var.region
  project_id = var.project_id
  target_size       = 5
  hostname          = "elastic-data-spid"
  instance_template = module.instance_template-es-data.self_link
  named_ports = [{
    name = "elasticsearch"
    port = 9200
  }]
}
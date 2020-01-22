module "service_accounts" {
  source        = "../../modules/service_account"
  project_id    = var.project_id
  prefix        = var.prefix
  names         = ["redis-cluster"]
  project_roles = ["${var.project_id}=>roles/viewer","${var.project_id}=>roles/compute.admin",
]
}
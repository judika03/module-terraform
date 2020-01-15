locals {
  account_billing = var.grant_billing_role && var.billing_account_id != ""
  org_billing     = var.grant_billing_role && var.billing_account_id == "" && var.org_id != ""
  prefix          = var.prefix != "" ? "${var.prefix}-" : ""
  xpn             = var.grant_xpn_roles && var.org_id != ""
  emails          = [for account in google_service_account.service_accounts : account.email]
  iam_emails      = [for email in local.emails : "serviceAccount:${email}"]
}

# create service accounts
resource "google_service_account" "service_accounts" {
  count        = length(var.names)
  account_id   = "${local.prefix}${lower(element(var.names, count.index))}"
  display_name = "Terraform-managed service account"
  project      = var.project_id
}

# common roles
resource "google_project_iam_member" "project-roles" {
  count = length(var.project_roles) * length(var.names)

  project = element(
    split(
      "=>",
      element(var.project_roles, count.index % length(var.project_roles)),
    ),
    0,
  )

  role = element(
    split(
      "=>",
      element(var.project_roles, count.index % length(var.project_roles)),
    ),
    1,
  )

  member = "serviceAccount:${element(
    google_service_account.service_accounts.*.email,
    floor(count.index / length(var.project_roles)),
  )}"
}



resource "google_organization_iam_member" "xpn_admin" {
  count  = local.xpn ? length(var.names) : 0
  org_id = var.org_id
  role   = "roles/compute.xpnAdmin"
  member = "serviceAccount:${google_service_account.service_accounts[count.index].email}"
}

resource "google_organization_iam_member" "organization_viewer" {
  count  = local.xpn ? length(var.names) : 0
  org_id = var.org_id
  role   = "roles/resourcemanager.organizationViewer"
  member = "serviceAccount:${google_service_account.service_accounts[count.index].email}"
}

# keys
resource "google_service_account_key" "keys" {
  count              = var.generate_keys ? length(var.names) : 0
  service_account_id = google_service_account.service_accounts[count.index].email
}

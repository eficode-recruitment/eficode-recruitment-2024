resource "google_service_account" "ansible_sa" {
  account_id  = "ansible-sa"
  description = "Service account for Ansible"
}

resource "google_project_iam_member" "ansible_sa_viewer" {
  project = var.gcp_project_id
  role    = "roles/viewer"
  member  = "serviceAccount:${google_service_account.ansible_sa.email}"
}

resource "google_service_account_key" "ansible_sa_key" {
  service_account_id = google_service_account.ansible_sa.name
  public_key_type    = "TYPE_X509_PEM_FILE"
}

resource "local_file" "service_account_key" {
  filename = "../ansible/inventory/ansible-sa-key.json"
  content  = base64decode(google_service_account_key.ansible_sa_key.private_key)
}

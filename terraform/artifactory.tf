resource "google_artifact_registry_repository" "artifactory" {
  location      = var.gcp_region
  repository_id = "containers"
  description   = "Weather App Docker repository"
  format        = "DOCKER"
}

resource "google_artifact_registry_repository_iam_binding" "artifactory_iam_binding" {
  project = google_artifact_registry_repository.artifactory.project
  location = google_artifact_registry_repository.artifactory.location
  repository = google_artifact_registry_repository.artifactory.name
  role = "roles/artifactregistry.reader"
  members = [
    "allUsers"
  ]
}

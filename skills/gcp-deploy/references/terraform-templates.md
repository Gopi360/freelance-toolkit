# Terraform Templates

## Cloud Run Service

```hcl
resource "google_cloud_run_v2_service" "service" {
  name     = var.service_name
  location = "europe-west2"

  template {
    containers {
      image = "gcr.io/${var.project_id}/${var.service_name}:${var.image_tag}"

      ports {
        container_port = 8080
      }

      resources {
        limits = {
          memory = var.memory
          cpu    = var.cpu
        }
      }

      dynamic "env" {
        for_each = var.env_vars
        content {
          name  = env.key
          value = env.value
        }
      }

      dynamic "env" {
        for_each = var.secret_env_vars
        content {
          name = env.key
          value_source {
            secret_key_ref {
              secret  = env.value
              version = "latest"
            }
          }
        }
      }
    }

    scaling {
      min_instance_count = var.min_instances
      max_instance_count = var.max_instances
    }
  }
}

# Public access (for webhooks only)
resource "google_cloud_run_v2_service_iam_member" "public" {
  count    = var.allow_unauthenticated ? 1 : 0
  location = google_cloud_run_v2_service.service.location
  name     = google_cloud_run_v2_service.service.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

variable "service_name" { type = string }
variable "project_id" { type = string }
variable "image_tag" { type = string }
variable "memory" { type = string; default = "512Mi" }
variable "cpu" { type = string; default = "1" }
variable "min_instances" { type = number; default = 0 }
variable "max_instances" { type = number; default = 5 }
variable "allow_unauthenticated" { type = bool; default = false }
variable "env_vars" { type = map(string); default = {} }
variable "secret_env_vars" { type = map(string); default = {} }
```

## Secret Manager

```hcl
resource "google_secret_manager_secret" "secrets" {
  for_each  = var.secrets
  secret_id = each.key

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "versions" {
  for_each    = var.secrets
  secret      = google_secret_manager_secret.secrets[each.key].id
  secret_data = each.value
}

resource "google_secret_manager_secret_iam_member" "access" {
  for_each  = var.secrets
  secret_id = google_secret_manager_secret.secrets[each.key].id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${var.service_account}"
}

variable "secrets" { type = map(string); sensitive = true }
variable "service_account" { type = string }
```

## Cloud Scheduler

```hcl
resource "google_cloud_scheduler_job" "cron" {
  name      = "${var.service_name}-cron"
  schedule  = var.schedule
  time_zone = "Europe/London"
  region    = "europe-west2"

  http_target {
    http_method = "POST"
    uri         = "${google_cloud_run_v2_service.service.uri}${var.cron_path}"

    oidc_token {
      service_account_email = var.scheduler_sa_email
    }
  }
}

variable "schedule" { type = string; default = "0 * * * *" }
variable "cron_path" { type = string; default = "/cron" }
variable "scheduler_sa_email" { type = string }
```

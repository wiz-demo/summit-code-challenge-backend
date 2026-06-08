# =============================================================================
# Wiz GitHub Connector
# =============================================================================
# Self-contained: connector-specific variables, the resource, and outputs.
#
# Unlike the AWS connector, GitHub auth is self-contained (GitHub App ID +
# private key), so this connector has NO wiz-iam dependency. It is provisioned
# by the root module's `make apply-root` target.
# =============================================================================

# --- Variables --------------------------------------------------------------

variable "github_connector_name" {
  description = "Display name for the Wiz GitHub connector shown in the Wiz UI."
  type        = string
}

variable "github_app_id" {
  description = "GitHub App ID Wiz authenticates as. Found in the GitHub App's settings page."
  type        = string

  validation {
    condition     = length(var.github_app_id) > 0
    error_message = "github_app_id must not be empty."
  }
}

variable "github_app_private_key_path" {
  description = "Filesystem path (relative to infra/wiz/) to the GitHub App private key PEM. Must point at a gitignored .pem; never commit the key."
  type        = string
}

# --- Resource ---------------------------------------------------------------

resource "wiz-v2_generic_connector" "github" {
  name = var.github_connector_name
  type = "github"

  # GitHub App auth against github.com (SaaS). `apps` is a list so one
  # connector could front multiple installations; we use a single app.
  # privateKey is read from a gitignored PEM file on disk (see
  # github_app_private_key_path); it is never committed.
  auth_params = jsonencode({
    serverType = "github.com"
    apps = [{
      id         = var.github_app_id
      privateKey = file("${path.module}/${var.github_app_private_key_path}")
    }]
  })

  # Custom scheduled-scan settings, mirroring the connector's "Custom scan
  # settings → Scheduled Scanning" panel in the Wiz UI. Event-triggered (PR)
  # scanning is left at tenant defaults. NOTE: the Wiz V2 API has no delete
  # semantics for these fields — once set they can only be overwritten, not
  # removed, without recreating the connector.
  extra_config = jsonencode({
    scan = {
      scheduled = {
        enabled                        = true
        gitHistoryScanningEnabled      = false
        scanPublicRepositories         = true # organizational public repos
        scanPublicPersonalRepositories = true # personal public repos
        modules = {
          vulnerabilities     = { enabled = true }
          data                = { enabled = true } # "Sensitive Data scanning"
          iac                 = { enabled = true }
          secrets             = { enabled = true }
          sast                = { enabled = true }
          softwareSupplyChain = { enabled = true } # "Software Management scanning"
        }
      }
    }
  })
}

# --- Outputs ----------------------------------------------------------------

output "github_connector_id" {
  description = "Wiz GitHub connector ID (visible in the Wiz UI)."
  value       = wiz-v2_generic_connector.github.id
}

output "github_connector_name" {
  description = "Wiz GitHub connector display name."
  value       = wiz-v2_generic_connector.github.name
}

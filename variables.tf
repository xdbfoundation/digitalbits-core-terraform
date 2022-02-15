variable "domain_name" {
  description = "URL of hosted hoze managed by AWS Route53"
}

variable "DD_API_KEY" {
  description = "Datadog API Key"
}

variable "DD_SITE" {
  description = "Datadog home site"
  default     = "datadoghq.com"
}

# --- Nodes Seed Secrets 
variable "secret_deu" {}
variable "secret_irl" {}
variable "secret_swe" {}
variable "secret_can" {}
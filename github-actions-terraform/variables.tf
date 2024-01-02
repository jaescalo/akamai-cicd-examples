variable "akamai_client_secret" {}
variable "akamai_host" {}
variable "akamai_access_token" {}
variable "akamai_client_token" {}
variable "akamai_account_key" {}

variable "edgerc" {
  type    = string
  default = "default"
}

variable "section" {
  type    = string
  default = "default"
}

variable "group_name" {
  type    = string
  default = ""
}

variable "contract_id" {
  type    = string
  default = "ctr_1-1NC95D"
}

variable "edge_hostname" {
  type    = string
  default = ""
}

variable "property_name" {
  type    = string
  default = ""
}

variable "activation_notes" {
  type    = string
  default = "Activated by GitHub Workflow"
}

variable "hostname" {
  type    = string
  default = ""
}

variable "emails" {
  type    = list(string)
  default = ["noreply@akamai.com"]
}
variable "edgerc_path" {
  type    = string
  default = "~/.edgerc"
}

variable "config_section" {
  type    = string
  default = "default"
}

variable "env" {
  type    = string
  default = "staging"
}

variable "group_name" {
  type    = string
  default = "JAESCALO Testing"
}

variable "contract_id" {
  type    = string
  default = "ctr_1-1NC95D"
}

variable "edge_hostname" {
  type    = string
  default = "jaescalo.test.edgekey.net"
}

variable "property_name" {
  type    = string
  default = "gitops-prod.demo.com"
}

variable "hostname" {
  type    = list(string)
  default = ["noreply@akamai.com"]
}

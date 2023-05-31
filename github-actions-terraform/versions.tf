terraform {
  required_providers {
    akamai = {
      source  = "akamai/akamai"
      version = ">= 3.5.0"
    }
    linode = {
      source = "linode/linode"
    }
  }
  required_version = ">= 0.13"
  # Linode S3 is our remote backend and we'll pass the configuration parameters with the TF "-backend-config" flag as this block doesn't allow the use of variables. See the ./github/workflows/akamai_pm.yaml.
  backend "s3" {}
}

provider "akamai" {
  edgerc         = var.edgerc_path
  config_section = var.config_section
}
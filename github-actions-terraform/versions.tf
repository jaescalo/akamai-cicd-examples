terraform {
  required_providers {
    akamai = {
      source  = "akamai/akamai"
      version = ">= 5.2.0"
    }
    linode = {
      source = "linode/linode"
    }
  }
  required_version = ">= 0.13"
  # Linode S3 is our remote backend and we'll pass the configuration parameters with 
  # the TF "-backend-config" flag as this block doesn't allow the use of variables. 
  # See the ./github/workflows/akamai_pm.yaml.
  backend "s3" {}
}

# Akamai API credentials passed on as environment variables
provider "akamai" {
  config {
    client_secret = var.akamai_client_secret
    host          = var.akamai_host
    access_token  = var.akamai_access_token
    client_token  = var.akamai_client_token
    account_key   = var.akamai_account_key
  }
}
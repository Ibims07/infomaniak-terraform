terraform {
  required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 2.0.0"
    }
  }
}

# Configure the OpenStack Provider
provider "openstack" {
  auth_url    = "https://api.pub1.infomaniak.cloud/identity/v3/"
  region      = "dc3-a"
  user_name   = var.INFOMANIAK_user
  tenant_name = var.INFOMANIAK_tennant
  password    = var.INFOMANIAK_password
}
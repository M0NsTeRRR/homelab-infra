locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  env_vars     = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  network_vars = read_terragrunt_config(find_in_parent_folders("network.hcl"))

  vsphere_user     = local.account_vars.locals.vsphere_user
  vsphere_password = local.account_vars.locals.vsphere_password
  powerdns_api_key = local.account_vars.locals.powerdns_api_key

  vm_user            = local.account_vars.locals.vm_user
  vm_password        = local.account_vars.locals.vm_password

  vsphere_datacenter = local.env_vars.locals.vsphere_datacenter
  vsphere_cluster    = local.env_vars.locals.vsphere_cluster
  dns                = local.env_vars.locals.dns

  network = local.network_vars.locals.network
  domain  = local.network_vars.locals.domain
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = "~> 1.24.2"
    }
    powerdns = {
      source  = "terraform-providers/powerdns"
      version = "~> 1.4.0"
    }
  }
}

provider "vsphere" {
  vsphere_server = "${local.vsphere_domain}"
  user           = "${local.vsphere_user}"
  password       = "${local.vsphere_password}"

  # If you have a self-signed cert
  allow_unverified_ssl = true
}

provider "powerdns" {
  api_key    = "${local.powerdns_api_key}"
  server_url = "https://dns1.unicornafk.fr"

  # If you have a self-signed cert
  insecure_https = true
}
EOF
}

inputs = merge(
  local.account_vars.locals,
  local.env_vars.locals,
  local.network_vars.locals
)
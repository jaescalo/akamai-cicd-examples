data "akamai_group" "group" {
  group_name  = var.group_name
  contract_id = var.contract_id
}

data "akamai_contract" "contract" {
  group_name = data.akamai_group.group.group_name
}

resource "akamai_edge_hostname" "jaescalo-test-edgekey-net" {
  contract_id   = data.akamai_contract.contract.id
  group_id      = data.akamai_group.group.id
  ip_behavior   = "IPV6_COMPLIANCE"
  edge_hostname = var.edge_hostname
}

resource "akamai_property" "gitops-prod-demo-com" {
  name        = var.property_name
  contract_id = data.akamai_contract.contract.id
  group_id    = data.akamai_group.group.id
  product_id  = "prd_Fresca"
  hostnames {
    cname_from             = var.hostname
    cname_to               = akamai_edge_hostname.jaescalo-test-edgekey-net.edge_hostname
    cert_provisioning_type = "DEFAULT"
  }
  rule_format = data.akamai_property_rules_builder.gitops-prod-demo-com_rule_default.rule_format
  rules       = data.akamai_property_rules_builder.gitops-prod-demo-com_rule_default.json
}

resource "akamai_property_activation" "gitops-prod-demo-com" {
  property_id = akamai_property.gitops-prod-demo-com.id
  contact     = var.emails
  version     = akamai_property.gitops-prod-demo-com.latest_version
  network     = upper(var.env)
  note        = "Property Manager CLI Activation"
}

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

resource "akamai_property" "dev-gitlab-pipeline-demo" {
  name        = var.property_name
  contract_id = data.akamai_contract.contract.id
  group_id    = data.akamai_group.group.id
  product_id  = "prd_Fresca"
  hostnames {
    cname_from             = var.hostname
    cname_to               = akamai_edge_hostname.jaescalo-test-edgekey-net.edge_hostname
    cert_provisioning_type = "CPS_MANAGED"
  }
  rule_format = data.akamai_property_rules_builder.dev-gitlab-pipeline-demo_rule_default.rule_format
  rules       = replace(data.akamai_property_rules_builder.dev-gitlab-pipeline-demo_rule_default.json, "\"rules\"", "\"comments\": \"${var.activation_notes}\", \"rules\"")
}

resource "akamai_property_activation" "dev-gitlab-pipeline-demo-staging" {
  property_id                    = akamai_property.dev-gitlab-pipeline-demo.id
  contact                        = var.emails
  version                        = akamai_property.dev-gitlab-pipeline-demo.latest_version
  network                        = "STAGING"
  note                           = var.activation_notes
  auto_acknowledge_rule_warnings = true
}

resource "akamai_property_activation" "dev-gitlab-pipeline-demo-production" {
  property_id                    = akamai_property.dev-gitlab-pipeline-demo.id
  contact                        = var.emails
  version                        = akamai_property.dev-gitlab-pipeline-demo.latest_version
  network                        = "PRODUCTION"
  note                           = var.activation_notes
  auto_acknowledge_rule_warnings = true
}
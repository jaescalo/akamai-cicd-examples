terraform -chdir=./github-actions-terraform import akamai_edge_hostname.jaescalo-test-edgekey-net ehn_4874468,ctr_1-1NC95D,grp_71960
terraform -chdir=./github-actions-terraform import akamai_property.dev-gitlab-pipeline-demo prp_735579,ctr_1-1NC95D,grp_71960,22
terraform -chdir=./github-actions-terraform akamai_property_activation.dev-gitlab-pipeline-demo-staging prp_735579:STAGING
terraform -chdir=./github-actions-terraform akamai_property_activation.dev-gitlab-pipeline-demo-staging prp_735579:PRODUCTION
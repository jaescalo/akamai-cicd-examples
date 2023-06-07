# Akamai Property Deployed by GitHub Actions with Terraform and Linode Backend

This is a demo on how to manage existing Akamai properties as code by leveraging the [Akamai Terraform Provider](https://techdocs.akamai.com/terraform/docs) in a GitHub Workflow:

* GitHub Actions used to run the workflow that executes Terraform to update the Akamai Property.
* Terraform's state file is stored remotely in Linode's Object Storage (S3 compatible).
* Terraform updates and activates a property based on the changes performed to the rule tree. 

## Prerequisites
- [Akamai API Credentials](https://techdocs.akamai.com/developer/docs/set-up-authentication-credentials). Also familiarize with concepts related to the `.edgerc` file.
- [Akamai Terraform Provider](https://techdocs.akamai.com/terraform/docs)
- [Akamai CLI for Terraform](https://github.com/akamai/cli-terraform)
- Basic Understanding of [GitHub Actions](https://docs.github.com/en/actions) and setting up [secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets).
- [Linode Object Storage](https://www.linode.com/lp/object-storage/) bucket with Access Keys created for storing Terraform's state file.
 
## Prepare Properties for Akamai as Code
Perhaps the most important step is to prepare the target properties for management via Akamai as Code:

* The code should be based on a production property (i.e. www.example.com NOT qa.example.com)
* If desired, perform a configuration clean-up (i.e. remove duplicated rules/behaviors, parameterize behaviors/matches, etc) which can help reduce the code length.
* All advanced rules and matches need to be converted first to [Akamai Custom Behaviors](https://developer.akamai.com/blog/2018/04/26/custom-behaviors-property-manager-papi) or to the Property Manager behaviors/matches if possible. If there is an advanced override section this can also be converted to a custom advanced override.
* Freeze the rule tree to a specific version to avoid future catalog updates that could turn the current Akamai as Code incompatible.
* Avoid code drift by changes made outside the Akamai as Code flow and develop new processes to make sure your code is fully up to date and the single source of truth

### Terraform Declarative Property Manager
In TF provider version 3.5.0 (March 30th 2023) a new way to build and maintain the rules in the property is available. The official documentation for the declarative rule resource `rule_property_rules_builder` can be found [HERE](https://techdocs.akamai.com/terraform/docs/rules-builder)

Akamai's Terraform CLI also supports exporting a property to TF using the declarative syntax (HCL). For more information check out the [official CLI repository](https://github.com/akamai/cli-terraform#property-manager-properties).
In summary here's how you would export an existing property to TF with the declarative syntax:
```
akamai terraform export-property --schema <property-name>
```
After running the above all the necessary terraform files will be created plus the `import.sh` file. The latter can be used to import existing resources in Akamai into Terraform's state. 

## Linode Object Storage for TF Remote Backend
Optionally (but highly recommended), a remote backed to store the Terraform state file is recommended. For testing and experimenting it is okay to keep the state file locally though. 
For this demo an S3 compatible [Linode Object Storage](https://www.linode.com/lp/object-storage/) bucket was setup to store Terraform's state file. 

## GitHub Actions Setup
For this demo, temporary Akamai API Credentials credentials are stored as Secret Repository variables. The naming convention for the variables used is:

- AKAMAI_CREDENTIAL_CLIENT_SECRET = Akamai `client_secret` credential
- AKAMAI_CREDENTIAL_HOST = Akamai `host` credential
- AKAMAI_CREDENTIAL_ACCESS_TOKEN = Akamai `access_token` credential
- AKAMAI_CREDENTIAL_CLIENT_TOKEN = Akamai `client_token` credential

Additionally for the S3 compatible Linode Object Storage the following Secret Repository variables are required:

- LINODE_OBJECT_STORAGE_BUCKET = the name of the bucket
- LINODE_OBJECT_STORAGE_ACCESS_KEY = access key for the Object Storage
- LINODE_OBJECT_STORAGE_SECRET_KEY = secret key for the Object Storage

In the `.github/workflows/akamai_pm.yaml` these variables are referenced to build the Terraform configurations.
* The Akamai variables are used to perform operations on the property such as create, update and destroy during the `terraform apply` step. Observe that these are passed as `TF_VAR_*` TF environment variables that TF can recognize.
* The Linode variables are used to build the Terraform's backend configuration which then is passed to TF during the `terraform init` command.

## Import Existing Property
Often times you want to manage an existing resource on Akamai via Terraform. For this to be successful the initial Terraform state must be created. This can be done by executing the `import.sh` script which runs the necessary `terraform import` commands for all the resources exported by the Akamai Terraform CLI.

In the `.github/workflows/akamai_pm.yaml` you will find this step, however it is commented out, and the reason is because it was executed on the very first run just to get the Terraform state generated. After that initial run you can comment it out or just remove it from the GitHub workflow code.

## Resources
- [Akamai API Credentials](https://techdocs.akamai.com/developer/docs/set-up-authentication-credentials)
- [Akamai Terraform Provider](https://techdocs.akamai.com/terraform/docs)
- [Akamai CLI for Terraform](https://github.com/akamai/cli-terraform)
- [Linode Object Storage](https://www.linode.com/lp/object-storage/)
- [Akamai Docker](https://github.com/akamai/akamai-docker)
- [Akamai Developer Youtube Channel](https://www.youtube.com/c/AkamaiDeveloper)
- [Akamai Github](https://github.com/akamai)
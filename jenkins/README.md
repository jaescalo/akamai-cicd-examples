![](https://img.shields.io/badge/License-MIT-brightgreen.svg?style=plastic)
![](https://img.shields.io/static/v1?label=Akamai&message=papi/v1&color=blue&style=plastic)

# Akamai Pipeline in Jenkins

This is a demo on how to manage existing Akamai properties as code by leveraging "Akamai Pipeline" CLI framework which allows to:

* Break an existing property into JSON snippets
* Parameterize the builds for the different environments by using the variables JSON files.
* Merge the changes to build the final rule tree. 

After the rule tree is built it will be pushed to Akamai and activated using the Akamai Property CLI commands (more flexibility for CI/CD) instead of the Akamai CLI pipeline promote commands.

## Prerequisites
- [Akamai API Credentials](https://developer.akamai.com/getting-started/edgegrid) for creating propertie, hostnames and CP codes.
- [Akamai Property Manager CLI](https://github.com/akamai/cli-property-manager)
- Go through the [Akamai Pipeline Runbook](https://developer.akamai.com/resource/whitepaper/akamai-pipeline-cli-framework-runbook/direct)

There are two main subjects: Property Preparation for Akamai as Code and Jenkins Pipeline Configuration.

## Prepare Properties for Akamai as Code
Perhaps the most important step is to prepare the target properties for management via the pipeline framework.

* Pipeline should be based on a production property (i.e. www.example.com NOT qa.example.com)
* If desired, perform a configuration clean-up (i.e. remove duplicated rules/behaviors, parameterize behaviors/matches, etc) which can help reduce the code length.
* All advanced rules and matches need to be converted first to [Akamai Custom Behaviors](https://developer.akamai.com/blog/2018/04/26/custom-behaviors-property-manager-papi) or to the Property Manager behaviors/matches if possible. If there is an advanced override section this can also be converted to a custom advanced override.
* The Akamai pipeline framework will create build artifacts for all stages using a common template metadata. For this to work effectively, all rules and behaviors must be normalized across each environment so that they work consistently. If there are lower level environment differences these can be added under a hostname match.

### Akamai Pipeline Setup
The main idea is to build a template property that will be used for all the environments. Once a property is ready for "Akamai as Code" it can be used as a template. It is a good idea to make your production property the template property.

These steps should only need to be executed once when you're converting a property to code or when you're adding new environments to the pipeline.

1. Create your Akamai API credentials and install the Akamai Property Manager CLI.
2. Create a local pipeline referring to the template property. You can give any name to the pipeline and at this point is not necessary to specify all the environments, these can be added later. This command will actually create new properties, but these can be deleted later.
```
$ akamai pipeline new-pipeline -p demo.com -e <propertyId> gitops-prod -g <groupId> --variable-mode user-var-value
```
3. At this point there will be multiple files and a folder structure created locally. Edits are recommended to add more environments and to clean up some of the files.
4. To add more environments (i.e. stage, test, dev, qa) add them to the /projectInfo.json file, plus only the `environments` and `name` key are needed and the rest can be deleted. For example adding the "gitops-dev" environment:
```
{
    "environments": [
        "gitops-prod",
        "gitops-dev"
    ],
    "name": "demo.com"
}
```
5. For the newly added environment in the (pipeline)/environments/(env)/ directory, edit the `envInfo.json` file and clean it up. Only keep the name key which specifies the environment name.
```
{
    "name": "gitops-dev"
} 
```
6. Because for an existing property it is rare to add/remove hostname the `hostnames.json` files can be deleted. These are located inside each environment folder.
7. Add any pipeline variables as needed through the JSON variables files to parameterize the different environments.
8. Build the rule tree files for each environment by submiting the merge command.
```
$ akamai pipeline merge  -n -v -p demo.com gitops-dev
$ akamai pipeline merge  -n -v -p demo.com gitops-prod
```
Our file repository is set up! These can be uploaded to the repository now and managed with CI/CD.

## Akamai Pipeline Setup in Jenkins
This is a simple example that leverages the akamai/shell Docker container to execute the pipeline. 

There are two `Jenkinsfile` in this repository:
1. `./Jenkinsfile` is the main Jenkins pipeline definition.
2. `./tests-pipeline/Jenkinsfile` is the test pipeline which is triggered from the main pipeline and uses Newman to run the website tests.
3. For simplicity variables are created which will reference to the pipeline name and environment. For example:
```
environment {
    EDGERC_FILE = credentials('AKAMAI_EDGERC')
    ACCOUNTKEY = '1-6JHGX'
    PIPELINE_NAME = 'demo.com'
    ENVIRONMENT = 'gitops-prod'
}
```
4. Store The Akamai {OPEN} API credentials in Jenkins Credentials. For this scenario the credentials were stored under the name `AKAMAI_EDGERC`.
5. The ACCOUNTKEY variables is used for the `--accountSwitchKey` flag which can be disregarded as it is only for managing multiple accounts with one API client. 

### The flow
1. A developer makes changes to JSON code and commits is to the repository. Git branching and collaboration concepts apply here.
2. Akamai CLI builds the rule file from the json snippets and variables
```
$ akamai pipeline merge  -n -v -p <pipeline-name> <environment>
```
3. Akamai CLI creates a new version of the property and updates it with the local rule tree file
```
$ akamai property-manager property-update -p <property-name> --file ./demo.com/dist/gitops-dev.demo.com message "Created By Jenkins-$JOB_BASE_NAME:$BUILD_NUMBER; Commit $COMMIT_MESSAGE"
```
4. Akamai CLI activates the property
```
$ akamai property-manager activate-version -p <property-name> --network staging --wait-for-activate
```

## Test Stage
This is optional but highly recommended to always test the changes through any testing framentworks. In this example Newman (CLI for Postman) is used to run a public collection from a URL. The Test Stage is defined as a separate Job in Jenkins therefore it has its own `Jenkinsfile` located in `./tests-pipeline/`.

## Resources
- [Akamai OPEN Edgegrid API Clients](https://developer.akamai.com/libraries)
- [Akamai Pipeline](https://developer.akamai.com/devops/use-cases/akamai-pipeline)
- [Akamai Property-Manager and Pipeline CLI](https://github.com/akamai/cli-property-manager)
- [Akamai as Code with Jsonnet](https://developer.akamai.com/blog/2021/04/28/akamai-code-jsonnet)
- [Akamai Docker](https://github.com/akamai/akamai-docker)
- [Test Changes With Akamai Sandbox & Docker](https://developer.akamai.com/blog/2020/12/11/test-changes-akamai-sandbox-docker)

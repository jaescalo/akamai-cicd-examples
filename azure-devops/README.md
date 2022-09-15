# Akamai Property Manager, Cloudlet and Test Center Pipeline

This Akamai Pipeline will add add a new redirect to your existing hostname and then test it. For managing the redirects we'll use the Edge Redirector Cloudlet and for testing the changes the Akamai Test Center tool. Property Manager is used to control when to trigger the Edge Redirector Cloudlet, however this step is not necessary and included only for demo purposes.

## Prerequisites
- [Akamai API Credentials](https://techdocs.akamai.com/developer/docs/set-up-authentication-credentials) for Cloudlets and Test Center. Also familiarize with concepts related to the .edgerc (location, section, account-key). These will be used in the pipeline code but removed from this writing for simplification.
- [Akamai Property Manager CLI](https://github.com/akamai/cli-property-manager)
- Go through the [Akamai Pipeline Runbook](https://developer.akamai.com/resource/whitepaper/akamai-pipeline-cli-framework-runbook/direct)
- [Akamai Cloudlets CLI](https://github.com/akamai/cli-cloudlets)
- [Akamai Test Center CLI](https://github.com/akamai/cli-test-center) - Beta as of September 2022
- [Akamai Account Switch Key](https://techdocs.akamai.com/developer/docs/manage-many-accounts-with-one-api-client). Only in case you manage multiple accounts with the same set of credentials.

## Prepare Properties for Akamai as Code
Perhaps the most important step is to prepare the target properties for management via the pipeline framework.

* Pipeline should be based on a production property (i.e. www.example.com NOT qa.example.com)
* If desired, perform a configuration clean-up (i.e. remove duplicated rules/behaviors, parameterize behaviors/matches, etc) which can help reduce the code length.
* All advanced rules and matches need to be converted first to [Akamai Custom Behaviors](https://developer.akamai.com/blog/2018/04/26/custom-behaviors-property-manager-papi) or to the Property Manager behaviors/matches if possible. If there is an advanced override section this can also be converted to a custom advanced override.
* The Akamai pipeline framework will create build artifacts for all stages using a common template metadata. For this to work effectively, all rules and behaviors must be normalized across each environment so that they work consistently. If there are lower level environment differences these can be added under a hostname match.
* Freeze the rule tree to a specific version to avoid future catalog updates that could turn the current Akamai as Code incompatible.
* Avoid code drift by changes made outside the Akamai as Code flow and develop new processes to make sure your code is fully up to date and the single source of truth

### Akamai Pipeline Setup
The main idea is to build a template property that will be used for all the environments. Once a property is ready for "Akamai as Code" it can be used as a template. It is a good idea to make your production property the template property.

These steps should only need to be executed once when you're converting a property to code or when you're adding new environments to the pipeline.

1. Create your Akamai API credentials and install the Akamai Property Manager CLI.
2. Create a local pipeline referring to the template property. You can give any name to the pipeline and at this point is not necessary to specify all the environments, these can be added later. This command will actually create new properties, but these can be deleted later.
    ```
    $ akamai pipeline new-pipeline -p demo.com -e <propertyId> dev prod -g <groupId> --variable-mode user-var-value
    ```
3. At this point there will be multiple files and a folder structure created locally. Edits are recommended to add more environments and to clean up some of the files.
4. To add more environments (i.e. stage, test, dev, qa) add them to the /projectInfo.json file, plus only the `environments` and `name` key are needed and the rest can be deleted. For example adding the "dev" environment:
    ```
    {
        "environments": [
            "prod",
            "dev"
        ],
        "name": "demo.com"
    }
    ```
5. For the newly added environment in the (pipeline)/environments/(dev)/ directory, edit the `envInfo.json` file and clean it up. Only keep the name key which specifies the environment name.
    ```
    {
        "name": "dev"
    } 
    ```
6. Because for an existing property it is rare to add/remove hostname the `hostnames.json` files can be deleted. These are located inside each environment folder.
7. Add any pipeline variables as needed through the JSON variables files to parameterize the different environments.
8. Build the rule tree file by submiting the merge command.
    ```
    $ akamai pipeline merge  -n -v -p demo.com dev
    ```
Our file repository is set up! These can be uploaded to GitLab now and managed with CI/CD.

## Prepare Your Cloudlet for Akamai as Code
Cloudlets are managed separatelly from the delivery property and can be expressed in JSON. The Cloudlets CLI simplifies the job but APIs and some scripting could have been used as well.

To convert the Cloudlet Policy rules to JSON code run the following CLI command. You have to pass the policy id or the policy name if you use the `--policy` flag.
```
$ akamai cloudlets retrieve --policy-id <policy_id> --only-match-rules > ER_rules.json
```
The command from above also saved all the Cloudlet rules in the file `ER_rules.json`. This file is our first Akamai as Code asset to be stored in the version control repository. For now we'll save it a the root level in the repo.

## Prepare Your Test for Akamai as Code
Of course a pipeline isn't complete without a testing stage. If you don't already have a Test Suite configured then you need to build one. See steps 1-2, otherwise skip to step 3. More information on managing [Test Center as JSON Code here](https://github.com/akamai/cli-test-center#manage-test-center-objects-using-json).

1. Generate a test suite. This is a a default test suite and you may need to modify the test scenarios. However in this demo we'll just add the new redirect as a new test case.
    ```
    $ akamai test-center test-suite generate-default --property <property_name> --propver <property_version> --url "https://www.example.com" --json > new_test_suite.json
    ```
    The output is saved in the `new_test_suite.json` file. Edit this file as needed. For the demos purposes we recommended to set `"locked": false` and change the `"testSuiteName"` to your own.

2. Create the test suite in Test Center:
    ```
    $ akamai test-center test-suite import < ./new_test_suite.json
    ```
    Take note of the Test Suite `Id` from the output as we'll use it next.


3. Get the test suite details. At this point we can get our Test Center as Code in JSON which we can use to manage our test suite.
    ```
    $ akamai test-center test-suite view --id <test_suite_id> --json > test_suite.json 
    ```
    The `test_suite.json` file will contain the JSON code for the test suite.

4. Modify the test suite to include the redirect. Make any necessary changes to the `test_suite.json`. For testing a redirect the following object can be used:

    ```
    {
      "testCaseId": null,
      "order": 1,
      "testRequest": {
        "testRequestUrl": "https://www.example.com/home/",
        "requestMethod": "GET"
      },
      "clientProfile": {
        "ipVersion": "IPV4",
        "clientType": "BROWSER"
      },
      "condition": {
        "conditionExpression": "Redirect response code is one of \"302\" and location is \"/\""
      }
    }
    ```
    * This file will be stored in the repository as `test/test_suite.json` (in a directory named test/)
    * Observe the `order` correlates to the order of the rules in the policy and you may need to modify it.
    * Observe the `testCaseId` is null because we want to create this new test case and we won't know the `testCaseId` until it is created. 
    * Because our CI/CD will execute this code we won't be able to know the `testCaseId` until after we have update the test suite. Therefore in the CI/CD one of the steps will be to repeat step 3 above to get the test suite details in JSON and store it as an artifact. Then this new version of the file which containes the `testCaseId` will be used by the developer. Otherwise if we continue using `"testCaseId": null` new and repeated test cases will be created. No work-around to this as of September 2022.

## Azure DevOps Setup
For this demo, temporary Akamai API Credentials credentials are stored as Secret Pipeline variables. The naming convention for the variables used is:

- CLIENT_SECRET = client_secret
- HOST = host
- ACCESS_TOKEN = access_token
- CLIENT_TOKEN = client_token

This values will be used in the pipeline Jobs/Steps to create the `.edgerc` file which the Akamai CLIs can consume.

You'll also notice that we will run our commands inside Docker containers which makes the environment setup much simpler.

Inside the CI/CD configuration file you will see references to the `--accountSwitchKey` which you can ignore if you don't manage multiple accounts with one API client.

## Stage 1: Update and Deploy changes to the Delivery Property
After a developer makes changes to the Akamai code and pushed to the repository the CI/CD pipeline starts by making the changes to the delivery property.

1. Akamai CLI builds the rule file from the json snippets and variables
    ```
    $ docker run --rm -v "$(pwd)":/workdir akamai/property-manager akamai pipeline merge -n -v -p <pipeline_name> <environment_name>
    ```
2. Akamai CLI creates a new version of the property and updates it with the local rule tree file
    ```
    $ docker run --rm -v "$(pwd)":/workdir akamai/property-manager akamai property-manager property-update -p <property_name> --file <*.papi.json> --message "Created By Azure DevOps; Commit-$BUILD_SOURCEVERSION - $BUILD_SOURCEVERSIONMESSAGE"
    ```
3. Akamai CLI activates the property
    ```
    docker run --rm -v "$(pwd)":/workdir akamai/property-manager akamai property-manager activate-version -p <property_name> --network staging --wait-for-activate
    ```

### Stage 2: Update and Deploy the New Cloudlet Rule
1. This stage reads the `ER_rules.json` from the repository and uploads it to the Cloudlet Policy to update. The CLI will create a new version of the policy if necessary and update the version notes with the commit ID and notes from the repo.
    ```
    docker run --rm -v "$(pwd)":/workdir akamai/cloudlets akamai cloudlets --edgerc ./.edgerc update --policy <policy_id> --file ER_rules.json --notes "Deployed by Azure DevOps Commit-$BUILD_SOURCEVERSION - $BUILD_SOURCEVERSIONMESSAGE"
    ```

2. Activate the newly updated Cloudlet policy to staging:
    ```
    docker run --rm -v "$(pwd)":/workdir akamai/cloudlets akamai cloudlets --edgerc ./.edgerc activate --policy <policy_name> --network staging
    ```

### Stage 3: Update and Run the Test Suite
Currently there is no Akamai Test Center CLI Docker image (still in Beta). Therefore a custom one was created under `jaimescalona/akamai-test-center` in Docker Hub.

1. This stage reads the `test/test_suite.json` from the repository and uploads it to the test suite to update. 
    ```
    docker run --rm -v "$(pwd)":/workdir jaimescalona/akamai-test-center akamai test-center --edgerc ./.edgerc test-suite manage < ./test/test_suite.json
    ```

2. Remember that the previous step will create new test cases with their new IDs. To save the new test suite with the updated info the following command is executed and the resulting JSON file stored as an artifact. 
    ```
    docker run --rm -v "$(pwd)":/workdir jaimescalona/akamai-test-center akamai test-center --edgerc ./.edgerc test-suite view --id <test_suite_id> --json > test_suite_updated.json
    ```
    The `test_suite_updated.json` file is saved as a pipeline artifact. 

3. Run the test suite:
    ```
    docker run --rm -v "$(pwd)":/workdir jaimescalona/akamai-test-center akamai test-center --edgerc ./.edgerc test --test-suite-id <test_suite_id>
    ```

## Resources
- [Akamai OPEN Edgegrid API Clients](https://techdocs.akamai.com/developer/docs/authenticate-with-edgegrid)
- [Akamai Pipeline](https://developer.akamai.com/devops/use-cases/akamai-pipeline)
- [Akamai as Code with Jsonnet](https://developer.akamai.com/blog/2021/04/28/akamai-code-jsonnet)
- [Cloudlets API v2](https://techdocs.akamai.com/cloudlets/v2/reference/api)
- [Cloudlets API v3](https://techdocs.akamai.com/cloudlets/reference/api)
- [Test Center API](https://techdocs.akamai.com/test-ctr/reference/api)
- [Akamai Docker](https://github.com/akamai/akamai-docker)
- [Akamai Developer Youtube Channel](https://www.youtube.com/c/AkamaiDeveloper)
- [Akamai Github](https://github.com/akamai)
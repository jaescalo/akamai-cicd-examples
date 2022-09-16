# Automated EdgeWorkers Deployments
Demo for bundling, saving, activating and generating enhanced debugging headers for EdgeWorkers upon a Git commit. All these steps will be completed within minutes of the repository commit by using CircleCi. 

*Keyword(s):* edgeworkers, circleci, automation

The actual EdgeWorkers example is based on the [hello-world](https://github.com/akamai/edgeworkers-examples/tree/master/edgecompute/examples/getting-started/hello-world%20(EW)) example in the official Akamai repository.

![CircleCI Pipeline](http://jaescalo.test.edgekey.net/images/CircleCI-flow.jpg)

## Prerequisites/Tools
- GitHub account and repository
- Akamai EdgeWorkers Enabled. EdgeKV is Optional.
- [CircleCI Account](https://app.circleci.com/dashboard)
- [EdgeWorkers Docker](https://hub.docker.com/r/akamai/edgeworkers)
- [EdgeWorkers CLI](https://github.com/akamai/cli-edgeworkers)
- Understand basic file manipulation with `echo` and `sed`

## Quick Setup
Follow the instructions to the line to run this same example in your Akamai EdgeWorkers environment.
1. Clone this repository and push it to your own repository. 
2. Modify the `.circleci/config.yml` configuration by adding your own values to the environmental variables  `EWID` and `BUNDLENAME`. For example:
  ```
  environment:
    EWID: 4885
    BUNDLENAME: ew-bundle.tgz
  ```
3. Set up a CircleCI Context named **edgerc** with all the variables labeled as "CircleCI Context" from the table below. If you’re not use EdgeKV then ignore the EDGEKV_* variables. [Instructions](https://circleci.com/docs/2.0/contexts/)
4. Set up a CircleCI project with GitHub. [Instructions](https://circleci.com/docs/2.0/getting-started/)
5. Commit your changes to your GitHub repository and watch the pipeline execute.

## CircleCI Setup
A workflow is defined in the `.circleci/config.yml` file which is comprised of the build, deploy and test jobs to exemplify a DevOps pipeline.
The different configuration files are parametrized and we need to define these parameters or variables first.

* In CircleCI Context set up the variables that will be used directly by the `.circleci/config.yml` file. These variables may contain sensitive information (values are obscured) and the values do not change frequently. Instructions here ALOHA POST.
* In the `.circleci/config.yml` configuration the local variables can be changed on every execution of the pipeline to adjust to each case and these do not contain sensitive information.
* In the `.circleci/config.yml` configuration file there are parameters which can be modified for conditional execution of blocks within the pipeline.

These are the variables and parameters to setup and modify. Keep the same names in the table below.
| Variable Name | Value (Example) | Location | Description |
| --- | --- |  --- |  --- | 
| CLIENT_SECRET | ***** | CircleCI Context | API Credential. Used to build the .edgerc file. |
| HOST | ***** | CircleCI Context | API Credential. Used to build the .edgerc file. |
| ACCESS_TOKEN | ***** | CircleCI Context | API Credential. Used to build the .edgerc file. |
| CLIENT_TOKEN | ***** | CircleCI Context | API Credential. Used to build the .edgerc file. |
| HOSTNAME | ***** | CircleCI Context | Hostname used to create the Enhanced Debug Token |
| ACCOUNTKEY | ***** | CircleCI Context | The account ID. Used to switch between accounts. If not needed remove the ‘accountkey’ flag from the commands. |
| EDGEKV_NAMESPACE | ***** | CircleCI Context | [OPTIONAL] Namespace if EdgeKV is enabled. Used to build the edgekv_tokens.js file. |
| EDGEKV_TOKEN_NAME | ***** | CircleCI Context | [OPTIONAL] Token Name if EdgeKV is enabled. Used to build the edgekv_tokens.js file.  |
| EDGEKV_TOKEN_VALUE | ***** | CircleCI Context | [OPTIONAL] Token Value if EdgeKV is enabled. Used to build the edgekv_tokens.js file.  |
| EWID | 1234 | .circleci/config.yml: environment block | EdgeWorkers ID |
| BUNDLENAME | my_bundle.tgz | .circleci/config.yml: environment block | The name for the bundle file. Used to update the bundle.json file. |
| edgekv | Boolean (true \|\| false) | .circleci/config.yml: parameter block | ‘true’ if EdgeKV is enabled and ‘false’ if EdgeKV is not enabled |
| production | Boolean (true \|\| false) | .circleci/config.yml: parameter block | ‘true’ to push to production and staging and ‘false’ to push only to staging |

## Postman Testing (OPTIONAL)
In the job "test" Newman (CLI for Postman) is used to test a collection exposed in a public URL. For this specific job [CircleCI Orbs](https://circleci.com/developer/orbs/orb/postman/newman) are used instead which package and simplifies the process of exectuting actions/commands in the `.circleci/config.yml`.
If you don't want to use Postman for testing or have other testing frameworks you can delete this block from the `.circleci/config.yml`. Also remove the orb declaration at the top of the file and the "test" job from the "workflow" block as they won't be needed.
```
orbs: 
  newman: postman/newman@0.0.2

...

  test:
    executor: newman/postman-newman-docker
    steps:  
      - checkout
      - newman/newman-run:
          collection: https://www.getpostman.com/collections/23635fa6dc0a1b47183d
          additional-options: --bail

      - test:
          requires:
            - deploy

...
```

## Future Improvements
* Add actual test jobs examples to test EW's code.

## More details on EdgeWorkers
- [Akamai EdgeWorkers](https://techdocs.akamai.com/edgeworkers/docs)
- [Akamai EdgeWorkers Examples](https://github.com/akamai/edgeworkers-examples)
- [Akamai CLI for EdgeWorkers](https://github.com/akamai/cli-edgeworkers)
- [Akamai EdgeKV](https://techdocs.akamai.com/edgekv/docs/welcome-to-edgekv)
- [Akamai EdgeKV CLI](https://github.com/akamai/cli-edgeworkers/blob/master/docs/edgekv_cli.md)
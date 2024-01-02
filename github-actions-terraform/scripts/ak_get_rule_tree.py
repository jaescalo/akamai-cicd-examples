#!/usr/bin/python3

import os
import sys
import json
import requests
from akamai.edgegrid import EdgeGridAuth
from ak_api_wrapper import AkamaiApis


########################################
# Build Akamai API EdgeGrid session object
#########################################

def init_config():

    try:        
        base_url = os.getenv('TF_VAR_akamai_host')
        session = requests.Session()
        session.auth = EdgeGridAuth(
            client_token=os.getenv('TF_VAR_akamai_client_token'),
            client_secret=os.getenv('TF_VAR_akamai_client_secret'),
            access_token=os.getenv('TF_VAR_akamai_access_token')
        )
    except Exception:
        print(f'ERROR: Unknown error occurred trying to read API credentials')
        exit(1)
    return base_url, session


########################################
# Obtain the Akamai Property Rule Tree
########################################

def get_rule_tree(property_name, account_key=None):

    # Initialize the session with Akamai's EdgeGrid Auth
    base_url, session = init_config()
    api_definition_object = AkamaiApis(base_url, account_key)

    # Build the POST body for the first Akamai API request to search for the property
    payload = { "propertyName": property_name }
    response = api_definition_object.search_property(session, payload)

    print(f"Searching for property {response.status_code} Response {(json.dumps(response.json(), indent=2, sort_keys=False))}")

    response_json_object = json.loads(response.text)
    
    # Check all the activations for the property and use the PRODUCTION activation data
    for item in response_json_object['versions']['items']:
        if item['productionStatus'] and item['productionStatus'] == "ACTIVE":

            # Collect the information needed for downloading the rule tree
            property_id = item['propertyId']
            property_version = item['propertyVersion']
            contract_id = item['contractId']
            group_id = item['groupId']

            # Download the Rule Tree
            response = api_definition_object.get_property_rule_tree(session, property_id, property_version, contract_id, group_id)
            response_object = json.loads(response.text)

            # We only care for the rules element
            rule_tree_object = response_object['rules']

            rule_tree_json = (json.dumps(rule_tree_object, indent=2, sort_keys=False))
            print(f"Downloading rule tree {response.status_code} Response {rule_tree_json}")

            return rule_tree_json


def main():

    account_key = os.getenv('TF_VAR_akamai_account_key')
    property_name = sys.argv[1]

    try: 
        rule_tree_ak_string = get_rule_tree(property_name, account_key)
        
        with open('./dist/rule_tree_sample.json', 'w') as file:
            file.write(rule_tree_ak_string)

    except Exception as e:
        print(f'Error {e}')

# Main function
if __name__ == "__main__":
    main()

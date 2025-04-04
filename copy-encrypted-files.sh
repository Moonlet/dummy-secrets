#!/bin/bash

# Check if the required parameters are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <from_directory> <to_directory>"
    echo "Example: $0 lb/devops/ ./target/"
    exit 1
fi

FROM_DIRECTORY=$1
TO_DIRECTORY=$2

# the VAULT_ID is the same as from_directory from ansible script
VAULT_ID=$(echo "$FROM_DIRECTORY" | sed 's/^\/\(.*\)\/$/\1/' | sed 's/^\/\(.*\)$/\1/' | sed 's/^\(.*\)\/$/\1/')

# Log the VAULT_ID
echo "copying files from ${FROM_DIRECTORY} to ${TO_DIRECTORY} with VAULT_ID: $VAULT_ID"

# Run the Ansible playbook with the provided parameters
ansible-playbook playbook.yml -i localhost, --connection=local \
  --vault-id ${VAULT_ID}@vault-pass-client.sh \
  -e "from_directory=${FROM_DIRECTORY} to_directory=${TO_DIRECTORY}"
#!/bin/bash

# Check if the required parameters are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <FROM_DIRECTORY> <TO_DIRECTORY>"
    echo "Example: $0 ./target/ lb/devops"
    exit 1
fi

FROM_DIRECTORY=$1
TO_DIRECTORY=./roles/moonlet-secrets/files/vaults/$2

# Ensure the source folder exists
if [ ! -d "$FROM_DIRECTORY" ]; then
    echo "Error: Source folder '$FROM_DIRECTORY' does not exist."
    exit 1
fi

# The VAULT_ID is the same as to_directory from the Ansible script
VAULT_ID=$(echo "$2" | sed 's/^\/\(.*\)\/$/\1/' | sed 's/^\/\(.*\)$/\1/' | sed 's/^\(.*\)\/$/\1/')

# Create the destination folder if it doesn't exist
mkdir -p "$TO_DIRECTORY"

# Encrypt and copy each file from the source folder to the destination folder
for file in $(find "$FROM_DIRECTORY" -type f); do
    # Get the relative path of the file
    relative_path=${file#$FROM_DIRECTORY/}
    
    # Create the corresponding directory structure in the destination folder
    mkdir -p "$TO_DIRECTORY/$(dirname "$relative_path")"
    
    # Force copy the file to the destination folder
    cp -f "$file" "$TO_DIRECTORY/$relative_path"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to copy '$file' to '$TO_DIRECTORY/$relative_path'."
        exit 1
    fi

    # Encrypt the file at the destination folder
    ./secret-create.sh ${VAULT_ID} "$TO_DIRECTORY/$relative_path"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to encrypt '$TO_DIRECTORY/$relative_path'."
        exit 1
    fi
done

echo "All files have been encrypted and copied to '$TO_DIRECTORY'."
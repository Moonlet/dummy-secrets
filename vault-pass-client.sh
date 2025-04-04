#!/bin/bash

# Parse arguments 
while (( "$#" )); do
  case "$1" in
    # -a|--my-boolean-flag)
    #   MY_FLAG=0
    #   shift
    #   ;;
    --vault-id)
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        VAULT_ID=$2
        shift 2
      else
        echo "Error: Argument for $1 is missing" 1>&2
        exit 1
      fi
      ;;
    # -*|--*=) # unsupported flags
    #   echo "Error: Unsupported flag $1" >&2
    #   exit 1
    #   ;;
    *) # preserve positional arguments
      PARAMS="$PARAMS $1"
      shift
      ;;
  esac
done

# Validate arguments
if [ "$VAULT_ID" ] 
then
    echo "Vault: $VAULT_ID" 1>&2
else
    echo "Arg --vault-id is not present" 1>&2
    exit 1
fi

# Transform vault id to secret key
VAULT_SECRET_KEY=`echo "$VAULT_ID" | tr a-z A-Z`
VAULT_SECRET_KEY=ANSIBLE_VAULT_${VAULT_SECRET_KEY//\//_}

# get secret from GCP Secret manager
gcloud secrets versions access latest --secret $VAULT_SECRET_KEY


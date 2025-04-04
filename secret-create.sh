VAULT_ID=$1
FILE=$2

SECRETS_PATH=roles/moonlet-secrets/files/vaults

if [ -z "$VAULT_ID" ] || [ -z "$FILE" ]; then
    echo "Usage: $0 <vault_id> <file>"
    echo "Example: $0  lb/devops/ roles/moonlet-secrets/files/vaults/lb/devops/sub/test2.txt"
    echo "Vault ID should be the path to the vault, e.g. lb/devops"
    exit 1
fi

# Remove leading and trailing slashes from VAULT_ID if present
VAULT_ID=$(echo "$VAULT_ID" | sed 's/^\/\(.*\)\/$/\1/' | sed 's/^\/\(.*\)$/\1/' | sed 's/^\(.*\)\/$/\1/')

VAULT_SECRET_KEY=`echo "$VAULT_ID" | tr a-z A-Z`
VAULT_SECRET_KEY=ANSIBLE_VAULT_${VAULT_SECRET_KEY//\//_}

echo "Creating encrypted file: $1 with vault id: $VAULT_ID using $VAULT_SECRET_KEY secret key from GCP"

# Check if encryption key exists in GCP
GCP_SECRET=$(gcloud secrets versions access latest --secret $VAULT_SECRET_KEY)


if [ "$GCP_SECRET" ]; then
    echo "GCP secret $VAULT_SECRET_KEY already exists creating encrypted file..."
else 
    echo "GCP secret $VAULT_SECRET_KEY doesn't exist."
    echo "Creating random ${VAULT_SECRET_KEY} ..."
    SECRET=$(openssl rand -base64 64 | tr -d '\n')
    echo $SECRET | gcloud secrets create $VAULT_SECRET_KEY --data-file -

    echo "Verifying secret value"
    GCP_SECRET=$(gcloud secrets versions access latest --secret $VAULT_SECRET_KEY)

    if [ "$SECRET" = "$GCP_SECRET" ]; then
        echo "Secret successfuly created in GCP."
    else 
        echo "Something went wrong, secred was incorectly stored in GCP."
        exit 1
    fi
fi

ansible-vault encrypt $FILE --encrypt-vault-id $VAULT_ID --vault-id ${VAULT_ID}@vault-pass-client.sh
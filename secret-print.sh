VAULT_ID=$1
FILE=$2

SECRETS_PATH=roles/moonlet-secrets/files/vaults

if [ -z "$VAULT_ID" ] || [ -z "$FILE" ]; then
    echo "Usage: $0 <vault_id> <file>"
    echo "Example: $0  lb/devops roles/moonlet-secrets/files/vaults/lb/devops/sub/test2.txt"
    echo "Vault ID should be the path to the vault, e.g. lb/devops/"
    exit 1
fi

# Remove leading and trailing slashes from VAULT_ID if present
VAULT_ID=$(echo "$VAULT_ID" | sed 's/^\/\(.*\)\/$/\1/' | sed 's/^\/\(.*\)$/\1/' | sed 's/^\(.*\)\/$/\1/')


VAULT_SECRET_KEY=`echo "$VAULT_ID" | tr a-z A-Z`
VAULT_SECRET_KEY=ANSIBLE_VAULT_${VAULT_SECRET_KEY//\//_}

ansible-vault view $FILE --vault-id ${VAULT_ID}@vault-pass-client.sh
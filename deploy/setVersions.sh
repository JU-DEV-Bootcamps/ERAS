#!/bin/bash

VERSION_FILE="$HOME/deploy/versions.json"
ENV_SAMPLE_FILE="$HOME/deploy/.env.sample"
ENV_FILE="$HOME/app/.env"

# Extract versions from json
FE_HASH=$(jq -r '."ERAS-FE"' "$VERSION_FILE" | cut -c1-7)
BE_HASH=$(jq -r '."ERAS-BE"' "$VERSION_FILE" | cut -c1-7)

# Verify if versions were succesfully extracted
if [[ -z "$FE_HASH" || -z "$BE_HASH" ]]; then
    echo "Error: Couldn't extract versions from  $VERSION_FILE"
    exit 1
fi

cp "$ENV_SAMPLE_FILE" "$ENV_FILE"

# Replace versions values at new .env file
sed -i "s/_ERAS-FE_/$FE_HASH/" "$ENV_FILE"
sed -i "s/_ERAS-BE_/$BE_HASH/" "$ENV_FILE"

echo "File .env generated - FE_VERSION=0.1.0-$FE_HASH-dev & BE_VERSION=0.1.0-$BE_HASH-dev"
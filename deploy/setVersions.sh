#!/bin/bash
set -ex

VERSION_FILE="$HOME/deploy/versions.json"
ENV_SAMPLE_FILE="$HOME/deploy/.env.sample"
ENV_FILE="$HOME/app/.env"

# Validate files existence
test -f "$VERSION_FILE" || (echo "Error: $VERSION_FILE not found" && exit 1)
test -f "$ENV_SAMPLE_FILE" || (echo "Error: $ENV_SAMPLE_FILE not found" && exit 1)

# Show version file contents
echo "Contenido de $VERSION_FILE:"
cat "$VERSION_FILE"

# Extract raw values from json file
FE_RAW=$(jq -r '."ERAS-FE"' "$VERSION_FILE")
BE_RAW=$(jq -r '."ERAS-BE"' "$VERSION_FILE")
# Extract versions
FE_HASH=$(cut -d'-' -f1 <<< "$FE_RAW")
BE_HASH=$(cut -d'-' -f1 <<< "$BE_RAW")

# Extract environment
FE_ENV=$(cut -d'-' -f2- <<< "$FE_RAW")
BE_ENV=$(cut -d'-' -f2- <<< "$BE_RAW")

echo "FE_HASH: $FE_HASH"
echo "BE_HASH: $BE_HASH"

# Verify extraction
if [[ -z "$FE_HASH" || -z "$BE_HASH" ]]; then
    echo "Error: Couldn't extract versions from $VERSION_FILE"
    exit 1
fi

# Copy base file
cp "$ENV_SAMPLE_FILE" "$ENV_FILE"


# Replace FE versions
if [ "$FE_ENV" != "dev" ]; then
  # If environment is not dev replace the hash + environment and deletes -dev at the end
  sed -i "s/_ERAS-FE_/${FE_HASH}-${FE_ENV}/" "$ENV_FILE"
  sed -i '/FE_VERSION/s/-dev$//' "$ENV_FILE"
else
  # If environment is dev just replace the hash
  sed -i "s/_ERAS-FE_/${FE_HASH}/" "$ENV_FILE"
fi

# Replace BE versions
if [ "$BE_ENV" != "dev" ]; then
  sed -i "s/_ERAS-BE_/${BE_HASH}-${BE_ENV}/" "$ENV_FILE"
  sed -i '/BE_VERSION/s/-dev$//' "$ENV_FILE"
else
  sed -i "s/_ERAS-BE_/${BE_HASH}/" "$ENV_FILE"
fi


# Show final result
echo "Archivo .env generado:"
cat "$ENV_FILE"

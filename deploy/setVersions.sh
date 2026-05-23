#!/bin/bash
set -ex

VERSION_FILE="$HOME/deploy/versions.json"
ENV_SAMPLE_FILE="$HOME/deploy/.env.sample"
ENV_FILE="$HOME/app/.env"

# Validar existencia de archivos
test -f "$VERSION_FILE" || (echo "Error: $VERSION_FILE not found" && exit 1)
test -f "$ENV_SAMPLE_FILE" || (echo "Error: $ENV_SAMPLE_FILE not found" && exit 1)

# Mostrar contenido del JSON
echo "Contenido de $VERSION_FILE:"
cat "$VERSION_FILE"

# Extraer versiones
FE_HASH=$(jq -r '."ERAS-FE"' "$VERSION_FILE" | cut -c1-8)
BE_HASH=$(jq -r '."ERAS-BE"' "$VERSION_FILE" | cut -c1-7)

# Extraer environment
FE_ENV=$(jq -r '."ERAS-FE"' "$VERSION_FILE" | cut -c10-)
BE_ENV=$(jq -r '."ERAS-BE"' "$VERSION_FILE" | cut -c9-)


echo "FE_HASH: $FE_HASH"
echo "BE_HASH: $BE_HASH"

# Verificar extracción
if [[ -z "$FE_HASH" || -z "$BE_HASH" ]]; then
    echo "Error: Couldn't extract versions from $VERSION_FILE"
    exit 1
fi

# Copiar archivo base
cp "$ENV_SAMPLE_FILE" "$ENV_FILE"


# Reemplazar versiones FE
if [ "$FE_ENV" != "dev" ]; then
  # Si el entorno NO es dev → reemplaza con hash + entorno y elimina el -dev final
  sed -i "s/_ERAS-FE_/${FE_HASH}-${FE_ENV}/" "$ENV_FILE"
  sed -i '/FE_VERSION/s/-dev$//' "$ENV_FILE"
else
  # Si el entorno ES dev → solo reemplaza el hash
  sed -i "s/_ERAS-FE_/${FE_HASH}/" "$ENV_FILE"
fi

# Reemplazar versiones BE
if [ "$BE_ENV" != "dev" ]; then
  sed -i "s/_ERAS-BE_/${BE_HASH}-${BE_ENV}/" "$ENV_FILE"
  sed -i '/BE_VERSION/s/-dev$//' "$ENV_FILE"
else
  sed -i "s/_ERAS-BE_/${BE_HASH}/" "$ENV_FILE"
fi


# Mostrar resultado final
echo "Archivo .env generado:"
cat "$ENV_FILE"

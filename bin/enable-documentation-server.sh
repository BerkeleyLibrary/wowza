#!/usr/bin/env bash

# Hacks Server.xml to enable the Swagger/OpenAPI documentation server, and disable
# authentication for it. Should only be used for local development.

BASENAME=$(basename ${BASH_SOURCE})
if [ -z "${WOWZA_ENABLE_DOCUMENTATION_SERVER}" ]; then
  echo "$BASENAME"': $WOWZA_ENABLE_DOCUMENTATION_SERVER not set; exiting'
  exit 0
fi

# ########################################
# Global configuration

WMSAPP_HOME="$(readlink /usr/local/WowzaStreamingEngine)"
WMSAPP_CONF="${WMSAPP_HOME}/conf"
SERVER_XML="${WMSAPP_CONF}/Server.xml"

# ########################################
# Enable documentation server

echo 'Enabling documentation server'

dse_re="^(\s*)<DocumentationServerEnable>false<\/DocumentationServerEnable>"
dse_rp="\1<DocumentationServerEnable>true<\/DocumentationServerEnable> <!-- set by ${BASENAME} -->"
sed -i -E "s/${dse_re}/${dse_rp}/g" "${SERVER_XML}"

# ########################################
# Disable doc server authentication

echo 'Allowing unauthenticated access to documentation server'

dsae_re="^(\s*)<DocumentationServerAuthenticationMethod>digest<\/DocumentationServerAuthenticationMethod>"
dsae_rp="\1<DocumentationServerAuthenticationMethod>none<\/DocumentationServerAuthenticationMethod> <!-- set by ${BASENAME} -->"
sed -i -E "s/${dsae_re}/${dsae_rp}/g" "${SERVER_XML}"

# ########################################
# Results

DS_PORT=$(grep -Po '(?<=<DocumentationServerPort>)[0-9]+' "${SERVER_XML}")
echo "Swagger/OpenAPI documentation server available at http://localhost:${DS_PORT}/api-docs"

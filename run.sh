#!/bin/bash

set -e

CONFIG_FILE="./.registry_env"

# Load the config file
if [ -f "$CONFIG_FILE" ]; then
  source "$CONFIG_FILE"
fi

# Prompt for email for cert request
if [ -z "$EMAIL" ]; then
    echo "Your email is required for Let's Encrypt certificate request."
    read -p "Enter your email: " EMAIL
    echo "EMAIL=$EMAIL" > "$CONFIG_FILE"
fi

# Query the Chameleon meta data service for this node
IP=$(curl --silent http://169.254.169.254/latest/meta-data/public-ipv4 | tr '.' '-')
export HOST="kvm-dyn-$IP.tacc.chameleoncloud.org"

touch users.csv
touch ./htpasswd
while IFS="," read -r username password; do
  if [[ -n "$username" && -n "$password" ]]; then
    # Generate htpasswd entry
    echo "$password"  | htpasswd -iB "./htpasswd" "$username"
  else
    echo "Skipping invalid line: $username,$password"
  fi
done < "users.csv"

echo "Starting registry on $HOST"

export EMAIL
export HOST

docker compose up -d


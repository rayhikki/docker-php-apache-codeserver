#!/bin/bash
set -e

# create user for ssh from vscode
ENV_FILE=/tmp/user.env

if [ -f "$ENV_FILE" ]; then
  export $(grep -v '^#' $ENV_FILE | xargs)
  if id "${SSH_USER}" >/dev/null 2>&1; then
    echo "✅ User '${SSH_USER}' already exists in /etc/passwd. Skipping creation."
    echo "$SSH_USER:$SSH_PASS" | chpasswd
    echo "root:$SSH_PASS_ROOT" | chpasswd
    rm $ENV_FILE
  else
    echo "👤 User not found. Creating user '${SSH_USER}'..."
    useradd -u 2000 -m -s /bin/bash -g www-data -G sudo $SSH_USER
    echo "$SSH_USER:$SSH_PASS" | chpasswd
    echo "root:$SSH_PASS_ROOT" | chpasswd
    rm $ENV_FILE
  fi
fi

# Define the path for the certificate and key
CERT_KEY="/etc/apache2/ssl/server.key"
CERT_FILE="/etc/apache2/ssl/server.crt"

# Check if the certificate file does not exist in the mounted volume
if [ ! -f "$CERT_FILE" ]; then
  echo ">>> Generating self-signed SSL certificate..."
  # Run the openssl command to generate the certificate and key
  openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
      -keyout "$CERT_KEY" \
      -out "$CERT_FILE" \
      -subj "/C=TH/ST=Bangkok/L=Bangkok/O=LocalDev/OU=Development/CN=localhost"
  echo ">>> SSL certificate generated."
else
  echo ">>> SSL certificate already exists. Skipping generation."
fi

# Execute the main command (CMD) from the Dockerfile, which is to start Apache
# exec "$@"

# Start the SSH daemon in the background
/usr/sbin/sshd

# Start the Apache webserver in the foreground
# This is important because Docker needs a foreground process to keep the container running.
apache2-foreground

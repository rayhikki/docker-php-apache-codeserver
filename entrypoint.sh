#!/bin/bash
set -e

# create user for ssh from vscode
ENV_FILE=/usr/local/bin/user.env
export $(grep -v '^#' $ENV_FILE | xargs)
useradd -u 2000 -m -s /bin/bash -g www-data -G sudo $SSH_USER
echo "$SSH_USER:$SSH_PASS" | chpasswd
rm $ENV_FILE

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


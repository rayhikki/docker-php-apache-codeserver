#!/bin/bash
set -e

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

# Start the SSH daemon in the background
/usr/sbin/sshd

# Start the Apache webserver in the foreground
# This is important because Docker needs a foreground process to keep the container running.
apache2-foreground

# Execute the main command (CMD) from the Dockerfile, which is to start Apache
# exec "$@"

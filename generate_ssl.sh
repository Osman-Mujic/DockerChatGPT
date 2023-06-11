#!/bin/bash

# Create the ssl directory if it doesn't exist
mkdir -p ssl

# Generate SSL certificate and key
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ssl/server.key -out ssl/server.crt -subj "//C=US/ST=State/L=City/O=Organization/CN=example.com"

# Set appropriate permissions for the SSL files
chmod 600 ssl/server.key ssl/server.crt

# Restart Apache
service apache2 restart

#!/bin/bash

# Generate SSL certificate and private key
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout "/etc/ssl/certs/server.key" -out "/etc/ssl/certs/server.crt" -subj "//C=US/ST=State/L=City/O=Organization/CN=example.com"

# Set appropriate permissions
chmod 600 /etc/ssl/certs/server.key
chmod 600 /etc/ssl/certs/server.crt

# Restart Apache
service apache2 restart

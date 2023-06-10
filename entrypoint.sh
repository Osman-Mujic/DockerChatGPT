#!/bin/bash
# Start Apache server
apachectl start

# Start WebSocket server
php /app/websocket_server.php

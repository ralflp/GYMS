#!/bin/bash

echo "=========================================="
echo " Starting GYM SaaS VPS Deployment Script"
echo "=========================================="

# 1. Update source code
echo "-> Pulling latest code from GitHub..."
/usr/bin/git pull

# 2. Rebuild and restart Docker containers (Backend + DB)
echo "-> Rebuilding Docker containers for Backend and Database..."
docker-compose down
docker-compose up -d --build

# 3. Inform about Flutter web
echo "=========================================="
echo " Deployment successful!"
echo " Backend running on http://YOUR_VPS_IP:3000"
echo " "
echo " Note: To serve the Flutter Web panels, you should compile them"
echo " locally or here, and serve the /build/web folder using Nginx/Apache."
echo "=========================================="

#!/bin/bash

set -e

echo "🚀 Deploying Adam's Zone to OCI..."

# Configuration
OCI_HOST="129.213.149.112"
OCI_USER="opc"
SSH_KEY="$HOME/.ssh/id_rsa"
CONTAINER_NAME="adams-zone-blog"
IMAGE_NAME="adams-zone:latest"
PORT="8081"

# Check if SSH key exists
if [ ! -f "$SSH_KEY" ]; then
    echo "❌ SSH key not found at $SSH_KEY"
    echo "Please configure your SSH key first"
    exit 1
fi

# Build Docker image locally
echo "📦 Building Docker image..."
docker build -t $IMAGE_NAME .

# Save image to tar
echo "💾 Saving Docker image..."
docker save $IMAGE_NAME | gzip > adams-zone.tar.gz

# Upload to OCI server
echo "📤 Uploading to OCI server..."
scp -i $SSH_KEY adams-zone.tar.gz $OCI_USER@$OCI_HOST:/tmp/

# Deploy on OCI server
echo "🔧 Deploying on OCI server..."
ssh -i $SSH_KEY $OCI_USER@$OCI_HOST << 'ENDSSH'
    # Load Docker image
    echo "Loading Docker image..."
    docker load < /tmp/adams-zone.tar.gz
    
    # Stop and remove existing container
    echo "Stopping existing container..."
    docker stop adams-zone-blog 2>/dev/null || true
    docker rm adams-zone-blog 2>/dev/null || true
    
    # Run new container
    echo "Starting new container..."
    docker run -d \
        --name adams-zone-blog \
        --restart unless-stopped \
        -p 8081:80 \
        adams-zone:latest
    
    # Cleanup
    rm /tmp/adams-zone.tar.gz
    
    # Wait for container to start
    sleep 3
    
    # Check container status
    if docker ps | grep -q adams-zone-blog; then
        echo "✅ Container started successfully"
    else
        echo "❌ Container failed to start"
        docker logs adams-zone-blog
        exit 1
    fi
    
    echo "✅ Deployment complete!"
    echo "🌐 Blog available at: http://129.213.149.112:8081"
ENDSSH

# Cleanup local tar
rm adams-zone.tar.gz

echo ""
echo "🎉 Deployment successful!"
echo "🌐 Visit: http://129.213.149.112:8081"
echo ""
echo "Useful commands:"
echo "  - View logs: ssh opc@129.213.149.112 'docker logs -f adams-zone-blog'"
echo "  - Restart: ssh opc@129.213.149.112 'docker restart adams-zone-blog'"
echo "  - Health check: ./health-check.sh"

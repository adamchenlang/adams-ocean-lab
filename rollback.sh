#!/bin/bash

set -e

OCI_HOST="129.213.149.112"
OCI_USER="opc"
SSH_KEY="$HOME/.ssh/id_rsa"

echo "⏪ Rolling back Adam's Zone to previous version..."

ssh -i $SSH_KEY $OCI_USER@$OCI_HOST << 'ENDSSH'
    # Get previous image
    PREVIOUS_IMAGE=$(docker images adams-zone --format "{{.ID}}" | sed -n 2p)
    
    if [ -z "$PREVIOUS_IMAGE" ]; then
        echo "❌ No previous version found"
        echo "Available images:"
        docker images adams-zone
        exit 1
    fi
    
    echo "Found previous image: $PREVIOUS_IMAGE"
    
    # Stop current container
    echo "Stopping current container..."
    docker stop adams-zone-blog
    docker rm adams-zone-blog
    
    # Run previous version
    echo "Starting previous version..."
    docker run -d \
        --name adams-zone-blog \
        --restart unless-stopped \
        -p 8081:80 \
        $PREVIOUS_IMAGE
    
    # Wait for container to start
    sleep 3
    
    # Check status
    if docker ps | grep -q adams-zone-blog; then
        echo "✅ Rollback complete!"
        echo "🌐 Blog available at: http://129.213.149.112:8081"
    else
        echo "❌ Rollback failed"
        docker logs adams-zone-blog
        exit 1
    fi
ENDSSH

echo ""
echo "🎉 Rollback successful!"
echo "🌐 Visit: http://129.213.149.112:8081"

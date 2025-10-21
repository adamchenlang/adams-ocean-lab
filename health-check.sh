#!/bin/bash

OCI_HOST="129.213.149.112"
PORT="8081"

echo "🏥 Checking Adam's Zone health..."
echo ""

# Check HTTP response
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://$OCI_HOST:$PORT)

if [ "$HTTP_CODE" = "200" ]; then
    echo "✅ Blog is healthy (HTTP $HTTP_CODE)"
    
    # Get response time
    RESPONSE_TIME=$(curl -s -o /dev/null -w "%{time_total}" http://$OCI_HOST:$PORT)
    echo "⏱️  Response time: ${RESPONSE_TIME}s"
    
    # Check container status
    echo ""
    echo "📊 Container status:"
    ssh opc@$OCI_HOST 'docker ps --filter name=adams-zone-blog --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
    
    exit 0
else
    echo "❌ Blog is unhealthy (HTTP $HTTP_CODE)"
    echo ""
    echo "🔍 Checking container logs:"
    ssh opc@$OCI_HOST 'docker logs --tail 50 adams-zone-blog'
    exit 1
fi

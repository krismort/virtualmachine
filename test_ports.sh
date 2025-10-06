#!/bin/bash

echo "=== Docker Compose Port Configuration Test ==="
echo

# Check if docker-compose.yml exists
if [ ! -f "docker-compose.yml" ]; then
    echo "❌ docker-compose.yml not found"
    exit 1
fi

echo "✅ docker-compose.yml found"

# Parse and validate port mappings
echo
echo "📋 Port Mappings Analysis:"
echo "=========================="

# Extract port mappings from docker-compose.yml
ssh_port=$(grep -A 10 "ports:" docker-compose.yml | grep "2222:22" | tr -d ' -"')
vnc_port=$(grep -A 10 "ports:" docker-compose.yml | grep "5900:5900" | tr -d ' -"')
stunnel_port=$(grep -A 10 "ports:" docker-compose.yml | grep "8443:443" | tr -d ' -"')

if [ -n "$ssh_port" ]; then
    echo "✅ SSH Port: $ssh_port (Host:Container)"
else
    echo "❌ SSH port mapping not found"
fi

if [ -n "$vnc_port" ]; then
    echo "✅ VNC Port: $vnc_port (Host:Container)"
else
    echo "❌ VNC port mapping not found"
fi

if [ -n "$stunnel_port" ]; then
    echo "✅ Stunnel Port: $stunnel_port (Host:Container)"
else
    echo "❌ Stunnel port mapping not found"
fi

echo
echo "🔧 Environment Variables:"
echo "========================"
ssh_pass=$(grep "SSH_PASSWORD" docker-compose.yml | cut -d'=' -f2)
vnc_pass=$(grep "VNC_PASSWORD" docker-compose.yml | cut -d'=' -f2)

echo "SSH Password: $ssh_pass"
echo "VNC Password: $vnc_pass"

echo
echo "📁 Volume Configuration:"
echo "======================="
if grep -q "desktop_data:/data" docker-compose.yml; then
    echo "✅ Persistent data volume configured"
else
    echo "❌ Data volume not configured"
fi

echo
echo "🧪 Service Configuration Test:"
echo "============================="

# Test if required configuration files exist for services
services=("stunnel.conf" "supervisord.conf" "startup.sh")
for service in "${services[@]}"; do
    if [ -f "$service" ]; then
        echo "✅ $service exists"
    else
        echo "❌ $service missing"
    fi
done

echo
echo "🚀 Docker Compose Commands:"
echo "=========================="
echo "To start the services:"
echo "  docker compose up -d --build"
echo
echo "To check running containers:"
echo "  docker compose ps"
echo
echo "To view logs:"
echo "  docker compose logs -f"
echo
echo "To test SSH connection:"
echo "  ssh appuser@localhost -p 2222"
echo
echo "To test VNC connection:"
echo "  Connect VNC client to localhost:5900"
echo
echo "To test stunnel connection:"
echo "  telnet localhost 8443"
echo
echo "To stop services:"
echo "  docker compose down"

echo
echo "✅ Port configuration test completed!"

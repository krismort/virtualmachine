#!/bin/bash

echo "=== Startup Debug Information ==="
echo "Date: $(date)"
echo "Container ID: $(hostname)"
echo

echo "=== Environment Variables ==="
echo "SSH_PASSWORD: ${SSH_PASSWORD:-'Not set (will use random)'}"
echo "VNC_PASSWORD: ${VNC_PASSWORD:-'Not set (will use random)'}"
echo "DISPLAY: ${DISPLAY:-'Not set'}"
echo

echo "=== System Information ==="
echo "OS: $(cat /etc/os-release | grep PRETTY_NAME)"
echo "Memory: $(free -h | grep Mem)"
echo "Disk: $(df -h / | tail -1)"
echo

echo "=== Package Verification ==="
packages=("x11vnc" "openssh-server" "stunnel4" "supervisor" "xvfb")
for pkg in "${packages[@]}"; do
    if command -v "$pkg" >/dev/null 2>&1; then
        echo "✅ $pkg: $(command -v $pkg)"
    elif dpkg -l | grep -q "$pkg"; then
        echo "✅ $pkg: installed"
    else
        echo "❌ $pkg: not found"
    fi
done

echo
echo "=== Port Status ==="
echo "Checking if ports are available..."
for port in 22 443 5900; do
    if netstat -tuln 2>/dev/null | grep -q ":$port "; then
        echo "⚠️  Port $port: already in use"
    else
        echo "✅ Port $port: available"
    fi
done

echo
echo "=== X11 Test ==="
export DISPLAY=:0
if command -v xdpyinfo >/dev/null 2>&1; then
    if xdpyinfo -display :0 >/dev/null 2>&1; then
        echo "✅ X server is running on :0"
    else
        echo "❌ X server not responding on :0"
    fi
else
    echo "⚠️  xdpyinfo not available for X server test"
fi

echo
echo "=== Process Status ==="
echo "Running processes:"
ps aux | grep -E "(Xvfb|x11vnc|sshd|stunnel|supervisord)" | grep -v grep

echo
echo "=== Log Files ==="
log_files=("/var/log/sshd.log" "/var/log/x11vnc.log" "/var/log/stunnel.log" "/var/log/supervisord.log")
for log in "${log_files[@]}"; do
    if [ -f "$log" ]; then
        echo "📄 $log exists ($(wc -l < "$log") lines)"
    else
        echo "❌ $log missing"
    fi
done

echo
echo "=== VNC Password Test ==="
if [ -f "/etc/vnc_password" ]; then
    echo "✅ VNC password file exists"
    echo "   Size: $(wc -c < /etc/vnc_password) bytes"
else
    echo "❌ VNC password file missing"
fi

if [ -f "/home/appuser/.vnc/passwd" ]; then
    echo "✅ User VNC password file exists"
    echo "   Owner: $(ls -la /home/appuser/.vnc/passwd | awk '{print $3":"$4}')"
else
    echo "❌ User VNC password file missing"
fi

echo
echo "=== Network Connectivity ==="
echo "Testing internal connectivity..."
for port in 22 5900; do
    if timeout 2 bash -c "</dev/tcp/localhost/$port" 2>/dev/null; then
        echo "✅ localhost:$port - reachable"
    else
        echo "❌ localhost:$port - not reachable"
    fi
done

echo
echo "=== Recommendations ==="
if ! command -v x11vnc >/dev/null 2>&1; then
    echo "❗ Install x11vnc package"
fi

if [ ! -f "/etc/vnc_password" ]; then
    echo "❗ Create VNC password file"
fi

if ! netstat -tuln 2>/dev/null | grep -q ":5900 "; then
    echo "❗ Start VNC server on port 5900"
fi

echo
echo "=== Debug Complete ==="

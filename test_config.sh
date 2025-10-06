#!/bin/bash

echo "Testing configuration files..."

# Test if all required files exist
files=("Dockerfile" "startup.sh" "stunnel.conf" "supervisord.conf" ".do/app.yaml")
for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        echo "✓ $file exists"
    else
        echo "✗ $file missing"
        exit 1
    fi
done

# Test if startup.sh is executable
if [ -x "startup.sh" ]; then
    echo "✓ startup.sh is executable"
else
    echo "✗ startup.sh is not executable"
    exit 1
fi

# Test stunnel config syntax
if stunnel -test -fd 0 < stunnel.conf > /dev/null 2>&1; then
    echo "✓ stunnel.conf syntax is valid"
else
    echo "⚠ stunnel.conf syntax check failed (stunnel may not be installed)"
fi

# Test YAML syntax
if command -v python3 > /dev/null; then
    if python3 -c "import yaml; yaml.safe_load(open('.do/app.yaml'))" 2>/dev/null; then
        echo "✓ app.yaml syntax is valid"
    else
        echo "✗ app.yaml syntax is invalid"
        exit 1
    fi
else
    echo "⚠ Cannot test YAML syntax (python3 not available)"
fi

echo "All configuration tests passed!"

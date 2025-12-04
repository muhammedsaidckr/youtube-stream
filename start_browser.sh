#!/bin/bash

WEBSITE_URL="${WEBSITE_URL:-https://www.example.com}"
DISPLAY=":99"
RESOLUTION="${RESOLUTION:-1920x1080}"

export DISPLAY=:99

# Wait for Xvfb to be ready
echo "Waiting for Xvfb to be ready..."
for i in {1..30}; do
    if xdpyinfo -display :99 >/dev/null 2>&1; then
        echo "Xvfb is ready"
        break
    fi
    if [ $i -eq 30 ]; then
        echo "Error: Xvfb did not become ready in time"
        exit 1
    fi
    sleep 1
done

# Create Chromium user data directory
mkdir -p /tmp/chromium-user-data

# Start Chromium
echo "Starting Chromium browser..."
chromium-browser \
    --kiosk \
    --no-sandbox \
    --disable-dev-shm-usage \
    --disable-gpu \
    --disable-software-rasterizer \
    --window-size=${RESOLUTION} \
    --start-fullscreen \
    --disable-infobars \
    --disable-notifications \
    --no-first-run \
    --disable-session-crashed-bubble \
    --disable-restore-session-state \
    --user-data-dir=/tmp/chromium-user-data \
    --disable-background-networking \
    --disable-background-timer-throttling \
    --disable-renderer-backgrounding \
    --disable-backgrounding-occluded-windows \
    "${WEBSITE_URL}" 2>&1

# If chromium exits, log the exit code
EXIT_CODE=$?
echo "Chromium exited with code: $EXIT_CODE"
exit $EXIT_CODE

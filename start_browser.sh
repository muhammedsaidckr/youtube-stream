#!/bin/bash

WEBSITE_URL="${WEBSITE_URL:-https://www.example.com}"
DISPLAY=":99"
RESOLUTION="${RESOLUTION:-1920x1080}"

export DISPLAY=:99

# Start Chromium
chromium-browser \
    --kiosk \
    --no-sandbox \
    --disable-dev-shm-usage \
    --disable-gpu \
    --window-size=${RESOLUTION} \
    --start-fullscreen \
    --disable-infobars \
    --disable-notifications \
    --no-first-run \
    --disable-session-crashed-bubble \
    --disable-restore-session-state \
    "${WEBSITE_URL}"

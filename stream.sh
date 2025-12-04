#!/bin/bash

# Configuration from environment variables
WEBSITE_URL="${WEBSITE_URL:-https://www.example.com}"
YOUTUBE_KEY="${YOUTUBE_KEY}"
DISPLAY=":99"
RESOLUTION="${RESOLUTION:-1920x1080}"
FRAMERATE="${FRAMERATE:-30}"
BITRATE="${BITRATE:-3000k}"
AUDIO="${ENABLE_AUDIO:-false}"

# Validate YouTube key
if [ -z "$YOUTUBE_KEY" ]; then
    echo "Error: YOUTUBE_KEY environment variable is required"
    exit 1
fi

echo "Starting stream for: $WEBSITE_URL"
echo "Resolution: $RESOLUTION"
echo "Framerate: $FRAMERATE"
echo "Bitrate: $BITRATE"

# Start Xvfb
Xvfb :99 -screen 0 ${RESOLUTION}x24 &
XVFB_PID=$!
sleep 2

# Start PulseAudio (for audio support)
pulseaudio --start --exit-idle-time=-1
sleep 1

# Start Chromium in kiosk mode
export DISPLAY=:99
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
    "${WEBSITE_URL}" &
BROWSER_PID=$!

# Wait for browser to load
sleep 5

# Build ffmpeg command
FFMPEG_CMD="ffmpeg -f x11grab -video_size ${RESOLUTION} -framerate ${FRAMERATE} -i ${DISPLAY}"

# Add audio if enabled
if [ "$AUDIO" = "true" ]; then
    FFMPEG_CMD="$FFMPEG_CMD -f pulse -i default -c:a aac -b:a 128k -ar 44100"
fi

# Add video encoding and output
FFMPEG_CMD="$FFMPEG_CMD \
    -c:v libx264 \
    -preset veryfast \
    -maxrate ${BITRATE} \
    -bufsize $(echo "${BITRATE}" | sed 's/k/*2/' | bc)k \
    -pix_fmt yuv420p \
    -g 60 \
    -f flv rtmp://a.rtmp.youtube.com/live2/${YOUTUBE_KEY}"

echo "Starting ffmpeg stream..."
eval $FFMPEG_CMD

# Cleanup on exit
trap "kill $XVFB_PID $BROWSER_PID 2>/dev/null" EXIT

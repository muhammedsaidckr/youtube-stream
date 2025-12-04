#!/bin/bash

# Configuration from environment variables
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

export DISPLAY=:99

echo "Starting ffmpeg stream..."
echo "Resolution: $RESOLUTION"
echo "Framerate: $FRAMERATE"
echo "Bitrate: $BITRATE"
echo "Audio: $AUDIO"

# Wait for Xvfb and browser to be ready
echo "Waiting for Xvfb and browser to be ready..."
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

# Wait a bit more for browser to fully load
sleep 5

# Build ffmpeg command
FFMPEG_CMD="ffmpeg -loglevel info -f x11grab -video_size ${RESOLUTION} -framerate ${FRAMERATE} -i ${DISPLAY}"

# Add audio if enabled
if [ "$AUDIO" = "true" ]; then
    FFMPEG_CMD="$FFMPEG_CMD -f pulse -i default -c:a aac -b:a 128k -ar 44100"
fi

# Add video encoding and output
# Force minimum bitrate to ensure YouTube accepts the stream
MIN_BITRATE=$(echo "${BITRATE}" | sed 's/k//' | awk '{print int($1*0.5)}')k
FFMPEG_CMD="$FFMPEG_CMD \
    -c:v libx264 \
    -preset veryfast \
    -tune zerolatency \
    -b:v ${BITRATE} \
    -minrate ${MIN_BITRATE} \
    -maxrate ${BITRATE} \
    -bufsize $(echo "${BITRATE}" | sed 's/k/*2/' | bc)k \
    -pix_fmt yuv420p \
    -g $(echo "${FRAMERATE} * 2" | bc) \
    -keyint_min ${FRAMERATE} \
    -sc_threshold 0 \
    -profile:v high \
    -level 4.0 \
    -force_key_frames \"expr:gte(t,n_forced*2)\" \
    -f flv \
    -flvflags no_duration_filesize \
    -rtmp_live live \
    rtmp://a.rtmp.youtube.com/live2/${YOUTUBE_KEY}"

echo "Executing: $FFMPEG_CMD"
echo "Starting stream to YouTube..."
echo "Stream URL: rtmp://a.rtmp.youtube.com/live2/${YOUTUBE_KEY}"
eval $FFMPEG_CMD 2>&1 | tee -a /var/log/supervisor/ffmpeg_stream.log

EXIT_CODE=$?
if [ $EXIT_CODE -ne 0 ]; then
    echo "FFmpeg exited with code: $EXIT_CODE"
    echo "Check /var/log/supervisor/ffmpeg_err.log for details"
fi
exit $EXIT_CODE

FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    xvfb \
    chromium-browser \
    ffmpeg \
    pulseaudio \
    x11vnc \
    supervisor \
    python3 \
    python3-pip \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
RUN pip3 install fastapi uvicorn pydantic

# Create directories
RUN mkdir -p /app /var/log/supervisor

# Copy application files
COPY stream.sh /app/stream.sh
COPY start_browser.sh /app/start_browser.sh
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY api.py /app/api.py

# Make scripts executable
RUN chmod +x /app/stream.sh /app/start_browser.sh

# Set working directory
WORKDIR /app

# Expose API port
EXPOSE 8000

# Start supervisor
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

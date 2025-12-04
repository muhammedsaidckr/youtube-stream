FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install base dependencies
RUN apt-get update && apt-get install -y \
    wget \
    gnupg \
    ca-certificates \
    unzip \
    xvfb \
    ffmpeg \
    pulseaudio \
    x11vnc \
    x11-utils \
    supervisor \
    python3 \
    python3-pip \
    curl \
    bc \
    && rm -rf /var/lib/apt/lists/*

# Install Chromium by downloading from official source
# Using a fixed version URL for reliability
RUN CHROMIUM_REV=$(curl -s "https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2FLAST_CHANGE?alt=media") && \
    wget -q "https://commondatastorage.googleapis.com/chromium-browser-snapshots/Linux_x64/${CHROMIUM_REV}/chrome-linux.zip" -O /tmp/chrome-linux.zip && \
    unzip -q /tmp/chrome-linux.zip -d /opt/ && \
    rm /tmp/chrome-linux.zip && \
    mv /opt/chrome-linux /opt/chromium && \
    ln -s /opt/chromium/chrome /usr/bin/chromium-browser && \
    chmod +x /usr/bin/chromium-browser

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

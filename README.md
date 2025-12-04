# Website to YouTube Live Streaming

Stream any website to YouTube Live using Docker. This solution captures a website in a headless browser and streams it to YouTube using ffmpeg.

## Features

- 🌐 Stream any website to YouTube Live
- 🐳 Fully containerized with Docker
- 🔧 FastAPI management interface
- 📊 Real-time stream monitoring
- 🎬 Configurable resolution, framerate, and bitrate
- 🔄 Easy restart and management
- 📝 Detailed logging

## Prerequisites

- Docker and Docker Compose installed
- YouTube account with live streaming enabled
- YouTube Stream Key (from YouTube Studio)

## Quick Start

### 1. Clone and Setup

```bash
# Create project directory
mkdir website-youtube-stream
cd website-youtube-stream

# Copy all files to this directory
# (Dockerfile, docker-compose.yml, stream.sh, etc.)
```

### 2. Configure Environment

```bash
# Copy example environment file
cp .env.example .env

# Edit .env with your settings
nano .env
```

**Required Configuration:**
- `YOUTUBE_KEY`: Your YouTube stream key (get from YouTube Studio > Go Live)
- `WEBSITE_URL`: The website you want to stream

**Optional Configuration:**
- `RESOLUTION`: Video resolution (default: 1920x1080)
- `FRAMERATE`: Frame rate (default: 30)
- `BITRATE`: Video bitrate (default: 3000k)
- `ENABLE_AUDIO`: Enable audio capture (default: false)

### 3. Get Your YouTube Stream Key

1. Go to [YouTube Studio](https://studio.youtube.com)
2. Click "Go Live" in the top right
3. Select "Stream" from the left sidebar
4. Copy your "Stream key"
5. Paste it into your `.env` file

### 4. Build and Run

```bash
# Build the Docker image
docker-compose build

# Start the container
docker-compose up -d

# View logs
docker-compose logs -f
```

## Usage

### Starting the Stream

The stream starts automatically when the container launches. To manually control it:

```bash
# Start stream
curl -X POST http://localhost:8000/start

# Stop stream
curl -X POST http://localhost:8000/stop

# Restart stream
curl -X POST http://localhost:8000/restart
```

### Monitoring

Check stream status via the API:

```bash
# Get status
curl http://localhost:8000/status

# Get logs
curl http://localhost:8000/logs/ffmpeg?lines=100
curl http://localhost:8000/logs/browser?lines=50
```

### API Documentation

Once running, visit:
- **API Docs**: http://localhost:8000/docs
- **Health Check**: http://localhost:8000/health

Available endpoints:
- `GET /` - API information
- `GET /status` - Current stream status
- `POST /start` - Start streaming
- `POST /stop` - Stop streaming
- `POST /restart` - Restart streaming
- `GET /logs/{service}` - Get service logs
- `GET /health` - Health check

## Configuration Options

### Resolution Options
- `1920x1080` (Full HD) - default
- `1280x720` (HD)
- `2560x1440` (2K)
- `3840x2160` (4K) - requires higher bitrate

### Bitrate Guidelines
- 720p30: 1500-4000 kbps
- 1080p30: 3000-6000 kbps
- 1080p60: 4500-9000 kbps
- 1440p30: 6000-13000 kbps
- 4K30: 13000-34000 kbps

### Example Configurations

**High Quality Stream:**
```env
RESOLUTION=1920x1080
FRAMERATE=60
BITRATE=6000k
```

**Low Bandwidth Stream:**
```env
RESOLUTION=1280x720
FRAMERATE=30
BITRATE=2000k
```

## Troubleshooting

### Stream Not Starting

1. Check YouTube stream key is correct
2. Verify YouTube account has streaming enabled
3. Check logs: `docker-compose logs -f`

### Browser Not Loading

```bash
# Check browser logs
curl http://localhost:8000/logs/browser

# Restart browser
docker-compose restart
```

### Low Quality Stream

Increase bitrate in `.env`:
```env
BITRATE=6000k
```

### High CPU Usage

Lower resolution or framerate:
```env
RESOLUTION=1280x720
FRAMERATE=30
```

### Container Crashes

Check memory limits:
```bash
# Increase shared memory in docker-compose.yml
shm_size: '4gb'
```

## Advanced Usage

### Custom Stream Script

Edit `stream.sh` for custom ffmpeg parameters:

```bash
# Add custom filters, overlays, etc.
-vf "drawtext=text='Live':fontsize=24:x=10:y=10"
```

### Multiple Streams

Run multiple containers with different configs:

```bash
# Copy directory
cp -r website-youtube-stream stream-2

# Edit docker-compose.yml to change ports
ports:
  - "8001:8000"

# Run second instance
cd stream-2
docker-compose up -d
```

### Integration with MediaMTX

You can output to MediaMTX instead of YouTube:

```bash
# In stream.sh, change the output URL
rtmp://your-mediamtx-server:1935/stream/live
```

## File Structure

```
.
├── Dockerfile              # Container definition
├── docker-compose.yml      # Docker Compose configuration
├── stream.sh              # Main streaming script
├── start_browser.sh       # Browser startup script
├── supervisord.conf       # Process supervisor config
├── api.py                 # FastAPI management interface
├── .env                   # Your configuration (create from .env.example)
└── logs/                  # Log files (created automatically)
```

## System Requirements

**Minimum:**
- 2 CPU cores
- 4GB RAM
- 10GB disk space

**Recommended:**
- 4+ CPU cores
- 8GB+ RAM
- 20GB disk space
- Good internet upload speed (5+ Mbps for 1080p)

## YouTube Requirements

- YouTube account must have live streaming enabled
- New accounts may need to wait 24 hours after enabling
- Accounts with strikes may have streaming disabled

## Security Notes

- Keep your `.env` file private (contains stream key)
- Don't commit `.env` to version control
- Use secure networks for streaming
- Consider using HTTPS for the website you're streaming

## Performance Tips

1. **Use a VPS/dedicated server** for best reliability
2. **Optimize website** being streamed for performance
3. **Monitor CPU usage** - lower resolution if needed
4. **Stable internet** - use wired connection if possible
5. **Test different bitrates** to find optimal quality

## License

MIT License - feel free to modify and use for your projects.

## Support

For issues or questions:
- Check logs: `docker-compose logs -f`
- Review API status: `curl http://localhost:8000/status`
- Test YouTube stream: Check YouTube Studio dashboard

## Credits

Built with:
- Docker
- FFmpeg
- Chromium
- FastAPI
- Xvfb (X Virtual Framebuffer)

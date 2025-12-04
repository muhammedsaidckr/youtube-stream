# Quick Start Guide

## Get YouTube Stream Key

1. Go to https://studio.youtube.com
2. Click **"Go Live"** (top right)
3. Select **"Stream"** from left sidebar
4. Copy your **"Stream key"**

## Setup (5 minutes)

```bash
# 1. Create .env file
cp .env.example .env

# 2. Edit .env and add your YouTube stream key
nano .env

# 3. Set the website you want to stream
# Edit WEBSITE_URL in .env
```

## Choose Your Version

### Option A: Full Version (with API & Management)

```bash
# Build
docker-compose build

# Start
docker-compose up -d

# Check status
curl http://localhost:8000/status

# View logs
docker-compose logs -f
```

**Features:**
- ✅ FastAPI management interface
- ✅ Start/stop/restart via API
- ✅ Real-time monitoring
- ✅ Detailed logs access

**API available at:** http://localhost:8000

### Option B: Simple Version (pure streaming)

```bash
# Build
docker-compose -f docker-compose.simple.yml build

# Start
docker-compose -f docker-compose.simple.yml up -d

# View logs
docker-compose -f docker-compose.simple.yml logs -f
```

**Features:**
- ✅ Lightweight
- ✅ No API overhead
- ✅ Just streams, nothing else

## Using Make Commands

If you have `make` installed:

```bash
# Setup
make build
make up

# Control
make status          # Check stream status
make restart         # Restart stream
make logs           # View all logs
make logs-ffmpeg    # View ffmpeg logs only

# Stream control
make start-stream   # Start streaming
make stop-stream    # Stop streaming
make restart-stream # Restart streaming

# Cleanup
make down           # Stop container
make clean          # Remove everything
```

## Verify It's Working

1. **Check Docker logs:**
   ```bash
   docker-compose logs -f
   ```
   
2. **Check YouTube Studio:**
   - Go to https://studio.youtube.com
   - Click "Go Live"
   - You should see "Stream health: Good"

3. **Monitor stream:**
   ```bash
   curl http://localhost:8000/status  # Full version only
   ```

## Common Issues

### Stream not appearing on YouTube?

- Wait 30 seconds after starting
- Check your stream key is correct
- Verify YouTube streaming is enabled on your account

### Browser not loading website?

```bash
# Check browser logs
docker-compose logs website-streamer | grep browser

# Or via API:
curl http://localhost:8000/logs/browser
```

### High CPU usage?

Lower resolution in `.env`:
```env
RESOLUTION=1280x720
FRAMERATE=30
```

## Configuration Examples

### High Quality (1080p60):
```env
RESOLUTION=1920x1080
FRAMERATE=60
BITRATE=6000k
```

### Balanced (1080p30):
```env
RESOLUTION=1920x1080
FRAMERATE=30
BITRATE=3000k
```

### Low Bandwidth (720p30):
```env
RESOLUTION=1280x720
FRAMERATE=30
BITRATE=2000k
```

## Stop Streaming

```bash
# Full version
docker-compose down

# Simple version
docker-compose -f docker-compose.simple.yml down
```

## Need Help?

Check the full [README.md](README.md) for:
- Detailed troubleshooting
- Advanced configuration
- Integration examples
- Performance tuning

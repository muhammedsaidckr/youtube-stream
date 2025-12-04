# Website to YouTube Live Stream - Project Summary

## 🎯 What This Does

This Docker-based solution captures any website in a headless browser and streams it to YouTube Live using ffmpeg. Perfect for:
- Live streaming dashboards
- Real-time data visualizations
- News websites
- Interactive web applications
- Any web content you want to broadcast

## 📦 What's Included

### Two Versions Available:

#### 1. **Full Version** (Recommended)
- Complete FastAPI management interface
- REST API for stream control
- Real-time monitoring and logs
- Easy restart/stop/start controls
- Perfect for production use

**Files:**
- `Dockerfile` - Main container
- `docker-compose.yml` - Orchestration
- `api.py` - FastAPI management server
- `stream.sh` - Streaming script with supervisor
- `supervisord.conf` - Process management

#### 2. **Simple Version**
- Lightweight, no API overhead
- Just streaming, nothing else
- Great for testing or minimal setups

**Files:**
- `Dockerfile.simple` - Simplified container
- `docker-compose.simple.yml` - Simple orchestration
- `stream-simple.sh` - Direct streaming script

### Supporting Files:
- `README.md` - Complete documentation
- `QUICKSTART.md` - Get started in 5 minutes
- `.env.example` - Configuration template
- `setup.sh` - Automated setup script
- `Makefile` - Convenient commands
- `.gitignore` - Git configuration

## 🚀 Quick Start

### 1. Get Your YouTube Stream Key
- Visit https://studio.youtube.com
- Go Live > Stream > Copy Stream Key

### 2. Setup
```bash
# Copy .env.example to .env
cp .env.example .env

# Edit .env with your YouTube key
nano .env
```

### 3. Choose Your Version

**Full Version:**
```bash
docker-compose build
docker-compose up -d
curl http://localhost:8000/status
```

**Simple Version:**
```bash
docker-compose -f docker-compose.simple.yml build
docker-compose -f docker-compose.simple.yml up -d
```

## 🔧 Configuration

Edit `.env` file:

```env
# Required
YOUTUBE_KEY=your-stream-key-here

# Website to stream
WEBSITE_URL=https://www.example.com

# Video settings
RESOLUTION=1920x1080
FRAMERATE=30
BITRATE=3000k
```

### Preset Configurations:

**High Quality (1080p60):**
- Resolution: 1920x1080
- Framerate: 60
- Bitrate: 6000k

**Balanced (1080p30):**
- Resolution: 1920x1080
- Framerate: 30
- Bitrate: 3000k

**Low Bandwidth (720p30):**
- Resolution: 1280x720
- Framerate: 30
- Bitrate: 2000k

## 📊 Management (Full Version)

### API Endpoints:
```bash
# Stream control
curl -X POST http://localhost:8000/start
curl -X POST http://localhost:8000/stop
curl -X POST http://localhost:8000/restart

# Monitoring
curl http://localhost:8000/status
curl http://localhost:8000/logs/ffmpeg
curl http://localhost:8000/logs/browser

# Health check
curl http://localhost:8000/health
```

### Using Make:
```bash
make status          # Check stream status
make restart         # Restart everything
make logs           # View all logs
make start-stream   # Start streaming
make stop-stream    # Stop streaming
```

## 🏗️ Architecture

```
┌─────────────────────────────────────┐
│         Docker Container            │
│                                     │
│  ┌──────────┐    ┌──────────────┐ │
│  │  Xvfb    │───▶│   Chromium   │ │
│  │ Display  │    │   (Kiosk)    │ │
│  └──────────┘    └──────────────┘ │
│                          │          │
│                          ▼          │
│                   ┌──────────────┐ │
│                   │    ffmpeg    │ │
│                   │   Encoder    │ │
│                   └──────────────┘ │
│                          │          │
│                          ▼          │
│                   ┌──────────────┐ │
│                   │  YouTube     │ │
│                   │  RTMP        │ │
│                   └──────────────┘ │
│                                     │
│  ┌──────────────────────────────┐ │
│  │    FastAPI (Full Version)    │ │
│  │    Port 8000                 │ │
│  └──────────────────────────────┘ │
└─────────────────────────────────────┘
```

## 🔍 File Structure

```
website-youtube-stream/
├── Dockerfile                 # Full version container
├── Dockerfile.simple         # Simple version container
├── docker-compose.yml        # Full version compose
├── docker-compose.simple.yml # Simple version compose
├── stream.sh                 # Main streaming script
├── stream-simple.sh          # Simple streaming script
├── start_browser.sh          # Browser launcher
├── api.py                    # FastAPI management
├── supervisord.conf          # Process supervisor
├── setup.sh                  # Setup automation
├── Makefile                  # Convenience commands
├── .env.example              # Config template
├── .gitignore               # Git ignore rules
├── README.md                 # Full documentation
├── QUICKSTART.md             # Quick start guide
└── logs/                     # Runtime logs (created)
```

## 💡 Use Cases

### 1. **Dashboard Broadcasting**
Stream your Grafana/Kibana dashboards to YouTube for public monitoring:
```env
WEBSITE_URL=https://your-grafana-dashboard.com
RESOLUTION=1920x1080
FRAMERATE=30
```

### 2. **News Website Stream**
Broadcast live news websites:
```env
WEBSITE_URL=https://news-site.com/live
RESOLUTION=1280x720
FRAMERATE=60
```

### 3. **Data Visualization**
Stream real-time data visualizations:
```env
WEBSITE_URL=https://your-d3-visualization.com
RESOLUTION=2560x1440
FRAMERATE=30
BITRATE=8000k
```

### 4. **Integration with MediaMTX**
Since you work with MediaMTX, you can modify `stream.sh` to output to your MediaMTX server:
```bash
# Change output in stream.sh:
rtmp://your-mediamtx-server:1935/stream/live
```

## 🛠️ Integration Ideas

### With Your FastAPI Projects:
The management API is built with FastAPI - you can easily extend it to:
- Add authentication
- Multiple stream management
- Webhook notifications
- Database logging
- Custom endpoints

### With Matrix Bots:
Control streams via Matrix commands:
```python
# Your Matrix bot can call the API
import requests
requests.post('http://stream-server:8000/start')
```

## ⚡ Performance

**System Requirements:**
- Minimum: 2 CPU cores, 4GB RAM
- Recommended: 4+ CPU cores, 8GB RAM
- Upload: 5+ Mbps for 1080p

**Optimization Tips:**
1. Use wired connection
2. Lower resolution if CPU is high
3. Adjust bitrate based on internet speed
4. Monitor with `docker stats`

## 🔐 Security Notes

- Keep `.env` file secure (contains stream key)
- Don't commit `.env` to version control
- Use environment variable injection in production
- Consider VPN for sensitive streams

## 📚 Documentation

- **QUICKSTART.md** - 5-minute setup guide
- **README.md** - Complete reference with troubleshooting
- **This file** - Project overview

## 🎓 Learning Resources

The code demonstrates:
- Docker multi-stage builds
- Supervisor process management
- FastAPI REST API design
- ffmpeg streaming configuration
- Xvfb virtual display usage
- Shell scripting best practices

## 🤝 Support

If you encounter issues:
1. Check `docker-compose logs -f`
2. Review YouTube Studio dashboard
3. Test with simple website first
4. Verify stream key is correct

## 🔄 Updates & Maintenance

To update:
```bash
git pull  # If using git
docker-compose build --no-cache
docker-compose up -d
```

## 📝 Next Steps

1. **Test locally** with a simple website
2. **Configure** your actual website and settings
3. **Monitor** the stream quality
4. **Optimize** based on your needs
5. **Extend** with custom features

---

**Built with:** Docker, FFmpeg, Chromium, FastAPI, Xvfb
**Compatible with:** YouTube Live, MediaMTX, custom RTMP servers
**License:** MIT (modify freely for your needs)

#!/bin/bash

echo "==================================="
echo "Website to YouTube Stream Setup"
echo "==================================="
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    echo "Visit: https://docs.docker.com/get-docker/"
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    echo "Visit: https://docs.docker.com/compose/install/"
    exit 1
fi

echo "✅ Docker is installed"
echo "✅ Docker Compose is installed"
echo ""

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo "📝 Creating .env file from template..."
    cp .env.example .env
    echo "✅ .env file created"
    echo ""
    echo "⚠️  IMPORTANT: Edit the .env file with your YouTube stream key!"
    echo "   nano .env"
    echo ""
else
    echo "✅ .env file already exists"
    echo ""
fi

# Check if YOUTUBE_KEY is set
source .env 2>/dev/null
if [ -z "$YOUTUBE_KEY" ] || [ "$YOUTUBE_KEY" = "your-youtube-stream-key-here" ]; then
    echo "⚠️  WARNING: YouTube stream key not configured!"
    echo ""
    echo "To get your YouTube stream key:"
    echo "1. Go to https://studio.youtube.com"
    echo "2. Click 'Go Live' > 'Stream'"
    echo "3. Copy your 'Stream key'"
    echo "4. Edit .env and replace YOUTUBE_KEY value"
    echo ""
    echo "Then run: make build && make up"
    exit 1
fi

echo "✅ YouTube stream key is configured"
echo ""

# Create logs directory
mkdir -p logs
echo "✅ Logs directory created"
echo ""

echo "==================================="
echo "Setup Complete!"
echo "==================================="
echo ""
echo "Next steps:"
echo "1. Build the Docker image: make build"
echo "2. Start streaming: make up"
echo "3. Check status: make status"
echo "4. View logs: make logs"
echo ""
echo "For more commands: make help"

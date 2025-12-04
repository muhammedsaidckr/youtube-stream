#!/usr/bin/env python3
"""
FastAPI application for managing website to YouTube Live streaming
"""

import os
import subprocess
from typing import Optional
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, HttpUrl
import uvicorn

app = FastAPI(title="Website to YouTube Stream API")


class StreamConfig(BaseModel):
    website_url: HttpUrl
    youtube_key: str
    resolution: Optional[str] = "1920x1080"
    framerate: Optional[int] = 30
    bitrate: Optional[str] = "3000k"
    enable_audio: Optional[bool] = False


class StreamStatus(BaseModel):
    status: str
    website_url: Optional[str] = None
    resolution: Optional[str] = None
    framerate: Optional[int] = None


# Store current configuration
current_config = {
    "website_url": os.getenv("WEBSITE_URL", "https://www.example.com"),
    "resolution": os.getenv("RESOLUTION", "1920x1080"),
    "framerate": int(os.getenv("FRAMERATE", "30")),
    "is_streaming": False,
}


@app.get("/")
async def root():
    return {
        "service": "Website to YouTube Live Streaming",
        "version": "1.0.0",
        "endpoints": {
            "status": "/status",
            "restart": "/restart (POST)",
            "update": "/update (POST)",
        },
    }


@app.get("/status", response_model=StreamStatus)
async def get_status():
    """Get current stream status"""
    try:
        result = subprocess.run(
            ["supervisorctl", "status", "ffmpeg"], capture_output=True, text=True
        )
        is_running = "RUNNING" in result.stdout

        return StreamStatus(
            status="streaming" if is_running else "stopped",
            website_url=current_config["website_url"],
            resolution=current_config["resolution"],
            framerate=current_config["framerate"],
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/restart")
async def restart_stream():
    """Restart the streaming service"""
    try:
        # Restart browser and ffmpeg
        subprocess.run(["supervisorctl", "restart", "browser"], check=True)
        subprocess.run(["supervisorctl", "restart", "ffmpeg"], check=True)

        return {"status": "success", "message": "Stream restarted successfully"}
    except subprocess.CalledProcessError as e:
        raise HTTPException(
            status_code=500, detail=f"Failed to restart stream: {str(e)}"
        )


@app.post("/stop")
async def stop_stream():
    """Stop the streaming service"""
    try:
        subprocess.run(["supervisorctl", "stop", "ffmpeg"], check=True)
        subprocess.run(["supervisorctl", "stop", "browser"], check=True)

        return {"status": "success", "message": "Stream stopped successfully"}
    except subprocess.CalledProcessError as e:
        raise HTTPException(status_code=500, detail=f"Failed to stop stream: {str(e)}")


@app.post("/start")
async def start_stream():
    """Start the streaming service"""
    try:
        subprocess.run(["supervisorctl", "start", "browser"], check=True)
        subprocess.run(["supervisorctl", "start", "ffmpeg"], check=True)

        return {"status": "success", "message": "Stream started successfully"}
    except subprocess.CalledProcessError as e:
        raise HTTPException(status_code=500, detail=f"Failed to start stream: {str(e)}")


@app.get("/logs/{service}")
async def get_logs(service: str, lines: int = 50):
    """Get logs for a specific service (xvfb, browser, ffmpeg, api)"""
    valid_services = ["xvfb", "browser", "ffmpeg", "api", "pulseaudio"]

    if service not in valid_services:
        raise HTTPException(
            status_code=400,
            detail=f"Invalid service. Must be one of: {', '.join(valid_services)}",
        )

    try:
        log_file = f"/var/log/supervisor/{service}.log"
        result = subprocess.run(
            ["tail", "-n", str(lines), log_file], capture_output=True, text=True
        )

        return {"service": service, "logs": result.stdout}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {"status": "healthy"}


if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)

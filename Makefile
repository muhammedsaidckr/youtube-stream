.PHONY: help build up down restart logs status clean

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Available targets:'
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-15s %s\n", $$1, $$2}'

build: ## Build the Docker image
	docker-compose build

up: ## Start the container
	docker-compose up -d
	@echo "Stream started! API available at http://localhost:8000"
	@echo "Check status: make status"

down: ## Stop the container
	docker-compose down

restart: ## Restart the container
	docker-compose restart

logs: ## Show container logs
	docker-compose logs -f

status: ## Show stream status
	@curl -s http://localhost:8000/status | python3 -m json.tool

stop-stream: ## Stop the stream (keep container running)
	@curl -X POST http://localhost:8000/stop

start-stream: ## Start the stream
	@curl -X POST http://localhost:8000/start

restart-stream: ## Restart the stream
	@curl -X POST http://localhost:8000/restart

logs-ffmpeg: ## Show ffmpeg logs
	@curl -s http://localhost:8000/logs/ffmpeg?lines=50

logs-browser: ## Show browser logs
	@curl -s http://localhost:8000/logs/browser?lines=50

shell: ## Open shell in container
	docker-compose exec website-streamer /bin/bash

clean: ## Remove container and volumes
	docker-compose down -v
	rm -rf logs/

test: ## Test the setup
	@echo "Testing Docker..."
	@docker --version
	@echo "Testing Docker Compose..."
	@docker-compose --version
	@echo "Checking .env file..."
	@test -f .env && echo ".env file exists" || echo "WARNING: .env file not found!"

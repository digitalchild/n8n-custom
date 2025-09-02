# Makefile for n8n Custom Image with Playwright
# Simplifies all Docker operations into a single file

# Variables
TAG ?= latest
ENV ?= local
DATE_TAG := $(shell date +"%Y%m%d")

# Build the custom base image
build:
	@echo "🔨 Building n8n custom base image with Playwright..."
	docker build -t n8n-custom-base:$(TAG) -f Dockerfile.base .
	@echo "✅ Built n8n-custom-base:$(TAG)"

# Build with date tag
build-dated:
	@make build TAG=$(DATE_TAG)
	docker tag n8n-custom-base:$(DATE_TAG) n8n-custom-base:latest
	@echo "✅ Tagged as n8n-custom-base:latest"

# Push image to registry
push:
	@echo "📤 Pushing image to registry..."
	docker push n8n-custom-base:$(TAG)
	@echo "✅ Pushed n8n-custom-base:$(TAG)"

# Copy environment sample file
env-init:
	@echo "📝 Creating environment file for $(ENV) environment..."
	@if [ ! -f ".env.$(ENV)" ]; then \
		if [ -f ".env.$(ENV).sample" ]; then \
			cp .env.$(ENV).sample .env.$(ENV); \
			echo "✅ Created .env.$(ENV) from sample file"; \
		else \
			echo "❌ Error: .env.$(ENV).sample not found"; \
			exit 1; \
		fi \
	else \
		echo "⚠️ .env.$(ENV) already exists. Not overwriting."; \
	fi

# Start n8n
start:
	@echo "🚀 Starting n8n in $(ENV) environment..."
	docker-compose -f docker-compose.$(ENV).yml --env-file .env.$(ENV) up -d
	@if [ "$(ENV)" = "local" ]; then \
		echo "✅ n8n started! Access at http://localhost:5678"; \
	else \
		echo "✅ n8n started in production mode!"; \
	fi

# Stop n8n
stop:
	@echo "🛑 Stopping n8n in $(ENV) environment..."
	docker-compose -f docker-compose.$(ENV).yml down
	@echo "✅ n8n stopped"

# Show logs
logs:
	@echo "📋 Showing logs for $(ENV) environment..."
	docker-compose -f docker-compose.$(ENV).yml logs -f

# Restart n8n
restart:
	@echo "🔄 Restarting n8n in $(ENV) environment..."
	docker-compose -f docker-compose.$(ENV).yml restart
	@echo "✅ n8n restarted"

# Generate secure encryption key
gen-key:
	@echo "🔑 Generating secure encryption key..."
	@openssl rand -hex 16
	@echo "✅ Copy this key to your .env.$(ENV) file"

# Generate secure JWT secret
gen-jwt:
	@echo "🔐 Generating secure JWT secret..."
	@openssl rand -hex 16
	@echo "✅ Copy this secret to your .env.$(ENV) file"

# Update base image and restart
update: build-dated
	@echo "🔄 Updating containers with new image..."
	docker-compose -f docker-compose.$(ENV).yml down
	docker-compose -f docker-compose.$(ENV).yml --env-file .env.$(ENV) up -d
	@echo "✅ Updated to latest version with tag $(DATE_TAG)"

# Create a backup
backup:
	@echo "💾 Creating backup of n8n data for $(ENV) environment..."
	@mkdir -p backups
	@if [ "$(ENV)" = "local" ]; then \
		echo "Creating SQLite backup..."; \
		docker cp $$(docker-compose -f docker-compose.$(ENV).yml ps -q n8n):/home/node/.n8n/database.sqlite ./backups/n8n-$(ENV)-backup-$(DATE_TAG).sqlite; \
	else \
		echo "Creating PostgreSQL backup..."; \
		docker-compose -f docker-compose.$(ENV).yml exec postgres pg_dump -U postgres n8n > ./backups/n8n-$(ENV)-backup-$(DATE_TAG).sql; \
	fi
	@echo "✅ Backup saved to backups/"

# Show help
help:
	@echo "n8n Custom Image with Playwright - Management Commands:"
	@echo ""
	@echo "Build Commands:"
	@echo "  make build [TAG=tag]    - Build custom n8n image"
	@echo "  make build-dated        - Build image with date-based tag"
	@echo "  make push [TAG=tag]     - Push image to registry"
	@echo ""
	@echo "Environment Setup:"
	@echo "  make env-init [ENV=env] - Create environment file from sample"
	@echo "  make gen-key            - Generate secure encryption key"
	@echo "  make gen-jwt            - Generate secure JWT secret"
	@echo ""
	@echo "Container Management:"
	@echo "  make start [ENV=env]    - Start n8n (env: local, production)"
	@echo "  make stop [ENV=env]     - Stop n8n"
	@echo "  make restart [ENV=env]  - Restart n8n"
	@echo "  make logs [ENV=env]     - Show logs"
	@echo "  make update             - Update base image and restart"
	@echo "  make backup [ENV=env]   - Create a backup"
	@echo ""
	@echo "Examples:"
	@echo "  make build TAG=v1.0     - Build with custom tag"
	@echo "  make env-init ENV=local - Initialize local environment file"
	@echo "  make start ENV=production - Start production environment"

# Default target
.DEFAULT_GOAL := help
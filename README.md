# n8n Custom Image Playwright

This is a custom n8n docker configuration with support for playwright. The official n8n images are built on Apline Linux which has limited support for playwright. This image switches out the base image for Debian and installs the all dependencies required for playwright.

This will allow you to use the [n8n-nodes-playwright](https://github.com/n8n-io/n8n-nodes-playwright) community node on your self hosted n8n instance.

## 🚀 Quick Start

1. **Copy environment variables:**

   ```bash
   cp .env.local.sample .env.local
   ```

2. **Build the base Docker image:**

   ```bash
   ./build-image.sh
   ```

3. **Start n8n locally:**

   ```bash
   docker-compose -f docker-compose.local.yml --env-file .env.local up -d
   ```

4. **Access n8n:**
   Open your browser and go to [http://localhost:5678](http://localhost:5678)

## Project Structure

```bash
n8n-custom/
├── Dockerfile.base
├── docker-entrypoint.sh
├── n8n-task-runners.json
├── package.json
├── docker-compose.local.yml
├── docker-compose.production.yml
├── .env.local
└── .env.production
```

## Building the base image

The base image can be built and used locally or pushed to a container registry.

### Local build

```bash
# Build the base image (default n8n-custom-base:latest) 
./build-image.sh

# Build the base image with a tag (optional)
./build-image.sh -t n8n-custom-base:latest
```

### Push to a container registry (optional)

```bash
# Push the base image to a container registry
./build-image.sh push
docker push n8n-custom-base:latest
```

## Running the local environment

The local environment uses SQLite as the database and runs a single n8n instance. It's ideal for development and testing purposes. The environment includes:

- n8n instance running on port 5678
- SQLite database for data persistence
- Basic configuration for local development
- Optional custom certificates support

### Local configuration

The @.env.local.sample file contains the required environment variables for the local environment. Copy the file and rename to .env.local

### Starting n8n in deamon mode

```bash
# Generate secure encryption key
docker-compose -f docker-compose.local.yml --env-file .env.local up -d
```

### Stopping the local environment

```bash
docker-compose -f docker-compose.local.yml down
```

To access the n8n instance, open your browser and navigate to:

```bash
http://localhost:5678
```

## Running the production environment

The production environment uses PostgreSQL and Redis as the database and queue. It's ideal for production use cases. The environment includes:

- n8n instance running on port 5678
- PostgreSQL database for data persistence
- Redis for queue processing

### Production configuration

The @.env.production.sample file contains the required environment variables for the production environment.

### Securing your host

To ensure your host is secure create secure encrption keys and JWT secret for production.

```bash
# Generate secure encryption key
openssl rand -hex 16

# Generate secure JWT secret  
openssl rand -hex 16
```

## Starting the production environment

```bash
# Start production environment with PostgreSQL and Redis
docker-compose -f docker-compose.production.yml --env-file .env.production up -d
```

## Stopping the production environment

```bash
docker-compose -f docker-compose.production.yml --env-file .env.production down
```

## Updating the base image

Updating the base image is very easy and straight forward. Run the following commands to update to the latest.

```bash
# 1. Build the new image
./build-image.sh -t n8n-custom-base:latest

# 2. Restart your environments to use the new image
docker-compose -f docker-compose.local.yml restart
docker-compose -f docker-compose.prod.yml restart
```

#!/bin/bash
# build-image.sh

# Parse command line arguments
TAG="n8n-custom-base:latest"
while getopts "t:" opt; do
  case $opt in
    t) TAG="$OPTARG" ;;
    \?) echo "Invalid option -$OPTARG" >&2 ;;
  esac
done

echo "Building custom n8n image with tag $TAG..."
docker build -t $TAG -f Dockerfile.base .
echo "Image built successfully!"
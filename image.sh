#!/bin/bash

# Define variables
IMAGE_NAME="ghcr.io/cgreggescalante/cgreggescalante"
TAG="latest"
DOCKERFILE_PATH="./Dockerfile"
PROJECT_DIR="."  # Change this to the directory containing your Go project if it's different

# Ensure Docker is running
docker info > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "Docker is not running. Please start Docker and try again."
  exit 1
fi

# Authenticate to GitHub Container Registry
echo "Authenticating to GitHub Container Registry..."
gh auth login --with-token <<EOF
$GH_TOKEN
EOF

# Build the Docker image
echo "Building Docker image $IMAGE_NAME:$TAG..."
docker build -f $DOCKERFILE_PATH -t $IMAGE_NAME:$TAG $PROJECT_DIR

if [ $? -ne 0 ]; then
  echo "Docker build failed. Please check the Dockerfile and try again."
  exit 1
fi

# Log in to GHCR (GitHub Container Registry)
echo "Logging into GitHub Container Registry..."
echo $GHCR_TOKEN | docker login ghcr.io -u $GH_USERNAME --password-stdin

# Push the Docker image to GHCR
echo "Pushing Docker image $IMAGE_NAME:$TAG to GHCR..."
docker push $IMAGE_NAME:$TAG

if [ $? -eq 0 ]; then
  echo "Successfully pushed Docker image to $IMAGE_NAME:$TAG"
else
  echo "Failed to push Docker image to GitHub Container Registry"
  exit 1
fi

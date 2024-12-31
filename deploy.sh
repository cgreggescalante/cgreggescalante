#!/bin/bash

# Define variables
REMOTE_USER="cge"
REMOTE_HOST="cge-1"
REMOTE_PATH="services/cgreggescalante"
DEPLOYMENT_FILE="deployment.yaml"
SERVICE_FILE="service.yaml"
INGRESS_FILE="ingress.yaml"

# Check if password is passed as an argument
if [ -z "$1" ]; then
  echo "Error: No sudo password provided."
  echo "Usage: $0 <sudo-password>"
  exit 1
fi

# Assign the sudo password from the first argument
SUDO_PASSWORD="$1"

# Check if the required YAML files exist
if [[ ! -f "kubernetes/$DEPLOYMENT_FILE" || ! -f "kubernetes/$SERVICE_FILE" || ! -f "kubernetes/$INGRESS_FILE" ]]; then
  echo "Error: One or more YAML files do not exist."
  exit 1
fi

# Transfer the YAML files to the remote machine
echo "Transferring YAML files to the remote machine..."

scp "kubernetes/$DEPLOYMENT_FILE" "kubernetes/$SERVICE_FILE" "kubernetes/$INGRESS_FILE" "$REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH"

# Check if the transfer was successful
if [[ $? -ne 0 ]]; then
  echo "Error: Failed to transfer files to the remote machine."
  exit 1
fi

# SSH into the remote machine and apply the YAML files
echo "Applying YAML files on the remote machine..."

ssh "$REMOTE_USER@$REMOTE_HOST" << EOF
  echo "$SUDO_PASSWORD" | sudo -S kubectl apply -f "$REMOTE_PATH/$DEPLOYMENT_FILE"
  echo "$SUDO_PASSWORD" | sudo -S kubectl apply -f "$REMOTE_PATH/$SERVICE_FILE"
  echo "$SUDO_PASSWORD" | sudo -S kubectl apply -f "$REMOTE_PATH/$INGRESS_FILE"
EOF

# Check if the apply was successful
if [[ $? -eq 0 ]]; then
  echo "Kubernetes resources have been successfully applied."
else
  echo "Error: Failed to apply Kubernetes resources."
  exit 1
fi
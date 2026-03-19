#!/bin/bash

# Docker Setup Script for RackNerd VPS
# Run after setup.sh has been completed

set -e

echo "Starting Docker setup..."

# Variables
USERNAME="rae"

# ─────────────────────────────────────────
# Remove Old Docker Versions (if any)
# ─────────────────────────────────────────
echo "Removing any old Docker installations..."
sudo apt remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true

# ─────────────────────────────────────────
# Install Dependencies
# ─────────────────────────────────────────
echo "Installing Docker dependencies..."
sudo apt update
sudo apt install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# ─────────────────────────────────────────
# Add Docker's Official GPG Key
# ─────────────────────────────────────────
echo "Adding Docker GPG key..."
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
    sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# ─────────────────────────────────────────
# Add Docker Repository
# ─────────────────────────────────────────
echo "Adding Docker repository..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# ─────────────────────────────────────────
# Install Docker Engine
# ─────────────────────────────────────────
echo "Installing Docker Engine..."
sudo apt update
sudo apt install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

# ─────────────────────────────────────────
# Add User to Docker Group
# (so you don't need sudo for every command)
# ─────────────────────────────────────────
echo "Adding $USERNAME to docker group..."
sudo usermod -aG docker $USERNAME

# ─────────────────────────────────────────
# Enable & Start Docker
# ─────────────────────────────────────────
echo "Enabling Docker service..."
sudo systemctl enable docker
sudo systemctl start docker

# ─────────────────────────────────────────
# Configure UFW for Docker
# (Docker bypasses UFW by default — this fixes it)
# ─────────────────────────────────────────
echo "Patching UFW to work with Docker..."
sudo tee /etc/docker/daemon.json << EOF
{
  "iptables": false,
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
EOF

# ─────────────────────────────────────────
# Reload Services
# ─────────────────────────────────────────
echo "Reloading daemon and restarting Docker..."
sudo systemctl daemon-reload
sudo systemctl restart docker

# ─────────────────────────────────────────
# Verify Installation
# ─────────────────────────────────────────
echo "Verifying Docker installation..."
docker --version
docker compose version

echo "─────────────────────────────────────────"
echo "✅ Docker setup complete!"
echo "⚠️  Log out and back in for group changes to take effect."
echo "    Then test with: docker run hello-world"
echo "─────────────────────────────────────────"
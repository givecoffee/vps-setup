#!/bin/bash

# VPS Initial Setup Script

set -e # if there is an error, stop the script

echo "Starting VPS initial setup..."

# Variables
USERNAME="rae"
SSH_PORT="2222"
TIMEZONE="America/Seattle"
LOCALE="en_US.UTF-8"

# Update System
echo "Updating system packages..."
sudo apt update && sudo apt upgrade -y

echo "Installing essential packages..."
sudo apt install -y \
    nginx \
    certbot python3-certbot-nginx \
    fail2ban \
    ufw \
    git \
    curl \
    wget \
    unzip \
    htop

# Create New User

echo "Creating new user '$USERNAME'..."
sudo adduser --disabled-password --gecos "" $USERNAME || true
sudo usermod -aG sudo $USERNAME

# Set up SSH
echo "Configuring SSH..."
sudo mkdir -p /home/$USERNAME/.ssh
sudo chmod 700 /home/$USERNAME/.ssh
sudo touch /home/$USERNAME/.ssh/authorized_keys
sudo chmod 600 /home/$USERNAME/.ssh/authorized_keys
sudo chown -R $USERNAME:$USERNAME /home/$USERNAME/.ssh 

# Configure SSH
echo "Configuring SSH daemon..."
sudo sed -i "s/#Port 22/Port $SSH_PORT/" /etc/ssh/sshd_config
sudo sed -i "s/PasswordAuthentication yes/PasswordAuthentication no/" /etc/ssh/sshd_config
sudo sed -i "s/#PubkeyAuthentication yes/PubkeyAuthentication yes/" /etc/ssh/sshd_config
sudo sed -i "s/PermitRootLogin yes/PermitRootLogin prohibit-password/" /etc/ssh/sshd_config

# Configure Firewall
echo "Setting up UFW firewall..."
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow $SSH_PORT/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw --force enable

# Configure Fail2Ban
echo "Configuring Fail2Ban..."
sudo cat > /etc/fail2ban/jail.local << EOF
[sshd]
enabled = true
port = $SSH_PORT
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 3600
findtime = 600
EOF

sudo systemctl enable fail2ban
sudo systemctl start fail2ban 

# Enable Automatic Security Updates
echo "Enabling automatic security updates..."
sudo apt install -y unattended-upgrades
sudo dpkg-reconfigure -plow unattended-upgrades

# Start Services
echo "Starting and enabling Nginx..."
sudo systemctl enable nginx
sudo systemctl start nginx

# Restart SSH
echo "Restarting SSH service..."
sudo systemctl restart sshd

echo "VPS initial setup completed successfully!"
echo "You can now log in as '$USERNAME' on port $SSH_PORT."
echo "Add your SSH public key to /home/$USERNAME/.ssh/authorized_keys to access the server."
echo "Then connect with: ssh -p $SSH_PORT $USERNAME@your_server_ip"

## NOW TO USE: when starting new vps, download and run: 
## curl -O https://raw.githubusercontent.com/yourusername/vps-setup/main/setup.sh
## chmod +x setup.sh
## sudo ./setup.sh
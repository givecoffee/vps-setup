#!/bin/bash
# setup.sh - Initial server provisioning
# Run once as user: rae (with sudo privileges)
# Usage: bash scripts/setup.sh
set -euo pipefail

LOG_FILE="$HOME/logs/setup.log"
mkdir -p "$HOME/logs"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "Starting server provisioning..."

# ---------------------------------------------------
# 1. System update
# ---------------------------------------------------
log "Updating system packages..."
sudo apt-get update -qq
sudo apt-get upgrade -y -qq
sudo apt-get autoremove -y -qq

# ---------------------------------------------------
# 2. Essential packages
# ---------------------------------------------------
log "Installing essential packages..."
sudo apt-get install -y -qq \
  curl \
  git \
  ufw \
  fail2ban \
  unattended-upgrades \
  apt-listchanges \
  logrotate \
  htop \
  jq

# ---------------------------------------------------
# 3. Automatic security updates
# ---------------------------------------------------
log "Configuring unattended-upgrades..."
sudo tee /etc/apt/apt.conf.d/20auto-upgrades > /dev/null <<'EOF'
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Download-Upgradeable-Packages "1";
APT::Periodic::AutocleanInterval "7";
APT::Periodic::Unattended-Upgrade "1";
EOF

# ---------------------------------------------------
# 4. UFW firewall
# ---------------------------------------------------
log "Configuring UFW firewall..."
sudo ufw --force reset
sudo ufw default deny incoming
sudo ufw default allow outgoing

# SSH on non-standard port
sudo ufw allow 2222/tcp comment 'SSH'

# HTTP and HTTPS — Cloudflare IPs only
# (full list maintained in ufw-cloudflare.sh)
sudo ufw allow 80/tcp comment 'HTTP'
sudo ufw allow 443/tcp comment 'HTTPS'

sudo ufw --force enable
log "UFW status:"
sudo ufw status verbose | tee -a "$LOG_FILE"

# ---------------------------------------------------
# 5. Fail2Ban
# ---------------------------------------------------
log "Configuring Fail2Ban..."
sudo tee /etc/fail2ban/jail.local > /dev/null <<'EOF'
[DEFAULT]
bantime  = 1h
findtime = 10m
maxretry = 5
backend  = systemd

[sshd]
enabled  = true
port     = 2222
logpath  = %(sshd_log)s
maxretry = 3
bantime  = 24h

[nginx-http-auth]
enabled  = true

[nginx-botsearch]
enabled  = true
EOF

sudo systemctl enable fail2ban
sudo systemctl restart fail2ban
log "Fail2Ban status:"
sudo fail2ban-client status | tee -a "$LOG_FILE"

# ---------------------------------------------------
# 6. SSH hardening
# ---------------------------------------------------
log "Hardening SSH configuration..."
sudo tee /etc/ssh/sshd_config.d/99-hardening.conf > /dev/null <<'EOF'
Port 2222
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys
X11Forwarding no
AllowTcpForwarding no
ClientAliveInterval 300
ClientAliveCountMax 2
MaxAuthTries 3
MaxSessions 3
LoginGraceTime 30
EOF

sudo sshd -t && sudo systemctl restart sshd
log "SSH hardened and restarted."

# ---------------------------------------------------
# 7. Directory structure
# ---------------------------------------------------
log "Creating application directory structure..."
mkdir -p "$HOME"/{apps/{coffee,portfolio,w26},scripts,config/nginx,logs/{health,backup,deploy},backups}

log "Provisioning complete."
log "Next: run scripts/install-node.sh to install Node.js and PM2."
#!/bin/bash
# ufw-cloudflare.sh
# Restrict HTTP/HTTPS to Cloudflare IPs only.
# Run after setup.sh. Re-run to refresh when Cloudflare updates their ranges.
# Source: https://www.cloudflare.com/ips/
set -euo pipefail

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] \$1"
}

log "Fetching Cloudflare IP ranges..."

CF_IPV4=$(curl -sf https://www.cloudflare.com/ips-v4)
CF_IPV6=$(curl -sf https://www.cloudflare.com/ips-v6)

# Remove any existing Cloudflare rules
sudo ufw status numbered \
  | grep 'Cloudflare' \
  | awk -F'[][]' '{print \$2}' \
  | sort -rn \
  | while read -r num; do
      sudo ufw --force delete "$num"
    done

log "Adding Cloudflare IPv4 ranges..."
while IFS= read -r ip; do
  sudo ufw allow from "$ip" to any port 80 comment 'Cloudflare'
  sudo ufw allow from "$ip" to any port 443 comment 'Cloudflare'
done <<< "$CF_IPV4"

log "Adding Cloudflare IPv6 ranges..."
while IFS= read -r ip; do
  sudo ufw allow from "$ip" to any port 80 comment 'Cloudflare'
  sudo ufw allow from "$ip" to any port 443 comment 'Cloudflare'
done <<< "$CF_IPV6"

# Block all other traffic on 80/443
sudo ufw deny 80/tcp comment 'Block non-CF HTTP'
sudo ufw deny 443/tcp comment 'Block non-CF HTTPS'

sudo ufw reload
log "UFW updated. Only Cloudflare IPs may reach ports 80 and 443."
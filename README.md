# vps-hosting

Single-VPS multi-domain hosting infrastructure.

## Stack

- Ubuntu 24.04 LTS (Racknerd KVM, Seattle)
- Cloudflare (CDN, DDoS, WAF)
- Nginx (reverse proxy)
- Node.js via nvm
- PM2 (process management)
- Cloudflare R2 + rclone (backups)

## Structure
apps/ Node.js applications
config/ Nginx and PM2 configuration
scripts/ Automation scripts
logs/ Runtime logs (gitignored)
backups/ Local backup copies (gitignored)


## Setup 

See `scripts/setup.sh` for initial server provisioning.
Each app has its own `README.md` with run instructions.

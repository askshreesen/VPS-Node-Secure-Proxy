#!/usr/bin/env bash
set -euo pipefail

# === Settings ===
APP_PORT="3000"       # Node.js app port
HTTPS_PORT="3443"     # Nginx HTTPS port
DOMAIN=$(curl -s ifconfig.me)   # VPS public IP
GITHUB_USER="askshreesen"

echo "=============================================="
echo " 🌍 VPS Node HTTPS Proxy Installer (No Auth)"
echo "=============================================="
echo "➡️  Node.js app running on: http://localhost:${APP_PORT}"
echo "➡️  Will be accessible via HTTPS: https://${DOMAIN}:${HTTPS_PORT}"
echo "=============================================="

# Install required packages
apt update -y
apt install -y nginx openssl curl

# Generate self-signed SSL certificate
ssl_dir="/etc/ssl/localcerts"
mkdir -p "$ssl_dir"
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout "$ssl_dir/${DOMAIN}.key" -out "$ssl_dir/${DOMAIN}.crt" \
  -subj "/CN=${DOMAIN}"

# Nginx configuration
site_conf="/etc/nginx/sites-available/nodeapp"
cat > "$site_conf" <<EOF
server {
    listen 80;
    server_name ${DOMAIN};
    return 301 https://\$host:${HTTPS_PORT}\$request_uri;
}

server {
    listen ${HTTPS_PORT} ssl;
    server_name ${DOMAIN};

    ssl_certificate ${ssl_dir}/${DOMAIN}.crt;
    ssl_certificate_key ${ssl_dir}/${DOMAIN}.key;

    location / {
        proxy_pass http://localhost:${APP_PORT};
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF

# Enable site and reload Nginx
ln -sf "$site_conf" /etc/nginx/sites-enabled/
nginx -t && systemctl restart nginx

echo ""
echo "=============================================="
echo " ✅ Setup Complete!"
echo "👉 Open your app at: https://${DOMAIN}:${HTTPS_PORT}"
echo "=============================================="
echo "⭐ Script by: https://github.com/${GITHUB_USER}"
echo "=============================================="

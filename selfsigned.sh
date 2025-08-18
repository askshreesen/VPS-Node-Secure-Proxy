#!/usr/bin/env bash
set -euo pipefail

# === Settings ===
USERNAME="admin"
PASSWORD="pass123"
PORT="3000"
DOMAIN=$(curl -s ifconfig.me)   # VPS public IP
GITHUB_USER="askshreesen"

echo "=============================================="
echo " 🌍 VPS Node Secure Proxy Installer"
echo "=============================================="
echo "➡️  Setting up HTTPS proxy for: http://localhost:${PORT}"
echo "➡️  Will be accessible at: https://${DOMAIN}:${PORT}"
echo "➡️  Default login -> ${USERNAME} / ${PASSWORD}"
echo "=============================================="

# Install required packages
apt update -y
apt install -y nginx apache2-utils openssl

# Create password file
htpasswd -cbB /etc/nginx/.htpasswd "$USERNAME" "$PASSWORD"

# Generate self-signed SSL
ssl_dir="/etc/ssl/localcerts"
mkdir -p "$ssl_dir"
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout "$ssl_dir/${DOMAIN}.key" -out "$ssl_dir/${DOMAIN}.crt" \
  -subj "/CN=${DOMAIN}"

# Nginx config
site_conf="/etc/nginx/sites-available/nodeapp"
cat > "$site_conf" <<EOF
server {
    listen 80;
    server_name ${DOMAIN};
    return 301 https://\$host:${PORT}\$request_uri;
}

server {
    listen ${PORT} ssl;
    server_name ${DOMAIN};

    ssl_certificate ${ssl_dir}/${DOMAIN}.crt;
    ssl_certificate_key ${ssl_dir}/${DOMAIN}.key;

    auth_basic "Restricted Access";
    auth_basic_user_file /etc/nginx/.htpasswd;

    location / {
        proxy_pass http://localhost:${PORT};
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF

# Enable site
ln -sf "$site_conf" /etc/nginx/sites-enabled/
nginx -t && systemctl reload nginx

echo ""
echo "=============================================="
echo " ✅ Setup Complete!"
echo "👉 Open your app at: https://${DOMAIN}:${PORT}"
echo "🔑 Login with: ${USERNAME} / ${PASSWORD}"
echo "=============================================="
echo "⭐ Script by: https://github.com/${GITHUB_USER}"
echo "=============================================="

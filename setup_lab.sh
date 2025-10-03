#!/bin/bash
# Reverse Proxy + Load Balancer Lab Setup
# Supports Debian/Ubuntu & RHEL (CentOS/Rocky/Alma)

set -e

OS_FAMILY=""
PKG_UPDATE=""
PKG_INSTALL=""

detect_os() {
  if [ -f /etc/debian_version ]; then
    OS_FAMILY="debian"
    PKG_UPDATE="apt update -y"
    PKG_INSTALL="apt install -y"
  elif [ -f /etc/redhat-release ]; then
    OS_FAMILY="rhel"
    PKG_UPDATE="yum -y update"
    PKG_INSTALL="yum -y install"
  else
    echo "[!] Unsupported OS"
    exit 1
  fi
}

install_webserver() {
  echo "[*] Setting up Web Server: $HOSTNAME"

  if [ "$OS_FAMILY" = "debian" ]; then
    $PKG_UPDATE
    $PKG_INSTALL nginx
  else
    $PKG_UPDATE
    $PKG_INSTALL epel-release
    $PKG_INSTALL nginx
  fi

  systemctl enable --now nginx

  # Custom index page
  echo "<h1>Hello from $HOSTNAME</h1>" > /var/www/html/index.html

  # Open firewall
  if command -v ufw &>/dev/null; then
    ufw allow 80/tcp || true
  elif command -v firewall-cmd &>/dev/null; then
    firewall-cmd --permanent --add-service=http || true
    firewall-cmd --reload || true
  fi

  echo "[+] Web Server $HOSTNAME ready!"
}

install_nginx_proxy() {
  echo "[*] Setting up Nginx Reverse Proxy..."
  $PKG_UPDATE &>/dev/null
  $PKG_INSTALL nginx &>/dev/null

  if [ "$OS_FAMILY" = "debian" ]; then
    CONF_FILE="/etc/nginx/sites-available/loadbalancer"
  else
    CONF_FILE="/etc/nginx/conf.d/loadbalancer.conf"
  fi

  cat > $CONF_FILE <<EOF
upstream backend {
    server 10.192.225.247:80;
    server 10.192.225.233:80;
}

server {
    listen 80;

    location / {
        proxy_pass http://backend;
    }
}
EOF

  if [ "$OS_FAMILY" = "debian" ]; then
    ln -sf $CONF_FILE /etc/nginx/sites-enabled/loadbalancer
  fi

  nginx -t
  systemctl enable --now nginx
  echo "[+] Nginx reverse proxy configured!"
}

install_haproxy_proxy() {
  echo "[*] Setting up HAProxy Load Balancer..."
  $PKG_UPDATE &>/dev/null
  $PKG_INSTALL haproxy &>/dev/null

  CONF_FILE="/etc/haproxy/haproxy.cfg"

  cat > $CONF_FILE <<EOF
global
    log /dev/log local0
    log /dev/log local1 notice
    maxconn 2048
    daemon

defaults
    log global
    mode http
    timeout connect 5000ms
    timeout client 50000ms
    timeout server 50000ms

frontend http-in
    bind *:80
    default_backend servers

backend servers
    balance roundrobin
    server web1 10.192.225.247:80 check
    server web2 10.192.225.233:80 check
EOF

  systemctl enable --now haproxy
  echo "[+] HAProxy configured!"
}

# =========== Main ============
detect_os

case "$1" in
  web)
    install_webserver
    ;;
  nginx-proxy)
    install_nginx_proxy
    ;;
  haproxy-proxy)
    install_haproxy_proxy
    ;;
  *)
    echo "Usage: $0 {web|nginx-proxy|haproxy-proxy}"
    exit 1
    ;;
esac


#!/bin/bash
# ===============================================
# Reverse Proxy + Load Balancer Lab Setup
# Supports Debian/Ubuntu & RHEL (CentOS/Rocky/Alma)
# Spinner + percentage style included
# ===============================================

set -euo pipefail

OS_FAMILY=""
PKG_UPDATE=""
PKG_INSTALL=""

# ----------------------------
# Spinner + percentage function
# ----------------------------
show_progress() {
    local msg=$1
    local duration=${2:-3}
    local frames=(⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏)
    local end_time=$((SECONDS + duration))
    local progress=0
    while [ $SECONDS -lt $end_time ]; do
        for f in "${frames[@]}"; do
            printf "\r%s  %s... %d%%" "$f" "$msg" "$progress"
            sleep 0.1
            progress=$((progress + RANDOM % 5))
            [ $progress -ge 99 ] && progress=99
        done
    done
    printf "\r✅  %s... 100%%\n" "$msg"
}

# ----------------------------
# Detect OS
# ----------------------------
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

# ----------------------------
# Install Web Server
# ----------------------------
install_webserver() {
    show_progress "Installing Web Server ($HOSTNAME)" 4

    if [ "$OS_FAMILY" = "debian" ]; then
        $PKG_UPDATE &>/dev/null
        $PKG_INSTALL nginx &>/dev/null
    else
        $PKG_UPDATE &>/dev/null
        $PKG_INSTALL epel-release &>/dev/null
        $PKG_INSTALL nginx &>/dev/null
    fi

    systemctl enable --now nginx
    echo "<h1>Hello from $HOSTNAME</h1>" > /var/www/html/index.html

    if command -v ufw &>/dev/null; then
        ufw allow 80/tcp || true
    elif command -v firewall-cmd &>/dev/null; then
        firewall-cmd --permanent --add-service=http || true
        firewall-cmd --reload || true
    fi

    echo "✅ Web Server $HOSTNAME ready!"
}

# ----------------------------
# Install Nginx Reverse Proxy
# ----------------------------
install_nginx_proxy() {
    show_progress "Installing Nginx Reverse Proxy" 4

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

    nginx -t &>/dev/null
    systemctl enable --now nginx
    echo "✅ Nginx reverse proxy configured!"
}

# ----------------------------
# Install HAProxy Load Balancer
# ----------------------------
install_haproxy_proxy() {
    show_progress "Installing HAProxy Load Balancer" 4

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
    echo "✅ HAProxy configured!"
}

# ----------------------------
# Main
# ----------------------------
detect_os

case "${1:-}" in
    web) install_webserver ;;
    nginx-proxy) install_nginx_proxy ;;
    haproxy-proxy) install_haproxy_proxy ;;
    *)
        echo "Usage: $0 {web|nginx-proxy|haproxy-proxy}"
        exit 1
        ;;
esac

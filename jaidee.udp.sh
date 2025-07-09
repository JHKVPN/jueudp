#!/usr/bin/env bash

------------------------------------------------------------------

Jaidee VPN Installer with Extended Menu

Supports Ubuntu 20–24 & Debian 11/12

------------------------------------------------------------------

set -e

WS_PORT=80 UDP_PORT=36712 UDP_PASSWORD=agnudp DOMAIN=""

color() { local c="$1"; shift; echo -e "\e[${c}m$\e[0m"; } info()  { color 34 "[INFO] $"; } error() { color 31 "[ERR]  $*"; }

require_root() { if [[ $EUID -ne 0 ]]; then error "Please run as root (sudo)." exit 1 fi }

check_os() { source /etc/os-release case "$ID" in ubuntu) VER=${VERSION_ID%%.*} [[ $VER -ge 20 && $VER -le 24 ]] || { error "Unsupported Ubuntu $VERSION_ID"; exit 1; } ;; debian) [[ $VERSION_ID == "11" || $VERSION_ID == "12" ]] || { error "Unsupported Debian $VERSION_ID"; exit 1; } ;; *) error "Unsupported OS $ID"; exit 1 ;; esac info "Detected OS: $PRETTY_NAME" }

install_packages() { info "Installing dependencies…" apt-get update -y DEBIAN_FRONTEND=noninteractive apt-get install -y 
curl wget tar unzip iptables-persistent ca-certificates }

install_websocat() { ARCH=$(uname -m) case "$ARCH" in x86_64) FILE="websocat.x86_64-unknown-linux-musl" ;; aarch64) FILE="websocat.aarch64-unknown-linux-musl" ;; armv7l|armv7*) FILE="websocat.arm-unknown-linux-musleabi" ;; *) error "Unsupported arch $ARCH for Websocat"; exit 1 ;; esac info "Installing Websocat ($ARCH)…" wget -qO /usr/local/bin/websocat "https://github.com/vi/websocat/releases/latest/download/$FILE" chmod +x /usr/local/bin/websocat }

create_ws_service() { info "Setting up SSH over WebSocket…" cat >/etc/systemd/system/ssh-websocket.service <<EOF [Unit] Description=SSH over WebSocket tunnel (port ${WS_PORT}) After=network.target ssh.service Wants=ssh.service

[Service] Type=simple ExecStart=/usr/local/bin/websocat -b -s 0.0.0.0:${WS_PORT} tcp:127.0.0.1:22 Restart=on-failure CapabilityBoundingSet=CAP_NET_BIND_SERVICE AmbientCapabilities=CAP_NET_BIND_SERVICE

[Install] WantedBy=multi-user.target EOF systemctl daemon-reload systemctl enable --now ssh-websocket.service }

install_agn_udp() { info "Installing AGN-UDP (Hysteria)…" curl -sO https://raw.githubusercontent.com/khaledagn/AGN-UDP/main/install_agnudp.sh chmod +x install_agnudp.sh DOMAIN="$DOMAIN" UDP_PORT=":${UDP_PORT}" PASSWORD="$UDP_PASSWORD" ./install_agnudp.sh }

configure_firewall() { info "Opening firewall ports ${WS_PORT}/tcp and ${UDP_PORT}/udp…" iptables -I INPUT -p tcp --dport ${WS_PORT} -j ACCEPT || true iptables -I INPUT -p udp --dport ${UDP_PORT} -j ACCEPT || true netfilter-persistent save }

Placeholder functions for extended menu options

todo() { echo -e "\n[TODO] This feature is not implemented yet: $1\n" sleep 2 }

menu() { clear echo -e "\n💻 \e[1;32mJaidee VPN Extended Menu\e[0m\n" echo "[1] Install SSH over WebSocket (port $WS_PORT)" echo "[2] Install AGN-UDP (Hysteria UDP port $UDP_PORT)" echo "[3] Open Firewall Ports" echo "[4] Install Both (1 + 2 + 3)" echo "[5] Create Account" echo "[6] Delete Account" echo "[7] Set User Limit" echo "[8] Show Online Users" echo "[9] Renew User" echo "[10] Change Ports" echo "[11] Change Domain" echo "[12] Exit" echo -n "\nSelect an option [1-12]: " read -r opt case $opt in 1) install_packages; install_websocat; create_ws_service;; 2) install_packages; install_agn_udp;; 3) configure_firewall;; 4) install_packages; install_websocat; create_ws_service; install_agn_udp; configure_firewall;; 5) todo "Create Account";; 6) todo "Delete Account";; 7) todo "Set User Limit";; 8) todo "Show Online Users";; 9) todo "Renew User";; 10) todo "Change Ports";; 11) todo "Change Domain";; 12) exit 0;; *) echo "Invalid option"; sleep 1;; esac echo -e "\n✅ Done. Press Enter to return to menu." read -r menu }

main() { require_root check_os menu }

main "$@"


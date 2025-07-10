#!/usr/bin/env bash
# ================================================================
#  JueVPN – Interactive Installer Menu
#     1) Jue UDP
#     2) WebSocket-SSH
#     3) 3x-ui (Xray/V2Ray panel)
#     4) ALL (1 + 2 + 3 + 5)
#     5) Web SSH Panel (painel.sh)
#     0) Quit
# ---------------------------------------------------------------
set -euo pipefail

blue() { printf '\033[1;34m%s\033[0m\n' "$*"; }
red()  { printf '\033[1;31m%s\033[0m\n' "$*"; }

need_root() { [[ $EUID -eq 0 ]] || { red "⚠️  run with sudo/root"; exit 1; }; }

fetch() { # $1=url  $2=output
  wget -qO "$2" "$1" || { red "Download failed: $1"; exit 1; }
  chmod +x "$2"
}

run_udp() {
  blue "🚀 Installing Jue UDP..."
  fetch https://raw.githubusercontent.com/Juessh/Juevpnscript/main/install_jueudp.sh /tmp/install_jueudp.sh
  /tmp/install_jueudp.sh
}

run_ws() {
  blue "🌐 Installing WebSocket-SSH..."
  fetch https://raw.githubusercontent.com/Juessh/Juevpnscript/main/install.sh /tmp/install_ws.sh
  /tmp/install_ws.sh
}

run_3xui() {
  blue "🧩 Installing 3x-ui..."
  bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)
}

run_ssh_panel() {
  blue "🧭 Installing Web SSH Panel (painel.sh)..."
  bash <(curl -sSL https://raw.githubusercontent.com/painelssh/painel.sh/main/install.sh)
}

menu() {
  clear
  blue "========= JueVPN Setup Menu ========="
  echo " 1) Install Jue UDP"
  echo " 2) Install WebSocket-SSH"
  echo " 3) Install 3x-ui (Xray panel)"
  echo " 4) Install ALL (1 + 2 + 3 + 5)"
  echo " 5) Install Web SSH Panel"
  echo " 0) Quit"
  echo "--------------------------------------"
  read -rp "Choice [0-5]: " c
  case "$c" in
    1) run_udp;;
    2) run_ws;;
    3) run_3xui;;
    4) run_udp && run_ws && run_3xui && run_ssh_panel;;
    5) run_ssh_panel;;
    0) exit 0;;
    *) red "❌ Invalid choice"; sleep 1;;
  esac
}

main() { need_root; while true; do menu; done; }
main "$@"

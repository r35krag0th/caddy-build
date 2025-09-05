#!/usr/bin/env bash

set -euo pipefail

# Based on:
# https://github.com/caddy-dns/route53/issues/58#issuecomment-2829589469

echo ""
echo -e "\033[1;36m[CHECK]\033[0m Dependencies"
echo ""
if ! command -v xcaddy >/dev/null; then
  echo -e "\t\033[1;37m\033[41m MISSING \033[0m xcaddy (binary)"
  go install github.com/caddyserver/xcaddy/cmd/xcaddy@latest
else
  echo -e "\t\033[1;30m\033[42m OK \033[0m xcaddy (binary)"
fi
if ! command -v make >/dev/null; then
  echo -e "\t\033[1;37m\033[41m MISSING \033[0m make (binary)"
  echo ""
  echo "You'll need to install the 'build-essential' package on Ubuntu"
  echo "or whatever provides 'make' on your OS."
  echo ""
  exit 1
else
  echo -e "\t\033[1;30m\033[42m OK \033[0m make (binary)"
fi

echo ""
echo -e "\033[1;36m[CHECK]\033[0m route53 plugin"
echo ""

if [ ! -d route53 ]; then
  echo -e "\t\033[1;30m\033[43m CLONE \033[0m route53 plugin"
  git clone https://github.com/theAeon/route53.git
else
  echo -e "\t\033[1;30m\033[42m UPDATE \033[0m route53 plugin"
  git -C route53 fetch &&
    git -C route53 pull
fi

echo ""
echo -e "\033[35m[BUILD]\033[0m Caddy Binary"
echo ""

xcaddy build \
  --with github.com/caddy-dns/route53 \
  --replace github.com/libdns/route53@v1.5.1=./route53 \
  --with github.com/caddy-dns/cloudflare \
  --with github.com/monobilisim/caddy-ip-list \
  --with github.com/greenpau/caddy-security &&
  sudo systemctl stop caddy &&
  sudo cp caddy /usr/bin/caddy &&
  sudo cp caddy /bin/caddy &&
  sudo systemctl start caddy

echo ""
echo -e "\033[36m[DONE]\033[0m Binary deployed and Caddy restarted!"
echo ""

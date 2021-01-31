#!/bin/bash
set -e
set -x

# Determine if user is on Mac or Linux
UNAME=$(uname -a)
case "${UNAME}" in
    Linux*)     OS=Linux;;
    Darwin*)    OS=Mac;;
    *)          OS="?"
esac
echo "Operating system found : ${OS}"

# Add dependencies
echo "Installing dependencies..."
if [ "$OS" == "Linux" ]; then
  sudo apt install -y jq httpie
elif [ "$OS" == "Mac" ]; then
  brew install jq
  brew install httpie
else
  echo "Operating system not supported!"
  exit 1
fi
echo "Dependencies installed."

# Copy binaries
mkdir -p "${HOME}/.dns"
if [ -z "${1}" ]; then
  cp ./dns.config "${HOME}/.dns/dns.config"
else
  cp "${1}" "${HOME}/.dns/dns.config"
fi
cp ./dns-sync.sh "${HOME}/.dns/dns-sync.sh"
sed -i -e "s@http @$(which http) @g" "${HOME}/.dns/dns-sync.sh"
sed -i -e "s@jq @$(which jq) @g" "${HOME}/.dns/dns-sync.sh"
chmod +x "${HOME}/.dns/dns-sync.sh"

# Add cron
echo "0 */1 * * * \"${HOME}/.dns/dns-sync.sh\" \"${HOME}/.dns\" >> \"${HOME}/.dns/dns.log\" 2>&1" | sudo crontab
sudo crontab -l

exit 0


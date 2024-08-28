#!/bin/bash

set -euxo pipefail

NODENAME="justtesting"
SCRIPT_DIR="$(dirname "$(realpath "$0")")"

mkdir -p ~/.babylond
mkdir -p ~/.babylond/cosmovisor
mkdir -p ~/.babylond/cosmovisor/genesis
mkdir -p ~/.babylond/cosmovisor/genesis/bin
mkdir -p ~/.babylond/cosmovisor/upgrades
mkdir -p ~/.babylond/config/

cp $SCRIPT_DIR/config.toml ~/.babylond/config/

cd $HOME/babylon/

babylond init $NODENAME --chain-id bbn-test-3

wget https://github.com/babylonchain/networks/raw/main/bbn-test-3/genesis.tar.bz2
tar -xjf genesis.tar.bz2 && rm genesis.tar.bz2
mv genesis.json ~/.babylond/config/genesis.json

# Set iavl-cache-size to 0
sed -i 's/^iavl-cache-size = .*/iavl-cache-size = 0/' ~/.babylond/config/app.toml

# Set network to "signet" under the [btc-config] section
sed -i '/\[btc-config\]/,/^\[.*\]/s/^network = .*/network = "signet"/' ~/.babylond/config/app.toml

# Update minimum-gas-prices to "0.00001ubbn"
sed -i 's/^minimum-gas-prices = .*/minimum-gas-prices = "0.00001ubbn"/' ~/.babylond/config/app.toml

go install cosmossdk.io/tools/cosmovisor/cmd/cosmovisor@latest

cp $GOPATH/bin/babylond ~/.babylond/cosmovisor/genesis/bin/babylond

sudo tee /etc/systemd/system/babylond.service > /dev/null <<EOF
[Unit]
Description=Babylon daemon
After=network-online.target

[Service]
User=$USER
ExecStart=$(which cosmovisor) run start --x-crisis-skip-assert-invariants
Restart=always
RestartSec=3
LimitNOFILE=infinitysudo -S systemctl daemon-reload
sudo -S systemctl enable babylond
sudo -S systemctl start babylond

Environment="DAEMON_NAME=babylond"
Environment="DAEMON_HOME=${HOME}/.babylond"
Environment="DAEMON_RESTART_AFTER_UPGRADE=true"
Environment="DAEMON_ALLOW_DOWNLOAD_BINARIES=false"

[Install]
WantedBy=multi-user.target
EOF

sudo -S systemctl daemon-reload
sudo -S systemctl enable babylond
sudo -S systemctl start babylond

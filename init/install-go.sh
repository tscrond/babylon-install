#!/bin/bash

set -euxo pipefail

echo "Download Go binary"
wget https://go.dev/dl/go1.21.6.linux-amd64.tar.gz

echo "Extract Go binary to the home directory"
sudo tar -C $HOME -xzf go1.21.6.linux-amd64.tar.gz

echo Change ownership of the Go directory
sudo chown -R $(whoami) $HOME/go

echo "Add Go binary path to .bashrc if it's not already there"
GO_PATH='export PATH=$PATH:$HOME/go/bin'
GOPATH_PATH='export GOPATH=$HOME/go/bin'
GOPATH_BIN_PATH='export PATH=$PATH:$GOPATH/bin'

if ! grep -q "$GO_PATH" "$HOME/.bashrc"; then
    echo "$GO_PATH" >> "$HOME/.bashrc"
    echo "$GOPATH_PATH" >> "$HOME/.bashrc"
    echo "$GOPATH_BIN_PATH" >> "$HOME/.bashrc"
fi

echo "Source .bashrc to apply changes immediately"
source "$HOME/.bashrc"

# Optionally, inform the user to restart the terminal
echo "Go has been installed and PATH has been updated. Please restart your terminal or run 'source ~/.bashrc' to apply changes."

#!/bin/bash

set -euxo pipefail

# Download Go binary
wget https://go.dev/dl/go1.21.6.linux-amd64.tar.gz

# Extract Go binary to the home directory
sudo tar -C $HOME -xzf go1.21.6.linux-amd64.tar.gz

# Change ownership of the Go directory
sudo chown -R $(whoami) $HOME/go

# Add Go binary path to .bashrc if it's not already there
GO_PATH='export PATH=$PATH:$HOME/go/bin'

if ! grep -q "$GO_PATH" "$HOME/.bashrc"; then
    echo "$GO_PATH" >> "$HOME/.bashrc"
fi

# Source .bashrc to apply changes immediately
source "$HOME/.bashrc"

# Optionally, inform the user to restart the terminal
echo "Go has been installed and PATH has been updated. Please restart your terminal or run 'source ~/.bashrc' to apply changes."

#!/bin/bash
set -euxo pipefail

echo "Update + upgrade..."
sudo apt update -y && sudo apt upgrade -y
echo "Install Git..."
sudo apt install -y git

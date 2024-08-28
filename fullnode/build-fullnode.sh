#!/bin/bash

sudo apt install git make build-essential curl jq --yes

git clone https://github.com/babylonchain/babylon.git $HOME/babylon

cd $HOME/babylon/

git checkout v0.8.4

make install

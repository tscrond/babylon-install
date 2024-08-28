#!/bin/bash

git clone https://github.com/babylonchain/finality-provider.git

cd $HOME/finality-provider

git checkout v0.3.0

make install

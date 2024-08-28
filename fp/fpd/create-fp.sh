#!/bin/bash

fpcli create-finality-provider \
    --key-name finality-provider \
    --chain-id bbn-test-3 \
    --commission 0.05 \
    --moniker "justtesting-fp"

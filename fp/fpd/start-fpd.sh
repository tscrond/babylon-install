#!/bin/bash

set -euxo pipefail

fpd init

fpd keys add finality-provider --keyring-backend test --output json

fpd start

#!/bin/bash

#addr=$1


cabal exec make-policy stake.policy 

cardano-cli address build --payment-script-file stake.policy --testnet-magic 2 --out-file script.addr

echo "done"
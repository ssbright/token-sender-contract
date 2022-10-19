#!/bin/bash

#addr=$1
addr=wallets/test-user.address

echo "address : $addr"

cardano-cli address key-hash --payment-verification-key-file wallets/user.stake.vkey --out-file user.pkh


cabal exec make-policy stake.policy $(cat user.pkh)

cardano-cli address build --payment-script-file stake.policy --mainnet  --out-file script.addr

echo "done"
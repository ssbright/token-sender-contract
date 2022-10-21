#!/bin/bash

#addr=$1

addr=$(cat script.addr)

echo "address : $addr"

cardano-cli address key-hash --payment-verification-key-file wallets/epool-stake.vkey --out-file user.pkh


cabal exec make-datum $(cat user.pkh)
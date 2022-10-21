#!/bin/bash



cardano-cli address key-hash --payment-verification-key-file wallets/epool-payment-0.vkey --out-file seller.pkh


cabal exec make-datum $(cat seller.pkh)
#!/bin/bash

cardano-cli query utxo \
   $MAGIC \
   --address $(cat ./wallets/epool.address)


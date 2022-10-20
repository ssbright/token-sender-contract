#!/bin/bash

cardano-cli query utxo \
   $MAGIC \
   --address $(cat ./script.addr)


#!/bin/bash

oref=$1
amt=$2
tn=$3
addrFile=wallets/epool.address
skeyFile=wallets/epool-payment-0.skey

echo "oref: $oref"
echo "amt: $amt"
echo "tn: $tn"
echo "address file: $addrFile"
echo "signing key file: $skeyFile"

ppFile=pparams.json
cardano-cli query protocol-parameters $MAGIC --out-file $ppFile

policyFile=mint.plutus
cabal exec token-policy $policyFile $oref $amt $tn

unsignedFile=tx.unsigned
signedFile=tx.signed
pid=$(cardano-cli transaction policyid --script-file $policyFile)
tnHex=$(cabal exec token-name -- $tn)
addr=$(cat $addrFile)
v="$amt $pid.$tnHex"

echo "currency symbol: $pid"
echo "token name (hex): $tnHex"
echo "minted value: $v"
echo "address: $addr"

cardano-cli transaction build \
    --babbage-era \
    $MAGIC \
    --tx-in $oref \
    --tx-in-collateral $oref \
    --tx-out "$addr + 10000000 lovelace + $v" \
    --mint "$v" \
    --mint-script-file $policyFile \
    --mint-redeemer-file unit.json \
    --metadata-json-file token_meta.json \
    --change-address $addr \
    --required-signer $skeyFile \
    --protocol-params-file $ppFile \
    --out-file $unsignedFile \



cardano-cli transaction sign \
    --tx-body-file $unsignedFile \
    --signing-key-file $skeyFile \
    $MAGIC \
    --out-file $signedFile



cardano-cli transaction submit \
    $MAGIC \
    --tx-file $signedFile

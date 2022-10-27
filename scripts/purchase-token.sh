#!/bin/bash


orefscript=$1
orefcust=$2
amt=$3
selleraddr=$(cat wallets/epool.address)
scriptAddrFile=$(cat script.addr)
custAddrFile=$(cat wallets/ecust.address)
skeyFile=wallets/ecust-payment-0.skey
pid=64ce70c760fe545f1681074308d135f8d94d76de50ba44d86a53e41b
tnHex=424c414e4b
adaAmt=$(expr $amt \* 1000000 ) 
tokenamt=1
v="$tokenamt $pid.$tnHex"

echo "orefscript : $orefscript"
echo "orefcust : $orefcust" 
echo "selletaddr: $selleraddr"
echo "amt : $amt" 
echo "scriptAddrFile: $scriptAddrFile"
echo "custAddrFile: $custAddrFile"
echo "ADA spent: $adaAmt"
echo "token number: $tokenamt"
echo "token amount: $v"
echo "cust skey file: $skeyFile"


unsignedFile=tx.unsigned
signedFile=tx.signed



cardano-cli transaction build \
    --babbage-era \
    $MAGIC \
    --tx-in $orefcust \
    --tx-in $orefscript \
    --tx-in-script-file stake.policy \
    --tx-in-redeemer-file unit.json \
    --tx-in-datum-file sale-datum.json \
    --required-signer $skeyFile \
    --tx-in-collateral $orefcust \
    --tx-out "$selleraddr + $adaAmt lovelace" \
    --tx-out "$custAddrFile + 2000000 lovelace + $v" \
    --change-address $custAddrFile \
    --protocol-params-file pparams.json \
    --out-file $unsignedFile \


cardano-cli transaction sign \
    --tx-body-file $unsignedFile \
    --signing-key-file $skeyFile \
    $MAGIC \
    --out-file $signedFile

cardano-cli transaction submit \
    $MAGIC \
    --tx-file $signedFile

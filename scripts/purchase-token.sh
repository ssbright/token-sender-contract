#!/bin/bash


orefscript=$1
orefcust=$2
amt=$3
scriptAddrFile=$(cat script.addr)
custAddrFile=$(cat wallets/ecust.address)
custSkeyFile= wallets/ecust-payment-0.skey
pid=953173ed54667a5694a150035d50296f96fb7697d7ebc4f8f6502954
tnHex=46554e74657374
adaAmt = $( expr $amt * 1000000 ) 
tokenamt = 1
v="$tokenamt $pid.$tnHex"

echo "orefscript : $orefscript"
echo "orefcust : $orefcust" 
echo "amt : $amt" 
echo "scriptAddrFile: $scriptAddrFile"
echo "custAddrFile: $custAddrFile"
echo "token math: $tokenamt"
echo "token amount: $v"

useraddr=$addrFile
unsignedFile=tx.unsigned
signedFile=tx.signed


cardano-cli transaction build \
    --babbage-era \
    $MAGIC \
    --tx-in $orefscript \
    --tx-in $orefcust \
    --required-signer $custSKeyFile \
    --tx-in-collateral $orefcust \
    --change-address $custAddrFile \
    --tx-out "$scriptAddrFile + $adaAmt lovelace" \
    --tx-out "$custAddrFile + 2000000 lovelace +$v" \
    --out-file $unsignedFile \

cardano-cli transaction sign \
    --tx-body-file $unsignedFile \
    --signing-key-file $custSKeyFile \
    $MAGIC \
    --out-file $signedFile

cardano-cli transaction submit \
    $MAGIC \
    --tx-file $signedFile

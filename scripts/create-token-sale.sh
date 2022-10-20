#!/bin/bash


oref=$1
amt=$2
toAddr=$(cat script.addr)
addrFile=$(cat wallets/epool.address)
skeyFile=wallets/epool-payment-0.skey
token=953173ed54667a5694a150035d50296f96fb7697d7ebc4f8f6502954.46554e74657374

echo "oref : $oref" 
echo "amt : $amt" 
echo "toAddr: $toAddr"
echo "signing key file: $skeyFile"
echo "sender address: $addrFile"
echo "token: $token"

useraddr=$addrFile
unsignedFile=tx.unsigned
signedFile=tx.signed
utxo=$(cardano-cli-balance-fixer utxo-assets -u $oref  $MAGIC )
v="$amt $token"
starttoken=$(echo $utxo |  sed "s/.*+ //g" | sed s/$token//) 
remainingtoken=$(expr $starttoken - $amt)
rv="$remainingtoken $token"
backuputxo=$(cardano-cli-balance-fixer collateral -a $useraddr $MAGIC)
poolDatumFile=sale-datum.json
echo "v :$v"
echo "starttoken : $starttoken" 
echo "remainingtoken : $remainingtoken"


cardano-cli transaction build \
    --babbage-era \
    $MAGIC \
    --tx-in $oref \
    --required-signer $skeyFile \
    --tx-in-collateral $oref \
    --change-address $useraddr \
    --tx-out "$useraddr + 2000000 lovelace + $rv" \
    --tx-out "$toAddr + 2000000 lovelace +$v" \
    --tx-out-datum-hash-file  $poolDatumFile\
    --out-file $unsignedFile \

cardano-cli transaction sign \
    --tx-body-file $unsignedFile \
    --signing-key-file $skeyFile \
    $MAGIC \
    --out-file $signedFile

cardano-cli transaction submit \
    $MAGIC \
    --tx-file $signedFile

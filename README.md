# token-sender-contract

### Minting Token
# Next, run the command
	$ cabal exec token-policy -- mint.plutus your_txHash#your_TxIX desired_number_of_tokens desired_token_name
	$ cat policy.plutus  

# Next, generate the policy.id for token. 
	$ cardano-cli transaction policyid --script-file mint.plutus > policy.id

# Add policy id into the token_meta.json, and change whatever else as desired

# Mint With
    $./scripts/mint-token-cli.sh your_txHash#your_TxIX desired_number_of_tokens desired_token_name   
    (You will need to add your address file path and skey file path in the shell command file)

### Make Order

# Make Datum
	Change Token Name and Currency Symbol in make-datum.hs file to your token
	$ ./scripts/make-datum.sh

# Make Policy
	$ ./scripts/make-policy.sh

# Make UTXO for sale
	Change policyid.assetname in t he token= variable in create-token-sale.sh to your token
	$./scripts/create-token-sale.sh your_txHash_withtoken#your_TxIX desired_number_of_tokens_for_sale

# Make Purchase
	Replace pid variable and tnHex variable in purchase-token.sh to your token
	./scripts/purchase-token.sh script_txHash_withtoken#your_TxIX customer_txHash_withADA#your_TxIX tokens_for_sale
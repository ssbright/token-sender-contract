# token-sender-contract

### Minting Token
# Next, run the command
	$ cabal exec token-policy -- policy.plutus your_txHash#your_TxIX desired_number_of_tokens desired_token_name
	$ cat policy.plutus  

# Next, generate the policy.id for token. 
	$ cardano-cli transaction policyid --script-file policy.plutus > policy.id

# Add policy id into the token_meta.json, and change whatever else as desired

# Mint With
    $./scripts/mint-token-cli.sh your_txHash#your_TxIX desired_number_of_tokens desired_token_name   
    (You will need to add your address file path and skey file path in the shell command file)

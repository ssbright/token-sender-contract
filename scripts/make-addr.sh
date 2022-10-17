name=$1

cardano-cli address key-gen \
--verification-key-file $name.vkey \
--signing-key-file $name.skey

cardano-cli stake-address key-gen \
--verification-key-file stake-$name.vkey \
--signing-key-file stake-$name.skey

cardano-cli address build \
--payment-verification-key-file $name.vkey \
--stake-verification-key-file stake-$name.vkey \
--out-file $name.addr \
--mainnet



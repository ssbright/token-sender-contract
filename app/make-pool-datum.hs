{-# LANGUAGE ImportQualifiedPost #-}
{-# LANGUAGE DataKinds           #-}
{-# LANGUAGE DeriveAnyClass      #-}
{-# LANGUAGE DeriveGeneric       #-}
{-# LANGUAGE FlexibleContexts    #-}
{-# LANGUAGE NoImplicitPrelude   #-}
{-# LANGUAGE OverloadedStrings   #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TemplateHaskell     #-}
{-# LANGUAGE TypeApplications    #-}
{-# LANGUAGE TypeFamilies        #-}
{-# LANGUAGE TypeOperators       #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# OPTIONS_GHC -fno-warn-unused-imports #-}

import Data.Aeson as Json ( encode )
import Data.ByteString.Lazy qualified as LB
import qualified Data.ByteString.Char8       as BS8
import System.Environment ( getArgs )
import Prelude
import Ledger as Ledger 
import Ledger.Address              (toPubKeyHash)
import Data.String (fromString) 
import Ledger.Tx.CardanoAPI (fromCardanoAddress, FromCardanoError)
--import Data.ByteString.Lazy.UTF8 as BLU
-- import Codec.Binary.Encoding (base16)
-- import Data.Text.Encoding (Base16(..))
import Data.Text (unpack, Text)
--import Data.ByteArray.Encoding
import Cardano.Api( scriptDataToJson, ScriptDataJsonSchema(ScriptDataJsonDetailedSchema), deserialiseAddress, AsType(AsAlonzoEra,AsAddressInEra) )
import Cardano.Api.Shelley ( fromPlutusData )
import qualified PlutusTx
import Data.Maybe (fromJust)
import Data.Either (fromRight, fromLeft)
import Data.Time.Clock.POSIX as Time 
import Ledger                      (Address, PubKeyHash)
import Stake           (ContractStake(ContractStake), StakeDatum(CStake), ODatumHash(ODHash,OUnit))


mkContractStake :: Address -> ODatumHash -> Ledger.POSIXTime -> ContractStake
mkContractStake addr dh time = ContractStake addr dh time

mkPoolDatum :: Address -> ODatumHash -> Ledger.POSIXTime -> StakeDatum
mkPoolDatum addr dh time = CStake $ mkContractStake addr dh time

mkODHash :: DatumHash -> ODatumHash
mkODHash dh = ODHash dh 

mkODUnit :: ODatumHash
mkODUnit = OUnit ()

main :: IO ()
main = do
  [addr'] <- getArgs
  currPOSIX' <- Time.getPOSIXTime
  let addr = fromRight (error "not right") $ fromCardanoAddress $ fromJust $ deserialiseAddress (AsAddressInEra AsAlonzoEra) (Data.String.fromString addr') ---should add bettter error message for maybe failture (example of good in old redeemer make file)
      currPOSIX = Ledger.POSIXTime ( round $ currPOSIX' * 1000)
      dh = mkODUnit
      datum   = mkPoolDatum addr dh currPOSIX 
  print $ show addr
  writeData ("datum-pool.json") datum 
  putStrLn "Done"
-- Datum also needs to be passed when sending the token to the script (aka putting for sale)
-- When doing this, the datum needs to be hashed.

writeData :: PlutusTx.ToData a => FilePath -> a -> IO ()
writeData file isData = do
  print file
  LB.writeFile file (toJsonString isData)

toJsonString :: PlutusTx.ToData a => a -> LB.ByteString
toJsonString =
  Json.encode
    . scriptDataToJson ScriptDataJsonDetailedSchema
    . fromPlutusData
    . PlutusTx.toData
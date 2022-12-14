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
--import Ledger as Ledger 
import Ledger.Address              (toPubKeyHash, PaymentPubKeyHash(PaymentPubKeyHash))
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
import Ledger                      (Address, PubKeyHash, AssetClass(..), CurrencySymbol, TokenName)
import OnChain                    (SaleDatum(SaleDatum))
import Plutus.V1.Ledger.Value


mkSaleDatum :: PaymentPubKeyHash -> AssetClass -> Integer -> SaleDatum
mkSaleDatum ppkh ac int = SaleDatum ppkh ac int

getPaymentPubKeyHash :: String -> PaymentPubKeyHash
getPaymentPubKeyHash pkhstr = PaymentPubKeyHash (fromString pkhstr :: PubKeyHash)
--https://cardano.stackexchange.com/questions/7039/how-to-make-a-pubkeyhash-into-a-paymentpubkeyhash

mainTokenSymbol :: CurrencySymbol
mainTokenSymbol = "424c414e4b"

mainToken :: TokenName
mainToken = "BLANK"

mainTokenAC :: AssetClass
mainTokenAC = assetClass mainTokenSymbol mainToken


main :: IO ()
main = do
  [pkhstr'] <- getArgs
  let ppkh = getPaymentPubKeyHash pkhstr'
    -- ppkh = fromRight (error "not right") $ fromCardanoAddress $ fromJust $ deserialiseAddress (AsAddressInEra AsAlonzoEra) (Data.String.fromString addr') ---should add bettter error message for maybe failture (example of good in old redeemer make file
      ac = mainTokenAC
      int = 10000000
      datum = mkSaleDatum ppkh ac int 
  print $ show ppkh
  writeData ("sale-datum.json") datum 
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
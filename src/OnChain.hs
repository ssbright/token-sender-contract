--1 Extensions
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE NoImplicitPrelude   #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE DataKinds #-}

--This is to work not only with Strings
{-# LANGUAGE OverloadedStrings   #-}

-- required to use custom data types
{-# LANGUAGE TypeFamilies        #-}
{-# LANGUAGE TypeOperators       #-}
{-# LANGUAGE TypeApplications    #-}

module OnChain where

-- Sections of a Plutus contract


--2 Imports
import PlutusTx
import PlutusTx.Prelude
import qualified Ledger.Address                                  as V1LAddress
import qualified Plutus.V2.Ledger.Api                            as V2LedgerApi
import qualified Plutus.V2.Ledger.Contexts                       as Contexts
import qualified Plutus.Script.Utils.V2.Typed.Scripts.Validators as V2UtilsTypeScripts
import qualified Prelude                                         as P
import qualified Ledger                                          (PaymentPubKeyHash, unPaymentPubKeyHash, AssetClass)
import qualified Plutus.V1.Ledger.Interval                       as LedgerIntervalV1
import qualified Plutus.V1.Ledger.Value                          as LedgerValueV1
import qualified Ledger.Ada                                      as Ada
import qualified Ledger.Tokens
import qualified Data.ByteString.Lazy                            as LBS
import qualified Data.ByteString.Short                           as SBS               
import           Cardano.Api.Shelley                             (PlutusScript (..), FileError, PlutusScriptV2, writeFileTextEnvelope)      
import           Codec.Serialise                                 (serialise)          


--3 Onchain code

data SaleDatum = SaleDatum
    {
        dSeller :: Ledger.PaymentPubKeyHash,
        dTokenID :: Ledger.AssetClass,
        dPrice :: Integer  --changes this to Ada.xxx
    }

data SaleRedeemer = ApplyOrder | CancelOrder

PlutusTx.unstableMakeIsData ''SaleRedeemer -- This is to instantiate the IsData class
PlutusTx.unstableMakeIsData ''SaleDatum


data Simple
instance V2UtilsTypeScripts.ValidatorTypes Simple where
    type instance RedeemerType Simple = SaleRedeemer
    type instance DatumType Simple = SaleDatum


{-# INLINABLE saleValidator #-}
{-# INLINABLE validateReturnTokentoSeller #-}
{-# INLINABLE validateSellToken #-}

--Actual validator logic
saleValidator :: SaleDatum -> SaleRedeemer -> Contexts.ScriptContext -> Bool
saleValidator d r context = 
    case r of
        ApplyOrder -> validateSellToken d context
        CancelOrder -> validateReturnTokentoSeller d context

validateSellToken :: SaleDatum -> Contexts.ScriptContext -> Bool
validateSellToken d context = traceIfFalse "Amount sent less than token price" checkIfPaymentCorrect
    where 
        txinfo :: Contexts.TxInfo
        txinfo = Contexts.scriptContextTxInfo context

        checkIfPaymentCorrect :: Bool
        checkIfPaymentCorrect = 
            let 
                valuepay = Contexts.valuePaidTo txinfo $ Ledger.unPaymentPubKeyHash (dSeller d)
            in 
                LedgerValueV1.gt valuepay (Ada.lovelaceValueOf $ dPrice d)

validateReturnTokentoSeller :: SaleDatum -> Contexts.ScriptContext -> Bool
validateReturnTokentoSeller d context = traceIfFalse "Only the seller can get back the NFT" signedBySeller
    where
        txinfo :: Contexts.TxInfo
        txinfo = Contexts.scriptContextTxInfo context

        signedBySeller :: Bool
        signedBySeller = Contexts.txSignedBy txinfo $ Ledger.unPaymentPubKeyHash (dSeller d)

--Boilerplate
saleTypeV :: V2UtilsTypeScripts.TypedValidator Simple
saleTypeV = V2UtilsTypeScripts.mkTypedValidator @Simple
    $$(compile [|| saleValidator ||])
    $$(compile [|| wrap ||]) where
        wrap = V2UtilsTypeScripts.mkUntypedValidator @SaleDatum @SaleRedeemer

validator :: V2LedgerApi.Validator
validator = V2UtilsTypeScripts.validatorScript saleTypeV

validatorHash :: V2LedgerApi.ValidatorHash
validatorHash = V2UtilsTypeScripts.validatorHash saleTypeV

address :: V1LAddress.Address
address = V1LAddress.scriptHashAddress validatorHash

writeValidator :: P.FilePath -> V2LedgerApi.Validator -> P.IO (Either (FileError ()) ())
writeValidator file = writeFileTextEnvelope @(PlutusScript PlutusScriptV2) file Nothing . PlutusScriptSerialised . SBS.toShort . LBS.toStrict . serialise . V2LedgerApi.unValidatorScript

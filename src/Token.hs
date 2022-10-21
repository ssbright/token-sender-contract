{-# LANGUAGE DataKinds                  #-}
{-# LANGUAGE DeriveAnyClass             #-}
{-# LANGUAGE DeriveGeneric              #-}
{-# LANGUAGE DerivingStrategies         #-}
{-# LANGUAGE FlexibleContexts           #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE LambdaCase                 #-}
{-# LANGUAGE MultiParamTypeClasses      #-}
{-# LANGUAGE NoImplicitPrelude          #-}
{-# LANGUAGE OverloadedStrings          #-}
{-# LANGUAGE RecordWildCards            #-}
{-# LANGUAGE ScopedTypeVariables        #-}
{-# LANGUAGE TemplateHaskell            #-}
{-# LANGUAGE TypeApplications           #-}
{-# LANGUAGE TypeFamilies               #-}
{-# LANGUAGE TypeOperators              #-}
{-# LANGUAGE RankNTypes                 #-}
{-# LANGUAGE TupleSections              #-}
{-# LANGUAGE AllowAmbiguousTypes        #-}
{-# LANGUAGE NumericUnderscores         #-}

module Token where

--Import Externos

import qualified Ledger                              as Ledger (CurrencySymbol)
import qualified Plutus.Script.Utils.V2.Scripts      as UtilsScriptsV2
import qualified Plutus.Script.Utils.V2.Typed.Scripts.MonetaryPolicies as UtilsTypedScriptsMintingV2
import qualified Plutus.V2.Ledger.Api                as LedgerApiV2
import           Plutus.V1.Ledger.Value                (flattenValue)
import qualified Plutus.V2.Ledger.Contexts           as LedgerContextsV2  (ScriptContext, TxInfo)
import qualified PlutusTx
import           PlutusTx.Prelude                    hiding (unless)

{-# INLINABLE mkTokenPolicy #-}
mkTokenPolicy :: LedgerApiV2.TxOutRef -> LedgerApiV2.TokenName -> Integer -> BuiltinData -> LedgerContextsV2.ScriptContext -> Bool
mkTokenPolicy oref tn amt red ctx = traceIfFalse "UTxO not consumed"   hasUTxO           &&
                                   traceIfFalse "wrong amount minted" checkMintedAmount
  where
    info :: LedgerContextsV2.TxInfo
    info = LedgerApiV2.scriptContextTxInfo ctx

    hasUTxO :: Bool
    hasUTxO = any (\i -> LedgerApiV2.txInInfoOutRef i == oref) $ LedgerApiV2.txInfoInputs info

    checkMintedAmount :: Bool
    checkMintedAmount = case flattenValue (LedgerApiV2.txInfoMint info) of
        [(_, tn', amt')] -> tn' == tn && amt' == amt
        _                -> False

policy :: LedgerApiV2.TxOutRef -> LedgerApiV2.TokenName -> Integer -> LedgerApiV2.MintingPolicy
policy oref tn amt = LedgerApiV2.mkMintingPolicyScript $
    $$(PlutusTx.compile [|| \oref' tn' amt' -> fn $ mkTokenPolicy oref' tn' amt' ||])
    `PlutusTx.applyCode`
    PlutusTx.liftCode oref
    `PlutusTx.applyCode`
    PlutusTx.liftCode tn
    `PlutusTx.applyCode`
    PlutusTx.liftCode amt
  where
    fn :: (BuiltinData -> LedgerContextsV2.ScriptContext -> Bool) -> UtilsTypedScriptsMintingV2.UntypedMintingPolicy
    fn = UtilsTypedScriptsMintingV2.mkUntypedMintingPolicy

--curSymbol :: LedgerApiV2.TxOutRef -> LedgerApiV2.TokenName -> Integer -> Ledger.CurrencySymbol
--curSymbol oref tn = UtilsScriptsV2.scriptCurrencySymbol . policy oref tn 

--policyScript :: LedgerApiV2.TxOutRef -> LedgerApiV2.TokenName -> Integer -> LedgerApiV2.Script
--policyScript oref tn = LedgerApiV2.unMintingPolicyScript . policy oref tn

--mintValidator :: LedgerApiV2.TxOutRef -> LedgerApiV2.TokenName -> Integer -> LedgerApiV2.Validator
--mintValidator oref tn = LedgerApiV2.Validator . policyScript oref tn

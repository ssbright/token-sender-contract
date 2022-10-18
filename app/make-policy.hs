import Control.Exception           (throwIO)
import Data.String                 (IsString (..))
import System.Environment          (getArgs)
import Plutus.V1.Ledger.Credential as Plutus
import Plutus.V1.Ledger.Crypto     as Plutus
import qualified Ledger            as Plutus
import Ledger                      (Address, PubKeyHash)
import Ledger.Address              (toPubKeyHash)
import OnChain                     (validaotr, writeValidator)


main :: IO ()
main = do
    [file] <- getArgs 
    let p = validator 
    e <- writeValidator file p 
    case e of 
        Left err -> throwIO $ userError $ show err
        Right () -> return ()
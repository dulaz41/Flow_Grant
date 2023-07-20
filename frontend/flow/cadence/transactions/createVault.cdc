import MyFlowToken from "../contracts/FlowToken.cdc"
import FungibleToken from "../contracts/FungibleToken.cdc"

transaction {

    prepare(acct: AuthAccount) {
        acct.save(<- MyFlowToken.createEmptyVault(), to: /storage/Vault)
        acct.link<&MyFlowToken.Vault{FungibleToken.Balance, FungibleToken.Receiver}>(/public/Vault, target: /storage/Vault)
    }

    execute{
        log("I saved my own personal vault")
    }
}
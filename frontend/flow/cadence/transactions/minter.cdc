import MyFlowToken from "../contracts/FlowToken.cdc"
import FungibleToken from "../contracts/FungibleToken.cdc"

transaction(receiverAccount: Address) {
    prepare(acct: AuthAccount) {
        let minter = acct.borrow<&MyFlowToken.Minter>(from: MyFlowToken.TokenMinterStoragePath)
                                 ?? panic("We could not borrow the Minter resource")
        let newVault <- minter.mintTokens(amount: 20.0)
        
        let receiverVault = getAccount(receiverAccount).getCapability(MyFlowToken.TokenVaultPublicPath)
                                          .borrow<&FungibleToken.Vault{FungibleToken.Receiver}>()
                                          ?? panic("Couldn't get the public Vault")
                                          
        receiverVault.deposit(from: <- newVault)
    }

    execute{
        log("Vault funded")
    }
}
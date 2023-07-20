import FungibleToken from 0x6d9cda4dce6218f2
import FGrant from 0x6d9cda4dce6218f2

transaction (id: UInt64, amount: UFix64) {

    prepare(acct: AuthAccount) {

        let contractRef = getAccount(acct.address).getCapability(Fgrant.FgrantPublicPath)
                        .borrow<&Fgrant.ProposalRes{Fgrant.ProposalPublic}>()
                        ?? panic("Proposal Resourse does not exist")

        let tokenVault = acct.borrow<&FungibleToken.Vault>(from: MyFlowToken.TokenVaultStoragePath)
            ?? panic("Could not borrow FlowToken Vault from storage")

            let vault <- tokenVault.withdraw(amount: amount)
            contractRef.fundProposal(proposalId: id, amount: <-vault)
    }

    execute {
        log("Proposal Funded")
    }
}
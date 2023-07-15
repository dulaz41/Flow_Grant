import FGrant from 0x058eff19c094b6de
import FungibleToken from 0x058eff19c094b6de

transaction {
  prepare(acct: AuthAccount) {
    let balance: UFix64 = 100.0
    let proposal: Fgrant.ProposalDetails = Fgrant.ProposalDetails(
      _id: 1,
      _proposer: acct.address,
      _name: "Sample Proposal",
      _projectName: "Sample Project",
      _coverDescription: "Sample Cover Description",
      _projectDescription: "Sample Project Description",
      _fundingGoal: 1000.0
    )
    
    let tokenCapability: Capability<&{FungibleToken.Receiver}> = acct.getCapability<&FungibleToken.Vault{FungibleToken.Receiver}>(/public/fungibleTokenReceiver)
    let sourceProviderCapability = acct.getCapability<&FungibleToken.Vault{FungibleToken.Provider}>(/public/fungibleTokenProvider)

    let pool: Fgrant.PoolDetails = Fgrant.PoolDetails(
      _id: 1,
      _proposalId: proposal.id,
      _poolCreator: acct.address,
      _amount: 0.0
    )

    let fgrantContract <- Fgrant.createFgrant(balance: balance, proposal: proposal, token: tokenCapability, sourceProvider: sourceProviderCapability, pool: pool)

    acct.save(<-fgrantContract, to: /storage/fgrantContract)

    log("Fgrant contract saved to storage")
  }
}


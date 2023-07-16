import FGrant from 0x058eff19c094b6de
import FungibleToken from 0x058eff19c094b6de

transaction (proposer: Address, name: String, projectName: String, coverDescription: String, projectDescription: String, fundingGoal: UFix64){
  prepare(acct: AuthAccount) {

    let proposalRes = acct.borrow<&Fgrant.ProposalRes>(from: Fgrant.FgrantStoragePath) 
                            ?? panic("Proposal Resourse does not exist")
    
    let proposalID = proposalRes.createProposal(
      proposer: proposer,
      name: name,
      projectName: projectName,
      coverDescription: coverDescription,
      projectDescription: projectDescription,
      fundingGoal: fundingGoal
    )

    log(proposalID)
  }

  execute {
      log("Successfully Created Proposal")
  }
}
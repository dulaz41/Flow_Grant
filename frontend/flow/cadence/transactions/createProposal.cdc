import FGrant from 0x058eff19c094b6de
import FungibleToken from 0x058eff19c094b6de

transaction {
  prepare(signer: AuthAccount) {
    let proposalCreator = signer.address
    let name = "Sample Proposal"
    let projectName = "Project A"
    let coverDescription = "Cover Description"
    let projectDescription = "Project Description"
    let fundingGoal: UFix64 = 100.0

    let capability = signer.getCapability<&Fgrant.ProposalRes>(/public/fgrantProposalRes)
    let proposalRes = capability.borrow() ?? panic("Could not borrow proposal transact reference")

    let proposalID = proposalRes.createProposal(
      proposer: proposalCreator,
      name: name,
      projectName: projectName,
      coverDescription: coverDescription,
      projectDescription: projectDescription,
      fundingGoal: fundingGoal
    )

    log("Proposal created with ID")
  }
}

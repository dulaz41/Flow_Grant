import Fgrant from 0x6d9cda4dce6218f2

    pub fun main(proposalId: UInt64): &Fgrant.ProposalDetails? {
        let contract = getAccount(0x6d9cda4dce6218f2).getCapability(/public/FgrantPublicP).borrow<&Fgrant.ProposalRes{Fgrant.ProposalPublic}>()!
        return contract.getProposalById(proposalId: proposalId)
    }
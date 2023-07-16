 import Fgrant from 0x6d9cda4dce6218f2

    pub fun main(): [Fgrant.ProposalDetails] {
        let propose = getAccount(0x6d9cda4dce6218f2).getCapability(/public/FgrantPublicP).borrow<&Fgrant.ProposalRes{Fgrant.ProposalPublic}>()!
        return [propose.getProposals()]
    }
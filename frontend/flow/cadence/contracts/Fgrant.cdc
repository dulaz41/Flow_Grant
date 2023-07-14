import FungibleToken from 0x058eff19c094b6de

pub contract Fgrant {

    pub var proposals: {UInt64: ProposalDetails}
    pub var proposalCounter: UInt64

    pub var pools: {UInt64: [PoolDetails]}
    pub var poolCounter: UInt64

    pub event ProposalCreated(
        from: Address?, name: String, projectName: String, description: String, amount: UFix64
    )

    pub event ProposalFunded(
       id: UInt64, acct: Address?, amount: UFix64
    )

    pub event ProposalFundingCompleted(
       id: UInt64
    )

    pub event PoolCreated(
        id: UInt64, acct: Address?, amount: UFix64
    )

    pub event PoolFundingCompleted(
        id: UInt64, acct: Address?
    )

    pub event ProposalFundsWithdrawn(
        id: UInt64, from: Address?, amount: UFix64
    )
    pub event FundsWithdrawn(
        from: Address?, amount: UFix64
    )

    pub struct ProposalDetails {
        pub(set) var id: UInt64
        pub var proposer: Address?
        pub var name: String
        pub var projectName: String
        pub var coverDescription: String
        pub var projectDescription: String
        pub var fundingGoal: UFix64
        pub(set) var totalFunds: UFix64
        pub(set) var fundingCompleted: Bool
        pub(set) var funder: [Address?]

        init(id: UInt64,proposer: Address?, name: String, projectName: String, coverDescription : String, projectDescription: String, fundingGoal: UFix64){
            self.id = id
            self.proposer = proposer
            self.name = name
            self.projectName = projectName
            self.coverDescription = coverDescription
            self.projectDescription = projectDescription
            self.fundingGoal = fundingGoal
            self.totalFunds = 0.0
            self.fundingCompleted = false
            self.funder = []
        }
    }

    pub struct PoolDetails {
        pub var id: UInt64
        pub var proposalId: UInt64
        pub(set) var poolCreator: Address
        pub(set) var amount: UFix64

        init(id: UInt64, proposalId: UInt64, creator: Address, amount: UFix64) {
            self.id = id
            self.proposalId = proposalId
            self.poolCreator = creator
            self.amount = amount
        }
    }

    pub resource interface ProposalTransact {
       access(contract) fun createProposal(_proposer: Address, _name: String, _projectName: String, _coverDescription: String, _projectDescription: String, _fundingGoal: UFix64): UInt64
       pub fun fundProposal(proposalID: UInt64, amount: @FungibleToken.Vault)
       pub fun withdrawProposalFund(id: UInt64)
       pub fun getProposals(): ProposalDetails
    }
    
    pub resource ProposalRes: ProposalTransact {
        //pub var balance: UFix64
        access(self) var proposal: ProposalDetails
        access(contract) var token: Capability<&{FungibleToken.Receiver}>
        access(self) var pool: PoolDetails


        init(proposal: ProposalDetails, token: Capability<&{FungibleToken.Receiver}>, pool: PoolDetails/*, balance: UFix64*/){
           //self.balance = balance
            self.proposal = proposal
            self.token = token
            self.pool = pool
        }

        access(contract) fun createProposal(_proposer: Address, _name: String, _projectName: String, _coverDescription: String, _projectDescription: String, _fundingGoal: UFix64): UInt64  {
            Fgrant.proposalCounter = Fgrant.proposalCounter + 1
            self.proposal.id = Fgrant.proposalCounter

            self.proposal = ProposalDetails(id: self.proposal.id, proposer: _proposer, name: _name, projectName: _projectName, coverDescription: _coverDescription, projectDescription: _projectDescription, fundingGoal: _fundingGoal)
            let propose = self.proposal
            return propose.id
        }

        pub fun fundProposal(proposalID: UInt64, amount: @FungibleToken.Vault){
            
            if self.proposal.id != proposalID { 
                panic("Invalid proposal ID")
            }
            if !self.proposal.fundingCompleted { 
                panic("Project funding is already completed")
            }
            let vaultRef = self.token.borrow() ?? panic("could not borrow reference to owner token vault")
            vaultRef.deposit(from: <- amount)
            
            self.proposal.totalFunds = self.proposal.totalFunds
            self.proposal.funder.append(self.owner!.address)
            if self.proposal.totalFunds >= self.proposal.fundingGoal {
                self.proposal.fundingCompleted = true
            }
            
        }

        pub fun withdrawProposalFund(id: UInt64) {
            
            // Only the proposer can withdraw funds
            pre {
                self.proposal.proposer == self.owner?.address:
                    "Only the proposer can withdraw funds"
                    // Can only withdraw when funding is completed
                self.proposal.fundingCompleted:
                    "Funding goal must be completed to withdraw funds"
            }
            let amount = self.proposal.totalFunds
            // Withdraw funds from the contract's vault
            //let withdrawnVault <- self.proposal.proposer?.withdraw(amount: amount)
            //vault.deposit(from: <-withdrawnVault)
            // Emit event
            emit ProposalFundsWithdrawn(id: id, from: self.proposal.proposer, amount: amount)

            // Reset proposal data
            self.proposal.totalFunds = 0.0
            self.proposal.fundingCompleted = false
             
        }


        pub fun createPool(proposalId: UInt64, amount: @FungibleToken.Vault):  UInt64 {
            // Check if the proposal exists
            if self.proposal.id != proposalId { 
                 panic("Invalid proposal ID")
            }

            Fgrant.poolCounter = Fgrant.poolCounter + 1
            let poolID = Fgrant.poolCounter
            let vaultRef = self.token.borrow() ?? panic("could not borrow reference to owner token vault")
            vaultRef.deposit(from: <- amount)
            //self.pool = PoolDetails(id: poolID, proposalId: proposalId, creator: self.owner!.address, amount: amount.balance)
            return poolID
        }

        /*pub fun fundPool(proposalID: UInt64, amount: UFix64) {
            
            self.pool.amount = self.pool.amount + amount
        }*/

        pub fun getProposals(): ProposalDetails {
            return self.proposal
        }

        pub fun getProposal(proposalId: UInt64): &ProposalDetails? {
            return &Fgrant.proposals[proposalId] as &ProposalDetails?
        }

        
    }
    
    pub fun createEmptyVault(proposal:ProposalDetails, token: Capability<&{FungibleToken.Receiver}>, pool: PoolDetails): @Fgrant.ProposalRes {
        return <- create ProposalRes(proposal: proposal, token: token, pool: pool )
    }

    init() {
        self.proposals = {}
        self.proposalCounter = 0
        self.pools = {}
        self.poolCounter = 0
    }
}
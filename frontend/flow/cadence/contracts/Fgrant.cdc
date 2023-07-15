import FungibleToken from 0x01
//import FlowToken from 0x01

pub contract Fgrant {

    pub var proposals: {UInt64: ProposalDetails}
    pub var proposalCounter: UInt64

    pub var pools: {UInt64: PoolDetails}
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
        poolID: UInt64, proposalId: UInt64, from: Address?, amount: UFix64
    )

    pub event PoolFundingCompleted(
        id: UInt64, from: Address?
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

        init(_id: UInt64, _proposer: Address?, _name: String, _projectName: String, _coverDescription : String, _projectDescription: String, _fundingGoal: UFix64){
            self.id = _id
            self.proposer = _proposer
            self.name = _name
            self.projectName = _projectName
            self.coverDescription = _coverDescription
            self.projectDescription = _projectDescription
            self.fundingGoal = _fundingGoal
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

        init(_id: UInt64, _proposalId: UInt64, _poolCreator: Address, _amount: UFix64) {
            self.id = _id
            self.proposalId = _proposalId
            self.poolCreator = _poolCreator
            self.amount = _amount
        }
    }

    pub resource interface ProposalTransact {
       access(contract) fun createProposal(proposer: Address, name: String, projectName: String, coverDescription: String, projectDescription: String, fundingGoal: UFix64): UInt64
       pub fun fundProposal(proposalId: UInt64, amount: @FungibleToken.Vault)
       pub fun withdrawProposalFund(id: UInt64): @FungibleToken.Vault
       pub fun getProposals(): ProposalDetails
    }
    
    pub resource ProposalRes: ProposalTransact {
        pub var balance: UFix64
        pub var withdrawn: UFix64
        access(self) var proposal: ProposalDetails
        pub let token: Capability<&{FungibleToken.Receiver}>
        pub let sourceProvider: Capability<&{FungibleToken.Provider}>
        access(self) var pool: PoolDetails

        init(_balance: UFix64,_proposal: ProposalDetails, _token: Capability<&{FungibleToken.Receiver}>, _sourceProvider: Capability<&{FungibleToken.Provider}>, _pool: PoolDetails){
            pre {
                _sourceProvider.check(): "Problem with given Provider Capability!"
            }
            self.withdrawn = 0.0
            self.balance = _balance
            self.proposal = _proposal
            self.token = _token
            self.sourceProvider = _sourceProvider
            self.pool = _pool
        }

        access(all) fun createProposal(proposer: Address, name: String, projectName: String, coverDescription: String, projectDescription: String, fundingGoal: UFix64): UInt64  {
            Fgrant.proposalCounter = Fgrant.proposalCounter + 1
            self.proposal.id = Fgrant.proposalCounter

            self.proposal = ProposalDetails(_id: self.proposal.id, _proposer: self.owner!.address, _name: name, _projectName: projectName, _coverDescription: coverDescription, _projectDescription: projectDescription, _fundingGoal: fundingGoal)
            let propose = self.proposal
            emit ProposalCreated(from: proposer, name: name, projectName: projectName, description: coverDescription, amount: fundingGoal)
            return propose.id
        }

        pub fun fundProposal(proposalId: UInt64, amount: @FungibleToken.Vault){
            
            if self.proposal.id != proposalId { 
                panic("Invalid proposal ID")
            }
            if self.proposal.fundingCompleted { 
                panic("Project funding is already completed")
            }

            /*if (Fgrant.proposals[proposalId]?.funder.length > 0) ||
                Fgrant.proposals[proposalId]?.funder[0] == self.owner!.address{
            panic("Proposal can only be funded by the initial funder")
            }*/
            
            let vaultRef = self.token.borrow() ?? panic("could not borrow reference to owner token vault")
            let balance = amount.balance
            vaultRef.deposit(from: <- amount)
            
            self.proposal.totalFunds = self.proposal.totalFunds + balance
            self.proposal.funder.append(self.owner!.address)
            if self.proposal.totalFunds >= self.proposal.fundingGoal {
                self.proposal.fundingCompleted = true
                emit ProposalFundingCompleted(id: proposalId)
            }
            emit ProposalFunded(id: proposalId, acct: self.owner!.address, amount: balance)
        }

        pub fun createPool(proposalId: UInt64, amount: @FungibleToken.Vault){
            Fgrant.poolCounter = Fgrant.poolCounter + 1
            let poolID = Fgrant.poolCounter
            // Check if the proposal exists
            if self.proposal.id != proposalId { 
                 panic("Invalid proposal ID")
            }
            // Check if funding is completed
            if self.proposal.fundingCompleted { 
                panic("Project funding is already completed")
            }
            
            if !(amount.balance > 0.0) { 
                panic("Invalid contribution amount")
            }
            let balance = amount.balance
            let vaultRef = self.token.borrow() ?? panic("Insufficient funds")
            vaultRef.deposit(from: <- amount)
            self.pool = PoolDetails(_id: poolID, _proposalId: proposalId, _poolCreator: self.owner!.address, _amount: balance)
            emit PoolCreated(poolID: poolID, proposalId: proposalId , from: self.owner!.address, amount: balance)
        }

        pub fun fundPool(poolId: UInt64, amount: @FungibleToken.Vault) {
            if self.pool.id != poolId { 
                 panic("Invalid Pool ID")
            }
            // Check if funding is completed
            if self.proposal.fundingCompleted { 
                panic("Project funding has already been completed for this pool")
            }
            let vaultRef = self.token.borrow() ?? panic("Insufficient funds")
            let balance = amount.balance
            vaultRef.deposit(from: <- amount)
            self.pool.amount = self.pool.amount + balance
            if self.proposal.totalFunds >= self.proposal.fundingGoal {
                self.proposal.fundingCompleted = true
                emit  PoolFundingCompleted(id: poolId, from: self.owner!.address)
            }
        }

        pub fun withdrawProposalFund(id: UInt64): @FungibleToken.Vault {
            // Only the proposer can withdraw funds
            pre {
                self.proposal.proposer == self.owner?.address:
                    "Only the proposer can withdraw funds"
                    // Can only withdraw when funding is completed
                self.proposal.fundingCompleted:
                    "Funding goal must be completed to withdraw funds"
            }
            let amount = self.proposal.totalFunds
            let sourceProviderRef = self.sourceProvider.borrow()!
            emit ProposalFundsWithdrawn(id: id, from: self.proposal.proposer, amount: amount)
            // Reset proposal data
            self.proposal.totalFunds = 0.0
            self.proposal.fundingCompleted = false 
             return <-sourceProviderRef.withdraw(amount: amount)
        }

        pub fun withdraw(amount: UFix64): @FungibleToken.Vault {
            self.withdrawn = self.withdrawn + amount
            // Get a reference to the Provider given on init
            let sourceProviderRef = self.sourceProvider.borrow()!
            return <-sourceProviderRef.withdraw(amount: amount)
        }

        pub fun getProposals(): ProposalDetails {
            return self.proposal
        }

        pub fun getProposalById(proposalId: UInt64): &ProposalDetails? {
            return &Fgrant.proposals[proposalId] as &ProposalDetails?
        }

        pub fun getPool(poolId: UInt64): &PoolDetails? {
            return &Fgrant.pools[poolId] as &PoolDetails?
        }
    }
    
    pub fun createFgrant(balance: UFix64,proposal:ProposalDetails, token: Capability<&{FungibleToken.Receiver}>, sourceProvider: Capability<&{FungibleToken.Provider}>, pool: PoolDetails): @Fgrant.ProposalRes {
        return <- create ProposalRes(_balance: balance,_proposal: proposal, _token: token, _sourceProvider: sourceProvider ,_pool: pool )
    }

    init() {
        self.proposals = {}
        self.proposalCounter = 0
        self.pools = {}
        self.poolCounter = 0
    }
}
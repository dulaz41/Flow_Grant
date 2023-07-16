import FungibleToken from 0x6d9cda4dce6218f2
import MyFlowToken from 0x6d9cda4dce6218f2

pub contract Fgrant {

    pub let FgrantPublicPath:PublicPath  
    pub let FgrantPrivatePath:PrivatePath
    pub let FgrantStoragePath:StoragePath

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

    pub event ContractInitialized()

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

    pub resource interface ProposalPublic {
       access(all) fun createProposal(proposer: Address, name: String, projectName: String, coverDescription: String, projectDescription: String, fundingGoal: UFix64): UInt64
       pub fun fundProposal(proposalId: UInt64, amount: @FungibleToken.Vault)
       pub fun createPool(proposalId: UInt64, amount: @FungibleToken.Vault)
       pub fun fundPool(poolId: UInt64, amount: @FungibleToken.Vault)
       pub fun withdrawProposalFund(id: UInt64): @FungibleToken.Vault
       pub fun getProposals(): ProposalDetails
       pub fun getProposalById(proposalId: UInt64): &ProposalDetails?
       pub fun getPool(poolId: UInt64): &PoolDetails?
    }
    
    pub resource interface ProposalPrivate {
       pub fun withdraw(receiver:Capability<&{FungibleToken.Receiver}>,amount:UFix64)
    }

    pub resource ProposalRes: ProposalPublic, ProposalPrivate {
        pub var balance: UFix64
        pub var withdrawn: UFix64
        access(self) var proposal: ProposalDetails
        pub let token: @FungibleToken.Vault
        access(self) var pool: PoolDetails

        init(_proposal: ProposalDetails, _token:@FungibleToken.Vault , _pool: PoolDetails){
            self.withdrawn = 0.0
            self.balance = 0.0
            self.proposal = _proposal
            self.token <- _token
            self.pool = _pool
        }
        destroy() {
            destroy  self.token
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
            if (Fgrant.proposals[proposalId]!.funder.length > 0) ||
                Fgrant.proposals[proposalId]!.funder[0] == self.owner!.address{
                panic("Proposal can only be funded by the initial funder")
            }
            
            let balance = amount.balance
            self.token.deposit(from: <- amount)
            
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
            if self.proposal.id != proposalId { 
                 panic("Invalid proposal ID")
            }
            if self.proposal.fundingCompleted { 
                panic("Project funding is already completed")
            }
            
            if !(amount.balance > 0.0) { 
                panic("Invalid contribution amount")
            }
            let balance = amount.balance
            self.token.deposit(from: <- amount)
            self.pool = PoolDetails(_id: poolID, _proposalId: proposalId, _poolCreator: self.owner!.address, _amount: balance)
            emit PoolCreated(poolID: poolID, proposalId: proposalId , from: self.owner!.address, amount: balance)
        }

        pub fun fundPool(poolId: UInt64, amount: @FungibleToken.Vault) {
            if self.pool.id != poolId { 
                 panic("Invalid Pool ID")
            }
            if self.proposal.fundingCompleted { 
                panic("Project funding has already been completed for this pool")
            }
            let balance = amount.balance
            self.token.deposit(from: <- amount)
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
                self.proposal.fundingCompleted:
                    "Funding goal must be completed to withdraw funds"
            }
            let withdrawalAmount = self.proposal.fundingGoal - self.proposal.totalFunds
            if withdrawalAmount > 0.0 {
                panic("No funds available for withdrawal")
            }
            let amount = self.proposal.totalFunds
            self.withdrawn = self.withdrawn + amount
            emit ProposalFundsWithdrawn(id: id, from: self.proposal.proposer, amount: amount)
            // Reset proposal data
            self.proposal.totalFunds = 0.0
            self.proposal.fundingCompleted = false 
            return <-self.token.withdraw(amount: amount)
        }

        pub fun withdraw(receiver:Capability<&{FungibleToken.Receiver}>,amount:UFix64){
            let vault = receiver.borrow()!
            vault.deposit(from: <- self.token.withdraw(amount: amount))
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

    init() {
        self.proposals = {}
        self.proposalCounter = 0
        self.pools = {}
        self.poolCounter = 0

    let dummyProposal = ProposalDetails(
        _id: 1,
        _proposer: self.account.address,
        _name: "Dummy Proposal",
        _projectName: "Dummy Project",
        _coverDescription: "Dummy Cover Description",
        _projectDescription: "Dummy Project Description",
        _fundingGoal: 100.0
    )
    self.proposals[1] = dummyProposal
    self.proposalCounter = 1

    let dummyPool = PoolDetails(
        _id: 1,
        _proposalId: 1,
        _poolCreator: self.account.address,
        _amount: 50.0
    )
    self.pools[1] = dummyPool
    self.poolCounter = 1

    self.FgrantStoragePath = /storage/FgrantStorageP
    self.FgrantPrivatePath = /private/FgrantPrivateP
    self.FgrantPublicPath = /public/FgrantPublicP

    let vault <- MyFlowToken.createEmptyVault()

    if self.proposalCounter > 0 && self.poolCounter > 0 {
        let proposal = self.proposals[self.proposalCounter]
        let pool = self.pools[self.poolCounter]

        if proposal != nil && pool != nil {
            let fgrant <- create ProposalRes(_proposal: proposal!, _token: <-vault, _pool: pool!)
            self.account.save(<-fgrant, to: self.FgrantStoragePath)
            self.account.link<&Fgrant.ProposalRes{Fgrant.ProposalPublic}>(Fgrant.FgrantPublicPath, target: self.FgrantStoragePath)
            self.account.link<&Fgrant.ProposalRes{Fgrant.ProposalPrivate}>(Fgrant.FgrantPrivatePath, target: self.FgrantStoragePath)
            emit ContractInitialized()
        } else {
            panic("Invalid proposal or pool. Please make sure they exist in the dictionaries.")
        }
    } else {
        panic("No valid proposals or pools found. Please add data to the dictionaries before initializing the contract.")
    }
    }
}
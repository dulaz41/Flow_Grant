//import FlowToken from "./FlowToken.cdc"

pub contract FGrant/*: FlowToken*/ {

    pub var proposals: @{Address: Proposal}
    pub var proposalCounter: UInt64

    pub var pools: @{Address: [Pool]}
    pub var poolCounter: UInt64

    pub var owner: Address

    pub struct ProjectProposal {
        pub var proposer: Address
        pub var name: String
        pub var projectName: String
        pub var coverDescription: String
        pub var projectDescription: String
        pub var fundingGoal: UFix64
        pub var totalFunds: UFix64
        pub var fundingCompleted: Bool
        pub var funders: [Address]

        init(proposer: Address, name: String, projectName: String, coverDescription : String, projectDescription: String, fundingGoal: UFix64){
            self.proposer = proposer
            self.name = name
            self.projectName = projectName
            self.coverDescription = coverDescription
            self.projectDescription = projectDescription
            self.fundingGoal = fundingGoal
            self.totalFunds = 0.0
            self.fundingCompleted = false
            self.funders = []
        }
    }

    pub struct ProjectPool {
        pub var poolCreator: Address
        pub var amount: UFix64

        init(creator: Address, amount: UFix64){
            self.poolCreator = creator
            self.amount = amount
        }
    }

    pub resource Proposal {
        pub var proposal: ProjectProposal
        init(_proposer: Address, _name: String, _projectName: String, _coverDescription: String, _projectDescription: String, _fundingGoal: UFix64){
            self.proposal = ProjectProposal(proposer: _proposer, name: _name, projectName: _projectName, coverDescription: _coverDescription, projectDescription: _projectDescription, fundingGoal: _fundingGoal)
        }
    }

    pub resource Pool {
        pub var pool: ProjectPool
        init(_creator: Address, _amount: UFix64){
            self.pool = ProjectPool(creator: _creator, amount: _amount)
        }
    }

    pub event ProposalCreated(
        acct: Address?, name: String, projectName: String, description: String, amount: UFix64
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

    init() {
        self.proposals <- {}
        self.proposalCounter = 0
        self.pools <- {}
        self.poolCounter = 0
        self.owner = Address(0x01)
    }

    pub fun createProposal(_proposer: Address, _name: String, _projectName: String, _coverDescription: String, _projectDescription: String, _fundingGoal: UFix64): @Proposal {
        self.proposalCounter = self.proposalCounter + 1

        self.proposals[_proposer] <-! create Proposal(_proposer: _proposer, _name: _name, _projectName: _projectName, _coverDescription: _coverDescription, _projectDescription: _projectDescription, _fundingGoal: _fundingGoal)

        let proposal <- create Proposal(_proposer: _proposer, _name: _name, _projectName: _projectName, _coverDescription: _coverDescription, _projectDescription: _projectDescription, _fundingGoal: _fundingGoal)

        emit ProposalCreated(from: _proposer, name: _name, projectName: _projectName, description: _projectDescription, amount: _fundingGoal)

        return <- proposal
    }

    pub fun getProposer(proposerAddress: Address): &Proposal? {
        return &self.proposals[proposerAddress] as &Proposal?
    }

    pub fun getProposers(): [&Proposal] {
        let propose: [&Proposal] = []
        for proposerAddress in self.proposals.keys {
            propose.append(self.getProposer(proposerAddress: proposerAddress)!)
        }
        return propose
    }
}
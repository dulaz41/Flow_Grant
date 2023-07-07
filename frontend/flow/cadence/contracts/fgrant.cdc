import FlowToken from FungibleToken

// Define the Grant contract
pub contract Grant {

    // Proposal structure
    pub struct Proposal {
        pub var proposer: Address
        pub var name: String
        pub var project: String
        pub var description: String
        pub var totalFunds: UFix64
        pub var fundingGoal: UFix64
        pub var fundingCompleted: Bool
        pub var pooledFunds: @{Address: UFix64}
        pub var createdPools: @{UFix64: Bool}
        pub var owners: @{Address: Bool}
        pub var funders: [Address]
    }

    // Store the proposals in an array
    pub var proposals: [Proposal]
    // Counter for proposal IDs
    pub var proposalCounter: UInt64

    // Event emitted when a proposal is created
    pub event ProposalCreated(
        proposer: Address,
        name: String,
        project: String,
        description: String,
        fundingGoal: UFix64
    )

    // Event emitted when a proposal is funded
    pub event ProposalFunded(
        proposalId: UInt64,
        funder: Address,
        amount: UFix64
    )

    // Event emitted when funding for a proposal is completed
    pub event ProposalFundingCompleted(
        proposalId: UInt64
    )

    // Event emitted when a pool is created
    pub event PoolCreated(
        proposalId: UInt64,
        poolCreator: Address,
        amount: UFix64
    )

    // Event emitted when funding for a pool is completed
    pub event PoolFundingCompleted(
        proposalId: UInt64,
        poolCreator: Address
    )

    // Event emitted when proposal funds are withdrawn
    pub event ProposalFundsWithdrawn(
        proposalId: UInt64,
        proposalCreator: Address,
        withdrawalAmount: UFix64
    )

    // Create a proposal
    pub fun createProposal(
        name: String,
        project: String,
        description: String,
        fundingGoal: UFix64
    ) {
        let proposal = Proposal(
            proposer: getAccount(Address(flow.ServiceAddress)),
            name: name,
            project: project,
            description: description,
            totalFunds: UFix64(0),
            fundingGoal: fundingGoal,
            fundingCompleted: false,
            pooledFunds: {},
            createdPools: {},
            owners: {},
            funders: []
        )

        proposals.append(proposal)
        emit ProposalCreated(
            proposer: proposal.proposer,
            name: name,
            project: project,
            description: description,
            fundingGoal: fundingGoal
        )
    }

    // Fund a proposal
    pub fun fundProposal(
        proposalId: UInt64,
        amount: UFix64
    ) {
        let proposal = &proposals[proposalId]
        assert(!proposal.fundingCompleted, message: "Project funding is already completed")
        assert(proposal.funders.isEmpty || proposal.funders[0] == getAccount(Address(flow.ServiceAddress)),
            message: "Proposal can only be funded by the initial funder")

        FlowToken.deposit(from: <-FlowToken.getTokenHolder(), amount: <-FlowToken.balance, recipient: self)

        proposal.totalFunds += amount
        proposal.funders.append(getAccount(Address(flow.ServiceAddress)))

        emit ProposalFunded(
            proposalId: proposalId,
            funder:

        getAccount(Address(flow.ServiceAddress)),
            amount: amount
        )

        if proposal.totalFunds >= proposal.fundingGoal {
            proposal.fundingCompleted = true
            emit ProposalFundingCompleted(proposalId: proposalId)
        }
    }

    // Create a pool within a proposal
    pub fun createPool(
        proposalId: UInt64,
        amount: UFix64
    ) {
        let proposal = &proposals[proposalId]
        assert(!proposal.fundingCompleted, message: "Project funding is already completed")
        assert(!proposal.createdPools[proposalId], message: "Pool already created for this proposal")

        FlowToken.deposit(from: <-FlowToken.getTokenHolder(), amount: <-FlowToken.balance, recipient: self)

        proposal.pooledFunds[getAccount(Address(flow.ServiceAddress))] = amount
        proposal.funders.append(getAccount(Address(flow.ServiceAddress)))
        proposal.createdPools[proposalId] = true

        if !proposal.fundingCompleted && proposal.totalFunds + amount >= proposal.fundingGoal {
            proposal.fundingCompleted = true
            emit ProposalFundingCompleted(proposalId: proposalId)
        }

        emit PoolCreated(
            proposalId: proposalId,
            poolCreator: getAccount(Address(flow.ServiceAddress)),
            amount: amount
        )
    }

    // Fund a pool within a proposal
    pub fun fundPool(
        proposalId: UInt64,
        amount: UFix64
    ) {
        let proposal = &proposals[proposalId]
        assert(!proposal.fundingCompleted, message: "Project funding has been completed")
        assert(proposal.createdPools[proposalId], message: "No pool exists for this proposal")

        FlowToken.deposit(from: <-FlowToken.getTokenHolder(), amount: <-FlowToken.balance, recipient: self)

        proposal.totalFunds += amount
        proposal.pooledFunds[getAccount(Address(flow.ServiceAddress))] += amount
        proposal.funders.append(getAccount(Address(flow.ServiceAddress)))

        emit ProposalFunded(
            proposalId: proposalId,
            funder: getAccount(Address(flow.ServiceAddress)),
            amount: amount
        )
    }

    // Withdraw proposal funds by the proposal creator
    pub fun withdrawProposalFunds(
        proposalId: UInt64
    ) {
        let proposal = &proposals[proposalId]
        assert(getAccount(Address(flow.ServiceAddress)) == proposal.proposer,
            message: "Only the proposal creator can withdraw funds")
        assert(proposal.fundingCompleted, message: "Project funding is not completed")

        let withdrawalAmount = proposal.fundingGoal - proposal.totalFunds
        assert(withdrawalAmount > 0, message: "No funds available for withdrawal")

        FlowToken.withdraw(from: self, amount: withdrawalAmount, recipient: <-FlowToken.getTokenHolder())

        emit ProposalFundsWithdrawn(
            proposalId: proposalId,
            proposalCreator: getAccount(Address(flow.ServiceAddress)),
            withdrawalAmount: withdrawalAmount
        )
    }

    // Withdraw funds by the contract owner
    pub fun withdrawFunds(
        amount: UFix64
    ) {
        assert(getAccount(Address(flow.ServiceAddress)) == getAccount(Address(flow.ServiceAddress)),
            message: "Only the contract owner can withdraw funds")

        FlowToken.withdraw(from: self, amount: amount, recipient: <-FlowToken.getTokenHolder())
    }
}
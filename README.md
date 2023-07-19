# Flow Grant - Decentralized Funding Platform

### Table of Contents

1. Introduction
2. Contract Overview
3. Smart Contract Logic
4. Smart Contract Interfaces
5. Code Usage and Interaction
6. Frontend - React and TypeScript
7. Backend - AWS S3
8. How to Deploy the Contract
9. Known Issues and Limitations
10. Acknowledgements
11. Deployed Link

### 1. Introduction

Flow Grant is a decentralized funding platform built on the Flow blockchain. The main purpose of this smart contract is to allow users to propose projects and receive funding from the community. It facilitates the creation of funding pools where users can contribute their tokens to support specific projects.

The contract is written in Cadence, the resource-oriented programming language used in the Flow blockchain. It leverages Flow's built-in FungibleToken and FlowToken contracts for handling token transfers.

### 2. Contract Overview

The Flow Grant contract consists of three main parts:

- ProposalDetails struct: This defines the data structure for a project proposal, including details like the proposer's address, project name, description, funding goal, and the total funds raised so far.
- PoolDetails struct: This defines the data structure for a funding pool, including details like the pool ID, associated proposal ID, pool creator's address, and the total amount contributed to the pool.
- Proposal(Res) Resource: This resource contains the main logic for the Fgrant contract. It implements the ProposalPublic and ProposalPrivate interfaces, providing functions for creating proposals, funding proposals, creating funding pools, contributing to pools, and withdrawing funds.

### 3. Smart Contract Logic

The Flow Grant contract allows users to perform the following actions:

- Create Proposal: Users can propose a new project by providing relevant details such as project name, description, funding goal, etc. A unique proposal ID is generated, and the proposal is added to the proposals dictionary.
- Fund Proposal: Users can contribute tokens to a specific proposal. The contract ensures that a proposal can only be funded once and by someone other than the proposer. When the funding goal is met, the fundingCompleted flag is set to true.
- Create Pool: Users can create a funding pool associated with a particular proposal. The pool allows users to contribute to the project without directly funding the proposal. The contract verifies that funding is not already completed for the associated proposal.
- Fund Pool: Users can contribute tokens to a specific funding pool. The contract ensures that the funding is not already completed for the associated proposal.
- Withdraw Proposal Funds: Only the proposer can withdraw the funds raised for their proposal once the funding goal is met. The total funds are transferred to the proposer's account.
- Withdraw: This function allows users to withdraw their remaining funds from the contract.

### 4. Smart Contract Interfaces

The Flow Grant contract exposes two resource interfaces: ProposalPublic and ProposalPrivate.

ProposalPublic Interface:

- createProposal: Allows users to propose a new project.
- fundProposal: Allows users to contribute tokens to a proposal.
- createPool: Allows users to create a funding pool.
- fundPool: Allows users to contribute tokens to a funding pool.
- withdrawProposalFund: Allows the proposer to withdraw the funds once the funding goal is met.
- getProposals: Returns the details of the current proposal.

ProposalPrivate Interface:

- withdraw: Allows users to withdraw their remaining funds from the contract.

### 5. Code Usage and Interaction

To interact with the Flow Grant contract, users need to have access to the contract's resource interfaces: ProposalPublic and ProposalPrivate.

For example, a proposer can create a new project proposal as follows:

```cadence
import FGrant from 0x6d9cda4dce6218f2;
import FungibleToken from 0x6d9cda4dce6218f2;

transaction (proposer: Address, name: String, projectName: String, coverDescription: String, projectDescription: String, fundingGoal: UFix64) {
  prepare(acct: AuthAccount) {

    let proposalRes = acct.borrow<&Fgrant.ProposalRes>(from: Fgrant.FgrantStoragePath)
                            ?? panic("Proposal Resource does not exist");

    let proposalID = proposalRes.createProposal(
      proposer: proposer,
      name: name,
      projectName: projectName,
      coverDescription: coverDescription,
      projectDescription: projectDescription,
      fundingGoal: fundingGoal
    );

    log(proposalID);
  }

  execute {
      log("Successfully Created Proposal");
  }
}
```

### 6. Frontend - React and TypeScript

The Flow Grant frontend is built using React and TypeScript to provide a user-friendly interface for interacting with the smart contract.

### 7. Backend - AWS S3

The backend Flow Grant utilizes AWS S3 to save user profile data securely.

### 8. How to Deploy the Contract

To deploy the Flow Grant contract on the Flow blockchain, you need to use the Flow CLI or a development tool like VSCode with the Cadence extension.

Install the Flow CLI: Follow the official Flow documentation to install the Flow CLI on your machine.

Configure the Flow Project: Set up a new Flow project or use an existing project to deploy the Fgrant contract.

Write the Contract Code: Copy the Fgrant contract code into a new Cadence file (e.g., Fgrant.cdc).

Deploy the Contract: Use the Flow CLI to deploy the contract to the Flow blockchain.

### 9. Known Issues and Limitations

- The contract doesn't implement a mechanism for validating projects or performing background checks on proposers. Users are advised to conduct due diligence before contributing to any proposals.
- This is a minimum viable product (MVP), and additional features and validations will be added moving on.

### 10. Acknowledgements

The Flow Grant contract was inspired by various crowdfunding platforms.

### 11. Deployed Link

[Flow Grant](https://flow-view-source.com/testnet/account/0x6d9cda4dce6218f2/contract/Fgrant)

Deploying 3 contracts for accounts: my-testnet-account

Fgrant -> 0x6d9cda4dce6218f2 (93bf223deeda3d8a9883f8554e79e7b5b5e7c3290364d4f0bd9c6406bc2bbc64)
FungibleToken -> 0x6d9cda4dce6218f2 [skipping, no changes found]
FlowToken -> 0x6d9cda4dce6218f2 [skipping, no changes found]

🎉 All contracts deployed successfully

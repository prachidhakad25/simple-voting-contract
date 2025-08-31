Decentralized Voting System

A secure and transparent voting smart contract built on the Ethereum blockchain using Solidity. This project enables a decentralized election process where an admin can manage candidates, register voters, and allow them to cast votes securely.

Features

Add candidates by the admin
Register voters by the admin
Start or stop the voting session
Cast votes securely with one vote per registered voter
View candidates and their vote counts
Display election statistics and results
List all registered voters and their voting status for admin

Smart Contract Details

Language: Solidity ^0.8.19
License: MIT
Contract Name: Project
Author: Your Name

Functions Overview
Admin Functions

addCandidate(string _name) → Add a new candidate when voting is closed
registerVoter(address _voter) → Register a voter for the election
toggleVoting() → Start or stop the voting process
getAllVoters() → View all registered voters and their voting status

Voter Functions

vote(uint256 _candidateId) → Cast a vote for a candidate only once

View Functions

getCandidate(uint256 _candidateId) → Get candidate details including ID, name, and votes
getResults() → Get the winning candidate and vote count
getVoterInfo(address _voter) → Check if a voter is registered and whether they have voted
getElectionStats() → Get election name, total votes, candidate count, and voting status
getAllCandidates() → Get all candidates and their vote counts

Deployment and Usage
Prerequisites

Install Node.js and npm
Install Hardhat or Truffle
Install MetaMask for testing

Steps

Clone this repository:

git clone https://github.com/your-username/voting-contract.git
cd voting-contract


Install dependencies:

npm install


Compile the contract:

npx hardhat compile


Deploy the contract:

npx hardhat run scripts/deploy.js --network goerli


Interact with the contract using Remix IDE, Hardhat scripts, or a front-end DApp built with React or Vue.

Events

CandidateAdded(uint256 candidateId, string name)
VoterRegistered(address voter)
VoteCast(address voter, uint256 candidateId)
VotingStatusChanged(bool isOpen)

Security Features

Only the admin can add candidates, register voters, and start or stop voting
One vote per voter enforced by modifiers
Immutable data stored on the blockchain for transparency

Future Enhancements

Add time-based voting windows with start and end timestamps
Add multiple admins with roles using OpenZeppelin’s AccessControl
Add a function to reset the election for a new voting round
Add IPFS integration for storing candidate images

License

This project is licensed under the MIT License.

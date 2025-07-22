// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title Simple Voting Contract
 * @dev A decentralized voting system for transparent and secure elections
 */
contract Project {
    // Struct to represent a candidate
    struct Candidate {
        uint256 id;
        string name;
        uint256 voteCount;
        bool exists;
    }
    
    // Struct to represent a voter
    struct Voter {
        bool isRegistered;
        bool hasVoted;
        uint256 votedCandidateId;
    }
    
    // State variables
    address public admin;
    string public electionName;
    bool public votingOpen;
    uint256 public totalVotes;
    uint256 public candidateCount;

    // New: Array to store all voter addresses
    address[] private allVoters;
    
    // Mappings
    mapping(uint256 => Candidate) public candidates;
    mapping(address => Voter) public voters;
    
    // Events
    event CandidateAdded(uint256 indexed candidateId, string name);
    event VoterRegistered(address indexed voter);
    event VoteCast(address indexed voter, uint256 indexed candidateId);
    event VotingStatusChanged(bool isOpen);
    
    // Modifiers
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }
    
    modifier votingIsOpen() {
        require(votingOpen, "Voting is not currently open");
        _;
    }
    
    modifier votingIsClosed() {
        require(!votingOpen, "Voting must be closed for this action");
        _;
    }
    
    modifier onlyRegisteredVoter() {
        require(voters[msg.sender].isRegistered, "You are not a registered voter");
        _;
    }
    
    modifier hasNotVoted() {
        require(!voters[msg.sender].hasVoted, "You have already voted");
        _;
    }
    
    /**
     * @dev Constructor to initialize the voting contract
     * @param _electionName Name of the election
     */
    constructor(string memory _electionName) {
        admin = msg.sender;
        electionName = _electionName;
        votingOpen = false;
        totalVotes = 0;
        candidateCount = 0;
    }
    
    /**
     * @dev Add a new candidate (only admin)
     * @param _name Name of the candidate
     */
    function addCandidate(string memory _name) external onlyAdmin votingIsClosed {
        require(bytes(_name).length > 0, "Candidate name cannot be empty");
        
        candidateCount++;
        candidates[candidateCount] = Candidate({
            id: candidateCount,
            name: _name,
            voteCount: 0,
            exists: true
        });
        
        emit CandidateAdded(candidateCount, _name);
    }
    
    /**
     * @dev Register a voter (only admin)
     * @param _voter Address of the voter to register
     */
    function registerVoter(address _voter) external onlyAdmin {
        require(_voter != address(0), "Invalid voter address");
        require(!voters[_voter].isRegistered, "Voter is already registered");
        
        voters[_voter] = Voter({
            isRegistered: true,
            hasVoted: false,
            votedCandidateId: 0
        });

        allVoters.push(_voter); // New: track registered voter

        emit VoterRegistered(_voter);
    }
    
    /**
     * @dev Toggle voting status (only admin)
     */
    function toggleVoting() external onlyAdmin {
        votingOpen = !votingOpen;
        emit VotingStatusChanged(votingOpen);
    }
    
    /**
     * @dev Cast a vote for a candidate
     * @param _candidateId ID of the candidate to vote for
     */
    function vote(uint256 _candidateId) external 
        votingIsOpen 
        onlyRegisteredVoter 
        hasNotVoted 
    {
        require(_candidateId > 0 && _candidateId <= candidateCount, "Invalid candidate ID");
        require(candidates[_candidateId].exists, "Candidate does not exist");
        
        voters[msg.sender].hasVoted = true;
        voters[msg.sender].votedCandidateId = _candidateId;
        candidates[_candidateId].voteCount++;
        totalVotes++;
        
        emit VoteCast(msg.sender, _candidateId);
    }
    
    /**
     * @dev Get candidate details
     */
    function getCandidate(uint256 _candidateId) external view returns (
        uint256 id,
        string memory name,
        uint256 voteCount
    ) {
        require(_candidateId > 0 && _candidateId <= candidateCount, "Invalid candidate ID");
        require(candidates[_candidateId].exists, "Candidate does not exist");
        
        Candidate memory candidate = candidates[_candidateId];
        return (candidate.id, candidate.name, candidate.voteCount);
    }
    
    /**
     * @dev Get voting results
     */
    function getResults() external view returns (
        uint256 winningCandidateId,
        string memory winningCandidateName,
        uint256 winningVoteCount
    ) {
        require(candidateCount > 0, "No candidates available");
        
        uint256 winningId = 0;
        uint256 highestVoteCount = 0;
        
        for (uint256 i = 1; i <= candidateCount; i++) {
            if (candidates[i].exists && candidates[i].voteCount > highestVoteCount) {
                highestVoteCount = candidates[i].voteCount;
                winningId = i;
            }
        }
        
        if (winningId > 0) {
            return (winningId, candidates[winningId].name, highestVoteCount);
        } else {
            return (0, "No votes cast", 0);
        }
    }
    
    /**
     * @dev Get voter information
     */
    function getVoterInfo(address _voter) external view returns (
        bool isRegistered,
        bool hasVoted,
        uint256 votedCandidateId
    ) {
        Voter memory voter = voters[_voter];
        return (voter.isRegistered, voter.hasVoted, voter.votedCandidateId);
    }
    
    /**
     * @dev Get election statistics
     */
    function getElectionStats() external view returns (
        string memory _electionName,
        uint256 _totalVotes,
        uint256 _candidateCount,
        bool _votingOpen
    ) {
        return (electionName, totalVotes, candidateCount, votingOpen);
    }
    
    /**
     * @dev Get all candidates
     */
    function getAllCandidates() external view returns (
        uint256[] memory candidateIds,
        string[] memory candidateNames,
        uint256[] memory voteCounts
    ) {
        uint256[] memory ids = new uint256[](candidateCount);
        string[] memory names = new string[](candidateCount);
        uint256[] memory counts = new uint256[](candidateCount);
        
        for (uint256 i = 1; i <= candidateCount; i++) {
            if (candidates[i].exists) {
                ids[i-1] = candidates[i].id;
                names[i-1] = candidates[i].name;
                counts[i-1] = candidates[i].voteCount;
            }
        }
        
        return (ids, names, counts);
    }

    /**
     * @dev NEW FUNCTION: Get all registered voters and their voting status (admin only)
     */
    function getAllVoters() external view onlyAdmin returns (
        address[] memory voterAddresses,
        bool[] memory hasVotedFlags
    ) {
        uint256 total = allVoters.length;
        address[] memory addresses = new address[](total);
        bool[] memory votedFlags = new bool[](total);

        for (uint256 i = 0; i < total; i++) {
            address voter = allVoters[i];
            addresses[i] = voter;
            votedFlags[i] = voters[voter].hasVoted;
        }

        return (addresses, votedFlags);
    }
}


    

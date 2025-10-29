// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Voting {
    address public owner;
    struct Candidate {
        string name;
        uint voteCount;
    }

    Candidate[] private candidates;
    mapping(address => bool) public hasVoted;

    event CandidateAdded(string name, uint index);
    event Voted(address voter, uint candidateIndex);

    error NotOwner(address);
    error AlreadyVoted(address);
    error InvalidCandidate();
    error NoCandidates();
    error NoVotesCasted();

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner(msg.sender);
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    /// @notice Adds a new candidate (only callable by the owner)
    /// @param name The candidate's name
    function addCandidate(string memory name) external onlyOwner {
        candidates.push(Candidate({name: name, voteCount: 0}));
        emit CandidateAdded(name, candidates.length - 1);
    }

    /// @notice Allows a user to vote for a candidate by index
    /// @param candidateIndex Index of the candidate in the candidates array
    function vote(uint candidateIndex) external {
        if (hasVoted[msg.sender]) revert AlreadyVoted(msg.sender);
        if (candidateIndex >= candidates.length) revert InvalidCandidate();

        candidates[candidateIndex].voteCount++;
        hasVoted[msg.sender] = true;

        emit Voted(msg.sender, candidateIndex);
    }

    /// @notice Returns all candidates and their vote counts
    /// @return An array of all candidates
    function getCandidates() external view returns (Candidate[] memory) {
        return candidates;
    }

    /// @notice Declares the winner based on highest vote count
    /// @return name The name of the winning candidate
    function getWinner() external view returns (string memory name) {
        if (candidates.length == 0) revert NoCandidates();

        uint winningVoteCount = 0;
        uint winnerIndex = 0;

        for (uint i = 0; i < candidates.length; i++) {
            if (candidates[i].voteCount > winningVoteCount) {
                winningVoteCount = candidates[i].voteCount;
                winnerIndex = i;
            }
        }
        if (winningVoteCount == 0) revert NoVotesCasted();
        return candidates[winnerIndex].name;
    }
}

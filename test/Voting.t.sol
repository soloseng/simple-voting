// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../contracts/Voting.sol";

contract VotingTest is Test {
    Voting public voting;
    address public owner = address(this);
    address public alice = address(0x1);
    address public bob = address(0x2);
    address public carol = address(0x3);

    event CandidateAdded(string name, uint index);
    event Voted(address voter, uint candidateIndex);

    error NotOwner(address);
    error AlreadyVoted(address);
    error InvalidCandidate();
    error NoCandidates();
    error NoVotesCasted();

    function setUp() public {
        voting = new Voting();
    }

    // --- Candidate Management ---
    function testAddCandidateByOwner() public {
        vm.expectEmit(true, true, false, false);
        emit CandidateAdded("Alice", 0);

        voting.addCandidate("Alice");

        Voting.Candidate[] memory candidates = voting.getCandidates();
        assertEq(candidates.length, 1);
        assertEq(candidates[0].name, "Alice");
        assertEq(candidates[0].voteCount, 0);
    }

    function testCannotAddCandidateIfNotOwner() public {
        vm.prank(alice);
        vm.expectRevert(
            abi.encodeWithSelector(VotingTest.NotOwner.selector, alice)
        );
        voting.addCandidate("Alice");
    }

    function testVoteIncrementsVoteCount() public {
        voting.addCandidate("Alice");
        voting.addCandidate("Bob");

        vm.prank(alice);
        voting.vote(1);

        Voting.Candidate[] memory candidates = voting.getCandidates();
        assertEq(candidates[1].voteCount, 1);
    }

    function testCannotVoteTwice() public {
        voting.addCandidate("Alice");

        vm.startPrank(alice);
        voting.vote(0);

        vm.expectRevert(
            abi.encodeWithSelector(VotingTest.AlreadyVoted.selector, alice)
        );
        voting.vote(0);
        vm.stopPrank();
    }

    function testCannotVoteInvalidIndex() public {
        voting.addCandidate("Alice");

        vm.prank(alice);
        vm.expectRevert(
            abi.encodeWithSelector(VotingTest.InvalidCandidate.selector)
        );
        voting.vote(5);
    }

    function testGetWinnerReturnsHighestVote() public {
        voting.addCandidate("Alice");
        voting.addCandidate("Bob");

        vm.prank(alice);
        voting.vote(0); // Alice +1

        vm.prank(bob);
        voting.vote(1); // Bob +1

        vm.prank(carol);
        voting.vote(1); // Bob +1 again

        string memory winner = voting.getWinner();
        assertEq(winner, "Bob");
    }

    function testGetWinnerRevertsWhenNoCandidates() public {
        vm.expectRevert(VotingTest.NoCandidates.selector);
        voting.getWinner();
    }
    function testGetWinnerRevertsWhenNoVotesCasted() public {
        voting.addCandidate("Alice");
        voting.addCandidate("Bob");
        vm.expectRevert(VotingTest.NoVotesCasted.selector);
        voting.getWinner();
    }

    function testVoteEmitsEvent() public {
        voting.addCandidate("Alice");

        vm.expectEmit(true, true, false, false);
        emit Voted(alice, 0);

        vm.prank(alice);
        voting.vote(0);
    }
}

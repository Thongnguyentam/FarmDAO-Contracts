// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./FDAO.sol";
import "./DisputeManager.sol";

contract GovernanceDao is Ownable {
    FDAO public fdaoToken;
    DisputeManager public disputeManager;
    
    uint256 public constant MINIMUM_STAKE = 100 * 1e18; // 100 FDAO
    uint256 public constant VOTING_PERIOD = 24 hours;
    uint256 public constant REWARD_AMOUNT = 10 * 1e18; // 10 FDAO

    struct Vote {
        bool approved;
        uint256 stakedAmount;
    }

    struct Dispute {
        uint256 policyId;
        uint256 startTime;
        uint256 approvalVotes;
        uint256 rejectionVotes;
        bool resolved;
        mapping(address => Vote) votes;
        mapping(address => bool) hasVoted;
        address[] voters;
    }

    mapping(uint256 => Dispute) public disputes;
    uint256 public disputeCount;

    event DisputeCreated(uint256 indexed disputeId, uint256 indexed policyId);
    event VoteCast(uint256 indexed disputeId, address indexed voter, bool approved, uint256 amount);
    event DisputeResolved(uint256 indexed disputeId, bool approved);

    constructor(address _fdaoToken) Ownable(msg.sender) {
        fdaoToken = FDAO(_fdaoToken);
    }

    function setDisputeManager(address _disputeManager) external onlyOwner {
        disputeManager = DisputeManager(_disputeManager);
    }

    function createDispute(uint256 _policyId) external returns (uint256) {
        require(msg.sender == address(disputeManager), "Only DisputeManager can create disputes");
        
        uint256 disputeId = disputeCount++;
        Dispute storage dispute = disputes[disputeId];
        dispute.policyId = _policyId;
        dispute.startTime = block.timestamp;

        emit DisputeCreated(disputeId, _policyId);
        return disputeId;
    }

    function vote(uint256 _disputeId, bool _approve, uint256 _stakeAmount) external {
        Dispute storage dispute = disputes[_disputeId];
        require(!dispute.resolved, "Dispute already resolved");
        require(block.timestamp <= dispute.startTime + VOTING_PERIOD, "Voting period ended");
        require(!dispute.hasVoted[msg.sender], "Already voted");
        require(_stakeAmount >= MINIMUM_STAKE, "Insufficient stake");
        require(fdaoToken.transferFrom(msg.sender, address(this), _stakeAmount), "Stake transfer failed");

        dispute.votes[msg.sender] = Vote(_approve, _stakeAmount);
        dispute.hasVoted[msg.sender] = true;
        dispute.voters.push(msg.sender);

        if (_approve) {
            dispute.approvalVotes += _stakeAmount;
        } else {
            dispute.rejectionVotes += _stakeAmount;
        }

        emit VoteCast(_disputeId, msg.sender, _approve, _stakeAmount);
    }

    function resolveDispute(uint256 _disputeId) external {
        Dispute storage dispute = disputes[_disputeId];
        require(!dispute.resolved, "Already resolved");
        require(block.timestamp > dispute.startTime + VOTING_PERIOD, "Voting period not ended");

        bool approved = dispute.approvalVotes > dispute.rejectionVotes;
        dispute.resolved = true;

        // Execute the dispute resolution through DisputeManager
        disputeManager.executeResolution(dispute.policyId, approved);

        // Reward voters who voted with majority
        rewardMajorityVoters(_disputeId, approved);

        emit DisputeResolved(_disputeId, approved);
    }

    function rewardMajorityVoters(uint256 _disputeId, bool _majorityApproved) internal {
        Dispute storage dispute = disputes[_disputeId];
        uint256 totalStaked = dispute.approvalVotes + dispute.rejectionVotes;
        
        // Check if contract has enough tokens to return stakes
        require(fdaoToken.balanceOf(address(this)) >= totalStaked, "Insufficient balance to return stakes");
        
        // Return stakes and distribute rewards
        for (uint256 i = 0; i < dispute.voters.length; i++) {
            address voter = dispute.voters[i];
            Vote memory voterInfo = dispute.votes[voter];
            
            // Return staked amount first
            require(fdaoToken.transfer(voter, voterInfo.stakedAmount), "Stake return failed");
            
            // If voted with majority, mint additional reward tokens
            if (voterInfo.approved == _majorityApproved) {
                fdaoToken.mint(voter, REWARD_AMOUNT);
            }
        }
    }
}

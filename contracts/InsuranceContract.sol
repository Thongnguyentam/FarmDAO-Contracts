// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./FUSD.sol";
import "./ReceiptNFT.sol";

contract InsuranceContract is Ownable {
    // Struct to store policy information
    struct Policy {
        address farmer;
        uint256 premium;
        uint256 maxPayout;
        uint256 startTime;
        uint256 endTime;
        bool isActive;
        bool isClaimed;
    }

    // Mapping to store policies
    mapping(uint256 => Policy) public policies;
    uint256 public policyCount;

    // Token contracts
    IERC20 public stablecoin;
    ReceiptNFT public receiptNFT;
    address public disputeManager;
    uint256 public constant INITIAL_FUND_AMOUNT = 10000 * 1e18; // 10,000 FUSD initial fund

    // Events
    event PolicyCreated(uint256 indexed policyId, address indexed farmer, uint256 premium, uint256 maxPayout);
    event PayoutTriggered(uint256 indexed policyId, address indexed farmer, uint256 amount);
    event PolicyCancelled(uint256 indexed policyId, address indexed farmer);
    event DisputeManagerSet(address indexed disputeManager);
    event ContractFunded(uint256 amount);
    event ReceiptNFTMinted(uint256 indexed policyId, address indexed farmer);

    constructor(address _stablecoin, address _receiptNFT) Ownable(msg.sender) {
        stablecoin = IERC20(_stablecoin);
        receiptNFT = ReceiptNFT(_receiptNFT);
    }

    function setDisputeManager(address _disputeManager) external onlyOwner {
        require(_disputeManager != address(0), "Invalid dispute manager address");
        disputeManager = _disputeManager;
        emit DisputeManagerSet(_disputeManager);
    }

    // Function to create a new insurance policy
    function createPolicy(uint256 _premium, uint256 _maxPayout) external returns (uint256) {
        require(_premium > 0, "Premium must be greater than 0");
        require(_maxPayout > _premium, "Max payout must be greater than premium");

        // Transfer premium from farmer to contract
        require(
            stablecoin.transferFrom(msg.sender, address(this), _premium),
            "Premium transfer failed"
        );

        uint256 policyId = policyCount++;
        uint256 startTime = block.timestamp;
        uint256 endTime = startTime + 365 days; // 1 year policy

        policies[policyId] = Policy({
            farmer: msg.sender,
            premium: _premium,
            maxPayout: _maxPayout,
            startTime: startTime,
            endTime: endTime,
            isActive: true,
            isClaimed: false
        });

        // Mint receipt NFT
        receiptNFT.mintReceipt(
            msg.sender,
            policyId,
            _premium,
            _maxPayout,
            startTime,
            endTime
        );

        emit PolicyCreated(policyId, msg.sender, _premium, _maxPayout);
        emit ReceiptNFTMinted(policyId, msg.sender);
        return policyId;
    }

    // Function to trigger payout for a policy (callable by owner or dispute manager)
    function triggerPayout(uint256 _policyId) external {
        require(msg.sender == owner() || msg.sender == disputeManager, "Not authorized");
        Policy storage policy = policies[_policyId];
        require(policy.isActive, "Policy is not active");
        require(!policy.isClaimed, "Policy already claimed");
        require(block.timestamp <= policy.endTime, "Policy expired");

        policy.isActive = false;
        policy.isClaimed = true;

        // Transfer max payout to farmer
        require(
            stablecoin.transfer(policy.farmer, policy.maxPayout),
            "Payout transfer failed"
        );

        emit PayoutTriggered(_policyId, policy.farmer, policy.maxPayout);
    }

    // Function to cancel policy and get refund (if within cooling period)
    function cancelPolicy(uint256 _policyId) external {
        Policy storage policy = policies[_policyId];
        require(policy.farmer == msg.sender, "Not policy owner");
        require(policy.isActive, "Policy not active");
        require(block.timestamp <= policy.startTime + 7 days, "Cooling period expired");

        policy.isActive = false;

        // Refund premium
        require(
            stablecoin.transfer(policy.farmer, policy.premium),
            "Refund transfer failed"
        );

        emit PolicyCancelled(_policyId, policy.farmer);
    }

    // Function to get policy details
    function getPolicy(uint256 _policyId) external view returns (
        address farmer,
        uint256 premium,
        uint256 maxPayout,
        uint256 startTime,
        uint256 endTime,
        bool isActive,
        bool isClaimed
    ) {
        Policy memory policy = policies[_policyId];
        return (
            policy.farmer,
            policy.premium,
            policy.maxPayout,
            policy.startTime,
            policy.endTime,
            policy.isActive,
            policy.isClaimed
        );
    }

    // Function to add more funds to the contract
    function fundContract(uint256 _amount) external onlyOwner {
        require(
            stablecoin.transferFrom(msg.sender, address(this), _amount),
            "Funding failed"
        );
        emit ContractFunded(_amount);
    }

    // Function to check contract's FUSD balance
    function getContractBalance() external view returns (uint256) {
        return stablecoin.balanceOf(address(this));
    }
}
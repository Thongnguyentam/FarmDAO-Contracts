// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./InsuranceContract.sol";
import "./GovernanceDao.sol";

contract DisputeManager is Ownable {
    InsuranceContract public insuranceContract;
    GovernanceDao public governanceDao;
    
    event DisputeInitiated(uint256 indexed policyId);
    event DisputeResolved(uint256 indexed policyId, bool approved);

    constructor(address _insuranceContract) Ownable(msg.sender) {
        insuranceContract = InsuranceContract(_insuranceContract);
    }

    function setGovernanceDao(address _governanceDao) external onlyOwner {
        governanceDao = GovernanceDao(_governanceDao);
    }

    // Called by Chainlink oracle or authorized entity when bad weather is detected
    function initiateDispute(uint256 _policyId) external onlyOwner {
        // Create dispute in DAO
        governanceDao.createDispute(_policyId);
        emit DisputeInitiated(_policyId);
    }

    // Called by GovernanceDao after dispute resolution
    function executeResolution(uint256 _policyId, bool _approved) external {
        require(msg.sender == address(governanceDao), "Only DAO can execute resolution");
        
        if (_approved) {
            insuranceContract.triggerPayout(_policyId);
        }
        
        emit DisputeResolved(_policyId, _approved);
    }
}
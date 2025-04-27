const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

const FarmDaoModule = buildModule("FarmDaoModule", (m) => {
    // Deploy FUSD first as it's needed by other contracts
    const fusd = m.contract("FUSD");

    // Deploy FDAO with FUSD address
    const fdao = m.contract("FDAO", [fusd]);

    // Deploy ReceiptNFT for insurance policies
    const receiptNFT = m.contract("ReceiptNFT");

    // Deploy Insurance Contract with FUSD and ReceiptNFT addresses
    const insuranceContract = m.contract("InsuranceContract", [fusd, receiptNFT]);

    // Deploy Dispute Manager with Insurance Contract address
    const disputeManager = m.contract("DisputeManager", [insuranceContract]);

    // Deploy Governance DAO with FDAO address
    const governanceDao = m.contract("GovernanceDao", [fdao]);

    // Set up contract connections
    m.call(disputeManager, "setGovernanceDao", [governanceDao]);
    m.call(governanceDao, "setDisputeManager", [disputeManager]);
    m.call(insuranceContract, "setDisputeManager", [disputeManager]);

    // Transfer ownership of ReceiptNFT to InsuranceContract
    m.call(receiptNFT, "transferOwnership", [insuranceContract]);

    // Initial funding setup
    // Mint 1M FUSD to deployer for initial setup
    m.call(fusd, "mint", [m.deployer(), ethers.parseEther("1000000")]);

    // Transfer 100K FUSD to FDAO contract for redemptions
    m.call(fusd, "transfer", [fdao, ethers.parseEther("100000")]);

    // Approve and fund insurance contract with 100K FUSD
    m.call(fusd, "approve", [insuranceContract, ethers.parseEther("100000")]);
    m.call(insuranceContract, "fundContract", [ethers.parseEther("100000")]);

    return {
        fusd,
        fdao,
        receiptNFT,
        insuranceContract,
        disputeManager,
        governanceDao
    };
});

module.exports = FarmDaoModule;

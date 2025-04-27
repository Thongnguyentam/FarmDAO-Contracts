# 🌾 Farmer Insurance DAO – Smart Contracts

Decentralized smart contracts powering the Farmer Insurance DAO — enabling parametric crop insurance, weather-triggered payouts, decentralized dispute resolution, and DAO-driven governance.

---

## 📜 Overview

This repository contains Solidity smart contracts for:
- Insurance policy purchase and payout
- Weather-triggered automatic payouts
- DAO-governed dispute resolution
- Governance token economy (earn and redeem)

---

## ✨ Twitter Announcement

Check out our official launch announcement on Twitter:

➡️ [@gokulnpcc's Tweet about FarmDAO](https://x.com/gokulnpcc/status/1916512312590053482)

> "FarmDAO: decentralized crop insurance on Polkadot.  
> Automated payouts. DAO governance. Built for the future of agriculture. 🌾🚀"

---

## 💻 Demo Video

[![FarmDAO Demo](https://img.youtube.com/vi/Zg_fGW89kMY/0.jpg)](https://youtu.be/Zg_fGW89kMY)

> 📺 **Watch the full demo:** [https://youtu.be/Zg_fGW89kMY](https://youtu.be/Zg_fGW89kMY)

---

## 🚀 Contract Addresses on Moonbase Alpha (Moonbeam Testnet)

| Contract | Address | Purpose |
|:---|:---|:---|
| **DisputeManager** | [`0x23988C9d187A064Feb7EE21dB389B469FbDc6421`](https://moonbase.moonscan.io/address/0x23988C9d187A064Feb7EE21dB389B469FbDc6421) | Manages disputes after weather event triggers |
| **GovernanceDAO** | [`0x37035da168BaEE11970019B3fe7377aB3984A18b`](https://moonbase.moonscan.io/address/0x37035da168baee11970019b3fe7377ab3984a18b) | Stake and vote on dispute resolutions |
| **InsuranceContract** | [`0x7784f99F10b318D41Ea040d4EaAd8f385Ad1f511`](https://moonbase.moonscan.io/address/0x7784f99F10b318D41Ea040d4EaAd8f385Ad1f511) | Buy insurance policies and trigger payouts |
| **ReceiptNFT** | [`0x20db875112FF5083267A3C19C3812de5eb3C4C8C`](https://moonbase.moonscan.io/address/0x20db875112FF5083267A3C19C3812de5eb3C4C8C) | NFT representing farmer’s insurance policies |
| **FUSD (Stablecoin)** | [`0xF52593b79C6a6c48DE918C1a3469959029DC3a8e`](https://moonbase.moonscan.io/address/0xF52593b79C6a6c48DE918C1a3469959029DC3a8e) | Payment token for insurance premiums and payouts |
| **FDAO (Governance Token)** | [`0xaC348bAB58b649a41DC23D108e90d949A8852fa0`](https://moonbase.moonscan.io/address/0xaC348bAB58b649a41DC23D108e90d949A8852fa0) | Governance and staking token for dispute resolution |

> ✨ **Block Explorer:** [Moonbase Moonscan](https://moonbase.moonscan.io/)

> ✨ **RPC Endpoint:** `https://rpc.api.moonbase.moonbeam.network`

---

## 📂 Contract Descriptions

- **InsuranceContract.sol**  
  Handles policy purchase, premium payments, weather-triggered payouts, and minting ReceiptNFTs.

- **DisputeManager.sol**  
  Manages the dispute lifecycle and interacts with the DAO for resolution.

- **GovernanceDAO.sol**  
  Allows FDAO token holders to stake, vote, and resolve disputes transparently.

- **ReceiptNFT.sol**  
  ERC721 NFTs representing insured policies.

- **FUSD.sol**  
  ERC20 stablecoin for buying insurance and receiving payouts.

- **FDAO.sol**  
  ERC20 governance token for staking, voting, and redeeming for FUSD.

---

## 🛠 Deployment Challenges

<img width="1419" alt="image" src="https://github.com/user-attachments/assets/dd0c8387-c4f2-4360-8e2c-871da2a38442" />

During deployment testing, we faced significant challenges while attempting to deploy our smart contracts, particularly the `FDAO.sol` contract, on the **Westend Asset Hub** (Polkadot Testnet for assets):

### ⚠️ Problem Faced:
- **Transaction size limit exceeded:**  
  Even for the simplest contract (FDAO.sol), the **initcode size** (deployment bytecode) exceeded the **maximum allowed size** on Westend.
  
- **Error Message:**
  ```
  creation of FDAO errored: Error occurred: the initcode size of this transaction is too large: 
  it is 79168 bytes while the max is 49152 bytes
  ```

- **Explanation:**
  - Westend Asset Hub imposes a strict limit of **49152 bytes** for smart contract initcode (deployment bytecode).
  - Our FDAO contract compiled into **~79 KB** initcode even after optimization.
  - Due to fundamental Solidity structure, even stripping features still does not shrink it enough for Westend deployment.
  - The contract involves ERC20 functionalities, staking logic, reward distribution, and emergency withdrawal, making further modularization impractical without fundamentally redesigning the architecture.

---

### 🛠 Actions Taken:
- Tried maximum Solidity optimizations (`optimizer: true, runs: 2000`) in Hardhat config.
- Removed extra comments and unused imports.
- Attempted flattening and modular compilation.
- Tried deploying with **higher gas limits** (although the error is size-related, not gas-related).

---

### 🎯 Outcome:
- **Conclusion:**  
  Westend Asset Hub is currently **not suitable for full-scale smart contract deployments** involving ERC20 governance tokens like FDAO due to severe initcode size restrictions.

- **Final Decision:**  
  We deployed successfully on **Moonbase Alpha** (Moonbeam Testnet) which fully supports Solidity and has no initcode size issue, while still benefiting from Polkadot’s shared security model.

---

## 🚀 Why Moonbase Alpha?

- Full EVM compatibility (supports standard Solidity contracts easily)
- Part of the Polkadot ecosystem (decentralized, secure, fast)
- Easy transition in future toward multi-chain XCM-based deployments across the Polkadot parachains.

---

## 🛠️ Local Development Setup

```bash
# Install dependencies
npm install

# Compile smart contracts
npx hardhat compile

# Deploy to Moonbase Alpha
npx hardhat run scripts/deploy.js --network moonbase
```

**Moonbase Network Config (hardhat.config.js)**:
```javascript
moonbase: {
  url: "https://rpc.api.moonbase.moonbeam.network",
  accounts: [PRIVATE_KEY],
  chainId: 1287
}
```

---

## 🧪 Testing

```bash
npx hardhat test
```

---

## ✨ Future Enhancements

- Redundant oracle feeds (multi-oracle support)
- Expand insurance types (flood, drought, fire)
- Treasury yield farming strategies (T-Bills, delta-neutral strategies)

---

## 👨‍💻 Contributors

- [Gokuleshwaran Narayanan](https://linkedin.com/in/gokulnpc)
- [Dylan Nguyen](https://www.linkedin.com/in/dylan-nguyen-1b5783212/) 

---

## 🏛️ License

MIT License

---

# 🌟
_"Protecting crops. Empowering communities. Decentralizing fairness."_

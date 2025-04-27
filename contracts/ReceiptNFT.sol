// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract ReceiptNFT is ERC721, Ownable {
    using Strings for uint256;

    struct PolicyDetails {
        uint256 premium;
        uint256 maxPayout;
        uint256 creationDate;
        uint256 expiryDate;
    }

    mapping(uint256 => PolicyDetails) public policyDetails;

    constructor() ERC721("Insurance Policy Receipt", "IPRCPT") Ownable(msg.sender) {}

    function mintReceipt(
        address to,
        uint256 policyId,
        uint256 premium,
        uint256 maxPayout,
        uint256 creationDate,
        uint256 expiryDate
    ) external onlyOwner {
        policyDetails[policyId] = PolicyDetails({
            premium: premium,
            maxPayout: maxPayout,
            creationDate: creationDate,
            expiryDate: expiryDate
        });

        _mint(to, policyId);
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_ownerOf(tokenId) != address(0), "Token does not exist");
        PolicyDetails memory details = policyDetails[tokenId];

        string memory json = Base64.encode(
            bytes(string(
                abi.encodePacked(
                    '{"name": "Insurance Policy Receipt #', tokenId.toString(),
                    '", "description": "This NFT represents an insurance policy receipt.", ',
                    '"attributes": [',
                    '{"trait_type": "Premium", "value": "', (details.premium / 1e18).toString(), ' FUSD"}, ',
                    '{"trait_type": "Max Payout", "value": "', (details.maxPayout / 1e18).toString(), ' FUSD"}, ',
                    '{"trait_type": "Creation Date", "value": "', details.creationDate.toString(), '"}, ',
                    '{"trait_type": "Expiry Date", "value": "', details.expiryDate.toString(), '"}',
                    ']}'
                )
            ))
        );

        return string(abi.encodePacked("data:application/json;base64,", json));
    }

    function getPolicyDetails(uint256 policyId) external view returns (PolicyDetails memory) {
        require(_ownerOf(policyId) != address(0), "Token does not exist");
        return policyDetails[policyId];
    }
}

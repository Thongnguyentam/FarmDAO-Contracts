// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract FUSD is ERC20, Ownable {
    event TokensBurned(address indexed from, uint256 amount);
    event TokensMinted(address indexed to, uint256 amount);

    constructor() ERC20("Farmer USD", "FUSD") Ownable(msg.sender) {
        // Initial supply is 0
    }

    function mint(address to, uint256 amount) external onlyOwner {
        require(to != address(0), "Cannot mint to zero address");
        _mint(to, amount);
        emit TokensMinted(to, amount);
    }
}
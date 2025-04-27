// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract FDAO is ERC20, Ownable {
    IERC20 public fusd;
    uint256 public constant REDEMPTION_RATIO = 50; // 50 FDAO : 1 FUSD

    constructor(address _fusd) ERC20("Farmer DAO Token", "FDAO") Ownable(msg.sender) {
        fusd = IERC20(_fusd);
    }

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }

    function redeemForFUSD(uint256 fdaoAmount) external {
        require(fdaoAmount >= REDEMPTION_RATIO, "Must redeem at least 50 FDAO");
        require(fdaoAmount % REDEMPTION_RATIO == 0, "Amount must be divisible by 50");

        uint256 fusdAmount = fdaoAmount / REDEMPTION_RATIO;
        require(fusd.balanceOf(address(this)) >= fusdAmount, "Insufficient FUSD reserves");

        _burn(msg.sender, fdaoAmount);
        require(fusd.transfer(msg.sender, fusdAmount), "FUSD transfer failed");
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

import "./ERC4626ETH.sol";

contract Vault is ERC4626ETH {
    address public flagHolder;

    // If more balance than shares, send extra balance to the caller.
    // Shares can only become more than 1 to 1 by destroying a contract to inject eth (first step of attack)
    // Extra balance sent only after the original withdraw
    // Reentrancy taking the extra multiple times
    constructor() payable ERC20("Vault Challenge Token", "VCT") {
        require(msg.value == 1 ether, "Must init the contract with 1 eth");
        _deposit(msg.sender, address(this), msg.value);
    }

    function captureTheFlag(address newFlagHolder) external {
        require(address(this).balance == 0, "Balance is not 0");

        flagHolder = newFlagHolder;
    }
}

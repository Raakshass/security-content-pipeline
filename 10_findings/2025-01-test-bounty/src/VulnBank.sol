// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title VulnBank (fixed) – re-entrancy-safe
contract VulnBank {
    mapping(address => uint256) public balances;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw() external {
        uint256 bal = balances[msg.sender];
        require(bal > 0, "no funds");

        // Effects
        balances[msg.sender] = 0;

        // Interactions
        (bool ok, ) = payable(msg.sender).call{value: bal}("");
        require(ok, "transfer failed");
    }
}


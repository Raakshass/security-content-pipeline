// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/VulnBank.sol";

/// @dev helper contract that re-enters the bank during withdraw
contract Attacker {
    VulnBank bank;
    constructor(VulnBank _bank) { bank = _bank; }

    // on receiving ETH, try to re-enter once
    receive() external payable {
        if (address(bank).balance >= 1 ether) {
            bank.withdraw();
        }
    }

    function attack() external payable {
        bank.deposit{value: 1 ether}(); // initial deposit
        bank.withdraw();                // first withdraw → triggers receive()
    }
}

contract ReentrancyTest is Test {
    VulnBank bank;
    Attacker attacker;

    function setUp() public {
        bank     = new VulnBank();
        attacker = new Attacker(bank);

        bank.deposit{value: 10 ether}();      // seed bank with float
        vm.deal(address(attacker), 2 ether);  // fund attacker
    }

    function testExploit() public {
        // The patched bank should revert the re-entrancy attempt
        vm.startPrank(address(attacker));
        vm.expectRevert("transfer failed");
        attacker.attack{value: 1 ether}();
        vm.stopPrank();

        // ─── Balances unchanged ───
        assertEq(address(attacker).balance, 2 ether);  // attacker kept original 2 ETH
        assertEq(address(bank).balance,    10 ether); // bank still has prefunded 10 ETH
    }
}

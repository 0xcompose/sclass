// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract Parent1 {}

contract Parent2 {}

contract Child1 is Parent1, Parent2 {
    uint256 public x;
}

contract Child2 {}

contract GrandChild is Child1, Child2 {
    bytes32 public y;

    function foo() public {}
}

interface Parent3 {}

interface Parent4 {}

interface Child3 is Parent3, Parent4 {}

interface Child4 is Child3 {}

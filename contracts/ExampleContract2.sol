// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

abstract contract Base {
    function baseFunc() public pure returns (uint256) {
        return 1;
    }
}

abstract contract MiddleInInheritance is Base {
    function middleFunc() public pure returns (uint256) {
        return 1;
    }
}

contract Excluded {
    function anotherFunc() public pure returns (uint256) {
        return 1;
    }
}

contract ExampleContract2 is MiddleInInheritance {
    function testContract2Func() public pure returns (uint256) {
        return 2;
    }

    function regExpFunc() public pure returns (uint256) {
        return 3;
    }

    function exceptionRegExp() public pure returns (uint256) {
        return 4;
    }
}

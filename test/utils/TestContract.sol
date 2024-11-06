// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ITestContract {
    function setUint256PublicVar(uint256 _uint256PublicVar) external;
}

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

contract ContractInCollection {
    function contractToFilterFunc() public view returns (address) {
        return address(this);
    }
}

contract TestContract1 is
    MiddleInInheritance,
    ContractInCollection,
    ITestContract
{
    uint256 public uint256PublicVar;
    address private addressPrivateVar;

    constructor() {}

    function setUint256PublicVar(uint256 _uint256PublicVar) external {
        uint256PublicVar = _uint256PublicVar;
    }
}

contract TestContract2 is MiddleInInheritance {
    function testContract2Func() public pure returns (uint256) {
        return 2;
    }
}

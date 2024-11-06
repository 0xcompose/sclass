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

contract OApp {} //from layerzero

contract Relayer {} //from layerzero

contract ExampleContract1 is
    MiddleInInheritance,
    ContractInCollection,
    ITestContract,
    OApp,
    Relayer
{
    uint256 public uint256PublicVar;
    address private addressPrivateVar;

    constructor() {}

    function setUint256PublicVar(uint256 _uint256PublicVar) external {
        uint256PublicVar = _uint256PublicVar;
    }
}

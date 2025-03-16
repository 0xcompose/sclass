// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract StateVariables {
    uint256 public stateVariable1;
    uint128 public stateVariable2;

    address public addressVariable;

    bytes32 public constant BYTES32_CONSTANT = keccak256("MY_CONSTANT");

    bytes2 internal immutable immutableBytes2Variable;

    uint8 internal constant _smallInternalVariable = type(uint8).max;

    mapping(address => uint256) public balances;

    mapping(address => mapping(address => uint256)) public allowed;

    mapping(address => mapping(address => mapping(bytes32 => uint256))) public crazyMapping;

    struct StructOfVariables {
        uint256 stateVariable;
        address addressVariable;
    }

    StructOfVariables public stateVariables;

    constructor(bytes2 _immutableBytes2Variable) {
        immutableBytes2Variable = _immutableBytes2Variable;
    }
}

abstract contract AnotherContract {
    uint256 public stateVariable;

    address public addressVariable;
}

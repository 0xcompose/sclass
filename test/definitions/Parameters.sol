// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract Parameters {
    function sum(uint256 a, uint256 b) public pure returns (uint256 c) {
        return a + b;
    }

    function setAddress(address _address) public pure returns (address newOwner) {
        return _address;
    }

    function setBytes32(bytes32 _bytes32) public pure returns (uint256) {
        return uint256(_bytes32);
    }

    struct MyStruct {
        uint256 a;
        uint256 b;
    }

    function setStruct(MyStruct memory myStruct) public pure returns (MyStruct memory) {
        return myStruct;
    }

    function setArray(uint256[] memory _array) public pure returns (uint256[] memory newArray) {
        return _array;
    }

    function setArray(uint256[] memory _array, uint256 _index) public pure returns (uint256[] memory newArray) {
        newArray[_index] = _array[_index];
        return newArray;
    }
}

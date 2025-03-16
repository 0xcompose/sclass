// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract Functions {
    function function1() public pure returns (uint256) {
        return 1;
    }

    function function2() public pure returns (uint256) {
        return 2;
    }

    receive() external payable {}

    fallback() external payable {}
}

interface IFunctionInterface {
    function function1() external pure returns (uint256);
    function function2(address _address) external pure returns (uint256);

    function function3(bytes32 _bytes32) external pure returns (bytes32);
}

library LibraryWithFunction {
    function function1() public pure returns (uint256) {
        return 1;
    }

    function function2(bytes4 _bytes4) public pure returns (bytes4) {
        return _bytes4;
    }
}

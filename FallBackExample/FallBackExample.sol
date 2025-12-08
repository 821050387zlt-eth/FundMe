
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract FallbackExample {
    uint256 public result;

    fallback() external payable { 
        result = 1;
    }

    receive() external payable {
        result = 2;
     }
}
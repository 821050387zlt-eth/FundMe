// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {PriceConverter} from "./PriceConverter.sol";

// gas优化 constant,immutable



error NotOwner();

// 1.从用户获取资金到这个合同中
// 2.提取资金到合同的所有者
// 3.设置一个最低的融资价值以美元作为单位
contract FundMe {
    
    using PriceConverter for uint256;

    uint256 public constant MINIMUM_USD = 5e18;

    mapping(address => uint256) public addressToAmountFunded;
    address[] public funders;

    //uint256 public constant MINIMUM_USD = 5 * 10 ** 18;

    address public immutable i_owner;

    constructor () {
        i_owner = msg.sender;
    }

    function fund() public payable {
        require(msg.value.getConversionRate() >= MINIMUM_USD, "You need to spend more ETH!");
        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);
    }

    function withdraw() public onlyOwner {
        for (uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++) 
        {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);

        // transfer
        payable(msg.sender).transfer(address(this).balance);
        
        // send
        bool sendSuccess = payable(msg.sender).send(address(this).balance);
        require(sendSuccess, "Send failed");

        // call
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }

    modifier onlyOwner() {
        require(msg.sender == i_owner, "Sender is not owner");
        if (msg.sender != i_owner) {
            revert NotOwner();
        }
        _;
    }



}
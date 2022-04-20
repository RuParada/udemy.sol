// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import '@openzeppelin/contracts/math/SafeMath.sol';

contract EthernautFallback {

    using SafeMath for uint256;
    mapping(address => uint) public contributions;
    address payable public owner;

    
}

/** 
 *  SourceUnit: /Users/ruslan/token/udemy.sol/contracts/EthernautFallback.sol
*/

////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
pragma solidity 0.8.0;

////import '@openzeppelin/contracts/math/SafeMath.sol';

contract EthernautFallback {

    using SafeMath for uint256;
    mapping(address => uint) public contributions;
    address payable public owner;

    
}


/** 
 *  SourceUnit: /Users/ruslan/token/udemy.sol/contracts/SimpleToken.sol
*/

////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
pragma solidity ^0.5.10;

contract TokenA {
    string  public name = "DApp Token";
    string  public symbol = "DAPP";
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;

    constructor(uint256 _initialSupply) public {
        balanceOf[msg.sender] = _initialSupply;
        totalSupply = _initialSupply;
    }
}

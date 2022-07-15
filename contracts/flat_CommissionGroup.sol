
/** 
 *  SourceUnit: /Users/ruslan/token/udemy.sol/contracts/CommissionGroup.sol
*/

////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
pragma solidity ^0.5.10;

//////import 'https://github.com/TRON-Developer-Hub/TRC20-Contract-Template/blob/main/TRC20.sol';
////import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract CommissionGroup is ERC20 {

    address public owner;
    address public recipient;
    address public tokenA;

    constructor(address _recipient, address _tokenA) public {
        owner = msg.sender;
        tokenA = _tokenA;
        recipient = _recipient;
        //recipient = 0x38fD65cf2594e9aC445c18c516b703c25a4a672f;
        //tokenA = 0x38fD65cf2594e9aC445c18c516b703c25a4a672f;
    }

    modifier onlyOwner(address _to) {
        require(owner == msg.sender, "You are not owner");
        require(_to != address(0), "Incorrect address");
        _;
    }

    function setRecipient(address _recipient) external onlyOwner(_recipient) {
        recipient = _recipient;
    }

    function transfer(address payable _to, uint _amount) external onlyOwner(_to) {
        if(_amount <= 100) {
            uint commis = _amount/100;
            tokenA.transfer(recipient, commis); 
        }
        if(_amount > 100 && _amount <= 1000	) {
            uint commis = _amount/100 * 2;
            tokenA.transfer(recipient, commis); 
        }
        if(_amount > 1000) {
            uint commis = _amount/100 * 3;
            tokenA.transfer(recipient, commis); 
        }
        tokenA.transfer(_to, _amount);
    }

    function getBalances(address _address, address[] memory _tokens) public view returns (uint[] memory) {
        
        address[] memory results = new address[](_tokens.length);

        for (uint i; i < _tokens.length; i++) {
            //(bool success, uint[] memory result) = _address[i].staticcall(_tokens[i]);
            //require(success, "call failed");
            
            uint result = _tokens[i].balanceOf(_address);
            
            results[i] = result;
        }

        return results;
        
        //return ERC20(tokenA).balanceOf(msg.sender);
        //return (companies[sender].name, companies[sender].age);
    }



}

// SPDX-License-Identifier: MIT
/**
 *  Explain whats wrong with this contract. 
 * 	And Fix the same, please take note of the solidity code version.
 */

 /**
  * Answer:
  * license required, there are two free ones, MIT and GPL 
  * unannounced Transfer event
  * version solidity 0.6.0 has breaking changes
  * withdrawAllAmount must be payable
  * depositAmount - is not used anywhere and just takes up space in storage
  * msg.value == amount - this generates an error, this check is not needed
  */

 pragma solidity >=0.4.21 <0.7.0;
 
 contract ContractBalanceTest {
     address public owner;

     event Transfer(uint amount);
 
     constructor() public payable {
         owner = msg.sender;
     }
 
     modifier onlyOwner () {
       require(msg.sender == owner, "This can only be called by the contract owner!");
       _;
     }
 
     function deposit() payable public {}
 
     function depositAmount(uint256 amount) payable public {
         //require(msg.value == amount);
     }
 
 
     function withdraw() payable public onlyOwner {
         msg.sender.transfer(address(this).balance);
     }
 
     function withdrawAmount(uint256 amount) payable public onlyOwner {
         //require(msg.value == amount);
         require(amount <= getBalance());
         msg.sender.transfer(amount);
         emit Transfer(amount);
     }
     
     function withdrawAllAmount(uint256 amount) payable public onlyOwner {
         //require(msg.value == amount);
         require(amount <= getBalance());
         msg.sender.transfer(getBalance());
     }
 
 
     function getBalance() public view returns (uint256) {
         return address(this).balance;
     }
 }

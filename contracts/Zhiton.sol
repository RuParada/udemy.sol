/**
 *  Explain whats wrong with this contract. 
 * 	And Fix the same, please take note of the solidity code version.
 */

 /**
  * Answer:
  * необходима лицензия, существуют две бесплатные это MIT и GPL
  * необъявленно событие Transfer 
  * 
  */

 pragma solidity >=0.4.21 <0.7.0;
 
 contract ContractBalanceTest {
     address public owner;
 
     constructor() public payable {
         owner = msg.sender;
     }
 
     modifier onlyOwner () {
       require(msg.sender == owner, "This can only be called by the contract owner!");
       _;
     }
 
     function deposit() payable public {
     }
 
     function depositAmount(uint256 amount) payable public {
         require(msg.value == amount);
     }
 
 
     function withdraw() payable onlyOwner public {
         msg.sender.transfer(address(this).balance);
     }
 
     function withdrawAmount(uint256 amount) onlyOwner payable public {
         require(msg.value == amount);
         require(amount <= getBalance());
         msg.sender.transfer(amount);
         emit Transfer(amount);
     }
     
     function withdrawAllAmount(uint256 amount) onlyOwner public {
         require(msg.value == amount);
         require(amount <= getBalance());
         msg.sender.transfer(getBalance());
     }
 
 
     function getBalance() public view returns (uint256) {
         return address(this).balance;
     }
 }

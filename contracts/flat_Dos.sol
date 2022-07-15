
/** 
 *  SourceUnit: /Users/ruslan/token/udemy.sol/contracts/Dos.sol
*/

////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
pragma solidity ^0.8.7;

contract ReentrancyAuction {
    mapping(address => uint) bidders;

    function bid() external payable {
        bidders[msg.sender] += msg.value;
    }

    function refund() external {
        uint countRefund = bidders[msg.sender];
        if (countRefund > 0) {
            //address(this).transfer(countRefund);
            (bool success, ) = msg.sender.call{value: countRefund}("");
            require(success, "failed to refund");
            if (success) {
                bidders[msg.sender] = 0;
            }
        }
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}

contract ReentrancyAttack {
    ReentrancyAuction auction;

    
}


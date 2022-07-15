
/** 
 *  SourceUnit: /Users/ruslan/token/udemy.sol/contracts/Event.sol
*/

////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
pragma solidity ^0.8.13;

contract EventContract {
    event Paid(address indexed _from, uint amount, uint _timestamp);

    function paid() external payable {
        emit Paid(msg.sender, msg.value, block.timestamp);
    }
}

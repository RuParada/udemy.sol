// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

//import "hardhat/console.sol";

contract Demo {
    //uint currentBalance; // 0

    // transact - pay
    function receiveFunds() external payable {
        //console.log(msg.value);
        //currentBalance = currentBalance + msg.value;
    }

    // call - not pay
    function getBalance() public view returns(uint) {
        //return currentBalance;
        return address(this).balance;
    }

    // argument func - local var - _to
    function withdrawFunds(address payable _to) external {
        //address targent = payable(_to);
        //_to.transfer(currentBalance);
        //currentBalance = 0;

        if(address(this).balance != 0) {
            _to.transfer(address(this).balance);
        }
        
    }
}
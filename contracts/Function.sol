// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract FunctionContract {
    // public external internal private
    // view pure

    uint public walletBalance;
    string message = "Basic text";

    // call 
    function getBalance() public view returns(uint) {
        return address(this).balance;
    }

    // call 
    function getBalance2() public view returns(uint balance) {
        balance = address(this).balance;
    }

    // transaction
    function pay() external payable {
        walletBalance += msg.value;
    }

    // alternative pay() fullback function receive
    receive() external payable {
        walletBalance += msg.value;
    }

    // Accept any incoming amount old version solidity v4-v5
    //function () public payable {}

    // if the function call does not exist
    fallback() external payable {
        // some do
    } 

    //transaction
    function setMessage(string memory newMessage) external {
        message = newMessage;
        //return message; // transaction func not return data!
    }
}
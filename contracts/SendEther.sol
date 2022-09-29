// SPDX-License-Identifier: MIT
pragma solidity 0.5.11;

contract SendEther {

    function sendEther(address payable recepient) external {
        recepient.transfer(1 ether);
        // trans 1 eth from this smart contract to recepient
    }
}

contract SendEtherTwo {

    address payable[] recepient;
    
    function sendEther(address payable _recepient) external {
        _recepient.transfer(1 ether);
        
        address a;
        a = _recepient;
        // a.transfer(100);

        msg.sender.transfer(100);

        _recepient.send(1 ether);

    }
}
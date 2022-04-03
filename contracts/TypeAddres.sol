// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract TypeAddres {
    address public add = 0x602B6CD4E94e69D2b6B550cF1F59c64ef75a6b1F;
    //address payable public add = 0x602B6CD4E94e69D2b6B550cF1F59c64ef75a6b1F;
    
    //addr.balance;
    //addr.transfer(uint 20);
    //addr.send(uint 20);
    
    // coding convention to uppercase constant variables
    address public constant MY_ADDRESS = 0x777788889999AaAAbBbbCcccddDdeeeEfFFfCcCc;
    uint public constant MY_UINT = 123;
}

contract DemoAddress {
    function sample(address payable _to) public {
        _to.transfer(1);
    }

    function samplePrivideniyeTypes(address _to) public {
        address payable toPay = payable(_to);
        toPay.transfer(1);
    }
}
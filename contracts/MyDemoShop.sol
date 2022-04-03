// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MyDemoShop {
    address public owner;
    mapping(address => uint) public payments;

    constructor()
    {
        owner = msg.sender;
    }

    function payForItem() public payable 
    {
        // mozhno nichego nepisat v func tak kak za4islenie proishodit avomat blagodaray modificatory payable
        // no mozhno naprimer save value addr wallet why pay me
        payments[msg.sender] = msg.value;
    }

    function withdrawAll() public
    {
        require(owner == msg.sender, "You are not an owner");
        address payable _to = payable(owner);
        address _thisContract = address(this);
        _to.transfer(_thisContract.balance);

    }
}
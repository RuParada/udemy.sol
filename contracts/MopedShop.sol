// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract MopedShop {
    mapping (address => bool) buyers; // list user to buy maped
    uint256 public price = 2 ether;
    address public owner;
    address public shopAddress;

    constructor() {
        owner = msg.sender;
        shopAddress = address(this); // ykaz na etot SC and prividenie tipov address
    }

    // func to added buyer
    // func prinim one argument - addr pokupatelya (buyer)
    // tolko public not view tak kak func must been update|write
    function addBuyer(address _addr) public { // address - type var, _addr - local var
        require(owner == msg.sender, "You are not an owner");
        buyers[_addr] = true;
    }

    // view - modificator ozna4 4to func been to read (not write)
    function getBalance() public view returns(uint) {
        return shopAddress.balance; // count in now balance SC
    }

    // func who prinimaet many
    // external - calling in outside but not to the this SC
    // payable - if exist this modifier to func will be prinimat money
    receive() external payable {

    }

}
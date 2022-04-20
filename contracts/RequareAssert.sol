// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract RequareAssert {
    // reaquire assert revert

    address owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner(address _to) {
        require(owner == msg.sender, "You are not owner");
        require(owner != address(0), "Incorrect address");
        _;
        // require(...);
    }

    function pay() external payable {
        //
    }

    function withdraw(address payable _to) external onlyOwner(_to) {
        require(owner == msg.sender, "You are not owner");

        // alternative require or it's the same as the next entry
        if(owner != msg.sender) {
            revert("You are not owner");
        } else {
            //
        }

        _to.transfer(address(this).balance);
    }

}
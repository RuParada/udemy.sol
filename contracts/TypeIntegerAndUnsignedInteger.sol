// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
/*
contract IntegerAndUnsignedInteger {
    int256 public a = -45;
    uint8 public b = 150;

    //v stepen vozvedenie
    function degree_u(uint256 x) public view returns(uint256) {
        return b ** x;
    }

    // izmenenie znacheniy peremennyh cherez settery
    function setA(uint256 _a) public {
        a = _a;
    }

    function setA(uint256 _b) public {
        b = _b;
    }
}*/

contract Counter {
    uint public count;

    function get() public view returns (uint) {
        return count;
    }

    function inc() public {
        count += 1;
    }

    function dec() public {
        count -= 1;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 < 0.9.0;

contract HelloWorld {
    string name; // var sostoyaniya and saved in blockchain

    constructor(string _name) public 
    {
        name = _name;
    }

    function getName() public view returns (string)
    {
        return name;
    }
}


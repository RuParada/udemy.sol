
/** 
 *  SourceUnit: /Users/ruslan/token/udemy.sol/contracts/HelloWorld.sol
*/

////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
pragma solidity >=0.4.22 < 0.9.0;

contract HelloWorld {
    string message; // var sostoyaniya and saved in blockchain

    constructor(string memory _message)
    {
        message = _message;
    }

    function getMessage() public view returns (string memory)
    {
        return message;
    }
}




/** 
 *  SourceUnit: /Users/ruslan/token/udemy.sol/contracts/FirstContract.sol
*/

////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
pragma solidity >=0.5.16;

contract Greetings {
    string public hello = "Hello World";

    function getHello() public view returns (string memory) {
        return hello;
    }

    function setHello(string memory newHello) public {
        hello = newHello;
    }

}

contract showWorld {
    string public messageWorld = "Hay, this world";
    uint public num = 7; // ungigned int
    bool public isActive = true; // boolean type
    address public myWallet = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4; // address type data
    uint[] public nums = [2, 120, 200]; // array with int type data
    uint[3] public numsFix = [2, 120, 200]; // fixed elements in array with int type data
    string[] public stickers = ["BTC", "ETH", "XTZ"]; // array with string type data

    function setNewMessageWorld(string memory newMessage) public {
        messageWorld = newMessage;
    }

    function setNewElement(uint index, uint newElement) public {
        nums[index] = newElement;
    }

    function pushNewElement(uint newElement) public returns (uint) {
        nums.push(newElement);
        return newElement;
    }

    function popLastElement() public returns (uint) {
        nums.pop();
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract Create2Deploy {
    address public owner;

    constructor(address _owner) {
        owner = _owner;
    }
}

contract Create2Factory {
    event Deploy(address addr);

    function deploy(uint _salt) external {
        Create2Deploy _contract = new Create2Deploy{
            salt: bytes32(_salt)
        }(msg.sender);

        emit Deploy(address(_contract));
    }

    function getAddress(bytes memory bytecode, uint _salt) public view returns (address) {

    }

    function getBytecode(address _owner) public pure returns (bytes memory) {
        
    }
}
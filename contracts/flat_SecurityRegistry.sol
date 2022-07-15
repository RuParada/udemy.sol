
/** 
 *  SourceUnit: /Users/ruslan/token/udemy.sol/contracts/SecurityRegistry.sol
*/

////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
pragma solidity ^0.8.0;

// Registry
contract SecurityRegistry {
    address owner;

    // является избирателем ?
    function isVoter(address _addr) external returns(bool) {
        // Code
    }
}

// Выборы
contract SecurityElection {
    SecurityRegistry registry;

    // имеет право на участие
    modifier isEligible(address _addr) {
        require(registry.isVoter(_addr));
        _;
    }

    // голосовать
    function vote() isEligible(msg.sender) public {
        // Code
    }

}
// контракт Registry может выполнить повторную атаку, вызвав Election.vote() внутри isVoter()


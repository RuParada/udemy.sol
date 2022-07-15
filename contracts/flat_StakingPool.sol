
/** 
 *  SourceUnit: /Users/ruslan/token/udemy.sol/contracts/StakingPool.sol
*/

////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
pragma solidity >=0.4.22 <0.9.0;

contract StakingPool {
    mapping(address => uint) balances;
    address public admin;
    uint public end;
    bool public totalInvested;
    bool public finalized;
    uint public totalChange;
    mapping(address => bool) public changeClaimed;


    event NewInvestor (
        address investor
    );

    constructor() {
        admin = msg.sender;
        end = block.timestamp + 7 days;
    }

    function invest() external payable {
        require(block.timestamp < end, 'too late');
        if(balances[msg.sender] == 0) {
            emit NewInvestor(msg.sender);
        }
        balances[msg.sender] += msg.value;
    }

    function finalize() external {
        require(block.timestamp >= end, 'too early');
        require(finalized == false, 'elready finalized');
        finalized = true;
        totalInvested = address(this).balance;
        totalChange = address(this).balance % 32 ether;
    }

    function getChange() external {
        require(finalized == true, 'not finalized');
        require(balance[msg.sender] > 0, 'not an investor');
        require(changeClaimed[msg.sender] == false, 'change already claimed');
        changeClaimed[msg.sender] = true;
        uint amount = totalChange * balance[msg.sender] / totalInvested;

        msg.sender.transfer(amount);
    }
}

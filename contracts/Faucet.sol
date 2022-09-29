// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

contract Owned {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(owner == msg.sender, "Not owner");
        _;
    }
}

contract Mortal is Owned {
    function destroy() public payable virtual onlyOwner {
        address payable owner_send = payable(address(owner));
        selfdestruct(owner_send);
    }
}

contract Faucet is Mortal {
    event Withdrawal(address indexed to, uint amount);
    event Deposit(address indexed from, uint amount);

    function withdraw(uint withdraw_amount) public {
        require(withdraw_amount <= 10000000000000000, "This count is big, must be 0.01 eth max");
        //require(this.balance >= withdraw_amount, "You have small balance");
        payable(msg.sender).transfer(withdraw_amount);
        emit Withdrawal(msg.sender, withdraw_amount);
    }

    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

}

contract Token is Mortal {
    Faucet _faucet = new Faucet();
    //Faucet _faucet = (new Faucet).value({0.5 ether})();
    //Faucet _faucet = (new Faucet).call{value: 0.5 ether}("");

    constructor (address _faucet_) {
        if(_faucet_.call("withdraw", 0.1 ether)) {
            revert("Withdrawal from faucet failed");
        }
    }

    function destroy() public payable override onlyOwner {
        _faucet.destroy();
    }
}
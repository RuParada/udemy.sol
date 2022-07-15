
/** 
 *  SourceUnit: /Users/ruslan/token/udemy.sol/contracts/UkraineAuction.sol
*/

////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
pragma solidity ^0.8.0;

////import 'hardhat/console.sol';

contract UkraineAuction {
    uint private constant DURATION = 2 days;
    address payable public immutable seller;
    uint public immutable startPrice;
    uint public immutable startAt;
    uint public immutable endAt;
    uint public immutable discountRate;
    string public item;
    bool public stopped;

    event Bought(uint price, address buyer);

    constructor(uint _startPrice, uint _discountRate, string memory _item) {
        require(_startPrice >= _discountRate * DURATION, "price to low");
        seller = payable(msg.sender);
        startPrice = _startPrice;
        discountRate = _discountRate;
        startAt = block.timestamp;
        endAt = block.timestamp + DURATION;
        item = _item;
    }

    modifier notStopped {
        require(!stopped, "has already stopped!");
        _;
    }

    function getPrice() public view notStopped returns(uint) {
        uint timeElapsed = block.timestamp - startAt;
        uint discount = discountRate * timeElapsed;
        return startPrice - discount;
    }

    function nextBlock() external {}

    fallback() external payable {}

    receive() external payable {}

    function buy() external payable notStopped {
        require(block.timestamp < endAt, "too late, auction is end");
        uint price = getPrice();
        require(msg.value >= price, "too low");
        uint refund = msg.value - price;
        if (refund > 0) {
            payable(msg.sender).transfer(refund);
        }
        seller.transfer(address(this).balance);
        stopped = true;
        emit Bought(price, msg.sender);
    }


}

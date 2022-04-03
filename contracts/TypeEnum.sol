// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import 'hardhat/console.sol';

contract Enum {
    enum Statuses {Unpaid, Paid, Shipped}
    Statuses status;

    function paid() public {
        status = Statuses.Paid;
    }

    function ship() public {
        if(status == Statuses.Paid) {
            // ...
        }
        status = Statuses.Shipped;
    }


}
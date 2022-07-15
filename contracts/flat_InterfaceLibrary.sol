
/** 
 *  SourceUnit: /Users/ruslan/token/udemy.sol/contracts/InterfaceLibrary.sol
*/

////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
pragma solidity ^0.8.0;

interface ILogger {
    function log(address _from, uint _amount) external;

    function getEntry(address _from, uint _index) external view returns(uint);  
}

// ////import "./ILogger.sol";

// можно как и contract Logger is ILogger так и без наследования 
contract Logger {
    mapping(address => uint[]) payments;

    function log(address _from, uint _amount) public {
        require(_from != address(0), "zero address");

        payments[_from].push(_amount);
    }

    // получить запись из журанала/маппинга 
    // _index - получить платёж по конкретному порядковому номеру
    function getEntry(address _from, uint _index) public view returns(uint) {
        return payments[_from][_index];
    }
}

// и теперь можно импортировать ILogger вместо Logger
// ////import "./ILogger.sol";

contract Demo {
    ILogger logger;

    constructor(address _logger) {
        logger = ILogger(_logger);
    }

    // получить инфо по платежу по какому-то порядковому номеру
    function payment(address _from, uint _number) public view returns(uint) {
        return logger.getEntry(_from, _number);
    }

    receive() external payable {
        logger.log(msg.sender, msg.value);
    }
}


///// Library //////

library StrExt {
    function eq(string memory str1, string memory str2) internal pure returns(bool) {
        return keccak256(abi.encode(str1)) == keccak256(abi.encode(str2));
    }
}

// ////import "StrExt.sol";

contract LibDemo {
    //using {eq} - можно подключить только нужные функции из библиотеки, либо всю
    using StrExt for string;

    function runnerStr(string memory str1, string memory str2) public pure returns(bool) {
        //return str1.eq(str2);
        return StrExt.eq(str1, str2);
    }
}

////// Library 2 //////

library ArrayExt {
    function inArray(uint[] memory arr, uint el) internal pure returns(bool) {
        for(uint i = 0; i < arr.length; i++) {
            if(arr[i] == el) {
                return true;
            }
        }
        return false;
    }
}

contract LibDemo2 {
    using ArrayExt for uint[];

    function runnerStr(uint[] memory numbers, uint number) public pure returns(bool) {
        //return ArrayExt.eq(members, number);
        return numbers.inArray(number);
    }
}

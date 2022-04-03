// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract TypeString {
    // динамическаий массив/курс бирж с дробями/много памяти
    string public str = "Some text";
    
    function changeStr(string memory _str) public {
        str = _str;
    }
}
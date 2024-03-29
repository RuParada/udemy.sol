// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external pure returns (uint);

    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address to, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint); 

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(address sender, address recepient, uint amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);

    event Approve(address indexed owner, address indexed to, uint value);
}
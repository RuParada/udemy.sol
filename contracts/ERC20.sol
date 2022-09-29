// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

import "./IERC20.sol";

contract ERC20 is IERC20 {
    uint totalTokens;
    address owner;
    mapping(address => uint) balances; // учёт сколько у кого токенов
    mapping(address => mapping(address => uint)) allowances; // с какого кошелька можно списать опредёллное кол-во токенов
    string _name;
    string _symbol;

    function name() external view returns (string memory) {
        return _name;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function decimals() external pure returns (uint) {
        return 18;
    }

    function totalSupply() external view returns (uint) {
        return totalTokens;
    }

    modifier enoughTokens(address _from, uint _amount) {
        require(balanceOf(_from) >= _amount, "not enough tokens!");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "not an owner!");
        _;
    }

    // shop нужен чтоб руками не перечислять влядельцу контракта токены
    // mint - введение токенов в оборот
    constructor(string memory name_, string memory symbol_, uint initialSupply, address shop) {
        _name = name_;
        _symbol = symbol_;
        owner = msg.sender;

        mint(initialSupply, shop);
    }

    function balanceOf(address account) public view returns (uint) {
        return balances[account];
    }

    function transfer(address to, uint amount) external enoughTokens(msg.sender, amount) returns (bool) {
        _beforeTokenTransfer(msg.sender, to, amount);
        balances[msg.sender] -= amount;
        balances[to] += amount;
        emit Transfer(msg.sender, to, amount);
    }

    function mint(uint amount, address shop) public onlyOwner {
        _beforeTokenTransfer(address(0), shop, amount);
        balances[shop] += amount;
        totalTokens += amount;
        emit Transfer(address(0), shop, amount);
    }

    function burn(address from, uint amount) public onlyOwner {
        _beforeTokenTransfer(from, address(0), amount);
        balances[from] -= amount;
        totalTokens -= amount;
    }

    function allowance(address _owner, address spender) public view returns (uint) {
        return allowances[_owner][spender];
    }

    function approve (address spender, uint amount) public {
        _approve(msg.sender, spender, amount);
    }

    function _approve(address sender, address spender, uint amount) internal virtual {
        allowances[sender][spender] = amount;
        emit Approve(sender, spender, amount);
    }

    function transferFrom(address sender, address recepient, uint amount) external enoughTokens(sender, amount) returns (bool) {
        _beforeTokenTransfer(sender, recepient, amount);
        require(allowances[sender][recepient] >= amount, "check allowance");
        allowances[sender][recepient] -= amount;

        balances[sender] -= amount;
        balances[recepient] += amount;
        emit Transfer(sender, recepient, amount);

    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint amount
    ) internal virtual {}

}

contract PRToken is ERC20 {
    constructor(address shop) ERC20("PRToken", "PRT", 1000, shop) {}
}

contract PRShop {
    IERC20 public token;
    address payable public owner;
    event Bought(uint _amount, address indexed _buyer);
    event Sold(uint _amount, address indexed _seller);

    constructor() {
        token = new PRToken(address(this));
        owner = payable(msg.sender);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "not an owner!");
        _;
    }

    function sell(uint _amountToSell) external {
        require(
            _amountToSell > 0 &&
            token.balanceOf(msg.sender) >= _amountToSell,
            "incorrect amount!"
        );
    }

    receive() external payable {
        uint tokensToBuy = msg.value; /// 1wei - 1token
        require(tokensToBuy > 0, "not enough founds!");

        uint currentBalance = tokenBalance();
        require(currentBalance >= tokensToBuy, "not enough tokens!");

        token.transfer(msg.sender, tokensToBuy);
        emit Bought(tokensToBuy, msg.sender);
    }


}
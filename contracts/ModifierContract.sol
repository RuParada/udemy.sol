// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract helloWorld {

    struct Company {
        string name;
        uint age;
        uint workers;
    }

    mapping(address => Company) private companies;

    address public ceo;

    modifier onlyOwner() {
        require(msg.sender == ceo, "Your are not ceo!");
        _; // prodolzhit vipolnenie func 
    }

    constructor() {
        ceo = msg.sender;

    }

    function addCompany(string memory name, uint age, uint workers) public {
        require(age < 2, "your company shold be older then 2 years ");
        address sender = msg.sender; 
    
        Company memory newCompany;
        newCompany.name = name;
        newCompany.age = age;
        newCompany.workers = workers;

        companies[sender] = newCompany;
    }

    function getCompany() public view returns (string memory name, uint age, uint workers) {
        address sender = msg.sender;
        return (companies[sender].name, companies[sender].age, companies[sender].workers);
    }

    function deleteCompany (address sender) public onlyOwner {
        
        delete companies[sender];
    }

}
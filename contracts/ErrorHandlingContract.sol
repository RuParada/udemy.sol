// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

// create mapping unique is addres and return owner wallel company

contract helloWorld {

    struct Company {
        string name;
        uint age;
        uint workers;
    }

    // worked privazky addreess wallet in to compani
    mapping(address => Company) private companies;

    address public ceo; // public for see get function vivoda

    // func why realisation and ispolnayetsa one time 4tob SC zapyshen s moego addr
    constructor() {
        ceo = msg.sender;

    }

    function addCompany(string memory name, uint age, uint workers) public {
        require(age < 2, "your company shold be older then 2 years ");
        address sender = msg.sender; // vstroenaya func - vernyt addr inicialtora etogo walleta/contracta
    
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

    function deleteCompany (address sender) public {
        require(msg.sender == ceo, "Your are not ceo!");
        delete companies[sender];
    }

}
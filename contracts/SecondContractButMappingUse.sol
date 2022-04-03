// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

// use Mapping and Internal func visibility

contract SecondContractMappingUse {
    struct Company {
        string name;
        uint age;
        uint workers;
        string status;
    }

    mapping(address => Company) private companies;

    function addCompany (string memory name, uint age, uint workers, string memory status) public {
        //address sender = msg.sender;
        Company memory newCompany;
        //newCompany.id = companies.length + 1;
        newCompany.name = name;
        newCompany.age = age;
        newCompany.workers = workers;

        if(workers <= 10) {
            newCompany.status = "small";
        } else if (workers > 10 && workers <= 30) {
            newCompany.status = "medium";
        } else {
            newCompany.status = "big";
        }
        //companies[sender] = newCompany;
        insertCompany(newCompany);
    }

    function insertCompany (Company memory newCompany) private {
        address sender = msg.sender;
        companies[sender] = newCompany;
    }

    function getCompany () public view returns (string memory name, uint age, uint workers, string memory status) {
        address sender = msg.sender;
        return (companies[sender].name, companies[sender].age, companies[sender].workers, companies[sender].status);
    }

}
// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract helloWorld {
    // набор компаний которые имеют свои криптокашельки

    struct Company {
        // structured data base and type

        uint id; // id company
        string name; // company name
        uint age; // count years company exist
        uint numberOfWorkers; // count workers in company
        address companyWallet; // company wallet
        string status; // company staus - big, medium or small

    }

    // logic create new company and new push data for this company
    // Company - type struct value array
    // for save value

    Company[] public companies; // in fact this is array

    // func with create added new sychnosti

    function newCompany(string memory name, uint age, uint numberOfWorkers, address companyWallet) public {
        //logic initiation
        // add new value to array

        //companies.push(Company(companies.length +1, name, age, numberOfWorkers, companyWallet));
    
        // and now second way (not population)
        
        Company memory newCompanies;
        newCompanies.id = companies.length + 1;
        newCompanies.name = name;
        newCompanies.age = age;
        newCompanies.numberOfWorkers = numberOfWorkers;
        newCompanies.companyWallet = companyWallet;

        if(numberOfWorkers <= 10) {
            newCompanies.status = "small";
        } else if (numberOfWorkers > 10 && numberOfWorkers <= 30) {
            newCompanies.status = "medium";
        } else {
            newCompanies.status = "big";
        }

        companies.push(newCompanies);
    
    }

}
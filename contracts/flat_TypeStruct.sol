
/** 
 *  SourceUnit: /Users/ruslan/token/udemy.sol/contracts/TypeStruct.sol
*/

//pragma solidity ^0.4.18;
//pragma solidity >=0.5.3;
//pragma solidity ^0.8.7;
//pragma solidity >=0.4.22 <0.9.0;
//pragma solidity >=0.4.0 <0.9.0;
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
//pragma solidity ^0.8.3;

////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
pragma solidity >=0.4.22 <0.9.0;

contract TypeStruct {
    struct Person {
        string name;
        string job;
        uint age;
    }
    
    Person[] public persons;
    
    function addPerson(string memory _name, string memory _job, uint _age) public {
        persons.push(Person(_name, _job, _age));
    } 
}

contract DemoStruct {
    struct Payment {
        uint amount;
        uint timestamp;
    }

    Payment[] public payments;

    function sample() public payable {
        Payment memory payment = Payment(msg.value, block.timestamp);
        payments.push(payment);
    }

    function withdraw(address payable _to) public {
        uint totalPayments;
        for(uint i = 0; i < payments.length; i++) {
            totalPayments += payments[i].amount;
        }

        _to.transfer(totalPayments);
    }

    struct Balance {
        uint totalBalance;
        mapping(uint => Payment) payments;
    }
}

contract Payments {
    
}


/*
contract Todos {
    struct Todo {
        string text;
        bool completed;
    }

    // An array of 'Todo' structs
    Todo[] public todos;

    function create(string memory _text) public {
        // 3 ways to initialize a struct
        // - calling it like a function
        todos.push(Todo(_text, false));

        // key value mapping
        todos.push(Todo({text: _text, completed: false}));

        // initialize an empty struct and then update it
        Todo memory todo;
        todo.text = _text;
        // todo.completed initialized to false

        todos.push(todo);
    }

    // Solidity automatically created a getter for 'todos' so
    // you don't actually need this function.
    function get(uint _index) public view returns (string memory text, bool completed) {
        Todo storage todo = todos[_index];
        return (todo.text, todo.completed);
    }

    // update text
    function update(uint _index, string memory _text) public {
        Todo storage todo = todos[_index];
        todo.text = _text;
    }

    // update completed
    function toggleCompleted(uint _index) public {
        Todo storage todo = todos[_index];
        todo.completed = !todo.completed;
    }
}*/

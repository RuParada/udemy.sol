// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC721Metadata.sol";

/**
 * The contractName contract does this and that...
 */
contract ERC721 is IERC721Metadata {
	string public name;
	string public symbol;

	// сколько и у кого есть нфт
	mapping (address => uint) _balances;
	// у каждого нфт есть свой владелец - мы отследиваем
	mapping (uint => address) _ownres; 
	// разрешение на управлением определённого моего нфт
	mapping (uint => address) _tokenApprovals;

	// отображаем что конкретный аддресс может управлять токеном
	// адресс оператора в нём адресс владельца и можно или нельзя
	mapping (address => mapping(address => bool)) _operatorApprovals;
	

	constructor(string memory _name, string memory _symbol) {
		name = _name;
		symbol = _symbol;

	}
}




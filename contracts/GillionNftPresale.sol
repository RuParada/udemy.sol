// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
                                          
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract GillionNftPresale is EIP712, ERC721Enumerable, Ownable {

    bytes32 public constant PRESALE_TYPEHASH = keccak256("Presale(address buyer,uint256 maxCount)");

    function _hash(address _buyer, uint _maxCount) internal view returns(bytes32 hash) {
        hash = _hashTypedDataV4(keccak256(abi.encode(
            PRESALE_TYPEHASH,
            _buyer,
            _maxCount
        )));
    }

    function _verify(bytes32 digest, bytes memory signature) internal view returns(bool) {
    
    }

    
    function buy(uint256 tokenQuantity) external payable {

    }
    
    function presaleBuy(uint256 tokenQuantity, uint256 maxCount, bytes memory signature) external payable {

    }
    
    
}
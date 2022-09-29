// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

//import "../../utils/introspection/IERC165.sol";

/**
  * @dev Интерфейс стандарта ERC165, как определено в
  * https://eips.ethereum.org/EIPS/eip-165[EIP].
  *
  * Разработчики могут заявить о поддержке контрактных интерфейсов, которые затем могут быть
  * запрошено другими ({ERC165Checker}).
  *
  * Для реализации см. {ERC165}.
  */
interface IERC165 {
    /**
      * @dev Возвращает true, если этот контракт реализует интерфейс, определенный
      * `идентификатор интерфейса`. См. соответствующий
      * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[раздел EIP]
      * чтобы узнать больше о том, как создаются эти идентификаторы.
      *
      * Этот вызов функции должен использовать менее 30 000 газа.
    */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

interface IERC721 is IERC165 {
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );
    event Approval(
        address indexed owner,
        address indexed approved,
        uint256 indexed tokenId
    );
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    function balanceOf(address owner) external view returns (uint256 balance);

    function ownerOf(uint256 tokenId) external view returns (address owner);

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function approve(address to, uint256 tokenId) external;

    function setApprovalForAll(address operator, bool _approved) external;

    function getApproved(uint256 tokenId)
        external
        view
        returns (address operator);

    function isApprovedForAll(address owner, address operator)
        external
        view
        returns (bool);
}

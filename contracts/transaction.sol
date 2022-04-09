//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./interfaces/IMinter.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract Transaction is IERC721Receiver{

    address to;

    constructor(address multi) {
        to = multi;
    }

    function transact(address contractAdd) external payable {
        IMinter(contractAdd).mint{value: msg.value}(1);
    }

    //auto transfer to multi sig wallet
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) public virtual override returns (bytes4) {
        IERC721(operator).safeTransferFrom(address(this), to, tokenId);
        return this.onERC721Received.selector;
    }

}
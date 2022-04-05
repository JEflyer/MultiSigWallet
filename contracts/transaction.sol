//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./interfaces/IMinter.sol";

contract Transaction {

    function transact(address contractAdd) external payable {
        IMinter(contractAdd).mint{value: msg.value}(1)(msg.sender);
    }

}
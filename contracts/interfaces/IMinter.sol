//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface IMinter {
    function mint(uint8 _amount) external payable;
}
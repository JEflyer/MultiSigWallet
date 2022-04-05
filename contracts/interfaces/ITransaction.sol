//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface ITransaction{
    function transact() external payable returns(uint16);
}
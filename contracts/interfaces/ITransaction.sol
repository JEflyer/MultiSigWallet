//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface ITransaction{
    function transact(address contractAdd) external payable;
}
  //SPDX-License-Identifier:  MIT

pragma solidity >=0.8.0;

import "hardhat/console.sol";

import "./Registry.sol";

contract RegisterFactory {
    Registry[] public registrys;
    address payable public owner;

    function createRegister() public {
        owner = payable (msg.sender);
        Registry registry = new Registry(owner);
        registrys.push(registry);
    }
}
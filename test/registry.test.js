const { expect, assert } = require("chai");
const { ethers } = require("hardhat");

describe("RegisterFactory", function () {
  it("Should deploy RegisterFactory and create a new registry contract successfully", async function () {
    const RegisterFactory = await ethers.getContractFactory("RegisterFactory");
    const registerFactory = await RegisterFactory.deploy();
    await registerFactory.deployed();
 
    
    console.log(`RegisterFactory deployed @ ${registerFactory.address}`);

    await registerFactory.createRegister();

    const newCreatedRegisterContract = await registerFactory.registrys(0);
     
    console.log(`a new register contract created @ ${newCreatedRegisterContract}`);

   
  });
});

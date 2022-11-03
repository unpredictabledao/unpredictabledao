const { ethers } = require("hardhat");
const hre = require("hardhat");

async function main() {
    const [ deployer ] = await ethers.getSigners();

    // Deploy Token contract
    const Token = await hre.ethers.getContractFactory("Token");
    const token = await Token.deploy(deployer.address);

    await token.deployed();

    console.log("Token deployed to:", token.address);


    // Deploy Rice contract
    const Rice = await hre.ethers.getContractFactory("Rice");
    const rice = await Rice.deploy(token.address);

    await rice.deployed();

    console.log("Rice deployed to:", rice.address);
}

main();

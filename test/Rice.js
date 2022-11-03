const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("RNG contract", function () {
  let deployer, Token, token, Rice, rice;

  beforeEach(async function () {
    [deployer] = await ethers.getSigners();

    Token = await ethers.getContractFactory("Token");
    token = await Token.deploy(deployer.address);

    await token.deployed();

    Rice = await hre.ethers.getContractFactory("Rice");
    rice = await Rice.deploy(token.address);

    await rice.deployed();
  });

  describe("Submission", () => {
    it("Should revert because not enough money is locked", async function () {
      let randomHash = ethers.utils.keccak256(
          ethers.utils.toUtf8Bytes(
              Math.floor(Math.random() * 10000).toString()
          )
      );

      await expect(rice.submit(randomHash)).to.be.revertedWith("Not enough money to participate.");
    });
  });

  describe("Submit", () => {
    it("Should revert because not enough money is locked", async function () {
      let randomHash = ethers.utils.keccak256(
          ethers.utils.toUtf8Bytes(
              Math.floor(Math.random() * 10000).toString()
          )
      );

      await expect(rice.submit(randomHash)).to.be.revertedWith("Not enough money to participate.");
    });
  });

  describe("Reveal", () => {
    it("Should revert because submission does not exist.", async function () {
      let realValue = Math.floor(Math.random() * 2147483648);
    
      let dummyValue = ethers.utils.keccak256(
          ethers.utils.toUtf8Bytes(
              Math.floor(Math.random() * 10000).toString()
          )
      );

      await expect(rice.reveal(100, realValue, dummyValue)).to.be.revertedWith("Submission does not exist.");
    });
  });

  describe("Generate random number", () => {
    it("Should revert because not enough money is sent", async function () {
      await expect(rice.generateNumber()).to.be.revertedWith("Not enough money to call contract.");
    });
  });

  describe("Collect reward", () => {
    it("Should revert because campaign/submission doesn't exist", async function () {
      await expect(rice.collectReward(100)).to.be.revertedWith("Submission is either not revealed, non-existent or participant has already been rewarded.");
    });
  });
});

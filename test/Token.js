const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("DGT Token Contract", function () {
  let deployer, addr1, addr2, Token, token, decimals;

  beforeEach(async function () {
    [deployer, addr1, addr2] = await ethers.getSigners();

    Token = await ethers.getContractFactory("Token");

    token = await Token.deploy(deployer.address);

    await token.deployed();

    decimals = await token.decimals();
  });

  describe("Deployment", () => {
    it("Deployment should assign the total supply of tokens to the owner", async function () {
      expect(await token.totalSupply()).to.equal(await token.balanceOf(deployer.address));
    });
  });


  describe("Transactions", () => {
    it("Should transfer tokens between accounts", async function() {
      // Transfer 50 tokens from deployer to addr1
      const amount = 50 * 10 ** decimals;

      await token.transfer(addr1.address, amount);
      expect(await token.balanceOf(addr1.address)).to.equal(amount);
  
      // Transfer 50 tokens from addr1 to addr2
      await token.connect(addr1).transfer(addr2.address, amount);
      expect(await token.balanceOf(addr2.address)).to.equal(amount);
    });

    it("Should transfer after being approved and have the correct allowance", async function() {
      const allowedAmount = 1000 * 10 ** decimals;
      const oldAdd2Balance = await token.balanceOf(addr2.address);
      const amountToBeSent = 500 * 10 ** decimals;

      await token.approve(addr1.address, allowedAmount);

      await token.connect(addr1).transferFrom(deployer.address, addr2.address, amountToBeSent);

      expect(await token.balanceOf(addr2.address)).to.equal(oldAdd2Balance.add(amountToBeSent));

      expect(allowedAmount - amountToBeSent).to.equal(await token.allowance(deployer.address, addr1.address));
    });
  });
});

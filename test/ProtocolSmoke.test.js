const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("MVP Contratos Web3", function () {
  async function deployFixture() {
    const [admin, validator, voter] = await ethers.getSigners();

    const MockPriceFeed = await ethers.getContractFactory("MockPriceFeed");
    const mockFeed = await MockPriceFeed.deploy(3000e8);
    await mockFeed.waitForDeployment();

    const Token = await ethers.getContractFactory("ContractToken");
    const token = await Token.deploy(admin.address, ethers.parseUnits("1000000", 18));
    await token.waitForDeployment();

    const NFT = await ethers.getContractFactory("DocumentNFT");
    const nft = await NFT.deploy(admin.address);
    await nft.waitForDeployment();

    const Staking = await ethers.getContractFactory("ContractStaking");
    const staking = await Staking.deploy(
      admin.address,
      await token.getAddress(),
      await nft.getAddress(),
      await mockFeed.getAddress(),
      ethers.parseUnits("1000", 18),
      ethers.parseUnits("10", 18)
    );
    await staking.waitForDeployment();

    const Governance = await ethers.getContractFactory("ContractGovernanceDAO");
    const governance = await Governance.deploy(
      admin.address,
      await token.getAddress(),
      await staking.getAddress(),
      ethers.parseUnits("5000", 18),
      3600
    );
    await governance.waitForDeployment();

    const validatorRole = await nft.VALIDATOR_ROLE();
    await nft.grantRole(validatorRole, await staking.getAddress());

    const governanceRole = await staking.GOVERNANCE_ROLE();
    await staking.grantRole(governanceRole, await governance.getAddress());

    await token.transfer(validator.address, ethers.parseUnits("5000", 18));
    await token.transfer(voter.address, ethers.parseUnits("7000", 18));
    await token.approve(await staking.getAddress(), ethers.parseUnits("50000", 18));
    await staking.fundRewardPool(ethers.parseUnits("50000", 18));

    return { admin, validator, voter, token, nft, staking, governance, mockFeed };
  }

  it("registra, valida e recompensa um documento", async function () {
    const { admin, validator, token, nft, staking } = await deployFixture();

    const hash = ethers.keccak256(ethers.toUtf8Bytes("contrato-001"));
    await nft.connect(admin).registerDocument(hash, "DOC-001", "ipfs://meta");
    await nft.connect(admin).signDocument(1);

    await token.connect(validator).approve(await staking.getAddress(), ethers.parseUnits("1500", 18));
    await staking.connect(validator).stake(ethers.parseUnits("1500", 18));

    await expect(staking.connect(validator).validateDocument(1)).to.emit(staking, "DocumentValidatedAndRewarded");

    const exists = await nft.verifyByHash(hash);
    expect(exists[0]).to.equal(true);
  });
});

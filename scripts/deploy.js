const hre = require("hardhat");
const fs = require("fs");
const path = require("path");
require("dotenv").config();

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  const priceFeed = process.env.PRICE_FEED_ADDRESS;

  if (!priceFeed) {
    throw new Error("Defina PRICE_FEED_ADDRESS no .env");
  }

  console.log("Deploy com:", deployer.address);

  const Token = await hre.ethers.getContractFactory("ContractToken");
  const token = await Token.deploy(deployer.address, hre.ethers.parseUnits("1000000", 18));
  await token.waitForDeployment();

  const NFT = await hre.ethers.getContractFactory("DocumentNFT");
  const nft = await NFT.deploy(deployer.address);
  await nft.waitForDeployment();

  const Staking = await hre.ethers.getContractFactory("ContractStaking");
  const staking = await Staking.deploy(
    deployer.address,
    await token.getAddress(),
    await nft.getAddress(),
    priceFeed,
    hre.ethers.parseUnits("1000", 18),
    hre.ethers.parseUnits("10", 18)
  );
  await staking.waitForDeployment();

  const Governance = await hre.ethers.getContractFactory("ContractGovernanceDAO");
  const governance = await Governance.deploy(
    deployer.address,
    await token.getAddress(),
    await staking.getAddress(),
    hre.ethers.parseUnits("5000", 18),
    3 * 24 * 60 * 60
  );
  await governance.waitForDeployment();

  const output = {
    network: hre.network.name,
    deployer: deployer.address,
    token: await token.getAddress(),
    documentNFT: await nft.getAddress(),
    staking: await staking.getAddress(),
    governance: await governance.getAddress(),
    priceFeed,
  };

  const outFile = path.join(__dirname, "..", "docs", "deployed-addresses.json");
  fs.writeFileSync(outFile, JSON.stringify(output, null, 2));

  console.log("Enderecos gravados em", outFile);
  console.table(output);
  console.log("Proximo passo: executar scripts/grantRoles.js e depois fundear o staking.");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

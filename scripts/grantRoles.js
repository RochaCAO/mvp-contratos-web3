const hre = require("hardhat");
require("dotenv").config();

async function main() {
  const tokenAddress = process.env.TOKEN_ADDRESS;
  const nftAddress = process.env.NFT_ADDRESS;
  const stakingAddress = process.env.STAKING_ADDRESS;
  const governanceAddress = process.env.GOVERNANCE_ADDRESS;

  if (!tokenAddress || !nftAddress || !stakingAddress || !governanceAddress) {
    throw new Error("Preencha TOKEN_ADDRESS, NFT_ADDRESS, STAKING_ADDRESS e GOVERNANCE_ADDRESS no .env");
  }

  const nft = await hre.ethers.getContractAt("DocumentNFT", nftAddress);
  const staking = await hre.ethers.getContractAt("ContractStaking", stakingAddress);

  const VALIDATOR_ROLE = await nft.VALIDATOR_ROLE();
  const GOVERNANCE_ROLE = await staking.GOVERNANCE_ROLE();

  console.log("Grant VALIDATOR_ROLE ao staking...");
  await (await nft.grantRole(VALIDATOR_ROLE, stakingAddress)).wait();

  console.log("Grant GOVERNANCE_ROLE a governance...");
  await (await staking.grantRole(GOVERNANCE_ROLE, governanceAddress)).wait();

  console.log("Roles concedidos com sucesso.");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

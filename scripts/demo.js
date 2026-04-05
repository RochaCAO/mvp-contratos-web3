require("dotenv").config();
const { ethers } = require("ethers");

const rpcUrl = process.env.SEPOLIA_RPC_URL;
const deployerPk = process.env.PRIVATE_KEY;
const validatorPk = process.env.VALIDATOR_PRIVATE_KEY || process.env.PRIVATE_KEY;

const tokenAddress = process.env.TOKEN_ADDRESS;
const nftAddress = process.env.NFT_ADDRESS;
const stakingAddress = process.env.STAKING_ADDRESS;
const governanceAddress = process.env.GOVERNANCE_ADDRESS;
const docHashSource = process.env.DOC_HASH_SOURCE || "Contrato de servicos exemplo";

if (!rpcUrl || !deployerPk || !tokenAddress || !nftAddress || !stakingAddress || !governanceAddress) {
  throw new Error("Preencha o .env com RPC, chaves e enderecos dos contratos.");
}

const provider = new ethers.JsonRpcProvider(rpcUrl);
const admin = new ethers.Wallet(deployerPk, provider);
const validator = new ethers.Wallet(validatorPk, provider);

const tokenAbi = [
  "function approve(address spender, uint256 amount) external returns (bool)",
  "function transfer(address to, uint256 amount) external returns (bool)",
  "function balanceOf(address account) external view returns (uint256)"
];

const nftAbi = [
  "function registerDocument(bytes32 documentHash, string externalReference, string tokenURI_) external returns (uint256)",
  "function nextTokenId() external view returns (uint256)",
  "function signDocument(uint256 tokenId) external",
  "function verifyByHash(bytes32 documentHash) external view returns (bool,uint256,address,uint64,uint64,bool,address)"
];

const stakingAbi = [
  "function fundRewardPool(uint256 amount) external",
  "function stake(uint256 amount) external",
  "function validateDocument(uint256 tokenId) external",
  "function previewReward() external view returns (uint256,uint256)"
];

const governanceAbi = [
  "function createProposal(uint8 proposalType, uint256 newValue, string description) external returns (uint256)",
  "function vote(uint256 proposalId, bool support) external"
];

async function main() {
  const tokenAdmin = new ethers.Contract(tokenAddress, tokenAbi, admin);
  const tokenValidator = new ethers.Contract(tokenAddress, tokenAbi, validator);
  const nftAdmin = new ethers.Contract(nftAddress, nftAbi, admin);
  const stakingAdmin = new ethers.Contract(stakingAddress, stakingAbi, admin);
  const stakingValidator = new ethers.Contract(stakingAddress, stakingAbi, validator);
  const governanceAdmin = new ethers.Contract(governanceAddress, governanceAbi, admin);

  const rewardFunding = ethers.parseUnits("50000", 18);
  const validatorFunding = ethers.parseUnits("3000", 18);
  const stakeAmount = ethers.parseUnits("1500", 18);

  console.log("1) Fundeando pool de recompensa...");
  await (await tokenAdmin.approve(stakingAddress, rewardFunding)).wait();
  await (await stakingAdmin.fundRewardPool(rewardFunding)).wait();

  console.log("2) Transferindo CRT para validador...");
  await (await tokenAdmin.transfer(validator.address, validatorFunding)).wait();

  console.log("3) Registrando documento como NFT...");
  const docHash = ethers.keccak256(ethers.toUtf8Bytes(docHashSource));
  const estimatedTokenId = await nftAdmin.nextTokenId();
  await (await nftAdmin.registerDocument(docHash, "DOC-001-2026", "ipfs://metadata-placeholder")).wait();
  await (await nftAdmin.signDocument(estimatedTokenId)).wait();

  console.log("4) Staking do validador...");
  await (await tokenValidator.approve(stakingAddress, stakeAmount)).wait();
  await (await stakingValidator.stake(stakeAmount)).wait();

  const [reward, oraclePrice] = await stakingValidator.previewReward();
  console.log("Recompensa prevista:", ethers.formatUnits(reward, 18), "CRT");
  console.log("Preco do oracle:", oraclePrice.toString());

  console.log("5) Validando documento e recebendo recompensa...");
  await (await stakingValidator.validateDocument(estimatedTokenId)).wait();

  console.log("6) Criando proposta de governanca (SetBaseReward)...");
  await (await governanceAdmin.createProposal(0, ethers.parseUnits("15", 18), "Ajustar recompensa base para 15 CRT")).wait();

  console.log("7) Votando na proposta...");
  await (await governanceAdmin.vote(1, true)).wait();

  console.log("8) Verificacao final do documento pelo hash...");
  const verification = await nftAdmin.verifyByHash(docHash);
  console.log(verification);
  console.log("Demo concluida.");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

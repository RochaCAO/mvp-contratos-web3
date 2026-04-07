# MVP Web3 — Contratos e Documentos com Validação On-Chain

Esse é um Projeto acadêmico pertinente ao Curso Smart Contracts da Formação Web 3.0.
O projeto foi estruturado para o estudo de caso **"Contratos"**, atendendo ao enunciado 
que exige **ERC-20, NFT, staking, governança simplificada, oráculo, integração Web3 e 
deploy em testnet**. O núcleo funcional do caso de uso foi mantido aderente ao slide 
de MVP aceitável para contratos: **registrar hash, assinatura e verificação**.

## 1. Problema resolvido

Processos de contratação digital frequentemente sofrem com três fragilidades:

1. dificuldade de provar a integridade do documento depois da assinatura;
2. baixa rastreabilidade sobre quem registrou, assinou e validou o contrato;
3. falta de incentivo econômico para validadores e curadores do protocolo.

## 2. Solução proposta

O MVP cria um fluxo descentralizado em que:

- um documento é registrado por **hash** e representado por um **NFT ERC-721**;
- partes interessadas registram seu aceite/assinatura on-chain;
- validadores fazem **staking** do token do protocolo e validam documentos;
- a recompensa de validação é ajustada por um **oráculo Chainlink ETH/USD**;
- parâmetros do staking podem ser alterados por uma **DAO simplificada**;
- um **script ethers.js** demonstra o uso prático do sistema.

## 3. Arquitetura

```mermaid
flowchart LR
    A[Usuário / Emissor] -->|registerDocument| B[DocumentNFT ERC-721]
    A -->|signDocument| B
    C[Validador] -->|stake CRT| D[ContractStaking]
    D -->|recordValidation| B
    D -->|reward CRT| C
    E[Chainlink ETH/USD] -->|latestRoundData| D
    F[Token Holder] -->|createProposal / vote| G[Governance DAO]
    G -->|setBaseReward / setMinStake / pause| D
    H[Backend ethers.js] --> B
    H --> D
    H --> G
    I[ContractToken ERC-20] -->|fundRewardPool / transfer / voting power| D
    I --> G
```

## 4. Contratos

### `ContractToken.sol`
- ERC-20 via OpenZeppelin.
- símbolo: `CRT`.
- `MINTER_ROLE` para mint controlado.
- usado em staking, recompensas e governança.

### `DocumentNFT.sol`
- ERC-721 via OpenZeppelin.
- registra `documentHash`, `creator`, `createdAt`, `validationCount`, `externalReference`.
- mantém unicidade de hash.
- registra assinatura on-chain (`signDocument`).
- permite verificação por hash (`verifyByHash`).

### `ContractStaking.sol`
- staking com `ReentrancyGuard`, `Pausable`, `AccessControl` e `SafeERC20`.
- valida documentos apenas para carteiras com stake mínimo.
- consulta o oráculo `ETH/USD` e ajusta a recompensa por tiers.

### `ContractGovernanceDAO.sol`
- governança simplificada.
- criação de propostas baseada em `balanceOf` do token.
- votação e execução de parâmetros sobre o staking.
- ações suportadas:
  - alterar recompensa base;
  - alterar stake mínimo;
  - pausar staking;
  - despausar staking.

## 5. Segurança aplicada

- Solidity `^0.8.24`.
- `ReentrancyGuard` no staking.
- `AccessControl` para funções administrativas.
- `Pausable` no staking.
- `SafeERC20` para transferências do token.
- prevenção de duplicidade de hash do documento.
- prevenção de validação duplicada por validador.
- validações explícitas de endereço zero, quantidade zero e parâmetros críticos.
- padrão **checks-effects-interactions** no staking.

## 6. Oráculo

O contrato de staking usa `AggregatorV3Interface` para consultar **ETH/USD**. A lógica do MVP aplica um tier simples:

- `>= 3500 USD` → `2x` recompensa base
- `>= 2500 USD` → `1.5x` recompensa base
- abaixo disso → recompensa base

> Observação: para produção, o ideal é calibrar a fórmula econômica com maior rigor e monitorar staleness do feed.

## 7. Integração Web3

O arquivo `scripts/demo.js` demonstra:

1. funding do pool de recompensa;
2. transferência de tokens ao validador;
3. registro de documento como NFT;
4. assinatura on-chain;
5. stake do validador;
6. validação do documento com recompensa;
7. criação de proposta de governança;
8. votação;
9. verificação final do documento por hash.

## 8. Deploy em Sepolia

### Pré-requisitos

- Node.js 20+
- carteira com ETH de teste
- RPC Sepolia
- endereço do feed ETH/USD da rede escolhida

### Instalação

```bash
npm install 
```
```PowerShell
Copy-Item .env.example .env
```

### Compilar

```bash
npx hardhat compile
```

### Deploy

```bash
npx hardhat run scripts/deploy.js --network sepolia
```

### Conceder roles após deploy

```bash
npx hardhat run scripts/grantRoles.js --network sepolia
```

## 9. Campos para entrega final
Preenchidos após o deploy real:

- Rede usada: `Sepolia`

- Endereço do `ContractToken`: `0x30DDDDad124B292C513a5F96E907f410541F53B2`
- Endereço do `DocumentNFT`: `0xDec861d2A470eC534F0933d4ddd25e0066e1df4E`
- Endereço do `ContractStaking`: `0x08044379CeFf8Cd3C6b6061c0B7c326dFCDf5164`
- Endereço do `ContractGovernanceDAO`: `0x250023bE3540533c5fab65deE7AfD51d774eAfaA`

- Hashes das transações de deploy:
  - `ContractToken`: `0xc9cd94ba0d6f2dfe1f0dc968b072485926d71a9b355c648e6a09afa8743208cb`
  - `DocumentNFT`: `0x336436833dbd6853d013f8177e736a2daeed6a65809e9bf834b76b2615ddfa9d`
  - `ContractStaking`: `0xad8a67307735ca1fd008bd0ab0e0ac70e525131bf2a64845570afd4b96ae54d1`
  - `ContractGovernanceDAO`: `0x03ee07247c8251d47ae83c4f37f291c583f0a8553aeb0ec620b6be5e52228f41`

- Hashes de execução de exemplo:
  - Registro (`DocumentNFT / registerDocument`): `0x954f0c0d4344056c596d41a33e4d56f0789dbfba67c91039681ab582f9336d77`
  - Validação (`ContractStaking / validateDocument`): `0x330a58db86888bfeef2d6f49daa53672f0f3ed538ce7310bf9b47ff322b5f3fc`
  - Voto (`ContractGovernanceDAO / vote`): `0x5f71536c01b094b029877cde74df99a3b3ddafe923d4192cfc6696a43728ac21`
  - Token (`ContractToken / transfer`): `0x5a1cf9dbf1fc01fe513c445ec8655709da435bfcf06c276be07d4435fe8471b2`

- Links do explorer:
  - Token: `https://sepolia.etherscan.io/address/0x30DDDDad124B292C513a5F96E907f410541F53B2`
  - DocumentNFT: `https://sepolia.etherscan.io/address/0xDec861d2A470eC534F0933d4ddd25e0066e1df4E`
  - Staking: `https://sepolia.etherscan.io/address/0x08044379CeFf8Cd3C6b6061c0B7c326dFCDf5164`
  - Governance: `https://sepolia.etherscan.io/address/0x250023bE3540533c5fab65deE7AfD51d774eAfaA`

- Link do GitHub: `https://github.com/RochaCAO/mvp-contratos-web3`


## 10. Limitações conhecidas do MVP

- a DAO não usa snapshot de saldo, então não é adequada para produção sem aprimoramento;
- a assinatura do documento é uma atestação on-chain simples, não um fluxo jurídico completo com EIP-712;
- o modelo não implementa slashing de validadores;
- o valor jurídico do documento continua dependendo do processo de negócio e da camada legal/off-chain.

## 11. Estrutura do repositório

```text
README.md
hardhat.config.js
mythril.remappings.json
package.json
package-lock.json
contracts/
  ContractToken.sol
  DocumentNFT.sol
  ContractStaking.sol
  ContractGovernanceDAO.sol
  MockPriceFeed.sol
  interfaces/
    AggregatorV3Interface.sol
    IDocumentNFT.sol
    IStakingGovernance.sol
scripts/
  demo.js
  deploy.js
  grantRoles.js
test/
  ProtocolSmoke.test.js
docs/
  deployed-addresses.json
  ENTREGA_STATUS.md
  relatorio_tecnico_base.md
  roteiro_video.md
audit/
  relatorio_auditoria_base.md
  real_outputs/
    slither-output.txt
    slither-checklist.md
    mythril-ContractToken.txt
    mythril-DocumentNFT.txt
    mythril-ContractStaking.txt
    mythril-ContractGovernanceDAO.txt
```

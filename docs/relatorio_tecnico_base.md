# Relatório Técnico — MVP Web3 de Contratos e Documentos com Validação On-Chain

## 1. Identificação
- Disciplina: Web 3.0 — Fase 2 Avançada
- Entrega: Unidade 1 | Capítulo 5
- Estudo de caso: **Contratos**
- Aluno: Carlos Rocha

## 2. Objetivo do MVP
Construir um protocolo descentralizado funcional que integre token ERC-20, NFT, staking, governança simplificada, oráculo, backend Web3 e deploy em testnet, mantendo aderência ao estudo de caso de contratos digitais com registro por hash, assinatura e verificação.

## 3. Problema
No fluxo digital tradicional, contratos podem sofrer com:
- dificuldade de comprovar integridade após o compartilhamento do arquivo;
- pouca auditabilidade sobre quem registrou, assinou e validou o documento;
- dependência excessiva de intermediários centralizados;
- baixa transparência sobre incentivos econômicos para validadores do protocolo.

## 4. Solução proposta
O protocolo permite:
1. registrar o hash de um documento no blockchain;
2. representar esse registro como NFT ERC-721;
3. registrar assinaturas/aceites on-chain;
4. exigir staking do token CRT para formar validadores;
5. recompensar a validação de documentos;
6. ajustar a recompensa conforme o preço ETH/USD via Chainlink;
7. governar parâmetros essenciais via DAO simplificada.

## 5. Justificativa dos padrões ERC
### 5.1 ERC-20
Escolhido para representar a camada econômica do protocolo, viabilizando:
- staking;
- recompensa;
- poder de voto.

### 5.2 ERC-721
Escolhido para representar individualmente cada documento/contrato registrado. Cada NFT corresponde a um documento único, identificado por hash.

## 6. Arquitetura
### 6.1 Componentes
- **ContractToken**: token utilitário do protocolo;
- **DocumentNFT**: registro, assinatura e verificação de documentos;
- **ContractStaking**: stake, validação e recompensa com oráculo;
- **ContractGovernanceDAO**: propostas e votação;
- **Oráculo Chainlink**: consulta ETH/USD;
- **Backend ethers.js**: demonstração de fluxo operacional.

### 6.2 Fluxo resumido
1. Usuário registra documento e recebe NFT.
2. Usuário/partes registram assinatura on-chain.
3. Validador faz stake de CRT.
4. Validador valida documento.
5. Staking consulta o oráculo e paga recompensa.
6. Holders de CRT votam em parâmetros do protocolo.

## 7. Implementação técnica
### 7.1 Token ERC-20
- OpenZeppelin ERC20 + Burnable + AccessControl.
- Mint inicial para o administrador.
- Minter role para expansão controlada do suprimento, se necessário.

### 7.2 NFT de documentos
- Garante unicidade do hash.
- Mantém metadados mínimos do documento.
- Registra assinaturas on-chain.
- Exponibiliza verificação por hash.

### 7.3 Staking com recompensa
- Stake mínimo para validar.
- Pool de recompensa fundeado em CRT.
- Reward dinâmico por tiers a partir do feed ETH/USD.

### 7.4 Governança simples
- Criação de proposta por threshold mínimo de CRT.
- Voto baseado em saldo atual do token.
- Execução de alterações sobre o contrato de staking.

## 8. Segurança aplicada
- `ReentrancyGuard` no contrato de staking;
- `AccessControl` para separação de privilégios;
- `Pausable` para resposta operacional;
- `SafeERC20` para interações com o token;
- validações de input com `require`;
- prevenção de duplicidade de hash e de validação;
- adoção de Solidity `^0.8.24`.

As ferramentas de auditoria executadas no ambiente local confirmaram a presença desses controles e apontaram principalmente melhorias de robustez e governança, sem invalidar o funcionamento do MVP.

## 9. Integração com oráculo
Foi adotado o padrão `AggregatorV3Interface` para consumo do feed de preço ETH/USD. O objetivo é demonstrar integração de dados externos e refletir isso no incentivo econômico do staking.

## 10. Integração com backend Web3
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

## 11. Deploy em testnet

O deploy foi realizado em `Sepolia` via Hardhat.

### 11.1 Endereços dos contratos
- ContractToken: `0x30DDDDad124B292C513a5F96E907f410541F53B2`
- DocumentNFT: `0xDec861d2A470eC534F0933d4ddd25e0066e1df4E`
- ContractStaking: `0x08044379CeFf8Cd3C6b6061c0B7c326dFCDf5164`
- ContractGovernanceDAO: `0x250023bE3540533c5fab65deE7AfD51d774eAfaA`

### 11.2 Hashes das transações de deploy
- ContractToken: `0xc9cd94ba0d6f2dfe1f0dc968b072485926d71a9b355c648e6a09afa8743208cb`
- DocumentNFT: `0x336436833dbd6853d013f8177e736a2daeed6a65809e9bf834b76b2615ddfa9d`
- ContractStaking: `0xad8a67307735ca1fd008bd0ab0e0ac70e525131bf2a64845570afd4b96ae54d1`
- ContractGovernanceDAO: `0x03ee07247c8251d47ae83c4f37f291c583f0a8553aeb0ec620b6be5e52228f41`

### 11.3 Hashes de execução de exemplo
- Registro (`DocumentNFT / registerDocument`): `0x954f0c0d4344056c596d41a33e4d56f0789dbfba67c91039681ab582f9336d77`
- Validação (`ContractStaking / validateDocument`): `0x330a58db86888bfeef2d6f49daa53672f0f3ed538ce7310bf9b47ff322b5f3fc`
- Voto (`ContractGovernanceDAO / vote`): `0x5f71536c01b094b029877cde74df99a3b3ddafe923d4192cfc6696a43728ac21`
- Token (`ContractToken / transfer`): `0x5a1cf9dbf1fc01fe513c445ec8655709da435bfcf06c276be07d4435fe8471b2`

### 11.4 Links do explorer
- Token: `https://sepolia.etherscan.io/address/0x30DDDDad124B292C513a5F96E907f410541F53B2`
- DocumentNFT: `https://sepolia.etherscan.io/address/0xDec861d2A470eC534F0933d4ddd25e0066e1df4E`
- Staking: `https://sepolia.etherscan.io/address/0x08044379CeFf8Cd3C6b6061c0B7c326dFCDf5164`
- Governance: `https://sepolia.etherscan.io/address/0x250023bE3540533c5fab65deE7AfD51d774eAfaA`

### 11.5 Repositório
- GitHub: `https://github.com/RochaCAO/mvp-contratos-web3`

## 12. Auditoria
Foi produzido um relatório de auditoria simples com base em revisão manual e em execução real de ferramentas no ambiente local.

Ferramentas efetivamente executadas:
- `npx hardhat compile`
- `npx hardhat test`
- `python -m slither . --filter-paths "node_modules|artifacts|cache|typechain-types"`
- análises Mythril via Docker para:
  - `ContractToken`
  - `DocumentNFT`
  - `ContractStaking`
  - `ContractGovernanceDAO`

Principais resultados observados:
- o Slither reportou 9 achados, concentrados em:
  - retorno parcialmente ignorado no consumo do oráculo;
  - emissão de eventos após chamadas externas;
  - uso de `block.timestamp` em regras temporais;
  - sugestão de aderência explícita a interface em `ContractStaking`;
- o Mythril foi executado com sucesso para os quatro contratos principais, sem issues detectadas nas análises realizadas.

Os artefatos de auditoria foram registrados em arquivos próprios dentro do repositório.

## 13. Conclusão
O MVP atende ao caso de uso “Contratos” ao preservar os três pilares mínimos do estudo de caso — registro por hash, assinatura e verificação — e expandi-los para um protocolo completo com token, incentivo econômico, governança, oráculo e demonstração Web3.

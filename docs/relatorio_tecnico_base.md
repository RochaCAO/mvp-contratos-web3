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

## 9. Integração com oráculo
Foi adotado o padrão `AggregatorV3Interface` para consumo do feed de preço ETH/USD. O objetivo é demonstrar integração de dados externos e refletir isso no incentivo econômico do staking.

## 10. Integração com backend Web3
O arquivo `scripts/demo.js` utiliza `ethers.js` para demonstrar:
- mint/registro do NFT;
- stake do token;
- validação com recompensa;
- criação de proposta;
- votação;
- verificação final do documento.

## 11. Deploy em testnet
O projeto foi estruturado para deploy em Sepolia via Hardhat. Os campos abaixo devem ser preenchidos após execução real:
- Rede:
- Endereço ContractToken:
- Endereço DocumentNFT:
- Endereço ContractStaking:
- Endereço ContractGovernanceDAO:
- Hash da transação de deploy:
- Hash de uma execução de exemplo:
- Link do explorer:

## 12. Auditoria
Foi preparado um relatório de auditoria simples contendo:
- escopo;
- premissas;
- achados manuais;
- comandos sugeridos para Slither, Mythril e Hardhat.

## 13. Conclusão
O MVP atende ao caso de uso “Contratos” ao preservar os três pilares mínimos do estudo de caso — registro por hash, assinatura e verificação — e expandi-los para um protocolo completo com token, incentivo econômico, governança, oráculo e demonstração Web3.

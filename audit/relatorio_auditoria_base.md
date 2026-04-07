# Relatório de Auditoria — MVP Contratos Web3

## 1. Escopo
Contratos analisados:
- ContractToken.sol
- DocumentNFT.sol
- ContractStaking.sol
- ContractGovernanceDAO.sol

## 2. Controles positivos identificados
- uso de OpenZeppelin;
- `AccessControl` para funções sensíveis;
- `ReentrancyGuard` no staking;
- `Pausable` no staking;
- `SafeERC20` nas transferências do token;
- validações explícitas contra entradas inválidas e ações duplicadas.

## 3. Achados de revisão manual e estática
### A1 — Governança sem snapshot de saldo
- Severidade: Média
- Descrição: a DAO utiliza `balanceOf` no momento do voto, sem snapshot histórico.
- Risco: um mesmo conjunto econômico de tokens pode influenciar mais de uma vez via transferências entre carteiras.
- Recomendação: migrar para `ERC20Votes` ou implementar snapshot.

### A2 — Dependência de oráculo único
- Severidade: Baixa
- Descrição: a recompensa depende de um único feed ETH/USD.
- Risco: indisponibilidade do feed impacta a previsibilidade da recompensa.
- Recomendação: adicionar checagem de staleness e fallback.

### A3 — Assinatura jurídica simplificada
- Severidade: Informativa
- Descrição: `signDocument` registra uma atestação on-chain, mas não substitui fluxo jurídico avançado com EIP-712, carimbo do tempo externo e cadeia documental.
- Recomendação: em produção, evoluir para assinatura tipada e trilha probatória ampliada.

### A4 — Ausência de slashing de validadores
- Severidade: Baixa
- Descrição: o staking remunera validação, mas não pune comportamento malicioso.
- Recomendação: incluir slashing, reputação ou votação de contestação.

### A5 — Dependência de URI off-chain
- Severidade: Informativa
- Descrição: o hash on-chain é a fonte de integridade, mas metadados/arquivo podem depender de armazenamento externo.
- Recomendação: usar IPFS/Arweave e versionamento explícito.

## 4. Ferramentas efetivamente executadas

### 4.1 Hardhat
- `npx hardhat compile`
- `npx hardhat test`

Resultado:
- compilação executada com sucesso;
- teste smoke executado com sucesso.

### 4.2 Slither
Comando executado:
- `python -m slither . --filter-paths "node_modules|artifacts|cache|typechain-types"`

Artefatos gerados:
- `audit/real_outputs/slither-output.txt`
- `audit/real_outputs/slither-checklist.md`

Resumo da análise:
- 34 contratos analisados;
- 101 detectores utilizados;
- 9 resultados reportados.

Síntese classificada dos achados do Slither:
- 1 achado `unused-return` (impacto médio / confiança média), relacionado ao uso parcial do retorno de `latestRoundData()` no consumo do oráculo;
- 2 achados `reentrancy-events` (impacto baixo / confiança média), relacionados à emissão de eventos após chamadas externas em `ContractStaking.fundRewardPool` e `ContractGovernanceDAO.executeProposal`;
- 5 achados `timestamp` (impacto baixo / confiança média), relacionados ao uso de `block.timestamp` em regras temporais da DAO e do fluxo documental;
- 1 achado `missing-inheritance` (informacional / confiança alta), sugerindo aderência explícita de `ContractStaking` à interface `IStakingGovernance`.

> Observação: o artefato `slither-output.txt` contém uma mensagem inicial do PowerShell (`NativeCommandError`) decorrente da captura da saída do processo, mas a análise foi concluída com sucesso, conforme o resumo final do Slither.

### 4.3 Mythril
Foram executadas análises individuais via Docker para os quatro contratos principais:

- `audit/real_outputs/mythril-ContractToken.txt`
- `audit/real_outputs/mythril-DocumentNFT.txt`
- `audit/real_outputs/mythril-ContractStaking.txt`
- `audit/real_outputs/mythril-ContractGovernanceDAO.txt`

Resumo das saídas do Mythril:
- `ContractToken`: análise concluída com sucesso, sem issues detectadas nas análises realizadas;
- `DocumentNFT`: análise concluída com sucesso, sem issues detectadas nas análises realizadas;
- `ContractStaking`: análise concluída com sucesso, sem issues detectadas nas análises realizadas;
- `ContractGovernanceDAO`: análise concluída com sucesso, sem issues detectadas nas análises realizadas.

## 5. Evidências observadas
- Compilação realizada com sucesso via Hardhat.
- Teste smoke executado com sucesso.
- Deploy realizado na rede `Sepolia`.
- Contratos implantados:
  - ContractToken: `0x30DDDDad124B292C513a5F96E907f410541F53B2`
  - DocumentNFT: `0xDec861d2A470eC534F0933d4ddd25e0066e1df4E`
  - ContractStaking: `0x08044379CeFf8Cd3C6b6061c0B7c326dFCDf5164`
  - ContractGovernanceDAO: `0x250023bE3540533c5fab65deE7AfD51d774eAfaA`

- Hashes de execução observados no README:
  - Registro (`DocumentNFT / registerDocument`): `0x954f0c0d4344056c596d41a33e4d56f0789dbfba67c91039681ab582f9336d77`
  - Validação (`ContractStaking / validateDocument`): `0x330a58db86888bfeef2d6f49daa53672f0f3ed538ce7310bf9b47ff322b5f3fc`
  - Voto (`ContractGovernanceDAO / vote`): `0x5f71536c01b094b029877cde74df99a3b3ddafe923d4192cfc6696a43728ac21`
  - Transferência de token (`ContractToken / transfer`): `0x5a1cf9dbf1fc01fe513c445ec8655709da435bfcf06c276be07d4435fe8471b2`  

## 6. Parecer final
O projeto apresenta uma base coerente de MVP on-chain, com boa separação modular e controles básicos de segurança.

Do ponto de vista das ferramentas executadas:
- o Hardhat validou compilação e teste básico;
- o Slither reportou alertas de atenção e melhoria arquitetural, mas não invalidou o funcionamento do MVP;
- o Mythril foi executado com sucesso nos quatro contratos principais, sem issues detectadas nas análises realizadas.

Antes de produção, são recomendadas evoluções principalmente em:
- governança com snapshot;
- robustez operacional do consumo do oráculo;
- modelo jurídico/técnico de assinatura;
- mecanismo de slashing ou reputação para validadores.
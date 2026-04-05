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

## 3. Achados
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

## 4. Comandos sugeridos para auditoria estática
> Observação: a execução automática destes comandos depende do ambiente local com as ferramentas instaladas.

### 4.1 Hardhat
```bash
npx hardhat compile
npx hardhat test
```

### 4.2 Slither
```bash
slither . --filter-paths node_modules
```

### 4.3 Mythril
```bash
myth analyze contracts/ContractStaking.sol
myth analyze contracts/DocumentNFT.sol
```

## 5. Parecer final
O projeto apresenta uma base coerente de MVP on-chain, com boa separação modular e controles básicos de segurança. Antes de produção, recomenda-se evoluir principalmente a governança, o modelo de assinatura e a robustez operacional do oráculo.

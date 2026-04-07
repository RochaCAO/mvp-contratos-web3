# Roteiro de Vídeo Demonstrativo (5–10 minutos)

## 1. Problema (30–45s)
- apresentar o caso de uso “Contratos”;
- explicar a necessidade de registro por hash, assinatura e verificação;
- conectar o problema a rastreabilidade, integridade e incentivo econômico para validadores.

## 2. Arquitetura (1–2 min)
- mostrar os 4 contratos;
- explicar a função de cada um;
- explicar onde o oráculo entra;
- mostrar rapidamente o diagrama do README.

## 3. Deploy e prova on-chain (1 min)
- mostrar a rede `Sepolia`;
- mostrar os 4 endereços dos contratos no explorer:
  - ContractToken
  - DocumentNFT
  - ContractStaking
  - ContractGovernanceDAO
- abrir pelo menos 1 hash de deploy no Etherscan;
- mencionar que os 4 hashes de deploy e os links do explorer constam no README.

## 4. Demo funcional (2–4 min)
- mostrar o funding do pool de recompensa;
- mostrar a transferência de CRT ao validador;
- mostrar o registro do documento como NFT;
- mostrar a assinatura on-chain do documento;
- mostrar o stake do validador;
- mostrar a validação do documento com recompensa;
- mostrar a criação da proposta de governança;
- mostrar a votação;
- mostrar a verificação final do documento por hash;
- abrir no explorer ao menos 3 transações de exemplo:
  - registro;
  - validação;
  - voto.

## 5. Segurança e auditoria (1 min)
- mencionar ReentrancyGuard, AccessControl, Pausable e SafeERC20;
- mencionar que `npx hardhat compile` e `npx hardhat test` foram executados com sucesso;
- mencionar que o Slither foi executado e reportou 9 achados de atenção, sem invalidar o MVP;
- mencionar que o Mythril foi executado nos 4 contratos principais, sem issues detectadas nas análises realizadas;
- mencionar as principais limitações conhecidas:
  - governança sem snapshot;
  - assinatura jurídica simplificada;
  - ausência de slashing;
  - dependência de oráculo único e de metadados off-chain.

## 6. Encerramento (30–45s)
- reforçar aderência ao estudo de caso “Contratos”;
- destacar próximos passos: snapshot na governança, EIP-712, checagem de staleness do oráculo e slashing.

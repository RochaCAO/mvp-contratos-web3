**THIS CHECKLIST IS NOT COMPLETE**. Use `--show-ignored-findings` to show all the results.
Summary
 - [unused-return](#unused-return) (1 results) (Medium)
 - [reentrancy-events](#reentrancy-events) (2 results) (Low)
 - [timestamp](#timestamp) (5 results) (Low)
 - [missing-inheritance](#missing-inheritance) (1 results) (Informational)
## unused-return
Impact: Medium
Confidence: Medium
 - [ ] ID-0
[ContractStaking._rewardFromOracle()](contracts/ContractStaking.sol#L150-L164) ignores return value by [(None,answer,None,None,None) = priceFeed.latestRoundData()](contracts/ContractStaking.sol#L151)

contracts/ContractStaking.sol#L150-L164


## reentrancy-events
Impact: Low
Confidence: Medium
 - [ ] ID-1
Reentrancy in [ContractStaking.fundRewardPool(uint256)](contracts/ContractStaking.sol#L100-L104):
	External calls:
	- [stakingToken.safeTransferFrom(msg.sender,address(this),amount)](contracts/ContractStaking.sol#L102)
	Event emitted after the call(s):
	- [RewardPoolFunded(msg.sender,amount)](contracts/ContractStaking.sol#L103)

contracts/ContractStaking.sol#L100-L104


 - [ ] ID-2
Reentrancy in [ContractGovernanceDAO.executeProposal(uint256)](contracts/ContractGovernanceDAO.sol#L133-L153):
	External calls:
	- [staking.setBaseReward(p.newValue)](contracts/ContractGovernanceDAO.sol#L143)
	- [staking.setMinValidatorStake(p.newValue)](contracts/ContractGovernanceDAO.sol#L145)
	- [staking.pause()](contracts/ContractGovernanceDAO.sol#L147)
	- [staking.unpause()](contracts/ContractGovernanceDAO.sol#L149)
	Event emitted after the call(s):
	- [ProposalExecuted(proposalId)](contracts/ContractGovernanceDAO.sol#L152)

contracts/ContractGovernanceDAO.sol#L133-L153


## timestamp
Impact: Low
Confidence: Medium
 - [ ] ID-3
[DocumentNFT.recordValidation(uint256,address)](contracts/DocumentNFT.sol#L100-L110) uses timestamp for comparisons
	Dangerous comparisons:
	- [require(bool,string)(_documents[tokenId].active,documento inativo)](contracts/DocumentNFT.sol#L103)

contracts/DocumentNFT.sol#L100-L110


 - [ ] ID-4
[ContractGovernanceDAO.executeProposal(uint256)](contracts/ContractGovernanceDAO.sol#L133-L153) uses timestamp for comparisons
	Dangerous comparisons:
	- [require(bool,string)(p.deadline != 0,proposal inexistente)](contracts/ContractGovernanceDAO.sol#L135)
	- [require(bool,string)(block.timestamp >= p.deadline,votacao em andamento)](contracts/ContractGovernanceDAO.sol#L136)
	- [require(bool,string)(! p.executed,proposal ja executada)](contracts/ContractGovernanceDAO.sol#L137)
	- [require(bool,string)(p.votesFor > p.votesAgainst,proposal rejeitada)](contracts/ContractGovernanceDAO.sol#L138)

contracts/ContractGovernanceDAO.sol#L133-L153


 - [ ] ID-5
[DocumentNFT.setDocumentStatus(uint256,bool)](contracts/DocumentNFT.sol#L115-L126) uses timestamp for comparisons
	Dangerous comparisons:
	- [require(bool,string)(msg.sender == doc.creator || hasRole(DEFAULT_ADMIN_ROLE,msg.sender),sem permissao)](contracts/DocumentNFT.sol#L119-L122)

contracts/DocumentNFT.sol#L115-L126


 - [ ] ID-6
[ContractGovernanceDAO.vote(uint256,bool)](contracts/ContractGovernanceDAO.sol#L113-L131) uses timestamp for comparisons
	Dangerous comparisons:
	- [require(bool,string)(p.deadline != 0,proposal inexistente)](contracts/ContractGovernanceDAO.sol#L115)
	- [require(bool,string)(block.timestamp < p.deadline,janela encerrada)](contracts/ContractGovernanceDAO.sol#L116)

contracts/ContractGovernanceDAO.sol#L113-L131


 - [ ] ID-7
[DocumentNFT.signDocument(uint256)](contracts/DocumentNFT.sol#L87-L94) uses timestamp for comparisons
	Dangerous comparisons:
	- [require(bool,string)(_documents[tokenId].active,documento inativo)](contracts/DocumentNFT.sol#L89)

contracts/DocumentNFT.sol#L87-L94


## missing-inheritance
Impact: Informational
Confidence: High
 - [ ] ID-8
[ContractStaking](contracts/ContractStaking.sol#L17-L165) should inherit from [IStakingGovernance](contracts/interfaces/IStakingGovernance.sol#L4-L12)

contracts/ContractStaking.sol#L17-L165



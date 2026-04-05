// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/IStakingGovernance.sol";

/**
 * @title ContractGovernanceDAO
 * @notice DAO simplificada para governar parâmetros essenciais do protocolo.
 * @dev Este MVP usa poder de voto baseado no balanceOf atual do token.
 *      Em produção, o ideal é snapshot para evitar dupla contagem via transferências.
 */
contract ContractGovernanceDAO is AccessControl {
    bytes32 public constant PARAM_ADMIN_ROLE = keccak256("PARAM_ADMIN_ROLE");

    enum ProposalType {
        SetBaseReward,
        SetMinValidatorStake,
        PauseStaking,
        UnpauseStaking
    }

    struct Proposal {
        ProposalType proposalType;
        uint256 newValue;
        address proposer;
        uint64 deadline;
        uint256 votesFor;
        uint256 votesAgainst;
        bool executed;
        string description;
    }

    IERC20 public immutable governanceToken;
    IStakingGovernance public immutable staking;

    uint256 public proposalCount;
    uint256 public minimumProposalTokens;
    uint256 public votingPeriod;

    mapping(uint256 => Proposal) public proposals;
    mapping(uint256 => mapping(address => bool)) public hasVoted;

    event ProposalCreated(
        uint256 indexed proposalId,
        address indexed proposer,
        ProposalType proposalType,
        uint256 newValue,
        uint256 deadline,
        string description
    );
    event VoteCast(uint256 indexed proposalId, address indexed voter, bool support, uint256 weight);
    event ProposalExecuted(uint256 indexed proposalId);
    event MinimumProposalTokensUpdated(uint256 oldValue, uint256 newValue);
    event VotingPeriodUpdated(uint256 oldValue, uint256 newValue);

    constructor(
        address admin,
        address governanceToken_,
        address staking_,
        uint256 minimumProposalTokens_,
        uint256 votingPeriod_
    ) {
        require(admin != address(0), "admin invalido");
        require(governanceToken_ != address(0), "token invalido");
        require(staking_ != address(0), "staking invalido");
        require(minimumProposalTokens_ > 0, "threshold invalido");
        require(votingPeriod_ >= 1 hours, "periodo curto");

        governanceToken = IERC20(governanceToken_);
        staking = IStakingGovernance(staking_);
        minimumProposalTokens = minimumProposalTokens_;
        votingPeriod = votingPeriod_;

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(PARAM_ADMIN_ROLE, admin);
    }

    function createProposal(
        ProposalType proposalType,
        uint256 newValue,
        string calldata description
    ) external returns (uint256 proposalId) {
        require(governanceToken.balanceOf(msg.sender) >= minimumProposalTokens, "tokens insuficientes");
        require(bytes(description).length > 0, "descricao obrigatoria");

        if (
            proposalType == ProposalType.SetBaseReward ||
            proposalType == ProposalType.SetMinValidatorStake
        ) {
            require(newValue > 0, "novo valor invalido");
        }

        proposalId = ++proposalCount;
        Proposal storage p = proposals[proposalId];
        p.proposalType = proposalType;
        p.newValue = newValue;
        p.proposer = msg.sender;
        p.deadline = uint64(block.timestamp + votingPeriod);
        p.description = description;

        emit ProposalCreated(
            proposalId,
            msg.sender,
            proposalType,
            newValue,
            p.deadline,
            description
        );
    }

    function vote(uint256 proposalId, bool support) external {
        Proposal storage p = proposals[proposalId];
        require(p.deadline != 0, "proposal inexistente");
        require(block.timestamp < p.deadline, "janela encerrada");
        require(!hasVoted[proposalId][msg.sender], "voto duplicado");

        uint256 weight = governanceToken.balanceOf(msg.sender);
        require(weight > 0, "sem poder de voto");

        hasVoted[proposalId][msg.sender] = true;

        if (support) {
            p.votesFor += weight;
        } else {
            p.votesAgainst += weight;
        }

        emit VoteCast(proposalId, msg.sender, support, weight);
    }

    function executeProposal(uint256 proposalId) external {
        Proposal storage p = proposals[proposalId];
        require(p.deadline != 0, "proposal inexistente");
        require(block.timestamp >= p.deadline, "votacao em andamento");
        require(!p.executed, "proposal ja executada");
        require(p.votesFor > p.votesAgainst, "proposal rejeitada");

        p.executed = true;

        if (p.proposalType == ProposalType.SetBaseReward) {
            staking.setBaseReward(p.newValue);
        } else if (p.proposalType == ProposalType.SetMinValidatorStake) {
            staking.setMinValidatorStake(p.newValue);
        } else if (p.proposalType == ProposalType.PauseStaking) {
            staking.pause();
        } else if (p.proposalType == ProposalType.UnpauseStaking) {
            staking.unpause();
        }

        emit ProposalExecuted(proposalId);
    }

    function setMinimumProposalTokens(uint256 newValue) external onlyRole(PARAM_ADMIN_ROLE) {
        require(newValue > 0, "novo valor invalido");
        emit MinimumProposalTokensUpdated(minimumProposalTokens, newValue);
        minimumProposalTokens = newValue;
    }

    function setVotingPeriod(uint256 newValue) external onlyRole(PARAM_ADMIN_ROLE) {
        require(newValue >= 1 hours, "periodo curto");
        emit VotingPeriodUpdated(votingPeriod, newValue);
        votingPeriod = newValue;
    }
}

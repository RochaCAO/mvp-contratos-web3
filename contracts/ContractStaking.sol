// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./interfaces/AggregatorV3Interface.sol";
import "./interfaces/IDocumentNFT.sol";

/**
 * @title ContractStaking
 * @notice Staking de CRT para formar validadores e remunerar validações de documentos.
 * @dev Segurança: ReentrancyGuard, SafeERC20, AccessControl e Pausable.
 */
contract ContractStaking is AccessControl, Pausable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    bytes32 public constant GOVERNANCE_ROLE = keccak256("GOVERNANCE_ROLE");

    IERC20 public immutable stakingToken;
    IDocumentNFT public immutable documentNFT;
    AggregatorV3Interface public immutable priceFeed;

    uint256 public minValidatorStake;
    uint256 public baseReward;
    uint256 public totalStaked;

    mapping(address => uint256) public stakedBalance;

    event Staked(address indexed account, uint256 amount, uint256 newBalance);
    event Unstaked(address indexed account, uint256 amount, uint256 newBalance);
    event RewardPoolFunded(address indexed from, uint256 amount);
    event DocumentValidatedAndRewarded(
        address indexed validator,
        uint256 indexed tokenId,
        uint256 reward,
        uint256 oraclePrice
    );
    event BaseRewardUpdated(uint256 oldValue, uint256 newValue);
    event MinValidatorStakeUpdated(uint256 oldValue, uint256 newValue);

    constructor(
        address admin,
        address token_,
        address documentNFT_,
        address priceFeed_,
        uint256 minValidatorStake_,
        uint256 baseReward_
    ) {
        require(admin != address(0), "admin invalido");
        require(token_ != address(0), "token invalido");
        require(documentNFT_ != address(0), "nft invalido");
        require(priceFeed_ != address(0), "oracle invalido");
        require(minValidatorStake_ > 0, "min stake invalido");
        require(baseReward_ > 0, "base reward invalida");

        stakingToken = IERC20(token_);
        documentNFT = IDocumentNFT(documentNFT_);
        priceFeed = AggregatorV3Interface(priceFeed_);
        minValidatorStake = minValidatorStake_;
        baseReward = baseReward_;

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(GOVERNANCE_ROLE, admin);
    }

    /**
     * @notice Deposita tokens CRT no staking.
     */
    function stake(uint256 amount) external nonReentrant whenNotPaused {
        require(amount > 0, "amount invalido");

        stakedBalance[msg.sender] += amount;
        totalStaked += amount;
        stakingToken.safeTransferFrom(msg.sender, address(this), amount);

        emit Staked(msg.sender, amount, stakedBalance[msg.sender]);
    }

    /**
     * @notice Retira tokens previamente depositados.
     * @dev Nao ha lockup neste MVP. Em producao, o ideal e avaliar janelas de unlock.
     */
    function unstake(uint256 amount) external nonReentrant whenNotPaused {
        require(amount > 0, "amount invalido");
        require(stakedBalance[msg.sender] >= amount, "saldo staked insuficiente");

        stakedBalance[msg.sender] -= amount;
        totalStaked -= amount;
        stakingToken.safeTransfer(msg.sender, amount);

        emit Unstaked(msg.sender, amount, stakedBalance[msg.sender]);
    }

    /**
     * @notice Alimenta o pool de recompensa com CRT.
     */
    function fundRewardPool(uint256 amount) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(amount > 0, "amount invalido");
        stakingToken.safeTransferFrom(msg.sender, address(this), amount);
        emit RewardPoolFunded(msg.sender, amount);
    }

    /**
     * @notice Valida um documento elegível e paga recompensa dinâmica.
     */
    function validateDocument(uint256 tokenId) external nonReentrant whenNotPaused {
        require(stakedBalance[msg.sender] >= minValidatorStake, "stake abaixo do minimo");
        require(!documentNFT.validatedBy(tokenId, msg.sender), "validacao duplicada");

        (uint256 reward, uint256 oraclePrice) = _rewardFromOracle();
        require(stakingToken.balanceOf(address(this)) >= reward, "pool insuficiente");

        documentNFT.recordValidation(tokenId, msg.sender);
        stakingToken.safeTransfer(msg.sender, reward);

        emit DocumentValidatedAndRewarded(msg.sender, tokenId, reward, oraclePrice);
    }

    /**
     * @notice Preview da recompensa baseada no preco ETH/USD.
     * @dev Assumimos feed com 8 casas decimais, como no padrao Chainlink ETH/USD.
     */
    function previewReward() external view returns (uint256 reward, uint256 oraclePrice) {
        return _rewardFromOracle();
    }

    function setBaseReward(uint256 newValue) external onlyRole(GOVERNANCE_ROLE) {
        require(newValue > 0, "novo valor invalido");
        emit BaseRewardUpdated(baseReward, newValue);
        baseReward = newValue;
    }

    function setMinValidatorStake(uint256 newValue) external onlyRole(GOVERNANCE_ROLE) {
        require(newValue > 0, "novo valor invalido");
        emit MinValidatorStakeUpdated(minValidatorStake, newValue);
        minValidatorStake = newValue;
    }

    function pause() external onlyRole(GOVERNANCE_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(GOVERNANCE_ROLE) {
        _unpause();
    }

    function _rewardFromOracle() internal view returns (uint256 reward, uint256 oraclePrice) {
        (, int256 answer, , , ) = priceFeed.latestRoundData();
        require(answer > 0, "oracle sem resposta valida");

        oraclePrice = uint256(answer);

        // Regras simples de tiering para o MVP.
        if (oraclePrice >= 3500e8) {
            reward = baseReward * 2;
        } else if (oraclePrice >= 2500e8) {
            reward = (baseReward * 15) / 10;
        } else {
            reward = baseReward;
        }
    }
}

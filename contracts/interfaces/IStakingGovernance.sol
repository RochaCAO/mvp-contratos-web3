// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IStakingGovernance {
    function setBaseReward(uint256 newValue) external;

    function setMinValidatorStake(uint256 newValue) external;

    function pause() external;

    function unpause() external;
}

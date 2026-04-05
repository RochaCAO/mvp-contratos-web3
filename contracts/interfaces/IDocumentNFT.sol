// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IDocumentNFT {
    function validatedBy(uint256 tokenId, address validator) external view returns (bool);

    function recordValidation(uint256 tokenId, address validator) external;
}

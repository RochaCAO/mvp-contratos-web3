// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

/**
 * @title ContractToken
 * @notice Token utilitário do protocolo de contratos digitais.
 * @dev Implementa ERC-20 via OpenZeppelin com controle de papel de mint.
 *      A proposta é manter a lógica simples, auditável e compatível com o MVP.
 */
contract ContractToken is ERC20, ERC20Burnable, AccessControl {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    /**
     * @param admin Endereço administrador inicial do token.
     * @param initialSupply Oferta inicial mintada para o administrador.
     */
    constructor(address admin, uint256 initialSupply) ERC20("Contract Reward Token", "CRT") {
        require(admin != address(0), "admin invalido");
        require(initialSupply > 0, "supply inicial invalida");

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(MINTER_ROLE, admin);
        _mint(admin, initialSupply);
    }

    /**
     * @notice Mint controlado para fundos de recompensa, tesouraria ou bootstrap.
     * @dev Restrito a enderecos com MINTER_ROLE.
     */
    function mint(address to, uint256 amount) external onlyRole(MINTER_ROLE) {
        require(to != address(0), "destino invalido");
        require(amount > 0, "amount invalido");
        _mint(to, amount);
    }
}

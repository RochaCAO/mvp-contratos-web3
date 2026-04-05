// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

/**
 * @title DocumentNFT
 * @notice NFT que representa o registro on-chain de um documento/contrato digital.
 * @dev O hash do documento é a âncora de integridade. O URI é opcional e pode apontar
 *      para metadados ou cópia cifrada armazenada fora da cadeia.
 */
contract DocumentNFT is ERC721URIStorage, AccessControl {
    bytes32 public constant VALIDATOR_ROLE = keccak256("VALIDATOR_ROLE");

    struct DocumentRecord {
        bytes32 documentHash;
        address creator;
        uint64 createdAt;
        uint64 validationCount;
        bool active;
        string externalReference;
    }

    uint256 public nextTokenId = 1;
    uint256 public totalDocuments;

    mapping(uint256 => DocumentRecord) private _documents;
    mapping(bytes32 => uint256) public tokenIdByHash;
    mapping(uint256 => mapping(address => bool)) public signedBy;
    mapping(uint256 => mapping(address => bool)) public validatedBy;

    event DocumentRegistered(
        uint256 indexed tokenId,
        address indexed creator,
        bytes32 indexed documentHash,
        string externalReference
    );
    event DocumentSigned(uint256 indexed tokenId, address indexed signer);
    event DocumentValidated(uint256 indexed tokenId, address indexed validator, uint256 validationCount);
    event DocumentStatusChanged(uint256 indexed tokenId, bool active);

    constructor(address admin) ERC721("Digital Contract NFT", "DCN") {
        require(admin != address(0), "admin invalido");
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(VALIDATOR_ROLE, admin);
    }

    /**
     * @notice Registra um novo documento por hash e gera um NFT representativo.
     */
    function registerDocument(
        bytes32 documentHash,
        string calldata externalReference,
        string calldata tokenURI_
    ) external returns (uint256 tokenId) {
        require(documentHash != bytes32(0), "hash invalido");
        require(tokenIdByHash[documentHash] == 0, "hash ja registrado");

        tokenId = nextTokenId;
        nextTokenId += 1;
        totalDocuments += 1;

        _safeMint(msg.sender, tokenId);
        if (bytes(tokenURI_).length > 0) {
            _setTokenURI(tokenId, tokenURI_);
        }

        _documents[tokenId] = DocumentRecord({
            documentHash: documentHash,
            creator: msg.sender,
            createdAt: uint64(block.timestamp),
            validationCount: 0,
            active: true,
            externalReference: externalReference
        });

        tokenIdByHash[documentHash] = tokenId;

        emit DocumentRegistered(tokenId, msg.sender, documentHash, externalReference);
    }

    /**
     * @notice Registra a manifestação de assinatura/aceite de uma carteira.
     * @dev Para um MVP jurídico-operacional, este evento funciona como atestação on-chain.
     */
    function signDocument(uint256 tokenId) external {
        require(_ownerOf(tokenId) != address(0), "documento inexistente");
        require(_documents[tokenId].active, "documento inativo");
        require(!signedBy[tokenId][msg.sender], "assinatura ja registrada");

        signedBy[tokenId][msg.sender] = true;
        emit DocumentSigned(tokenId, msg.sender);
    }

    /**
     * @notice Registra uma validação efetuada por um validador elegível.
     * @dev A chamada idealmente vem do contrato de staking, que concentra a regra de incentivo.
     */
    function recordValidation(uint256 tokenId, address validator) external onlyRole(VALIDATOR_ROLE) {
        require(_ownerOf(tokenId) != address(0), "documento inexistente");
        require(validator != address(0), "validador invalido");
        require(_documents[tokenId].active, "documento inativo");
        require(!validatedBy[tokenId][validator], "validacao duplicada");

        validatedBy[tokenId][validator] = true;
        _documents[tokenId].validationCount += 1;

        emit DocumentValidated(tokenId, validator, _documents[tokenId].validationCount);
    }

    /**
     * @notice Permite ao criador ou administrador ativar/desativar um documento.
     */
    function setDocumentStatus(uint256 tokenId, bool active) external {
        require(_ownerOf(tokenId) != address(0), "documento inexistente");
        DocumentRecord storage doc = _documents[tokenId];

        require(
            msg.sender == doc.creator || hasRole(DEFAULT_ADMIN_ROLE, msg.sender),
            "sem permissao"
        );

        doc.active = active;
        emit DocumentStatusChanged(tokenId, active);
    }

    /**
     * @notice Consulta completa por tokenId.
     */
    function getDocument(uint256 tokenId)
        external
        view
        returns (
            bytes32 documentHash,
            address creator,
            uint64 createdAt,
            uint64 validationCount,
            bool active,
            string memory externalReference,
            address currentOwner
        )
    {
        require(_ownerOf(tokenId) != address(0), "documento inexistente");
        DocumentRecord storage doc = _documents[tokenId];

        return (
            doc.documentHash,
            doc.creator,
            doc.createdAt,
            doc.validationCount,
            doc.active,
            doc.externalReference,
            ownerOf(tokenId)
        );
    }

    /**
     * @notice Verifica um documento a partir do hash registrado.
     */
    function verifyByHash(bytes32 documentHash)
        external
        view
        returns (
            bool exists,
            uint256 tokenId,
            address creator,
            uint64 createdAt,
            uint64 validationCount,
            bool active,
            address currentOwner
        )
    {
        tokenId = tokenIdByHash[documentHash];
        if (tokenId == 0) {
            return (false, 0, address(0), 0, 0, false, address(0));
        }

        DocumentRecord storage doc = _documents[tokenId];
        return (true, tokenId, doc.creator, doc.createdAt, doc.validationCount, doc.active, ownerOf(tokenId));
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721URIStorage, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}

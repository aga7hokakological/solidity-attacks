// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract SafeNFTMinting is ERC721, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private currentTokenId;

    error notWhitelisted();
    error notOwner();
    
    string public baseTokenURI;
    mapping(address => bool) whitelistedMinters;
    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;
    
    modifier whitelisted(address addr) {
        if(!whitelistedMinters[addr]) revert notWhitelisted();
        _;
    }

    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) {
        baseTokenURI = "https://CID_HERE.ipfs.dweb.link/metadata/";
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
    }

    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    function addToWhitelist(address addr) public onlyOwner {
        require(addr != address(0), "Zero address");
        whitelistedMinters[addr] = true;
    }

    function mint() public whitelisted(msg.sender) {
        currentTokenId.increment();
        uint256 newItemId = currentTokenId.current();
        _safeMint(msg.sender, newItemId);
        _owners[newItemId] = msg.sender;
    }

    function burn(uint256 tokenId) public {
        if(ownerOf(tokenId) != msg.sender) revert notOwner();
        super._burn(tokenId);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);
        if (from != address(0)) {
            address owner = ownerOf(tokenId);
            require(owner == msg.sender, "Only the owner of NFT can transfer or burn it");
        }
    }
}
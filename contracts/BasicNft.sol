// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BasicNft is ERC721 {
    string public constant TOKEN_URI =
        "ipfs://bafybeig37ioir76s7mg5oobetncojcm3c3hxasyd4rvid4jqhy4gkaheg4/?filename=0-PUG.json";
    uint256 private _tokenId;

    constructor() ERC721("Cat", "cat") {
        _tokenId = 0;
    }

    function mintNft() public {
        _safeMint(msg.sender, _tokenId);
        _tokenId += _tokenId;
    }

    function tokenURI(uint256 /*_tokenId*/) public view override returns (string memory) {
        return TOKEN_URI;
    }

    function getTokenId() public view returns (uint256) {
        return _tokenId;
    }
}

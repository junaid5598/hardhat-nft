// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "base64-sol/base64.sol";

contract DynamicSvgNft is ERC721 {
    uint256 private s_tokencounter;
    string private i_lowImageURI;
    string private i_highImageURI;
    string private constant base64EncodedSvgPrefix = "data:image/svg+xml;base64,";
    string private constant base64EncodedUriPrefix = "data:application/json;base64,";
    AggregatorV3Interface internal immutable i_pricefeed;
    mapping(uint256 => int256) public s_tokenIdToHighValue;

    event CreatedNFT(uint256 indexed tokenId, int256 highValue);

    constructor(
        address priceFeedAddress,
        string memory lowSvg,
        string memory highSvg
    ) ERC721("Dynamic SVG NFT", "DSN") {
        s_tokencounter = 0;
        i_lowImageURI = svgToImageURI(lowSvg);
        i_highImageURI = svgToImageURI(highSvg);
        i_pricefeed = AggregatorV3Interface(priceFeedAddress);
    }

    function svgToImageURI(string memory svg) public pure returns (string memory) {
        string memory svgBase64Encoded = Base64.encode(bytes(string(abi.encodePacked(svg))));
        return string(abi.encodePacked(base64EncodedSvgPrefix, svgBase64Encoded));
    }

    function mintNft(int256 highValue) public {
        s_tokenIdToHighValue[s_tokencounter] = highValue;
        s_tokencounter += s_tokencounter;
        _safeMint(msg.sender, s_tokencounter);
        emit CreatedNFT(s_tokencounter, highValue);
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "URI Query for nonexistent token");

        (, int256 price, , , ) = i_pricefeed.latestRoundData();
        string memory imageURI = i_lowImageURI;
        if (price >= s_tokenIdToHighValue[tokenId]) {
            imageURI = i_highImageURI;
        }

        string memory jsonBase64Encoded = Base64.encode(
            bytes(
                abi.encodePacked(
                    '{"name":"',
                    name(),
                    '", "description":"an NFT that changes based on the Chainlink Feed", ',
                    '"attributes": [{"trait_type": "coolness", "value": 100}], "image":"',
                    imageURI,
                    '"}'
                )
            )
        );
        return (string(abi.encodePacked(base64EncodedUriPrefix, jsonBase64Encoded)));
    }
}

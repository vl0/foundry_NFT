// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract MoodNft is ERC721, Ownable {
    //errors
    error MoodNft_CantFlipMoodIfNotOwner();
    error ERC721Metadata__URI_QueryFor_NonExistentToken();

    enum NFTState {
        HAPPY,
        SAD
    }

    uint256 private s_tokenCounter;
    string private s_sadSvgUri;
    string private s_happySvgUri;

    mapping(uint256 => NFTState) private s_tokenIdToMood;

    event CreatedNFT(uint256 indexed tokenId);

    constructor(
        string memory sadSvgUri,
        string memory happySvgUri
    ) ERC721("Mood NFT", "MN") {
        s_tokenCounter = 0;
        s_sadSvgUri = sadSvgUri;
        s_happySvgUri = happySvgUri;
    }

    function mintNft() public {
        _safeMint(msg.sender, s_tokenCounter);
        s_tokenCounter = s_tokenCounter + 1;
        emit CreatedNFT(s_tokenCounter);
    }

    function flipMood(uint256 tokenId) public {
        // only the NFT owner to be able to change mood
        if (!_isApprovedOrOwner(msg.sender, tokenId)) {
            revert MoodNft_CantFlipMoodIfNotOwner();
        }

        if (s_tokenIdToMood[tokenId] == NFTState.HAPPY) {
            s_tokenIdToMood[tokenId] = NFTState.SAD;
        } else {
            s_tokenIdToMood[tokenId] = NFTState.HAPPY;
        }
    }

    function _baseURI() internal pure override returns (string memory) {
        return "data:application/json;base64,";
    }

    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        if (!_exists(tokenId)) {
            revert ERC721Metadata__URI_QueryFor_NonExistentToken();
        }
        string memory imageURI = s_happySvgUri;

        if (s_tokenIdToMood[tokenId] == NFTState.SAD) {
            imageURI = s_sadSvgUri;
        }
        return
            string(
                abi.encodePacked(
                    _baseURI(),
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name":"',
                                name(), // You can add whatever name here
                                '", "description":"An NFT that reflects the mood of the owner, 100% on Chain!", ',
                                '"attributes": [{"trait_type": "moodiness", "value": 100}], "image":"',
                                imageURI,
                                '"}'
                            )
                        )
                    )
                )
            );
    }

    function getHappySVG() public view returns (string memory) {
        return s_happySvgUri;
    }

    function getSadSVG() public view returns (string memory) {
        return s_sadSvgUri;
    }

    function getTokenCounter() public view returns (uint256) {
        return s_tokenCounter;
    }
}

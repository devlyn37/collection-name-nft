// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";
import {Base64} from "./libraries/Base64.sol";

/// @title An NFT project
/// @author Devlyn Dorfer (completing buildspace project)
/// @notice the current randomization could be gamed
contract MyEpicNFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    string baseSvg =
        "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: white; font-family: serif; font-size: 24px; }</style><rect width='100%' height='100%' fill='black' /><text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>";

    string[] firstWords = [
        "10000 ",
        "9000 ",
        "8000 ",
        "7000 ",
        "5000 ",
        "6000 ",
        "4000 ",
        "3000 ",
        "2000 ",
        "11000 ",
        "12000 ",
        "13000 ",
        "20000 "
    ];

    string[] secondWords = [
        "Hungry ",
        "Thirsty ",
        "Tired ",
        "Bored ",
        "Honest ",
        "Bashful ",
        "Curious ",
        "Happy ",
        "Sore ",
        "Funny ",
        "Sad ",
        "Determined ",
        "Regretful ",
        "Angry ",
        "Stunning ",
        "Militant ",
        "Clean ",
        "Funny ",
        "Distraught ",
        "Loyal ",
        "Silly ",
        "Somber ",
        "Unstoppable ",
        "Immature ",
        "juvenile "
    ];

    string[] thirdWords = [
        "Hippos",
        "Tigers",
        "Cats",
        "Dogs",
        "Lions",
        "Apes",
        "Penguins",
        "Pigeons",
        "Bats",
        "Owls",
        "Gators",
        "Rhinos",
        "Seals",
        "Sparrows",
        "Eagles",
        "Racoons",
        "Pandas",
        "Unicorns",
        "Lemurs",
        "Cheetahs",
        "Dolphins",
        "Crabs",
        "Lobsters",
        "Cranes"
    ];

    event NewEpicNFTMinted(address sender, uint256 tokenId);

    /// @dev increments the token id such that the first mint is token #1
    constructor() ERC721("CollectionNames", "CNAME") {
        console.log("gm");
        _tokenIds.increment(); // Start from 1
    }

    /// @param tokenId the token id for the NFT being generated
    /// @return a randomish number meant for the beginning of the NFT
    function pickRandomFirstWord(uint256 tokenId)
        public
        view
        returns (string memory)
    {
        uint256 rand = random(
            string(abi.encodePacked("FIRST_WORD", Strings.toString(tokenId)))
        );
        // Squash the # between 0 and the length of the array to avoid going out of bounds.
        rand = rand % firstWords.length;
        return firstWords[rand];
    }

    /// @param tokenId the token id for the NFT being generated
    /// @return a randomish adjective meant for the middle of the NFT
    function pickRandomSecondWord(uint256 tokenId)
        public
        view
        returns (string memory)
    {
        uint256 rand = random(
            string(abi.encodePacked("SECOND_WORD", Strings.toString(tokenId)))
        );
        rand = rand % secondWords.length;
        return secondWords[rand];
    }

    /// @param tokenId the token id for the NFT being generated
    /// @return a randomish animal meant for the end of the NFT
    function pickRandomThirdWord(uint256 tokenId)
        public
        view
        returns (string memory)
    {
        uint256 rand = random(
            string(abi.encodePacked("THIRD_WORD", Strings.toString(tokenId)))
        );
        rand = rand % thirdWords.length;
        return thirdWords[rand];
    }

    /// @param input a seed for randomization
    /// @return a randomish number
    function random(string memory input) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(input)));
    }

    /// @notice the project's mint function
    function makeAnEpicNFT() public {
        uint256 newItemId = _tokenIds.current();
        require(newItemId <= 32, "All NFTs have been minted!");

        string memory first = pickRandomFirstWord(newItemId);
        string memory second = pickRandomSecondWord(newItemId);
        string memory third = pickRandomThirdWord(newItemId);
        string memory combinedWord = string(
            abi.encodePacked(first, second, third)
        );

        string memory finalSvg = string(
            abi.encodePacked(baseSvg, combinedWord, "</text></svg>")
        );

        // Get all the JSON metadata in place and base64 encode it.
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',
                        // We set the title of our NFT as the generated word.
                        combinedWord,
                        '", "description": "A collection of collection names :)", "image": "data:image/svg+xml;base64,',
                        // We add data:image/svg+xml;base64 and then append our base64 encode our svg.
                        Base64.encode(bytes(finalSvg)),
                        '"}'
                    )
                )
            )
        );

        // Just like before, we prepend data:application/json;base64, to our data.
        string memory finalTokenUri = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        console.log("\n--------------------");
        console.log(finalTokenUri);
        console.log("--------------------\n");

        _safeMint(msg.sender, newItemId);

        _setTokenURI(newItemId, finalTokenUri);

        _tokenIds.increment();
        console.log(
            "An NFT w/ ID %s has been minted to %s",
            newItemId,
            msg.sender
        );

        emit NewEpicNFTMinted(msg.sender, newItemId);
    }

    /// @return n the number of tokens that have been minted in this collection
    function getNumMinted() public view returns (uint256) {
        return _tokenIds.current() - 1;
    }
}

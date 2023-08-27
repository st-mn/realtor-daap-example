/**
Solidity contract represents an ERC-721 token contract called "RealEstate" that is used to tokenize real estate assets on the blockchain. 
This token contract uses the OpenZeppelin library for ERC-721 implementation and includes functionality for minting and managing these tokens. 

Import Statements:

@openzeppelin/contracts/utils/Counters.sol: Imports the Counters library from the OpenZeppelin contracts, which is used to manage token IDs.
@openzeppelin/contracts/token/ERC721/ERC721.sol: Imports the ERC721 base contract from OpenZeppelin.
@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol: Imports the extension contract for handling token URIs.
Contract Definition:

RealEstate contract inherits from ERC721URIStorage. This means it is an ERC-721 token with the added ability to store and manage token URIs associated with each token ID.
Using Counters:

The Counters.Counter is used to manage token IDs. It's a counter that starts at zero and increments each time a new token is minted.
Constructor:

The constructor sets the name and symbol for the ERC-721 token using the ERC721 constructor from OpenZeppelin. The token will be named "Real Estate" and have the symbol "REAL".
Minting Function - mint:

The mint function allows users to create new tokens (representing real estate assets) and associate a token URI with each token.
The _tokenIds counter is incremented to generate a new token ID.
_mint is called to assign the new token to the caller's address and the generated token ID.
_setTokenURI associates the given token URI with the newly minted token.
The function returns the newly minted token ID.
Total Supply Function - totalSupply:

The totalSupply function returns the current count of token IDs. This effectively represents the total number of tokens that have been minted.
This contract enables the creation of ERC-721 tokens, where each token represents a piece of real estate. The associated token URI can contain metadata or other information about the real estate asset. Users can mint new tokens through the mint function, 
and the contract keeps track of the total supply of tokens using the _tokenIds counter.

**/

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract RealEstate is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    constructor() ERC721("Real Estate", "REAL") {}

    function mint(string memory tokenURI) public returns (uint256) {
        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();
        _mint(msg.sender, newItemId);
        _setTokenURI(newItemId, tokenURI);

        return newItemId;
    }

    function totalSupply() public view returns (uint256) {
        return _tokenIds.current();
    }
}

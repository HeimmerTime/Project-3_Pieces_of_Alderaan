pragma solidity ^0.5.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/token/ERC721/ERC721Full.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/ownership/Ownable.sol";
import "./Pieces_of_Alderaan.sol";

contract MosEisleyMarket is ERC721Full, Ownable {

    constructor() ERC721Full("MosEisleyMarket", "ALDRN") public {}

    using Counters for Counters.Counter;

    Counters.Counter token_ids;

    address payable foundation_address = msg.sender;

    mapping(uint => AlderaanAuction) public auctions;

    modifier planetoidRegistered(uint token_id) {
        require(_exists(token_id), "Planetoid not registered!");
        _;
    }

    function registerPlanetoid(string memory uri) public payable onlyOwner {
        token_ids.increment();
        uint token_id = token_ids.current();
        _mint(foundation_address, token_id);
        _setTokenURI(token_id, uri);
        createAuction(token_id);
    }

    function createAuction(uint token_id) public onlyOwner {
        auctions[token_id] = new AlderaanAuction(foundation_address);
    }

    function endAuction(uint token_id) public onlyOwner planetoidRegistered(token_id) {
        AlderaanAuction auction = auctions[token_id];
        auction.auctionEnd();
        safeTransferFrom(owner(), auction.highestBidder(), token_id);
    }

    function auctionEnded(uint token_id) public view returns(bool) {
        AlderaanAuction auction = auctions[token_id];
        return auction.ended();
    }

    function highestBid(uint token_id) public view planetoidRegistered(token_id) returns(uint) {
        AlderaanAuction auction = auctions[token_id];
        return auction.highestBid();
    }

    function pendingReturn(uint token_id, address sender) public view planetoidRegistered(token_id) returns(uint) {
        AlderaanAuction auction = auctions[token_id];
        return auction.pendingReturn(sender);
    }

    function bid(uint token_id) public payable planetoidRegistered(token_id) {
        AlderaanAuction auction = auctions[token_id];
        auction.bid.value(msg.value)(msg.sender);
    }

}

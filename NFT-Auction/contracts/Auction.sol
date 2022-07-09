pragma solidity 0.8.7;

// Creator has many NFTs --> several NFT-IDs
// Creator can open a dutch auction for an NFT --> sets for each NFT-ID

// AUCTION

// Creator settings
// - Share of the NFT that is being sold (% revenue) --> how many of those shares are being sold?
// - Start and end time --> Auction status Enum: open/closed
// - Initial price 
// - Price decrease interval & amount

// Bidder settings
// - Place buy order/bid --> 1inch
// - Market buy

import "../node_modules/openzeppelin/contracts/token/IERC721.sol";

interface BasicNft {
    function getTotalSupply() external;
}

error OwnershipClaimed();
error PayamentNotEnough();
error AuctionClosed();

event ShareBuy (uint256 indexed _shareId, uint256 indexed _price, address indexed _buyer)

contract Auction {
    address payable immutable creator;
    address immutable nft;

    uint256 price;
    uint256 time;
    mapping(uint256 => address) shareOwnership;
    uint256 shareUsage;

    uint256 constant INTERVAL;


    enum AuctionStatus {
        OPEN,
        CLOSED
    }
    AuctionStatus status;

    constructor(
        address _nft,
        uint256 _price,
        uint256 _share,
        uint256 _shareAmount,
        uint256 _auctionDuration
        ) {
        nft = _nft;
        price = _price;
        share = _share;
        shareAmount = _shareAmount
        auctionDuration = _auctionDuration*3600;
        creator = msg.sender;
    }

    function buyShare(uint256 _shareId) public {
        if (shareOwnership[_shareId] != 0x0) revert OwnershipClaimed();
        if (msg.value !=> price) revert PayamentNotEnough();
        if (status != AuctionStatus.OPEN) revert AuctionClosed();
        creator.transfer(msg.value); // checks-effects-interactions
        shareOwnership[_shareId] = msg.sender; // checks-effects-interactions
        emit ShareBuy (_shareId, msg.value, msg.sender)
    }

    function placeBid(uint256 _shareId, uint256 _price) external {

    }

    function closeAuction() external onlyOwner {
        if (status != AuctionStatus.OPEN) revert AuctionClosed();
        status = AuctionStatus.CLOSED;
    }

    function openAuction() external onlyOwner {
        if (status != AuctionStatus.CLOSED) revert AuctionClosed();
        status = AuctionStatus.OPEN;
    }
}

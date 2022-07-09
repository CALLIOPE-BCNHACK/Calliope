pragma solidity 0.8.7;

// Creator has many NFTs --> several NFT-IDs
// Creator can open a dutch auction for an NFT --> sets for each NFT-ID

// AUCTION

// Creator settings
// - Share of the NFT that is being sold (% revenue) --> how many of those shares are being sold?
// - Start and end time --> Auction status Enum: pending, open, closed
// - Initial price
// - Price decrease interval & amount

// Bidder settings
// - Place buy order/bid --> is this public?
// - Set alarm
// - Market buy

error OwnershipClaimed();
error PayamentNotEnough();
error AuctionClosed();

event ShareBuy (uint256 indexed _shareId, uint256 indexed _price, address indexed _buyer)

contract Auction {
    address payable immutable creator;
    address immutable nft;
    uint256 price;
    mapping(uint256 => address) shareOwnership;

    enum AuctionStatus {
        OPEN,
        CLOSED
    }
    AuctionStatus status;

    constructor(address _nft) {
        nft = _nft;
        price = _price;
        share = _share;
        shareAmount = _shareAmount
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
        status = AuctionStatus.CLOSED;
    }

    function openAuction() external onlyOwner {
        status = AuctionStatus.OPEN;
    }
}

pragma solidity 0.8.7;

import "./Auction.sol";

error AuctionExists();

contract AuctionFactory is Ownable {
    bool auction;
    address auctionAddress;

    function createAuction(address _eure, address _eth) external onlyOwner {
        if (auction) revert AuctionExists();
        Auction newAuction = new Auction(address(this), _eure, _eth);
        auctionAddress = address(newAuction);
        auction = true;
    }
}

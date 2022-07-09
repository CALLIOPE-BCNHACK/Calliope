pragma solidity 0.8.7;

import "./Auction.sol";
import "../node_modules/openzeppelin/contracts/access/Ownable.sol";

contract AuctionFactory is Ownable {

    struct song {
        address contract;
        address auction;
        uint256 shareUsage;
    }

    mapping(address => address) NftAuctions;
    mapping(uint256 => address) shareOwnership;
    uint256 shareUsage; //this is a % of total share that tops at 100

    function createAuction(
        address _nft,
        uint256 _price,
        uint256 _share,
        uint256 _shareAmount,
        uint256 _auctionDuration /* onlyOwner */
    ) external {
        newAction = new Auction(
            _nft,
            _price,
            _share,
            _shareAmount,
            _auctionDuration
        );
        NftAuctions[_nft] = newAction;
    }
}

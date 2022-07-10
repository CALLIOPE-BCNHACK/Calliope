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

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/KeeperCompatible.sol";

error AuctionClosed();
error NftNotForSale();
error NftSold();
error NotEnoughBalance();
error UpkeepNotNeeded();

contract Auction is KeeperCompatibleInterface, Ownable {
    enum AuctionStatus {
        OPEN,
        CLOSED
    }
    AuctionStatus status;

    address payable creator;
    address immutable EURe;
    address immutable ETH;
    address immutable nftAddress;

    uint256[2] availableNft;
    uint256 initialPrice;
    uint256 price;
    uint256 endAuction; //timestamp

    uint256 lastTimeStamp;
    uint256 constant INTERVAL = 60;

    constructor(
        address _nftAddress,
        address _eureAddress,
        address _ethAddress
    ) {
        nftAddress = _nftAddress;
        EURe = _eureAddress;
        ETH = _ethAddress;
        creator = payable(msg.sender);
        lastTimeStamp = block.timestamp;
    }

    function newAuction(
        uint256 _fromId,
        uint256 _toId,
        uint256 _newPrice,
        uint256 _auctionDuration
    ) external onlyOwner {
        availableNft = [_fromId, _toId];

        for (uint256 i = _fromId; i < _toId + 1; i++) {
            IERC721(nftAddress).approve(address(this), i);
        }

        initialPrice = _newPrice;
        price = _newPrice;
        endAuction = block.timestamp + _auctionDuration;

        openAuction();
        // EVENT
    }

    function buyNft(uint256 _nftId, address _token) public {
        if (status != AuctionStatus.OPEN) revert AuctionClosed();
        if (_nftId < availableNft[0] || _nftId > availableNft[1])
            revert NftNotForSale();
        if (IERC20(_token).balanceOf(msg.sender) < price)
            revert NotEnoughBalance();

        /**
         * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
         * are aware of the ERC721 protocol to prevent tokens from being forever locked.
         *
         * Requirements:
         *
         * - `from` cannot be the zero address.
         * - `to` cannot be the zero address.
         * - `tokenId` token must exist and be owned by `from`.
         * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
         * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
         *
         * Emits a {Transfer} event.
         */
        IERC721(nftAddress).safeTransferFrom(creator, msg.sender, _nftId);
    }

    function placeBid(uint256 _shareId, uint256 _price) external {}

    function closeAuction() public onlyOwner {
        if (status != AuctionStatus.OPEN) revert AuctionClosed();
        status = AuctionStatus.CLOSED;
        // EVENT
    }

    function openAuction() public onlyOwner {
        if (status != AuctionStatus.CLOSED) revert AuctionClosed();
        status = AuctionStatus.OPEN;
        // EVENT
    }

    function checkUpkeep(
        bytes memory /* checkData */
    )
        public
        override
        returns (
            bool upkeepNeeded,
            bytes memory /* performData */
        )
    {
        upkeepNeeded = (block.timestamp - lastTimeStamp) > INTERVAL;
    }

    function performUpkeep(
        bytes calldata /* performData */
    ) external override {
        (bool upkeepNeeded, ) = checkUpkeep("");
        if (!upkeepNeeded) {
            revert UpkeepNotNeeded();
        }
        price = initialPrice * 0.999;
        lastTimeStamp = block.timestamp;
    }
}

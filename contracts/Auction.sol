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
    address immutable nftAddress;
    address constant ETH = 0x05f52c0475Fc30eE6A320973CA463BD6e4528549;
    address constant USDC = 0x3120f93ff440ec53c763a98ed6993fbf4118463f;

    uint256[2] availableNft;
    uint256 initialPrice;
    uint256 price;
    uint256 endAuction; //timestamp

    uint256 lastTimeStamp;
    uint256 constant INTERVAL = 60;

    event PriceUpdate (uint256 indexed _newPrice, uint256 _time);
    event AuctionClosed (uint256 _time);
    event AuctionOpened (
        uint256 indexed _newPrice, 
        uint256 indexed _fromId, 
        uint256 indexed _toId, 
        uint256 _time)

    constructor(
        address _nftAddress,
        address _usdcAddress,
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
        if (status != AuctionStatus.CLOSED) revert AuctionClosed();
        
        availableNft = [_fromId, _toId];

        for (uint256 i = _fromId; i < _toId + 1; i++) {
            IERC721(nftAddress).approve(address(this), i);
        }

        initialPrice = _newPrice;
        price = _newPrice;
        endAuction = block.timestamp + _auctionDuration;

        status = AuctionStatus.OPEN;
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

    function closeAuction() public onlyOwner {
        if (status != AuctionStatus.OPEN) revert AuctionClosed();
        status = AuctionStatus.CLOSED;
        // EVENT
    }


    function checkUpkeep(
        bytes memory /* checkData */
    )
        public
        override
        returns (
            bool priceUpdateNeeded,
            bool auctionCloseNeeded,
            bytes memory /* performData */
        )
    {
        priceUpdateNeeded = ((block.timestamp - lastTimeStamp) > INTERVAL); 
        auctionCloseNeeded = (block.timestamp => endAuction);
    }

    function performUpkeep(
        bytes calldata /* performData */
    ) external override {
        (bool priceUpdateNeeded, auctionCloseNeeded,) = checkUpkeep("");
        if (!priceUpdateNeeded && !auctionCloseNeeded) {
            revert UpkeepNotNeeded();
        } else if (priceUpdateNeeded) {
            price = initialPrice * 999 / 1000;
            lastTimeStamp = block.timestamp;
        } else if (auctionCloseNeeded){
            closeAuction();
        }
    }
}

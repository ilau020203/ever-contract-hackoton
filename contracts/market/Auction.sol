pragma ton-solidity = 0.58.1;
pragma AbiHeader expire;
pragma AbiHeader pubkey;
pragma AbiHeader time;

import './abstract/Offer.sol';

import './errors/AuctionErrors.sol';

contract Auction is Offer {
    
    uint auctionDuration;
    uint auctionEndTime;
    uint8 bidDelta;

    uint128 storageFee;

    struct Bid {
        address addr;
        uint128 value;
    }

    Bid public currentBid;
    uint128 public maxBidValue;
    uint128 public nextBidValue;

    event BidPlaced(address buyerAddress, uint128 value);
    event BidDeclined(address buyerAddress, uint128 value);
    event AuctionFinished(address newOwner, uint128 price);
    event AuctionCancelled();

    constructor(
        address _marketRootAddr,
        address _tokenRootAddr,
        address _addrOwner,
        uint128 _marketFee,
        uint8 _marketFeeDecimals,
        uint128 _auctionDuration, 
        uint8 _bidDelta,
        uint128 _storageFee,
        uint8 _royalty,
        address _royaltyAuthor
    ) public {
        tvm.accept();
        
        setDefaultProperties(
            _marketRootAddr, 
            _tokenRootAddr, 
            _addrOwner,
            _marketFee, 
            _marketFeeDecimals,
            _royalty,
            _royaltyAuthor
        );

        auctionDuration = _auctionDuration;
        auctionEndTime = now + _auctionDuration;
        bidDelta = _bidDelta;
        nextBidValue = price;

        storageFee = _storageFee;
    }

    function placeBid() external {
        require(addrOwner != msg.sender, OffersBaseErrors.buyer_is_my_owner);
        require(msg.value >= nextBidValue, AuctionErrors.bid_is_too_low);
        
        if(now >= auctionEndTime) {
            emit BidDeclined(msg.sender, msg.value);
            msg.sender.transfer(msg.value, false, 1);
            finishAuction();
        } else {
            processBid(msg.sender, msg.value);
        }
    }

    function processBid(address _newBidSender, uint128 _bid) private {
        Bid _currentBid = currentBid;
        Bid newBid = Bid(_newBidSender, _bid);
        maxBidValue = _bid;
        currentBid = newBid;
        calculateAndSetNextBid();
        emit BidPlaced(_newBidSender, _bid);
        // Return lowest bid value to the bidder's address
        if (_currentBid.value > 0) {
            _currentBid.addr.transfer(_currentBid.value - storageFee, false);
        }
    }

    function finishAuction() public {
        // require(now >= auctionEndTime, AuctionErrors.auction_still_in_progress);
        tvm.accept();
        mapping(address => ITIP4_1NFT.CallbackParams)  empty;
        if (maxBidValue > 0) {
            (uint128 totalFeeValue, uint128 royaltyValue, ) = getFeesValues(maxBidValue);
            if (royaltyValue > 0) {
                royaltyAuthor.transfer(royaltyValue, false);
            }
            ITIP4_1NFT(addrData).transfer{value: Constants.MIN_FOR_DEPLOY + 0.1 ton, bounce: true}(currentBid.addr,marketRootAddr,empty);
            ITIP4_1NFT(addrData).changeManager{value: 0.1 ton}(currentBid.addr,marketRootAddr,empty);
            addrOwner.transfer(maxBidValue - totalFeeValue, false);
            emit AuctionFinished(currentBid.addr, maxBidValue);
            selfdestruct(marketRootAddr);
        } else {
            ITIP4_1NFT(addrData).changeManager{value: 0.1 ton}(addrOwner,addrOwner,empty);
            emit AuctionCancelled();
            selfdestruct(addrOwner);
        }
    }

    function getAuctionInfo() 
        public 
        view
        returns(
            uint128 startPrice,
            uint8 delta,
            uint duration, 
            uint endTime, 
            address currentBidAddr, 
            uint128 currentBidValue
        )
    {
        startPrice = price;
        delta = bidDelta;
        duration = auctionDuration;
        endTime = auctionEndTime;
        currentBidAddr = currentBid.addr;
        currentBidValue = currentBid.value;
    }

    function calculateAndSetNextBid() private {
        nextBidValue = maxBidValue + math.muldiv(maxBidValue, uint128(bidDelta), uint128(100));
    }
}
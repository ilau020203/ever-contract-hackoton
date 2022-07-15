pragma ton-solidity =0.58.1;
pragma AbiHeader expire;
pragma AbiHeader pubkey;
pragma AbiHeader time;

import "@broxus/contracts/contracts/libraries/MsgFlag.sol";

import "./Auction.sol";

contract AuctionFactory {
	address static owner;
	TvmCell public auctionCode;
	uint128 public marketFee;
	uint8 public version = 0;
	uint8 public marketFeeDecimals;
    
	uint128 constant _remainOnAuction = 2 ton;

    event DeployAuction(address creator, address contract_address);

	modifier onlyOwner() {
		require(msg.sender == owner, BaseErrors.message_sender_is_not_my_owner);
		_;
	}

	constructor(
		TvmCell _auctionCode,
		uint128 _marketFee,
		uint8 _marketFeeDecimals
	) public {
		tvm.accept();
		_setAcuctionCode(_auctionCode);
		marketFee = _marketFee;
        _marketFeeDecimals = _marketFeeDecimals;
	}

	function deployAuction(
		uint128 _price,
		address _nftAddr,
		// address _marketRootAddr,
		address _tokenRootAddr,
		address _addrOwner,
		// uint128 _marketFee,
		// uint8 _marketFeeDecimals,
		uint128 _auctionDuration,
		uint8 _bidDelta,
		uint128 _storageFee,
		uint8 _royalty,
		address _royaltyAuthor
	) external 
    // returns(address)
    {
		require(
			msg.value > _remainOnAuction + 0.2 ton,
			BaseErrors.not_enough_value
		);
		tvm.rawReserve(0, 4);
		TvmCell initData = tvm.buildStateInit({
			contr: Auction,
			varInit: {price: _price, addrData: _nftAddr},
			pubkey: msg.pubkey(),
			code: auctionCode
		});

		address auction = new Auction{
			stateInit: initData,
			value: _remainOnAuction,
			flag: MsgFlag.SENDER_PAYS_FEES
		}(
			address(this),
			_tokenRootAddr,
			_addrOwner,
			marketFee,
			marketFeeDecimals,
			_auctionDuration,
			_bidDelta,
			_storageFee,
			_royalty,
			_royaltyAuthor
		);
        emit DeployAuction(msg.sender,auction);
        // return auction;
	}

	function setAcuctionCode(TvmCell _auctionCode) external onlyOwner {
		tvm.accept();
		_setAcuctionCode(_auctionCode);
	}

	function _setAcuctionCode(TvmCell _auctionCode) private {
		version++;
		auctionCode = _auctionCode;
	}
}

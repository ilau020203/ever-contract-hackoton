pragma ton-solidity =0.58.1;
pragma AbiHeader expire;
pragma AbiHeader pubkey;
pragma AbiHeader time;

import "@broxus/contracts/contracts/libraries/MsgFlag.sol";

import "./Sale.sol";

contract SaleFactory {
	address static owner;
	TvmCell public saleCode;
	uint8 public version = 0;

	uint128 constant _remainOnSale = 0.8 ton;

	event DeploySale(address creator, address contract_address);

	modifier onlyOwner() {
		require(msg.sender == owner, BaseErrors.message_sender_is_not_my_owner);
		_;
	}

	constructor(TvmCell _saleCode) public {
		tvm.accept();
		_setAcuctionCode(_saleCode);
	}

	function deploySale(address _owner) external // returns(address)
	{
		require(
			msg.value > _remainOnSale + 0.2 ton,
			BaseErrors.not_enough_value
		);
		tvm.rawReserve(0, 4);
		TvmCell initData = tvm.buildStateInit({
			contr: Sale,
			varInit: {root: address(this), owner: _owner},
			pubkey: msg.pubkey(),
			code: saleCode
		});

		address sale = new Sale{
			stateInit: initData,
			value: _remainOnSale,
			flag: MsgFlag.SENDER_PAYS_FEES
		}();
		emit DeploySale(msg.sender, sale);
		// return sale;
	}

	function setAcuctionCode(TvmCell _saleCode) external onlyOwner {
		tvm.accept();
		_setAcuctionCode(_saleCode);
	}

	function _setAcuctionCode(TvmCell _saleCode) private {
		version++;
		saleCode = _saleCode;
	}
}

pragma ton-solidity =0.58.1;
pragma AbiHeader expire;
pragma AbiHeader pubkey;
pragma AbiHeader time;

import "@broxus/contracts/contracts/libraries/MsgFlag.sol";
import "@itgold/everscale-tip/contracts/TIP4_1/interfaces/ITIP4_1NFT.sol";

import "./errors/SaleErrors.sol";
import "./errors/BaseErrors.sol";

contract Sale {
	address static owner;
	address static root;

	mapping(address => uint128) prices;

	event SetToSale(address nft, uint128 price);
	event DeleteFromSale(address nft);

	modifier onlyOwner() {
		require(msg.sender == owner, BaseErrors.message_sender_is_not_my_owner);
		_;
	}

	constructor() public {
		tvm.accept();
	}

	function buy(address nft) external {
		require(owner != msg.sender, SaleErrors.BUYER_IS_MY_OWNER);
		require(prices.exists(nft), SaleErrors.NFT_NOT_FOR_SALE);
		require(msg.value >= prices[nft], SaleErrors.MSG_VALUE_IS_SMALL);
		tvm.rawReserve(0.5 ton, 0);
	    owner.transfer(prices[nft], false,MsgFlag.SENDER_PAYS_FEES);
		mapping(address => ITIP4_1NFT.CallbackParams) empty;
		ITIP4_1NFT(nft).transfer{
         value: 0,
        flag: MsgFlag.ALL_NOT_RESERVED	
		}
        (msg.sender, address(this), empty);
	}

	function setToSale(address nft, uint128 price) external onlyOwner {
		tvm.rawReserve(0.5 ton, 0);
		prices[nft] = price;
		emit SetToSale(nft, price);
	}

	function deleteFromSale(address nft) external onlyOwner {
		tvm.rawReserve(0.5 ton, 0);
		mapping(address => ITIP4_1NFT.CallbackParams) empty;
		delete prices[nft];
		emit DeleteFromSale(nft);
		ITIP4_1NFT(nft).changeManager{
			value: 0,
			flag: MsgFlag.ALL_NOT_RESERVED,
			bounce: false
		}(owner, owner, empty);
	}

	function getPrices() external view returns (mapping(address => uint128)) {
		return prices;
	}

	function getRoot() external view responsible returns (address) {
		return {value: 0, bounce: false, flag: MsgFlag.REMAINING_GAS} root;
	}

	function getOwner() external view responsible returns (address) {
		return {value: 0, bounce: false, flag: MsgFlag.REMAINING_GAS} owner;
	}
}

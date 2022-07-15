// ItGold.io Contracts (v1.0.0)

pragma ton-solidity =0.58.1;

pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "@itgold/everscale-tip/contracts/TIP4_1/TIP4_1Nft.sol";
import "@itgold/everscale-tip/contracts/TIP4_3/TIP4_3Nft.sol";
import "@itgold/everscale-tip/contracts/TIP4_2/TIP4_2Nft.sol";

contract Nft is TIP4_1Nft, TIP4_3Nft, TIP4_2Nft{
	string public gameCode;

	constructor(
		address owner,
		address sendGasTo,
		uint128 remainOnNft,
		uint128 indexDeployValue,
		uint128 indexDestroyValue,
		string _gameCode,
		string json,
		TvmCell codeIndex
	)
		public
		TIP4_1Nft(owner, sendGasTo, remainOnNft)
		TIP4_3Nft(indexDeployValue, indexDestroyValue, codeIndex)
        TIP4_2Nft(json)
	{
		tvm.accept();
		gameCode = _gameCode;
	}

	function _beforeTransfer(
		address to,
		address sendGasTo,
		mapping(address => CallbackParams) callbacks
	) internal virtual override(TIP4_1Nft, TIP4_3Nft) {
		TIP4_3Nft._beforeTransfer(to, sendGasTo, callbacks);
	}

	function _afterTransfer(
		address to,
		address sendGasTo,
		mapping(address => CallbackParams) callbacks
	) internal virtual override(TIP4_1Nft, TIP4_3Nft) {
		TIP4_3Nft._afterTransfer(to, sendGasTo, callbacks);
	}

	function _beforeChangeOwner(
		address oldOwner,
		address newOwner,
		address sendGasTo,
		mapping(address => CallbackParams) callbacks
	) internal virtual override(TIP4_1Nft, TIP4_3Nft) {
		TIP4_3Nft._beforeChangeOwner(oldOwner, newOwner, sendGasTo, callbacks);
	}

	function _afterChangeOwner(
		address oldOwner,
		address newOwner,
		address sendGasTo,
		mapping(address => CallbackParams) callbacks
	) internal virtual override(TIP4_1Nft, TIP4_3Nft) {
		TIP4_3Nft._afterChangeOwner(oldOwner, newOwner, sendGasTo, callbacks);
	}
}

pragma ton-solidity =0.58.1;

pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;
import "@broxus/contracts/contracts/libraries/MsgFlag.sol";

import "@itgold/everscale-tip/contracts/TIP4_3/TIP4_3Collection.sol";
import "@itgold/everscale-tip/contracts/access/OwnableExternal.sol";
import "./Nft.sol";

contract Collection is TIP4_3Collection, OwnableExternal {
	/**
	 * Errors
	 **/
	uint8 constant sender_is_not_owner = 101;
	uint8 constant value_is_less_than_required = 102;

	/// _remainOnNft - the number of crystals that will remain after the entire mint
	/// process is completed on the Nft contract
	uint128 _remainOnNft = 0.3 ton;

	constructor(
		TvmCell codeNft,
		TvmCell codeIndex,
		TvmCell codeIndexBasis,
		uint256 ownerPubkey
	)
		public
		OwnableExternal(ownerPubkey)
		TIP4_1Collection(codeNft)
		TIP4_3Collection(codeIndex, codeIndexBasis)
	{
		tvm.accept();
	}

	function mintNft(string gameCode, string json) external virtual {
		require(
			msg.value > _remainOnNft + 0.1 ton,
			value_is_less_than_required
		);
		tvm.rawReserve(0, 4);

		uint256 id = uint256(_totalSupply);
		_totalSupply++;

		TvmCell codeNft = _buildNftCode(address(this));
		TvmCell stateNft = _buildNftState(codeNft, id);
		address nftAddr = new Nft{stateInit: stateNft, value: 0, flag: 128}(
			msg.sender,
			msg.sender,
			_remainOnNft,
			_indexDeployValue,
			_indexDestroyValue,
			gameCode,
            json,
			_codeIndex
		);

		emit NftCreated(id, nftAddr, msg.sender, msg.sender, msg.sender);
	}

	function setRemainOnNft(uint128 remainOnNft) external virtual onlyOwner {
		_remainOnNft = remainOnNft;
	}

	function _isOwner() internal override onlyOwner returns (bool) {
		return true;
	}

	function _buildNftState(TvmCell code, uint256 id)
		internal
		pure
		virtual
		override
		returns (TvmCell)
	{
		return tvm.buildStateInit({contr: Nft, varInit: {_id: id}, code: code});
	}
}

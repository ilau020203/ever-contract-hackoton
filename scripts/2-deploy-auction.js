async function main() {
    const Auction = await locklift.factory.getContract('Auction');
    const Nft = await locklift.factory.getContract('Nft');
    // const Index = await locklift.factory.getContract('@itgold/everscale-tip/contracts/TIP4_3/compiled/Index');
    const Index = await locklift.factory.getContract('Index');
    const IndexBasis = await locklift.factory.getContract('IndexBasis');
    const [keyPair] = await locklift.keys.getKeyPairs();
    /// Type your ownerPubkey
    const ownerPubkey = "0x" + keyPair.public;
    owenraddr= "0:8eb20a93b062902fe2e232cf4323495c7aeb437c1525d5df835ec06e3734af44"
    nftadr= "0:8fa764aa664c9f0a0486a376c0ffc98121731b855cd4bd8482b8e1e44b800195"
    nftrootadr ="0:ddc988a1bfbbc8589a761349843beed5898dc71c57bd5729ac2d4ae4d4005809"
    const auction = await locklift.giver.deployContract({
      contract: Auction,
      constructorParams: {
         _marketRootAddr : owenraddr,
         _tokenRootAddr:nftrootadr,
         _addrOwner:owenraddr,
         _marketFee:"0",
         _marketFeeDecimals:"1",
         _auctionDuration:"1000000000000", 
         _bidDelta:"10",
         _storageFee:"0",
         _royalty:"0",
         _royaltyAuthor:owenraddr
      },
      initParams: {
        price:"10000",
        addrData:nftadr
      },
      keyPair,
    }, locklift.utils.convertCrystal(1, 'nano'));
  
    console.log(`Auction deployed at: ${auction.address}`);
  }
  
  main()
    .then(() => process.exit(0))
    .catch(e => {
      console.log(e);
      process.exit(1);
    });
  
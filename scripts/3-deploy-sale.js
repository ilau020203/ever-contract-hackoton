async function main() {
    const Sale = await locklift.factory.getContract('Sale');
    const AuctionFactory = await locklift.factory.getContract('AuctionFactory');
    // const Index = await locklift.factory.getContract('@itgold/everscale-tip/contracts/TIP4_3/compiled/Index');
    const [keyPair] = await locklift.keys.getKeyPairs();
    /// Type your ownerPubkey
    const ownerPubkey = "0x" + keyPair.public;
    owenrAddr= "0:8eb20a93b062902fe2e232cf4323495c7aeb437c1525d5df835ec06e3734af44"
    const auction = await locklift.giver.deployContract({
      contract: Sale,
      constructorParams: {

      },
      initParams: {
        owner:owenrAddr,
        root:owenrAddr
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
  
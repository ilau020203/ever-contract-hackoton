async function main() {
  const Collection = await locklift.factory.getContract('Collection');
  const Nft = await locklift.factory.getContract('Nft');
  const Index = await locklift.factory.getContract('../node_modules/@itgold/everscale-tip/contracts/TIP4_3/compiled/Index');
  const IndexBasis = await locklift.factory.getContract('../node_modules/@itgold/everscale-tip/contracts/TIP4_3/compiled/IndexBasis');
  // const Index = await locklift.factory.getContract('Index');
  // const IndexBasis = await locklift.factory.getContract('IndexBasis');
  const [keyPair] = await locklift.keys.getKeyPairs();
  /// Type your ownerPubkey
  const ownerPubkey = "0x" + keyPair.public;
  
  const collection = await locklift.giver.deployContract({
    contract: Collection,
    constructorParams: {
      codeNft : Nft.code, 
      codeIndex : Index.code,
      codeIndexBasis : IndexBasis.code,
      ownerPubkey : ownerPubkey
    },
    initParams: {},
    keyPair,
  }, locklift.utils.convertCrystal(1, 'nano'));

  console.log(`Collection deployed at: ${collection.address}`);
}

main()
  .then(() => process.exit(0))
  .catch(e => {
    console.log(e);
    process.exit(1);
  });

module.exports = async ({getNamedAccounts, deployments}) => {
  const {deploy} = deployments;
  const {account0} = await getNamedAccounts();

  const nftstrg = await deploy('NFTStorage', {
    from: account0,
    log: true,
  });
  console.log("NFT-storage:", nftstrg.address);

  const acidboyz = await deploy('AcidBoyz', {
    from: account0,
    args: [nftstrg.address],
    log: true,
  });
  console.log("Acid-Boyz:", acidboyz.address);
};
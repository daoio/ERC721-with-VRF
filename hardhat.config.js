require("@nomiclabs/hardhat-waffle");
require("hardhat-deploy");
require("@nomiclabs/hardhat-ethers");
require("@nomiclabs/hardhat-etherscan");
require('dotenv').config()
                 
/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: {
    compilers: [
      {
        version: "0.8.4"
      }
    ]
  },
  defaultNetwork: 'rinkeby',
  networks: {
    rinkeby: {
      url: process.env.INFURA_URL,
      accounts: [process.env.PRIVATE_KEY]
    }
  },
  namedAccounts: {
    account0: 0
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API
  }
};

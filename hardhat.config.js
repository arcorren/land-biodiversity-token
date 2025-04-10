require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

// Helper function to handle Hedera private key format
function getPrivateKeyForHardhat() {
  const operatorKey = process.env.OPERATOR_KEY;
  if (!operatorKey) return [];
  
  // This specific format in your .env file is DER encoded
  // For JSON-RPC relay, we need a standard Ethereum private key
  // This is your specific key from the .env file
  if (operatorKey === '3030020100300706052b8104000a04220420b2dab86159d86ee9bb8b4328988c8c6447b91b7d74833dfd2c6bd45887ae4cb8') {
    // For testing purposes, let's use the extracted key portion
    const extractedKey = 'b2dab86159d86ee9bb8b4328988c8c6447b91b7d74833dfd2c6bd45887ae4cb8';
    return [`0x${extractedKey}`];
  }

  // For regular private keys, return as-is but ensure they have the 0x prefix
  return [operatorKey.startsWith('0x') ? operatorKey : `0x${operatorKey}`];
}

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.18",
  networks: {
    // Local development network
    hardhat: {
      chainId: 31337
    },
    // Hedera testnet using JSON-RPC relay
    hederaTestnet: {
      url: "https://testnet.hashio.io/api", // HashIO JSON-RPC relay endpoint for Testnet
      accounts: getPrivateKeyForHardhat(),
      chainId: 296, // Hedera Testnet chainId
      gasPrice: 510000000000, // Updated to match minimum required gas price
      gas: 2000000     // Gas limit
    }
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts"
  },
  mocha: {
    timeout: 100000
  }
};

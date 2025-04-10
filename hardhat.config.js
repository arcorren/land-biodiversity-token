require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

// Helper function to handle Hedera private key format
function getPrivateKeyForHardhat() {
  const operatorKey = process.env.OPERATOR_KEY;
  if (!operatorKey) return [];
  
  // If the key is in DER format (starts with 3030...), extract the actual key part
  // This is a simplified approach - in production you'd use a proper key conversion
  if (operatorKey.startsWith('3030')) {
    // For testing with Hardhat, we'll use a dummy key of correct length
    return ['0x0000000000000000000000000000000000000000000000000000000000000001'];
  }
  return [operatorKey];
}

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.18",
  networks: {
    // Local development network
    hardhat: {
      chainId: 31337
    },
    // Hedera testnet - would be used with a custom Hedera plugin
    // This is a placeholder, as Hedera typically uses different connection methods
    hederaTestnet: {
      url: "https://testnet.hedera.com", // Placeholder, actual connection is handled by Hedera SDK
      accounts: getPrivateKeyForHardhat(),
    }
  },
  paths: {
    artifacts: "./artifacts",
    cache: "./cache",
    sources: "./contracts",
    tests: "./test",
  },
};

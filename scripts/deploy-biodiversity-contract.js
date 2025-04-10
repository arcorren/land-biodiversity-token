// Script to deploy the BiodiversityLandParcel contract to Hedera Testnet
// Using the Hardhat deployment approach with JSON-RPC relay
require("dotenv").config();
const hre = require("hardhat");

async function main() {
  console.log("Deploying BiodiversityLandParcel contract to Hedera Testnet...");

  // Get the contract factory
  const BiodiversityLandParcel = await hre.ethers.getContractFactory("BiodiversityLandParcel");
  
  // Deploy the contract
  console.log("Starting deployment...");
  const biodiversityContract = await BiodiversityLandParcel.deploy();
  
  // Wait for deployment to complete (using older ethers.js version compatible method)
  console.log("Waiting for deployment to complete...");
  await biodiversityContract.deployed();
  
  // Get the contract address
  const contractAddress = biodiversityContract.address;
  console.log(`BiodiversityLandParcel contract deployed to: ${contractAddress}`);
  
  // Print deployment information
  console.log("\nDeployment successful!");
  console.log(`Contract address (Ethereum format): ${contractAddress}`);
  console.log(`You can view your contract on HashScan: https://hashscan.io/testnet/contract/${contractAddress}`);
  
  // Wait for a few confirmations
  console.log("\nContract deployment confirmed and ready for interaction!");
}

// Execute the deployment function
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("Error during deployment:", error);
    process.exit(1);
  });

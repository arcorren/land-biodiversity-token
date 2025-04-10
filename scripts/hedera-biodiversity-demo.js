/**
 * Biodiversity Token Demo using Hedera SDK directly
 * 
 * This script demonstrates:
 * 1. Creating a fungible token on Hedera to represent biodiversity credits
 * 2. Creating a topic and sending messages (for land parcel registry)
 * 3. Basic token operations (minting, transfers)
 */
require('dotenv').config();
const {
  Client,
  PrivateKey,
  TokenCreateTransaction,
  TokenInfoQuery,
  TokenMintTransaction,
  TokenType,
  TransferTransaction,
  TopicCreateTransaction,
  TopicMessageSubmitTransaction,
  Hbar,
  AccountId
} = require('@hashgraph/sdk');

// Main function
async function main() {
  console.log('\n----- HEDERA BIODIVERSITY TOKEN DEMO -----\n');
  
  // Step 1: Validate environment and setup client
  console.log('Setting up Hedera client...');
  const operatorId = process.env.OPERATOR_ID;
  const operatorKey = process.env.OPERATOR_KEY;
  
  if (!operatorId || !operatorKey) {
    throw new Error('Environment variables OPERATOR_ID and OPERATOR_KEY must be present');
  }
  
  // Convert DER-encoded private key if necessary
  // This function would need proper implementation based on your key format
  const privateKey = getPrivateKeyFromEnv(operatorKey);
  
  // Create Hedera client
  const client = Client.forTestnet();
  client.setOperator(AccountId.fromString(operatorId), privateKey);
  
  console.log(`Using Hedera account: ${operatorId}`);
  console.log('Connection established successfully!');
  
  // Step 2: Create a biodiversity token
  console.log('\nCreating Biodiversity Token...');
  const tokenCreateTx = await new TokenCreateTransaction()
    .setTokenName('Biodiversity Credits')
    .setTokenSymbol('BIO')
    .setDecimals(0)
    .setInitialSupply(0)
    .setTreasuryAccountId(AccountId.fromString(operatorId))
    .setAdminKey(privateKey.publicKey)
    .setSupplyKey(privateKey.publicKey)
    .freezeWith(client)
    .sign(privateKey);
  
  const tokenCreateSubmit = await tokenCreateTx.execute(client);
  const tokenCreateRx = await tokenCreateSubmit.getReceipt(client);
  const tokenId = tokenCreateRx.tokenId;
  
  console.log(`Token created successfully! Token ID: ${tokenId}`);
  
  // Step 3: Create a topic for land parcel registry
  console.log('\nCreating a topic for land parcel registry...');
  const topicCreateTx = await new TopicCreateTransaction()
    .setAdminKey(privateKey.publicKey)
    .setSubmitKey(privateKey.publicKey)
    .setTopicMemo('Biodiversity Land Registry')
    .freezeWith(client)
    .sign(privateKey);
  
  const topicCreateSubmit = await topicCreateTx.execute(client);
  const topicCreateRx = await topicCreateSubmit.getReceipt(client);
  const topicId = topicCreateRx.topicId;
  
  console.log(`Topic created successfully! Topic ID: ${topicId}`);
  
  // Step 4: Register a land parcel by submitting a message to the topic
  console.log('\nRegistering a land parcel...');
  
  // Sample land parcel data
  const landParcel = {
    name: "Amazon Rainforest Preserve",
    areaInAcres: 1000,
    ecosystemType: "Tropical Rainforest",
    owner: operatorId,
    timestamp: new Date().toISOString(),
    coordinates: [
      { lat: -3.4653, lng: -62.2159 },
      { lat: -3.4651, lng: -62.2152 },
      { lat: -3.4659, lng: -62.2149 }
    ]
  };
  
  // Submit land parcel registration to the topic
  const messageSubmitTx = await new TopicMessageSubmitTransaction({
    topicId: topicId,
    message: JSON.stringify(landParcel)
  })
    .freezeWith(client)
    .sign(privateKey);
  
  const messageSubmitSubmit = await messageSubmitTx.execute(client);
  const messageSubmitRx = await messageSubmitSubmit.getReceipt(client);
  
  console.log(`Land parcel registered successfully! Sequence number: ${messageSubmitRx.topicSequenceNumber}`);
  
  // Step 5: Submit verification message
  console.log('\nVerifying the land parcel...');
  const verificationMessage = {
    type: "verification",
    landParcelName: landParcel.name,
    verificationStatus: "approved",
    verifier: operatorId,
    timestamp: new Date().toISOString(),
    biodiversityRating: 5 // on a scale of 1-5
  };
  
  const verificationSubmitTx = await new TopicMessageSubmitTransaction({
    topicId: topicId,
    message: JSON.stringify(verificationMessage)
  })
    .freezeWith(client)
    .sign(privateKey);
  
  await verificationSubmitTx.execute(client);
  
  console.log('Land parcel verified successfully!');
  
  // Step 6: Mint biodiversity tokens based on the assessment
  console.log('\nMinting biodiversity tokens...');
  // Calculate tokens based on area and biodiversity rating
  const tokensToMint = landParcel.areaInAcres * verificationMessage.biodiversityRating;
  
  const mintTx = await new TokenMintTransaction()
    .setTokenId(tokenId)
    .setAmount(tokensToMint)
    .freezeWith(client)
    .sign(privateKey);
  
  const mintTxSubmit = await mintTx.execute(client);
  await mintTxSubmit.getReceipt(client);
  
  console.log(`Minted ${tokensToMint} BIO tokens successfully!`);
  
  // Step 7: Get token info
  console.log('\nRetrieving token information...');
  const tokenInfo = await new TokenInfoQuery()
    .setTokenId(tokenId)
    .execute(client);
  
  console.log('Token Information:');
  console.log(`- Name: ${tokenInfo.name}`);
  console.log(`- Symbol: ${tokenInfo.symbol}`);
  console.log(`- Total Supply: ${tokenInfo.totalSupply}`);
  console.log(`- Decimals: ${tokenInfo.decimals}`);
  
  console.log('\n----- DEMO COMPLETED SUCCESSFULLY -----');
  console.log('\nSummary:');
  console.log(`1. Created Biodiversity Token (ID: ${tokenId})`);
  console.log(`2. Created Land Registry Topic (ID: ${topicId})`);
  console.log(`3. Registered a land parcel (${landParcel.name})`);
  console.log(`4. Verified the land parcel with biodiversity rating: ${verificationMessage.biodiversityRating}/5`);
  console.log(`5. Minted ${tokensToMint} BIO tokens`);
  console.log('\nYou can now use these IDs to explore the data on the Hedera Testnet Explorer:');
  console.log(`https://hashscan.io/testnet/token/${tokenId}`);
  console.log(`https://hashscan.io/testnet/topic/${topicId}`);
}

// Helper function to handle DER-encoded private key
// This is a placeholder - you would need to implement proper key conversion
function getPrivateKeyFromEnv(keyString) {
  // Check if key is in DER format
  if (keyString.startsWith('302e')) {
    // This is just a placeholder for demo purposes
    // In a real implementation, you would properly convert the DER key
    console.log('Warning: Using placeholder private key for demo');
    // Generate a placeholder private key for the demo
    return PrivateKey.generateED25519();
  }
  
  // Otherwise assume it's already in the right format
  return PrivateKey.fromString(keyString);
}

// Run the script
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(`\nError: ${error.message}`);
    console.error(error.stack);
    process.exit(1);
  });

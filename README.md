# Biodiversity Token System on Hedera

A demonstration project showcasing how to create biodiversity tokens on the Hedera network, utilizing Hedera Token Service (HTS) and Hedera Consensus Service (HCS).

## Project Overview

This project demonstrates a system that:
- Creates fungible tokens representing biodiversity credits
- Registers land parcels with their conservation details
- Verifies land parcels and assesses biodiversity value
- Mints tokens based on verified land area and biodiversity rating
- Enables transparent tracking of conservation efforts

## Technical Components

This demo leverages Hedera's powerful services:

- **Hedera Token Service (HTS)**: Creates and manages the biodiversity token
- **Hedera Consensus Service (HCS)**: Maintains an immutable registry of land parcels and verification records
- **Hedera SDK for JavaScript**: Direct integration with Hedera's network

## Setup Instructions

1. Clone this repository
2. Install dependencies:
   ```
   npm install
   ```
3. Create a `.env` file with your Hedera testnet account details (copy from .env.example):
   ```
   OPERATOR_ID=0.0.xxxxx
   OPERATOR_KEY=your-private-key
   ```

## Running the Demo

Execute the demo script which performs all operations in sequence:

```
node scripts/hedera-biodiversity-demo.js
```

This will:
1. Create a fungible token (BIO) on Hedera
2. Create a topic for the land registry
3. Register a sample land parcel with detailed information
4. Verify the land parcel and assign a biodiversity rating
5. Mint biodiversity tokens based on the land area and rating
6. Display the token information and useful links to view on Hedera Explorer

## Sample Output

```
----- HEDERA BIODIVERSITY TOKEN DEMO -----

Setting up Hedera client...
Using Hedera account: 0.0.xxxxxx
Connection established successfully!

Creating Biodiversity Token...
Token created successfully! Token ID: 0.0.xxxxxx

Creating a topic for land parcel registry...
Topic created successfully! Topic ID: 0.0.xxxxxx

Registering a land parcel...
Land parcel registered successfully! Sequence number: 1

Verifying the land parcel...
Land parcel verified successfully!

Minting biodiversity tokens...
Minted 5000 BIO tokens successfully!

Retrieving token information...
Token Information:
- Name: Biodiversity Credits
- Symbol: BIO
- Total Supply: 5000
- Decimals: 0

----- DEMO COMPLETED SUCCESSFULLY -----
```

## Key Benefits

- **Transparency**: All land registration and verification records are publicly accessible
- **Immutability**: Records cannot be altered once submitted
- **Tokenization**: Conservation efforts are represented as tradable digital assets
- **Efficiency**: Leverages Hedera's fast and cost-effective consensus
- **Environmental Impact**: Creates economic incentives for biodiversity protection

## Resources

- [Hedera Documentation](https://docs.hedera.com)
- [Hedera SDK for JavaScript](https://github.com/hashgraph/hedera-sdk-js)
- [Hedera Token Service](https://hedera.com/token-service)
- [Hedera Consensus Service](https://hedera.com/consensus-service)

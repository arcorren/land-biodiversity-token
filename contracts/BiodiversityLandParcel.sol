// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.0 <0.9.0;

import "./HederaResponseCodes.sol";

/**
 * @title BiodiversityLandParcel
 * @dev A smart contract for managing biodiversity attributes of tokenized land parcels on Hedera
 * 
 * This contract enables:
 * 1. Storage of biodiversity data for tokenized land parcels
 * 2. Verification of biodiversity claims by authorized entities
 * 3. Interaction with Hedera Token Service (HTS) for token association and transfers
 * 
 * Use cases:
 * - Environmental organizations can register land parcels and their biodiversity value
 * - Third parties can verify biodiversity claims, adding transparency
 * - Token holders can transfer biodiversity tokens representing land parcels
 * - Conservation efforts can be tracked and monetized through the tokenization of land
 */
contract BiodiversityLandParcel {
    // Define the interface for the Hedera Token Service
    IHederaTokenService private tokenService;
    
    // Address of the precompiled contract for HTS
    // This is a fixed address on Hedera that provides access to the Hedera Token Service
    address constant private PRECOMPILED_TOKEN_SERVICE = address(0x167);
    
    /**
     * @dev Struct to store comprehensive biodiversity metadata for each land parcel
     * Each token represents a unique land parcel with its own biodiversity attributes
     */
    struct BiodiversityData {
        uint256 biodiversityScore;     // A score representing biodiversity value (0-100)
        string ecosystemType;          // Type of ecosystem (e.g., "forest", "wetland", "grassland")
        uint256 verificationTimestamp; // When the data was last verified (Unix timestamp)
        address verifier;              // Address of the entity that verified the data
        bool isVerified;               // Whether the data has been verified by an authorized entity
    }
    
    // Maps token IDs to their biodiversity data
    // Each token (representing a land parcel) has its own biodiversity attributes
    mapping(address => BiodiversityData) public landParcels;
    
    // Events for tracking important contract actions
    
    /**
     * @dev Emitted when new biodiversity data is added for a land parcel
     * @param tokenId The token ID representing the land parcel
     * @param biodiversityScore The assigned biodiversity score (0-100)
     * @param ecosystemType The type of ecosystem on the land parcel
     */
    event BiodiversityDataAdded(address tokenId, uint256 biodiversityScore, string ecosystemType);
    
    /**
     * @dev Emitted when biodiversity data is verified by an authorized entity
     * @param tokenId The token ID representing the land parcel
     * @param verifier The address of the entity that performed the verification
     * @param timestamp When the verification occurred (Unix timestamp)
     */
    event BiodiversityDataVerified(address tokenId, address verifier, uint256 timestamp);
    
    /**
     * @dev Constructor initializes the contract with access to Hedera Token Service
     * This enables token-related operations through the HTS precompiled contract
     */
    constructor() {
        // Initialize the Hedera Token Service interface with the precompiled contract address
        tokenService = IHederaTokenService(PRECOMPILED_TOKEN_SERVICE);
    }
    
    /**
     * @dev Add biodiversity data for a tokenized land parcel
     * This function registers initial biodiversity information that can later be verified
     * 
     * @param tokenId The token ID representing the land parcel
     * @param biodiversityScore Score from 0-100 representing biodiversity value
     * @param ecosystemType Type of ecosystem on the land parcel (e.g., "forest", "wetland")
     */
    function addBiodiversityData(
        address tokenId,
        uint256 biodiversityScore,
        string memory ecosystemType
    ) external {
        // Validate the score is in a valid range
        require(biodiversityScore <= 100, "Biodiversity score must be 0-100");
        
        // Store the biodiversity data with initial verification status as false
        landParcels[tokenId] = BiodiversityData({
            biodiversityScore: biodiversityScore,
            ecosystemType: ecosystemType,
            verificationTimestamp: 0,
            verifier: address(0),
            isVerified: false
        });
        
        // Emit event for off-chain tracking and transparency
        emit BiodiversityDataAdded(tokenId, biodiversityScore, ecosystemType);
    }
    
    /**
     * @dev Verify biodiversity data for a tokenized land parcel
     * This function is called by authorized verifiers to confirm biodiversity claims
     * In a production environment, this should include access control for authorized verifiers
     * 
     * @param tokenId The token ID representing the land parcel
     */
    function verifyBiodiversityData(address tokenId) external {
        // Ensure biodiversity data exists for this token
        require(landParcels[tokenId].biodiversityScore > 0, "No biodiversity data exists for this token");
        
        // Update verification status with current timestamp and verifier address
        landParcels[tokenId].isVerified = true;
        landParcels[tokenId].verificationTimestamp = block.timestamp;
        landParcels[tokenId].verifier = msg.sender;
        
        // Emit verification event for transparency and audit trail
        emit BiodiversityDataVerified(tokenId, msg.sender, block.timestamp);
    }
    
    /**
     * @dev Retrieve the complete biodiversity data for a tokenized land parcel
     * 
     * @param tokenId The token ID representing the land parcel
     * @return BiodiversityData struct containing all biodiversity attributes and verification status
     */
    function getBiodiversityData(address tokenId) external view returns (BiodiversityData memory) {
        return landParcels[tokenId];
    }
    
    /**
     * @dev Associate a token with an account using Hedera Token Service
     * This is required before an account can receive a token on Hedera
     * 
     * @param accountId Account to associate with the token
     * @param tokenId Token to be associated
     * @return int Response code from the Hedera Token Service
     */
    function associateToken(address accountId, address tokenId) external returns (int) {
        // Call the HTS precompiled contract to perform the association
        int response = tokenService.associateToken(accountId, tokenId);
        
        // Check for successful response
        if (response != HederaResponseCodes.SUCCESS) {
            revert("Token association failed");
        }
        
        return response;
    }
    
    /**
     * @dev Transfer a token from one account to another using Hedera Token Service
     * This allows land parcels to be transferred between owners
     * 
     * @param tokenId The token representing the land parcel
     * @param fromAccountId The sender account
     * @param toAccountId The recipient account
     * @param amount The number of tokens to transfer (typically 1 for NFTs)
     * @return int Response code from the Hedera Token Service
     */
    function transferToken(address tokenId, address fromAccountId, address toAccountId, int64 amount) external returns (int) {
        // Call the HTS precompiled contract to perform the token transfer
        int response = tokenService.transferToken(tokenId, fromAccountId, toAccountId, amount);
        
        // Check for successful response
        if (response != HederaResponseCodes.SUCCESS) {
            revert("Token transfer failed");
        }
        
        return response;
    }
}

/**
 * @dev Interface for the Hedera Token Service precompiled contract
 * This interface defines the HTS functions we can call from our contract
 * See Hedera documentation for more details: https://docs.hedera.com/hedera/sdks-and-apis/sdks/smart-contracts/supported-hts-functionality
 */
interface IHederaTokenService {
    /**
     * @dev Associate a token with an account
     * @param account The account to be associated with the token
     * @param token The token to be associated
     * @return responseCode The HTS response code
     */
    function associateToken(address account, address token) external returns (int responseCode);
    
    /**
     * @dev Transfer tokens between accounts
     * @param token The token to transfer
     * @param from Sending account
     * @param to Receiving account
     * @param amount Amount of tokens to transfer
     * @return responseCode The HTS response code
     */
    function transferToken(address token, address from, address to, int64 amount) external returns (int responseCode);
}

// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.0 <0.9.0;

import "./HederaResponseCodes.sol";

/**
 * @title BiodiversityLandParcel
 * @dev A contract to verify and manage biodiversity attributes for tokenized land parcels
 */
contract BiodiversityLandParcel {
    // Define the interface for the Hedera Token Service
    IHederaTokenService private tokenService;
    
    // Address of the precompiled contract for HTS
    address constant private PRECOMPILED_TOKEN_SERVICE = address(0x167);
    
    // Struct to store biodiversity metadata for each land parcel
    struct BiodiversityData {
        uint256 biodiversityScore;     // A score representing biodiversity value (0-100)
        string ecosystemType;          // Type of ecosystem (e.g., "forest", "wetland", "grassland")
        uint256 verificationTimestamp; // When the data was last verified
        address verifier;              // Address of the entity that verified the data
        bool isVerified;               // Whether the data has been verified
    }
    
    // Maps token IDs to their biodiversity data
    mapping(address => BiodiversityData) public landParcels;
    
    // Events
    event BiodiversityDataAdded(address tokenId, uint256 biodiversityScore, string ecosystemType);
    event BiodiversityDataVerified(address tokenId, address verifier, uint256 timestamp);
    
    constructor() {
        // Initialize the token service 
        tokenService = IHederaTokenService(PRECOMPILED_TOKEN_SERVICE);
    }
    
    /**
     * @dev Add biodiversity data for a token
     * @param tokenId The token ID representing the land parcel
     * @param biodiversityScore Score from 0-100 representing biodiversity value
     * @param ecosystemType Type of ecosystem on the land parcel
     */
    function addBiodiversityData(
        address tokenId,
        uint256 biodiversityScore,
        string memory ecosystemType
    ) external {
        // Validate the score is in range
        require(biodiversityScore <= 100, "Biodiversity score must be 0-100");
        
        // Store the data
        landParcels[tokenId] = BiodiversityData({
            biodiversityScore: biodiversityScore,
            ecosystemType: ecosystemType,
            verificationTimestamp: 0,
            verifier: address(0),
            isVerified: false
        });
        
        emit BiodiversityDataAdded(tokenId, biodiversityScore, ecosystemType);
    }
    
    /**
     * @dev Verify biodiversity data for a token (restricted to authorized verifiers)
     * @param tokenId The token ID representing the land parcel
     */
    function verifyBiodiversityData(address tokenId) external {
        // Ensure data exists
        require(landParcels[tokenId].biodiversityScore > 0, "No biodiversity data exists for this token");
        
        // Update verification status
        landParcels[tokenId].isVerified = true;
        landParcels[tokenId].verificationTimestamp = block.timestamp;
        landParcels[tokenId].verifier = msg.sender;
        
        emit BiodiversityDataVerified(tokenId, msg.sender, block.timestamp);
    }
    
    /**
     * @dev Get biodiversity data for a token
     * @param tokenId The token ID representing the land parcel
     * @return BiodiversityData struct containing the token's biodiversity information
     */
    function getBiodiversityData(address tokenId) external view returns (BiodiversityData memory) {
        return landParcels[tokenId];
    }
    
    /**
     * @dev Associate a token with an account (wrapper for HTS function)
     * @param accountId Account to associate with the token
     * @param tokenId Token to be associated
     */
    function associateToken(address accountId, address tokenId) external returns (int) {
        int response = tokenService.associateToken(accountId, tokenId);
        
        if (response != HederaResponseCodes.SUCCESS) {
            revert("Token association failed");
        }
        
        return response;
    }
    
    /**
     * @dev Transfer tokens from one account to another (wrapper for HTS function)
     * @param tokenId Token to transfer
     * @param fromId Account to transfer from
     * @param toId Account to transfer to
     * @param amount Amount of tokens to transfer
     */
    function transferToken(
        address tokenId,
        address fromId,
        address toId,
        int64 amount
    ) external returns (int) {
        int response = tokenService.transferToken(tokenId, fromId, toId, amount);
        
        if (response != HederaResponseCodes.SUCCESS) {
            revert("Token transfer failed");
        }
        
        return response;
    }
}

// Interface for interacting with the Hedera Token Service precompile
interface IHederaTokenService {
    function associateToken(address account, address token) external returns (int responseCode);
    function transferToken(address token, address from, address to, int64 amount) external returns (int responseCode);
}

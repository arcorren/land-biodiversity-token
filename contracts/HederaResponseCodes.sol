// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.0 <0.9.0;

/**
 * @dev Response codes for Hedera network operations
 */
library HederaResponseCodes {
    // Success response code
    int internal constant SUCCESS = 22;
    
    // Other common response codes
    int internal constant INVALID_TRANSACTION = 7;
    int internal constant TOKEN_NOT_ASSOCIATED_TO_ACCOUNT = 173;
    int internal constant INSUFFICIENT_ACCOUNT_BALANCE = 15;
    int internal constant INSUFFICIENT_TOKEN_BALANCE = 174;
}

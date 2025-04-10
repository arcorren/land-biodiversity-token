// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.0 <0.9.0;

import "./HederaResponseCodes.sol";

/**
 * @dev Interface for the Hedera Token Service precompiled contract
 */
abstract contract HederaTokenService {
    /**
     * @dev Associates a Hedera token to an account
     * @param account The account to be associated with the token
     * @param token The token to be associated with the account
     * @return responseCode The response code for the status of the request
     */
    function associateToken(address account, address token) internal virtual returns (int responseCode) {
        (bool success, bytes memory result) = precompileAddress().call(
            abi.encodeWithSelector(IHederaTokenService.associateToken.selector, account, token)
        );
        
        if (success) {
            return abi.decode(result, (int));
        } else {
            return HederaResponseCodes.INVALID_TRANSACTION;
        }
    }

    /**
     * @dev Transfers tokens from one account to another account
     * @param token The token to transfer
     * @param from The account to transfer from
     * @param to The account to transfer to
     * @param amount The amount to transfer
     * @return responseCode The response code for the status of the request
     */
    function transferToken(address token, address from, address to, int64 amount) internal virtual returns (int responseCode) {
        (bool success, bytes memory result) = precompileAddress().call(
            abi.encodeWithSelector(IHederaTokenService.transferToken.selector, token, from, to, amount)
        );
        
        if (success) {
            return abi.decode(result, (int));
        } else {
            return HederaResponseCodes.INVALID_TRANSACTION;
        }
    }

    /**
     * @dev Returns the address of the Hedera Token Service precompile
     */
    function precompileAddress() private pure returns (address) {
        return address(0x167);  // The precompiled contract address for the Hedera Token Service
    }
}

/**
 * @dev Interface for the Hedera Token Service precompile functions
 */
interface IHederaTokenService {
    function associateToken(address account, address token) external returns (int responseCode);
    function transferToken(address token, address from, address to, int64 amount) external returns (int responseCode);
}

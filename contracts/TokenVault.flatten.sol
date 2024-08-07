// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20 ^0.8.25;

// node_modules/@openzeppelin/contracts/interfaces/draft-IERC6093.sol

// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/draft-IERC6093.sol)

/**
 * @dev Standard ERC20 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC20 tokens.
 */
interface IERC20Errors {
    /**
     * @dev Indicates an error related to the current `balance` of a `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param balance Current balance for the interacting account.
     * @param needed Minimum amount required to perform a transfer.
     */
    error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC20InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC20InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `spender`’s `allowance`. Used in transfers.
     * @param spender Address that may be allowed to operate on tokens without being their owner.
     * @param allowance Amount of tokens a `spender` is allowed to operate with.
     * @param needed Minimum amount required to perform a transfer.
     */
    error ERC20InsufficientAllowance(address spender, uint256 allowance, uint256 needed);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC20InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `spender` to be approved. Used in approvals.
     * @param spender Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC20InvalidSpender(address spender);
}

/**
 * @dev Standard ERC721 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC721 tokens.
 */
interface IERC721Errors {
    /**
     * @dev Indicates that an address can't be an owner. For example, `address(0)` is a forbidden owner in EIP-20.
     * Used in balance queries.
     * @param owner Address of the current owner of a token.
     */
    error ERC721InvalidOwner(address owner);

    /**
     * @dev Indicates a `tokenId` whose `owner` is the zero address.
     * @param tokenId Identifier number of a token.
     */
    error ERC721NonexistentToken(uint256 tokenId);

    /**
     * @dev Indicates an error related to the ownership over a particular token. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param tokenId Identifier number of a token.
     * @param owner Address of the current owner of a token.
     */
    error ERC721IncorrectOwner(address sender, uint256 tokenId, address owner);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC721InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC721InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `operator`’s approval. Used in transfers.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     * @param tokenId Identifier number of a token.
     */
    error ERC721InsufficientApproval(address operator, uint256 tokenId);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC721InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `operator` to be approved. Used in approvals.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC721InvalidOperator(address operator);
}

/**
 * @dev Standard ERC1155 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC1155 tokens.
 */
interface IERC1155Errors {
    /**
     * @dev Indicates an error related to the current `balance` of a `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param balance Current balance for the interacting account.
     * @param needed Minimum amount required to perform a transfer.
     * @param tokenId Identifier number of a token.
     */
    error ERC1155InsufficientBalance(address sender, uint256 balance, uint256 needed, uint256 tokenId);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC1155InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC1155InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `operator`’s approval. Used in transfers.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     * @param owner Address of the current owner of a token.
     */
    error ERC1155MissingApprovalForAll(address operator, address owner);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC1155InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `operator` to be approved. Used in approvals.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC1155InvalidOperator(address operator);

    /**
     * @dev Indicates an array length mismatch between ids and values in a safeBatchTransferFrom operation.
     * Used in batch transfers.
     * @param idsLength Length of the array of token identifiers
     * @param valuesLength Length of the array of token amounts
     */
    error ERC1155InvalidArrayLength(uint256 idsLength, uint256 valuesLength);
}

// node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

// node_modules/@openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/extensions/IERC20Permit.sol)

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 *
 * ==== Security Considerations
 *
 * There are two important considerations concerning the use of `permit`. The first is that a valid permit signature
 * expresses an allowance, and it should not be assumed to convey additional meaning. In particular, it should not be
 * considered as an intention to spend the allowance in any specific way. The second is that because permits have
 * built-in replay protection and can be submitted by anyone, they can be frontrun. A protocol that uses permits should
 * take this into consideration and allow a `permit` call to fail. Combining these two aspects, a pattern that may be
 * generally recommended is:
 *
 * ```solidity
 * function doThingWithPermit(..., uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public {
 *     try token.permit(msg.sender, address(this), value, deadline, v, r, s) {} catch {}
 *     doThing(..., value);
 * }
 *
 * function doThing(..., uint256 value) public {
 *     token.safeTransferFrom(msg.sender, address(this), value);
 *     ...
 * }
 * ```
 *
 * Observe that: 1) `msg.sender` is used as the owner, leaving no ambiguity as to the signer intent, and 2) the use of
 * `try/catch` allows the permit to fail and makes the code tolerant to frontrunning. (See also
 * {SafeERC20-safeTransferFrom}).
 *
 * Additionally, note that smart contract wallets (such as Argent or Safe) are not able to produce permit signatures, so
 * contracts should have entry points that don't rely on permit.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     *
     * CAUTION: See Security Considerations above.
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// node_modules/@openzeppelin/contracts/utils/Address.sol

// OpenZeppelin Contracts (last updated v5.0.0) (utils/Address.sol)

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev The ETH balance of the account is not enough to perform the operation.
     */
    error AddressInsufficientBalance(address account);

    /**
     * @dev There's no code at `target` (it is not a contract).
     */
    error AddressEmptyCode(address target);

    /**
     * @dev A call to an address target failed. The target may have reverted.
     */
    error FailedInnerCall();

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://consensys.net/diligence/blog/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.8.20/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        if (address(this).balance < amount) {
            revert AddressInsufficientBalance(address(this));
        }

        (bool success, ) = recipient.call{value: amount}("");
        if (!success) {
            revert FailedInnerCall();
        }
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason or custom error, it is bubbled
     * up by this function (like regular Solidity function calls). However, if
     * the call reverted with no returned reason, this function reverts with a
     * {FailedInnerCall} error.
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        if (address(this).balance < value) {
            revert AddressInsufficientBalance(address(this));
        }
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and reverts if the target
     * was not a contract or bubbling up the revert reason (falling back to {FailedInnerCall}) in case of an
     * unsuccessful call.
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata
    ) internal view returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {
            // only check if target is a contract if the call was successful and the return data is empty
            // otherwise we already know that it was a contract
            if (returndata.length == 0 && target.code.length == 0) {
                revert AddressEmptyCode(target);
            }
            return returndata;
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and reverts if it wasn't, either by bubbling the
     * revert reason or with a default {FailedInnerCall} error.
     */
    function verifyCallResult(bool success, bytes memory returndata) internal pure returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {
            return returndata;
        }
    }

    /**
     * @dev Reverts with returndata if present. Otherwise reverts with {FailedInnerCall}.
     */
    function _revert(bytes memory returndata) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert FailedInnerCall();
        }
    }
}

// node_modules/@openzeppelin/contracts/utils/Context.sol

// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}

// node_modules/@openzeppelin/contracts/utils/ReentrancyGuard.sol

// OpenZeppelin Contracts (last updated v5.0.0) (utils/ReentrancyGuard.sol)

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;

    uint256 private _status;

    /**
     * @dev Unauthorized reentrant call.
     */
    error ReentrancyGuardReentrantCall();

    constructor() {
        _status = NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be NOT_ENTERED
        if (_status == ENTERED) {
            revert ReentrancyGuardReentrantCall();
        }

        // Any calls to nonReentrant after this point will fail
        _status = ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == ENTERED;
    }
}

// node_modules/@openzeppelin/contracts/utils/introspection/IERC165.sol

// OpenZeppelin Contracts (last updated v5.0.0) (utils/introspection/IERC165.sol)

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// node_modules/@openzeppelin/contracts/utils/math/Math.sol

// OpenZeppelin Contracts (last updated v5.0.0) (utils/math/Math.sol)

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Muldiv operation overflow.
     */
    error MathOverflowedMulDiv();

    enum Rounding {
        Floor, // Toward negative infinity
        Ceil, // Toward positive infinity
        Trunc, // Toward zero
        Expand // Away from zero
    }

    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds towards infinity instead
     * of rounding towards zero.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        if (b == 0) {
            // Guarantee the same behavior as in a regular Solidity division.
            return a / b;
        }

        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or
     * denominator == 0.
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv) with further edits by
     * Uniswap Labs also under MIT license.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0 = x * y; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                // Solidity will revert if denominator == 0, unlike the div opcode on its own.
                // The surrounding unchecked block does not change this fact.
                // See https://docs.soliditylang.org/en/latest/control-structures.html#checked-or-unchecked-arithmetic.
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            if (denominator <= prod1) {
                revert MathOverflowedMulDiv();
            }

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator.
            // Always >= 1. See https://cs.stackexchange.com/q/138556/92363.

            uint256 twos = denominator & (0 - denominator);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also
            // works in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /**
     * @notice Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator, Rounding rounding) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (unsignedRoundsUp(rounding) && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded
     * towards zero.
     *
     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
        //
        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
        // `msb(a) <= a < 2*msb(a)`. This value can be written `msb(a)=2**k` with `k=log2(a)`.
        //
        // This can be rewritten `2**log2(a) <= a < 2**(log2(a) + 1)`
        // → `sqrt(2**k) <= sqrt(a) < sqrt(2**(k+1))`
        // → `2**(k/2) <= sqrt(a) < 2**((k+1)/2) <= 2**(k/2 + 1)`
        //
        // Consequently, `2**(log2(a) / 2)` is a good first approximation of `sqrt(a)` with at least 1 correct bit.
        uint256 result = 1 << (log2(a) >> 1);

        // At this point `result` is an estimation with one bit of precision. We know the true value is a uint128,
        // since it is the square root of a uint256. Newton's method converges quadratically (precision doubles at
        // every iteration). We thus need at most 7 iteration to turn our partial result with one bit of precision
        // into the expected uint128 result.
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

    /**
     * @notice Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + (unsignedRoundsUp(rounding) && result * result < a ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 2 of a positive value rounded towards zero.
     * Returns 0 if given 0.
     */
    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 128;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 64;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 32;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 16;
            }
            if (value >> 8 > 0) {
                value >>= 8;
                result += 8;
            }
            if (value >> 4 > 0) {
                value >>= 4;
                result += 4;
            }
            if (value >> 2 > 0) {
                value >>= 2;
                result += 2;
            }
            if (value >> 1 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 2, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log2(value);
            return result + (unsignedRoundsUp(rounding) && 1 << result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 10 of a positive value rounded towards zero.
     * Returns 0 if given 0.
     */
    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10 ** 64) {
                value /= 10 ** 64;
                result += 64;
            }
            if (value >= 10 ** 32) {
                value /= 10 ** 32;
                result += 32;
            }
            if (value >= 10 ** 16) {
                value /= 10 ** 16;
                result += 16;
            }
            if (value >= 10 ** 8) {
                value /= 10 ** 8;
                result += 8;
            }
            if (value >= 10 ** 4) {
                value /= 10 ** 4;
                result += 4;
            }
            if (value >= 10 ** 2) {
                value /= 10 ** 2;
                result += 2;
            }
            if (value >= 10 ** 1) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return result + (unsignedRoundsUp(rounding) && 10 ** result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 256 of a positive value rounded towards zero.
     * Returns 0 if given 0.
     *
     * Adding one to the result gives the number of pairs of hex symbols needed to represent `value` as a hex string.
     */
    function log256(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 16;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 8;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 4;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 2;
            }
            if (value >> 8 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 256, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (unsignedRoundsUp(rounding) && 1 << (result << 3) < value ? 1 : 0);
        }
    }

    /**
     * @dev Returns whether a provided rounding mode is considered rounding up for unsigned integers.
     */
    function unsignedRoundsUp(Rounding rounding) internal pure returns (bool) {
        return uint8(rounding) % 2 == 1;
    }
}

// src/interfaces/IExecutor.sol

interface IWithdrawRequestLogic {
    /* ====== STRUCT ====== */

    struct WithdrawRequestInfo {
        address owner;
        address receiver;
        address token;
        uint32 dstEid;
        uint32 creationTime;
        uint256 shares;
    }

    /* ====== EVENTS ====== */

    event WithdrawRequestCancelled(bytes32 indexed intentionId);

    event WithdrawalRequested(
        address token,
        uint256 shares,
        address owner,
        bytes32 indexed intentionId,
        uint32 dstEid
    );

    event WithdrawRequestFulfilled(
        address token,
        uint256 assets,
        address owner,
        address receiver,
        bytes32 indexed intentionId
    );

    /* ====== FUNCTIONS ====== */

    function getWithdrawRequest(
        bytes32 intentionId
    ) external view returns (WithdrawRequestInfo memory);

    function getSupportedDstEidToWithdraw(
        uint32 _dstEid
    ) external view returns (bool);
}

interface IBridgeLogic {
    /* ====== EVENTS ====== */

    event Bridged(
        uint32 dstEid,
        address asset,
        uint256 amount,
        bytes32 indexed intentionId
    );

    event BridgeFinished(uint amount, bytes32 intentionId);

    /* ====== FUNCTIONS ====== */

    function finishBridge(uint256 amountBridged, bytes32 intentionId) external;
}

interface IStrategyManager {
    /* ====== STRUCT ====== */

    struct Strategy {
        address strategyAddress;
        bool isActive;
    }

    /* ====== EVENTS ====== */

    event StrategyAdded(bytes32 strategyId);
    event StrategyRemoved(bytes32 strategyId);
    event StrategyToggled(bytes32 strategyId, bool isActive);

    /* ====== FUNCTIONS ====== */

    function getStrategyById(
        bytes32 _strategyId
    ) external view returns (address, bool);

    function getStrategyByAddress(
        address _strategy
    ) external view returns (bytes32, bool);

    /// @notice Adds a new strategy to the list of valid strategies in the contract.
    /// @dev This function requires that the caller is an administrator or has appropriate access rights.
    function addStrategy(address strategy) external;

    /// @notice Delete a strategy from the list of valid strategies in the contract.
    /// @dev Requires that the caller is an administrator or has appropriate access rights.
    function removeStrategy(bytes32 _strategyId) external;

    ///@notice Deactivate a strategy in the contract. Deactivated strategies will not be able to perform any actions.
    function disableStrategy(bytes32 _strategyId) external;

    ///@notice Turn on a strategy
    function enableStrategy(bytes32 _strategyId) external;
}

interface IRoles {
    function setCommander(address _commander) external;
}

interface IExecutor is IWithdrawRequestLogic, IBridgeLogic, IStrategyManager {
    ///@dev Used to Deposit/Withdraw from strategy, Bridge assets between MaatVaultV1, Fulfill Requests
    enum ActionType {
        DEPOSIT,
        WITHDRAW,
        BRIDGE,
        FULFILL_WITHDRAW_REQUEST
    }

    ///@notice Not all fields are required for all actions
    struct ActionInput {
        uint32 dstEid;
        bytes32 strategyId;
        uint256 amount;
        bytes32 intentionId;
    }

    function execute(
        ActionType[] calldata actionType,
        ActionInput[] calldata inputs
    ) external returns (bool);

    event DepositedInStrategy(
        bytes32 strategyId,
        address asset,
        uint256 amount,
        bytes32 indexed intentionId
    );

    event WithdrewFromStrategy(
        bytes32 strategyId,
        address asset,
        uint256 amount,
        bytes32 indexed intentionId
    );

    event RebalanceRequested(bytes32 intentionId);

    enum RequestType {
        WITHDRAW,
        REBALANCE
    }

    struct RebalanceRequestInfo {
        uint32 lastRebalanceTime;
        bytes32 intentionId;
    }

    function requestRebalance() external returns (bytes32 intentionId);

    function requestWithdraw(
        uint shares,
        uint32 dstEid,
        address receiver,
        address owner
    ) external returns (bytes32);
}

// src/interfaces/IMaatAddressProvider.sol

interface IMaatAddressProvider {
    /**
     * @notice Add a strategy to a vault
     * @param strategy The address of the strategy to add
     * @dev This function can only be called by a vault
     */

    function addStrategy(address strategy) external;

    /**
     * @notice Remove a strategy from a vault
     * @param strategy The address of the strategy to remove
     * @dev This function can only be called by a vault
     */

    function removeStrategy(address strategy) external;

    /**
     * @notice Add a vault
     * @param vault The address of the vault to add
     * @dev This function can only be called by the admin
     */

    function addVault(address vault) external;

    /**
     * @notice Remove a vault
     * @param vault The address of the vault to remove
     * @dev This function can only be called by the admin
     */

    function removeVault(address vault) external;

    function changeOracle(address newOracle) external;

    function changeIncentiveController(address newIncentiveController) external;

    function changeStargateAdapter(address newStargateAdapter) external;

    function changeAdmin(address newAdmin) external;

    function isVault(address vault) external view returns (bool isVault);

    function isStrategy(
        address strategy
    ) external view returns (bool isStrategy);

    function getVaults() external view returns (address[] memory vaults);

    function getStrategies()
        external
        view
        returns (address[] memory strategies);

    function oracle() external view returns (address oracle);

    function stargateAdapter() external view returns (address stargateAdapter);

    function incentiveController()
        external
        view
        returns (address incentiveController);

    function admin() external view returns (address admin);
}

// src/interfaces/IMaatOracleGlobalPPS.sol

interface IMaatOracleGlobalPPS {
    struct PricePerShare {
        uint112 pricePerShare;
        uint112 prevPricePerShare;
        uint32 lastUpdateTime;
        uint32 prevUpdateTime;
    }

    event UpdatePPS(
        address token,
        uint256 pricePerShare,
        uint256 prevPricePerShare,
        uint32 prevUpdateTime
    );

    ///@notice This function returns the global PricePerShare value.
    function getGlobalPPS(address token) external view returns (uint256);
    function getPrevGlobalPPS(address token) external view returns (uint);

    ///@notice This function updates the global PricePerShare value.
    ///@dev This function requires that the caller is an administrator or has appropriate access rights.
    function updateGlobalPPS(address token, uint112 _pricePerShare) external;

    function decimals() external view returns (uint);

    function synchronize() external;
}

// src/interfaces/IStargateAdapter.sol

interface IStargateAdapter {
    event SendTokensToGateway(
        uint32 dstEid,
        uint32 poolId,
        address token,
        uint amountIn,
        bytes32 intentionId
    );

    event SendTokensToReceiver(
        uint32 dstEid,
        uint32 poolId,
        address token,
        uint amountIn,
        address receiver
    );

    event ReceivedOnDestination(
        address from,
        bytes32 guid,
        uint256 receivedAmountLD,
        address _executor,
        bytes32 intentionId
    );

    event DepositedOnDestination(bool success);

    event SetDstAdapter(uint32 dstEid, address dstAdapter);

    event SetSrcStargatePool(uint32 poolId, address srcStargatePool);

    event SetVault(address token, address srcVault);

    event SetPoolId(uint32 poolId, address token);

    /// @notice sends token to StargateAdapter on destination chain
    function sendTokens(
        uint32 dstEid, // endpoint ID on destination chain
        address srcToken, // token address on source chain
        uint amountLD, // amount in in Local Decimals
        bytes32 intentionId // encoded data for the Gateway on destination chain
    ) external;

    function sendTokensToReceiver(
        uint32 dstEid, // endpoint ID on destination chain
        address srcToken, // token address on source chain
        uint amountLD, // amount in in Local Decimals
        address receiver // receiver address on destination chain
    ) external;
}

// node_modules/@openzeppelin/contracts/access/Ownable.sol

// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// node_modules/@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/extensions/IERC20Metadata.sol)

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// node_modules/@openzeppelin/contracts/utils/introspection/ERC165Checker.sol

// OpenZeppelin Contracts (last updated v5.0.0) (utils/introspection/ERC165Checker.sol)

/**
 * @dev Library used to query support of an interface declared via {IERC165}.
 *
 * Note that these functions return the actual result of the query: they do not
 * `revert` if an interface is not supported. It is up to the caller to decide
 * what to do in these cases.
 */
library ERC165Checker {
    // As per the EIP-165 spec, no interface should ever match 0xffffffff
    bytes4 private constant INTERFACE_ID_INVALID = 0xffffffff;

    /**
     * @dev Returns true if `account` supports the {IERC165} interface.
     */
    function supportsERC165(address account) internal view returns (bool) {
        // Any contract that implements ERC165 must explicitly indicate support of
        // InterfaceId_ERC165 and explicitly indicate non-support of InterfaceId_Invalid
        return
            supportsERC165InterfaceUnchecked(account, type(IERC165).interfaceId) &&
            !supportsERC165InterfaceUnchecked(account, INTERFACE_ID_INVALID);
    }

    /**
     * @dev Returns true if `account` supports the interface defined by
     * `interfaceId`. Support for {IERC165} itself is queried automatically.
     *
     * See {IERC165-supportsInterface}.
     */
    function supportsInterface(address account, bytes4 interfaceId) internal view returns (bool) {
        // query support of both ERC165 as per the spec and support of _interfaceId
        return supportsERC165(account) && supportsERC165InterfaceUnchecked(account, interfaceId);
    }

    /**
     * @dev Returns a boolean array where each value corresponds to the
     * interfaces passed in and whether they're supported or not. This allows
     * you to batch check interfaces for a contract where your expectation
     * is that some interfaces may not be supported.
     *
     * See {IERC165-supportsInterface}.
     */
    function getSupportedInterfaces(
        address account,
        bytes4[] memory interfaceIds
    ) internal view returns (bool[] memory) {
        // an array of booleans corresponding to interfaceIds and whether they're supported or not
        bool[] memory interfaceIdsSupported = new bool[](interfaceIds.length);

        // query support of ERC165 itself
        if (supportsERC165(account)) {
            // query support of each interface in interfaceIds
            for (uint256 i = 0; i < interfaceIds.length; i++) {
                interfaceIdsSupported[i] = supportsERC165InterfaceUnchecked(account, interfaceIds[i]);
            }
        }

        return interfaceIdsSupported;
    }

    /**
     * @dev Returns true if `account` supports all the interfaces defined in
     * `interfaceIds`. Support for {IERC165} itself is queried automatically.
     *
     * Batch-querying can lead to gas savings by skipping repeated checks for
     * {IERC165} support.
     *
     * See {IERC165-supportsInterface}.
     */
    function supportsAllInterfaces(address account, bytes4[] memory interfaceIds) internal view returns (bool) {
        // query support of ERC165 itself
        if (!supportsERC165(account)) {
            return false;
        }

        // query support of each interface in interfaceIds
        for (uint256 i = 0; i < interfaceIds.length; i++) {
            if (!supportsERC165InterfaceUnchecked(account, interfaceIds[i])) {
                return false;
            }
        }

        // all interfaces supported
        return true;
    }

    /**
     * @notice Query if a contract implements an interface, does not check ERC165 support
     * @param account The address of the contract to query for support of an interface
     * @param interfaceId The interface identifier, as specified in ERC-165
     * @return true if the contract at account indicates support of the interface with
     * identifier interfaceId, false otherwise
     * @dev Assumes that account contains a contract that supports ERC165, otherwise
     * the behavior of this method is undefined. This precondition can be checked
     * with {supportsERC165}.
     *
     * Some precompiled contracts will falsely indicate support for a given interface, so caution
     * should be exercised when using this function.
     *
     * Interface identification is specified in ERC-165.
     */
    function supportsERC165InterfaceUnchecked(address account, bytes4 interfaceId) internal view returns (bool) {
        // prepare call
        bytes memory encodedParams = abi.encodeCall(IERC165.supportsInterface, (interfaceId));

        // perform static call
        bool success;
        uint256 returnSize;
        uint256 returnValue;
        assembly {
            success := staticcall(30000, account, add(encodedParams, 0x20), mload(encodedParams), 0x00, 0x20)
            returnSize := returndatasize()
            returnValue := mload(0x00)
        }

        return success && returnSize >= 0x20 && returnValue > 0;
    }
}

// src/lib/ERC165Registry.sol

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * by {{ numerai }}
 * from https://github.com/numerai/tournament-contracts
 *
 * Contracts may inherit from this and call {_registerInterface} to declare
 * their support of an interface.
 */

contract ERC165Registry is IERC165 {
    /*
     * bytes4(keccak256('supportsInterface(bytes4)')) == 0x01ffc9a7
     */
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    /**
     * @dev Mapping of interface ids to whether or not it's supported.
     */
    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () {
        // Derived contracts need only register support for their own interfaces,
        // we register support for ERC165 itself here
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     *
     * Time complexity O(1), guaranteed to always use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

    /**
     * @dev Registers the contract as an implementer of the interface defined by
     * `interfaceId`. Support of the actual ERC165 interface is automatic and
     * registering its interface id is not required.
     *
     * See {IERC165-supportsInterface}.
     *
     * Requirements:
     *
     * - `interfaceId` cannot be the ERC165 invalid interface (`0xffffffff`).
     */
    function _registerInterface(bytes4 interfaceId) internal {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}

// node_modules/@openzeppelin/contracts/interfaces/IERC4626.sol

// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/IERC4626.sol)

/**
 * @dev Interface of the ERC4626 "Tokenized Vault Standard", as defined in
 * https://eips.ethereum.org/EIPS/eip-4626[ERC-4626].
 */
interface IERC4626 is IERC20, IERC20Metadata {
    event Deposit(address indexed sender, address indexed owner, uint256 assets, uint256 shares);

    event Withdraw(
        address indexed sender,
        address indexed receiver,
        address indexed owner,
        uint256 assets,
        uint256 shares
    );

    /**
     * @dev Returns the address of the underlying token used for the Vault for accounting, depositing, and withdrawing.
     *
     * - MUST be an ERC-20 token contract.
     * - MUST NOT revert.
     */
    function asset() external view returns (address assetTokenAddress);

    /**
     * @dev Returns the total amount of the underlying asset that is “managed” by Vault.
     *
     * - SHOULD include any compounding that occurs from yield.
     * - MUST be inclusive of any fees that are charged against assets in the Vault.
     * - MUST NOT revert.
     */
    function totalAssets() external view returns (uint256 totalManagedAssets);

    /**
     * @dev Returns the amount of shares that the Vault would exchange for the amount of assets provided, in an ideal
     * scenario where all the conditions are met.
     *
     * - MUST NOT be inclusive of any fees that are charged against assets in the Vault.
     * - MUST NOT show any variations depending on the caller.
     * - MUST NOT reflect slippage or other on-chain conditions, when performing the actual exchange.
     * - MUST NOT revert.
     *
     * NOTE: This calculation MAY NOT reflect the “per-user” price-per-share, and instead should reflect the
     * “average-user’s” price-per-share, meaning what the average user should expect to see when exchanging to and
     * from.
     */
    function convertToShares(uint256 assets) external view returns (uint256 shares);

    /**
     * @dev Returns the amount of assets that the Vault would exchange for the amount of shares provided, in an ideal
     * scenario where all the conditions are met.
     *
     * - MUST NOT be inclusive of any fees that are charged against assets in the Vault.
     * - MUST NOT show any variations depending on the caller.
     * - MUST NOT reflect slippage or other on-chain conditions, when performing the actual exchange.
     * - MUST NOT revert.
     *
     * NOTE: This calculation MAY NOT reflect the “per-user” price-per-share, and instead should reflect the
     * “average-user’s” price-per-share, meaning what the average user should expect to see when exchanging to and
     * from.
     */
    function convertToAssets(uint256 shares) external view returns (uint256 assets);

    /**
     * @dev Returns the maximum amount of the underlying asset that can be deposited into the Vault for the receiver,
     * through a deposit call.
     *
     * - MUST return a limited value if receiver is subject to some deposit limit.
     * - MUST return 2 ** 256 - 1 if there is no limit on the maximum amount of assets that may be deposited.
     * - MUST NOT revert.
     */
    function maxDeposit(address receiver) external view returns (uint256 maxAssets);

    /**
     * @dev Allows an on-chain or off-chain user to simulate the effects of their deposit at the current block, given
     * current on-chain conditions.
     *
     * - MUST return as close to and no more than the exact amount of Vault shares that would be minted in a deposit
     *   call in the same transaction. I.e. deposit should return the same or more shares as previewDeposit if called
     *   in the same transaction.
     * - MUST NOT account for deposit limits like those returned from maxDeposit and should always act as though the
     *   deposit would be accepted, regardless if the user has enough tokens approved, etc.
     * - MUST be inclusive of deposit fees. Integrators should be aware of the existence of deposit fees.
     * - MUST NOT revert.
     *
     * NOTE: any unfavorable discrepancy between convertToShares and previewDeposit SHOULD be considered slippage in
     * share price or some other type of condition, meaning the depositor will lose assets by depositing.
     */
    function previewDeposit(uint256 assets) external view returns (uint256 shares);

    /**
     * @dev Mints shares Vault shares to receiver by depositing exactly amount of underlying tokens.
     *
     * - MUST emit the Deposit event.
     * - MAY support an additional flow in which the underlying tokens are owned by the Vault contract before the
     *   deposit execution, and are accounted for during deposit.
     * - MUST revert if all of assets cannot be deposited (due to deposit limit being reached, slippage, the user not
     *   approving enough underlying tokens to the Vault contract, etc).
     *
     * NOTE: most implementations will require pre-approval of the Vault with the Vault’s underlying asset token.
     */
    function deposit(uint256 assets, address receiver) external returns (uint256 shares);

    /**
     * @dev Returns the maximum amount of the Vault shares that can be minted for the receiver, through a mint call.
     * - MUST return a limited value if receiver is subject to some mint limit.
     * - MUST return 2 ** 256 - 1 if there is no limit on the maximum amount of shares that may be minted.
     * - MUST NOT revert.
     */
    function maxMint(address receiver) external view returns (uint256 maxShares);

    /**
     * @dev Allows an on-chain or off-chain user to simulate the effects of their mint at the current block, given
     * current on-chain conditions.
     *
     * - MUST return as close to and no fewer than the exact amount of assets that would be deposited in a mint call
     *   in the same transaction. I.e. mint should return the same or fewer assets as previewMint if called in the
     *   same transaction.
     * - MUST NOT account for mint limits like those returned from maxMint and should always act as though the mint
     *   would be accepted, regardless if the user has enough tokens approved, etc.
     * - MUST be inclusive of deposit fees. Integrators should be aware of the existence of deposit fees.
     * - MUST NOT revert.
     *
     * NOTE: any unfavorable discrepancy between convertToAssets and previewMint SHOULD be considered slippage in
     * share price or some other type of condition, meaning the depositor will lose assets by minting.
     */
    function previewMint(uint256 shares) external view returns (uint256 assets);

    /**
     * @dev Mints exactly shares Vault shares to receiver by depositing amount of underlying tokens.
     *
     * - MUST emit the Deposit event.
     * - MAY support an additional flow in which the underlying tokens are owned by the Vault contract before the mint
     *   execution, and are accounted for during mint.
     * - MUST revert if all of shares cannot be minted (due to deposit limit being reached, slippage, the user not
     *   approving enough underlying tokens to the Vault contract, etc).
     *
     * NOTE: most implementations will require pre-approval of the Vault with the Vault’s underlying asset token.
     */
    function mint(uint256 shares, address receiver) external returns (uint256 assets);

    /**
     * @dev Returns the maximum amount of the underlying asset that can be withdrawn from the owner balance in the
     * Vault, through a withdraw call.
     *
     * - MUST return a limited value if owner is subject to some withdrawal limit or timelock.
     * - MUST NOT revert.
     */
    function maxWithdraw(address owner) external view returns (uint256 maxAssets);

    /**
     * @dev Allows an on-chain or off-chain user to simulate the effects of their withdrawal at the current block,
     * given current on-chain conditions.
     *
     * - MUST return as close to and no fewer than the exact amount of Vault shares that would be burned in a withdraw
     *   call in the same transaction. I.e. withdraw should return the same or fewer shares as previewWithdraw if
     *   called
     *   in the same transaction.
     * - MUST NOT account for withdrawal limits like those returned from maxWithdraw and should always act as though
     *   the withdrawal would be accepted, regardless if the user has enough shares, etc.
     * - MUST be inclusive of withdrawal fees. Integrators should be aware of the existence of withdrawal fees.
     * - MUST NOT revert.
     *
     * NOTE: any unfavorable discrepancy between convertToShares and previewWithdraw SHOULD be considered slippage in
     * share price or some other type of condition, meaning the depositor will lose assets by depositing.
     */
    function previewWithdraw(uint256 assets) external view returns (uint256 shares);

    /**
     * @dev Burns shares from owner and sends exactly assets of underlying tokens to receiver.
     *
     * - MUST emit the Withdraw event.
     * - MAY support an additional flow in which the underlying tokens are owned by the Vault contract before the
     *   withdraw execution, and are accounted for during withdraw.
     * - MUST revert if all of assets cannot be withdrawn (due to withdrawal limit being reached, slippage, the owner
     *   not having enough shares, etc).
     *
     * Note that some implementations will require pre-requesting to the Vault before a withdrawal may be performed.
     * Those methods should be performed separately.
     */
    function withdraw(uint256 assets, address receiver, address owner) external returns (uint256 shares);

    /**
     * @dev Returns the maximum amount of Vault shares that can be redeemed from the owner balance in the Vault,
     * through a redeem call.
     *
     * - MUST return a limited value if owner is subject to some withdrawal limit or timelock.
     * - MUST return balanceOf(owner) if owner is not subject to any withdrawal limit or timelock.
     * - MUST NOT revert.
     */
    function maxRedeem(address owner) external view returns (uint256 maxShares);

    /**
     * @dev Allows an on-chain or off-chain user to simulate the effects of their redeemption at the current block,
     * given current on-chain conditions.
     *
     * - MUST return as close to and no more than the exact amount of assets that would be withdrawn in a redeem call
     *   in the same transaction. I.e. redeem should return the same or more assets as previewRedeem if called in the
     *   same transaction.
     * - MUST NOT account for redemption limits like those returned from maxRedeem and should always act as though the
     *   redemption would be accepted, regardless if the user has enough shares, etc.
     * - MUST be inclusive of withdrawal fees. Integrators should be aware of the existence of withdrawal fees.
     * - MUST NOT revert.
     *
     * NOTE: any unfavorable discrepancy between convertToAssets and previewRedeem SHOULD be considered slippage in
     * share price or some other type of condition, meaning the depositor will lose assets by redeeming.
     */
    function previewRedeem(uint256 shares) external view returns (uint256 assets);

    /**
     * @dev Burns exactly shares from owner and sends assets of underlying tokens to receiver.
     *
     * - MUST emit the Withdraw event.
     * - MAY support an additional flow in which the underlying tokens are owned by the Vault contract before the
     *   redeem execution, and are accounted for during redeem.
     * - MUST revert if all of shares cannot be redeemed (due to withdrawal limit being reached, slippage, the owner
     *   not having enough shares, etc).
     *
     * NOTE: some implementations will require pre-requesting to the Vault before a withdrawal may be performed.
     * Those methods should be performed separately.
     */
    function redeem(uint256 shares, address receiver, address owner) external returns (uint256 assets);
}

// src/core/vault/FeeManager.sol

abstract contract FeeManager is Ownable {
    uint112 private _feeIn = 5 * 10 ** 5;
    uint112 private _feeOut = 5 * 10 ** 5;
    uint32 public constant feePrecision = 10 ** 8;

    address private _feeTo;

    constructor(address feeTo_) {
        _feeTo = feeTo_;
    }

    /* ====== SETTER ====== */

    function setFees(uint112 feeIn_, uint112 feeOut_) external onlyOwner {
        require(
            feeIn_ < 10 ** 8 && feeOut_ < 10 ** 8,
            "MaatVaultV1: Fee is more than one"
        );

        _feeIn = feeIn_;
        _feeOut = feeOut_;
    }

    function setFeeTo(address feeTo_) external onlyOwner {
        require(feeTo_ != address(0), "MaatVaultV1: FeeTo is zero address");

        _feeTo = feeTo_;
    }

    /* ====== INTERNAL ====== */

    function _calculateFee(
        uint amount,
        uint112 fee
    ) internal pure returns (uint) {
        return (amount * fee) / feePrecision;
    }

    /* ====== VIEWS ====== */

    function feeIn() public view returns (uint112) {
        return _feeIn;
    }

    function feeOut() public view returns (uint112) {
        return _feeOut;
    }

    function feeTo() public view returns (address) {
        return _feeTo;
    }
}

// node_modules/@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/utils/SafeERC20.sol)

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    /**
     * @dev An operation with an ERC20 token failed.
     */
    error SafeERC20FailedOperation(address token);

    /**
     * @dev Indicates a failed `decreaseAllowance` request.
     */
    error SafeERC20FailedDecreaseAllowance(address spender, uint256 currentAllowance, uint256 requestedDecrease);

    /**
     * @dev Transfer `value` amount of `token` from the calling contract to `to`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transfer, (to, value)));
    }

    /**
     * @dev Transfer `value` amount of `token` from `from` to `to`, spending the approval given by `from` to the
     * calling contract. If `token` returns no value, non-reverting calls are assumed to be successful.
     */
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transferFrom, (from, to, value)));
    }

    /**
     * @dev Increase the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        forceApprove(token, spender, oldAllowance + value);
    }

    /**
     * @dev Decrease the calling contract's allowance toward `spender` by `requestedDecrease`. If `token` returns no
     * value, non-reverting calls are assumed to be successful.
     */
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 requestedDecrease) internal {
        unchecked {
            uint256 currentAllowance = token.allowance(address(this), spender);
            if (currentAllowance < requestedDecrease) {
                revert SafeERC20FailedDecreaseAllowance(spender, currentAllowance, requestedDecrease);
            }
            forceApprove(token, spender, currentAllowance - requestedDecrease);
        }
    }

    /**
     * @dev Set the calling contract's allowance toward `spender` to `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful. Meant to be used with tokens that require the approval
     * to be set to zero before setting it to a non-zero value, such as USDT.
     */
    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeCall(token.approve, (spender, value));

        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(token, abi.encodeCall(token.approve, (spender, 0)));
            _callOptionalReturn(token, approvalCall);
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data);
        if (returndata.length != 0 && !abi.decode(returndata, (bool))) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturn} that silents catches all reverts and returns a bool instead.
     */
    function _callOptionalReturnBool(IERC20 token, bytes memory data) private returns (bool) {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We cannot use {Address-functionCall} here since this should return false
        // and not revert is the subcall reverts.

        (bool success, bytes memory returndata) = address(token).call(data);
        return success && (returndata.length == 0 || abi.decode(returndata, (bool))) && address(token).code.length > 0;
    }
}

// src/core/base/AddressProviderKeeper.sol

contract AddressProviderKeeper {
    using ERC165Checker for address;

    IMaatAddressProvider private immutable _addressProvider;

    bytes4 public constant AddressProviderInterfaceId =
        bytes4(keccak256("MAAT.V1.AddressProvider"));

    error AddressIsNotAddressProvider(address addr);

    constructor(address addressProvider_) {
        _validateAddressProviderInterface(addressProvider_);

        _addressProvider = IMaatAddressProvider(addressProvider_);
    }

    function _validateAddressProviderInterface(
        address addressProvider_
    ) private view {
        if (addressProvider_.supportsInterface(AddressProviderInterfaceId))
            return;

        revert AddressIsNotAddressProvider(addressProvider_);
    }

    function addressProvider() public view returns (IMaatAddressProvider) {
        return _addressProvider;
    }
}

// src/core/execute/Roles.sol

abstract contract Roles is Ownable, IRoles {
    address public commander;
    address public watcher;

    constructor(address commander_, address watcher_) {
        commander = commander_;
        watcher = watcher_;
    }

    function setCommander(address _commander) external onlyOwner {
        commander = _commander;
    }

    function setWatcher(address _watcher) external onlyOwner {
        watcher = _watcher;
    }

    /* ======== MODIFIERS ======== */

    modifier onlyCommanderOrAdmin() {
        require(
            msg.sender == commander || msg.sender == owner(),
            "MaatVaultV1: Caller is not commander or admin"
        );
        _;
    }

    modifier onlyWatcherOrAdmin() {
        require(
            msg.sender == watcher || msg.sender == owner(),
            "MaatVaultV1: Caller is not watcher or admin"
        );
        _;
    }
}

// src/core/execute/WithdrawRequestLogic.sol

abstract contract WithdrawRequestLogic is Ownable, IWithdrawRequestLogic {
    /* ======== STATE ======== */

    uint public cancelWithdrawTimer = 1 hours;

    ///@dev Endpoint Id of current chain in stargate terminology
    uint32 public immutable chainEid;

    mapping(uint32 dstEid => bool) internal _supportedDstEidToWithdraw;

    mapping(bytes32 intentionId => WithdrawRequestInfo)
        private _withdrawRequests;

    constructor(uint32 _chainEid) {
        chainEid = _chainEid;
        _supportedDstEidToWithdraw[chainEid] = true;
    }

    /* ======== EXTERNAL ======== */

    function setWithdrawCancelTimer(uint timer) external onlyOwner {
        cancelWithdrawTimer = timer;
    }

    /* ======== INTERNAL ======== */

    function _createWithdrawRequest(
        bytes32 intentionId,
        address _owner,
        address receiver,
        address asset,
        uint32 dstEid,
        uint shares
    ) internal {
        // TODO: add validations for all params possible
        require(
            receiver != address(0),
            "WithdrawRequestLogic: Receiver is zero address"
        );

        _withdrawRequests[intentionId] = WithdrawRequestInfo({
            owner: _owner,
            receiver: receiver,
            token: asset,
            dstEid: dstEid,
            creationTime: uint32(block.timestamp),
            shares: shares
        });

        emit WithdrawalRequested(asset, shares, _owner, intentionId, dstEid);
    }

    function _cancelWithdrawRequest(
        bytes32 intentionId
    ) internal returns (address owner, uint shares) {
        WithdrawRequestInfo memory request = _withdrawRequests[intentionId];

        require(
            request.creationTime != 0,
            "WithdrawRequestLogic: Request does not exist"
        );

        require(
            request.creationTime + cancelWithdrawTimer <= block.timestamp,
            "WithdrawRequestLogic: Not enough time has passed yet to withdraw"
        );
        address _owner = request.owner;

        require(
            msg.sender == _owner,
            "WithdrawRequestLogic: Unauthorized caller"
        );

        _cleanRequestInfo(_owner, intentionId);

        emit WithdrawRequestCancelled(intentionId);

        return (_owner, request.shares);
    }

    function _cleanRequestInfo(address owner, bytes32 intentionId) internal {
        delete _withdrawRequests[intentionId];
    }

    function addChainToWithdraw(uint32 _dstEid) external onlyOwner {
        _supportedDstEidToWithdraw[_dstEid] = true;
    }

    function removeChainToWithdraw(uint32 _dstEid) external onlyOwner {
        _supportedDstEidToWithdraw[_dstEid] = false;
    }

    /* ======== VIEWS ======== */

    function getWithdrawRequest(
        bytes32 intentionId
    ) public view returns (WithdrawRequestInfo memory) {
        _validateWithdrawRequestExistence(intentionId);

        return _withdrawRequests[intentionId];
    }

    function getSupportedDstEidToWithdraw(
        uint32 _dstEid
    ) public view returns (bool) {
        return _supportedDstEidToWithdraw[_dstEid];
    }

    function _validateWithdrawRequestExistence(
        bytes32 intentionId
    ) internal view {
        WithdrawRequestInfo memory request = _withdrawRequests[intentionId];

        require(request.owner != address(0), "MaatVaultV1: Request not found");
    }
}

// src/interfaces/IStrategy.sol

interface IStrategy is IERC4626 {
    struct StrategyParams {
        uint32 chainId;
        string protocol;
        uint8 protocolVersion;
        address token;
        address protocolVault;
    }

    function getStrategyParams() external view returns (StrategyParams memory);

    function getStrategyId() external view returns (bytes32 strategyId);
}

// node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/ERC20.sol)

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * The default value of {decimals} is 18. To change this, you should override
 * this function so it returns a different value.
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 */
abstract contract ERC20 is Context, IERC20, IERC20Metadata, IERC20Errors {
    mapping(address account => uint256) private _balances;

    mapping(address account => mapping(address spender => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the default value returned by this function, unless
     * it's overridden.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `value`.
     */
    function transfer(address to, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, value);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `value` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, value);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `value`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `value`.
     */
    function transferFrom(address from, address to, uint256 value) public virtual returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead.
     */
    function _transfer(address from, address to, uint256 value) internal {
        if (from == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        if (to == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(from, to, value);
    }

    /**
     * @dev Transfers a `value` amount of tokens from `from` to `to`, or alternatively mints (or burns) if `from`
     * (or `to`) is the zero address. All customizations to transfers, mints, and burns should be done by overriding
     * this function.
     *
     * Emits a {Transfer} event.
     */
    function _update(address from, address to, uint256 value) internal virtual {
        if (from == address(0)) {
            // Overflow check required: The rest of the code assumes that totalSupply never overflows
            _totalSupply += value;
        } else {
            uint256 fromBalance = _balances[from];
            if (fromBalance < value) {
                revert ERC20InsufficientBalance(from, fromBalance, value);
            }
            unchecked {
                // Overflow not possible: value <= fromBalance <= totalSupply.
                _balances[from] = fromBalance - value;
            }
        }

        if (to == address(0)) {
            unchecked {
                // Overflow not possible: value <= totalSupply or value <= fromBalance <= totalSupply.
                _totalSupply -= value;
            }
        } else {
            unchecked {
                // Overflow not possible: balance + value is at most totalSupply, which we know fits into a uint256.
                _balances[to] += value;
            }
        }

        emit Transfer(from, to, value);
    }

    /**
     * @dev Creates a `value` amount of tokens and assigns them to `account`, by transferring it from address(0).
     * Relies on the `_update` mechanism
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead.
     */
    function _mint(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(address(0), account, value);
    }

    /**
     * @dev Destroys a `value` amount of tokens from `account`, lowering the total supply.
     * Relies on the `_update` mechanism.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead
     */
    function _burn(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        _update(account, address(0), value);
    }

    /**
     * @dev Sets `value` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     *
     * Overrides to this logic should be done to the variant with an additional `bool emitEvent` argument.
     */
    function _approve(address owner, address spender, uint256 value) internal {
        _approve(owner, spender, value, true);
    }

    /**
     * @dev Variant of {_approve} with an optional flag to enable or disable the {Approval} event.
     *
     * By default (when calling {_approve}) the flag is set to true. On the other hand, approval changes made by
     * `_spendAllowance` during the `transferFrom` operation set the flag to false. This saves gas by not emitting any
     * `Approval` event during `transferFrom` operations.
     *
     * Anyone who wishes to continue emitting `Approval` events on the`transferFrom` operation can force the flag to
     * true using the following override:
     * ```
     * function _approve(address owner, address spender, uint256 value, bool) internal virtual override {
     *     super._approve(owner, spender, value, true);
     * }
     * ```
     *
     * Requirements are the same as {_approve}.
     */
    function _approve(address owner, address spender, uint256 value, bool emitEvent) internal virtual {
        if (owner == address(0)) {
            revert ERC20InvalidApprover(address(0));
        }
        if (spender == address(0)) {
            revert ERC20InvalidSpender(address(0));
        }
        _allowances[owner][spender] = value;
        if (emitEvent) {
            emit Approval(owner, spender, value);
        }
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `value`.
     *
     * Does not update the allowance value in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Does not emit an {Approval} event.
     */
    function _spendAllowance(address owner, address spender, uint256 value) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            if (currentAllowance < value) {
                revert ERC20InsufficientAllowance(spender, currentAllowance, value);
            }
            unchecked {
                _approve(owner, spender, currentAllowance - value, false);
            }
        }
    }
}

// src/interfaces/IMaatVaultV1.sol

interface IMaatVaultV1 is IExecutor, IERC4626 {}

// src/core/base/TokenKeeper.sol

contract TokenKeeper {
    ERC20 public immutable token;
    uint private _idle;

    constructor(address _token) {
        token = ERC20(_token);
    }

    function _increaseIdle(uint value) internal virtual {
        _idle += value;
    }

    function _decreaseIdle(uint value) internal virtual {
        require(
            value <= _idle,
            "MaatVaultV1: Arithmetic error during idle calculations"
        );
        _idle -= value;
    }

    function idle() public view virtual returns (uint) {
        return _idle;
    }
}

// src/core/execute/StrategyManager.sol

abstract contract StrategyManager is
    Ownable,
    AddressProviderKeeper,
    TokenKeeper,
    IStrategyManager
{
    mapping(bytes32 => Strategy) private _supportedStrategies;
    mapping(address => bytes32) private _strategyAddressToId;

    /* ====== EXTERNAL ====== */

    ///@dev strategy is active after adding by default
    function addStrategy(address strategy) external onlyOwner {
        require(
            addressProvider().isStrategy(strategy),
            "MaatVaultV1: Invalid strategy"
        );

        bytes32 strategyId = IStrategy(strategy).getStrategyId();

        require(
            IStrategy(strategy).asset() == address(token),
            "MaatVaultV1: Cannot add strategy with different asset"
        );

        require(
            _supportedStrategies[strategyId].strategyAddress == address(0),
            "MaatVaultV1: Strategy already exists"
        );

        _supportedStrategies[strategyId].strategyAddress = strategy;
        _supportedStrategies[strategyId].isActive = true;

        _strategyAddressToId[strategy] = strategyId;

        emit StrategyAdded(strategyId);
    }

    ///@dev cannot remove strategy with funds
    function removeStrategy(bytes32 strategyId) external onlyOwner {
        _validateStrategyExistence(strategyId);

        IStrategy strategy = IStrategy(
            _supportedStrategies[strategyId].strategyAddress
        );

        require(
            strategy.balanceOf(address(this)) == 0,
            "MaatVaultV1: Cannot delete strategy with funds"
        );

        _deleteStrategy(strategyId, address(strategy));
    }

    // TODO: review such functionality requirement
    // disabling of strategies should be on a AddressProvider
    // should think about strategy deprecation after disable it on AddressProvider
    function enableStrategy(bytes32 strategyId) external onlyOwner {
        _validateStrategyExistence(strategyId);

        _toggleStrategy(strategyId, true);
    }

    function disableStrategy(bytes32 strategyId) external onlyOwner {
        _validateStrategyExistence(strategyId);

        _toggleStrategy(strategyId, false);
    }

    /* ====== INTERNALS ====== */

    function _deleteStrategy(bytes32 strategyId, address strategy) internal {
        delete _supportedStrategies[strategyId];
        delete _strategyAddressToId[strategy];
    }

    function _toggleStrategy(bytes32 strategyId, bool isActive) internal {
        _supportedStrategies[strategyId].isActive = isActive;

        emit StrategyToggled(strategyId, isActive);
    }

    /* ====== VIEWS ====== */

    function getStrategyByAddress(
        address strategy
    ) external view returns (bytes32, bool) {
        _validateStrategyExistence(strategy);

        return (
            _strategyAddressToId[strategy],
            _supportedStrategies[_strategyAddressToId[strategy]].isActive
        );
    }

    function getStrategyById(
        bytes32 strategyId
    ) public view returns (address, bool) {
        _validateStrategyExistence(strategyId);

        return (
            _supportedStrategies[strategyId].strategyAddress,
            _supportedStrategies[strategyId].isActive
        );
    }

    function _validateStrategyExistence(bytes32 strategyId) internal view {
        address strategy = _supportedStrategies[strategyId].strategyAddress;

        require(strategy != address(0), "MaatVaultV1: Nonexistent strategy");
    }

    function _validateStrategyExistence(address strategy) internal view {
        bytes32 strategyId = _strategyAddressToId[strategy];

        require(strategyId != bytes32(0), "MaatVaultV1: Nonexistent strategy");
    }
}

// src/core/execute/BridgeLogic.sol

abstract contract BridgeLogic is
    AddressProviderKeeper,
    TokenKeeper,
    IBridgeLogic
{
    /* ======== STATE ======== */

    using SafeERC20 for ERC20;

    /* ======== EXTERNAL/PUBLIC ======== */

    function stargateAdapter() public view returns (IStargateAdapter) {
        return IStargateAdapter(addressProvider().stargateAdapter());
    }

    ///@dev used to called by stargate adapter to receive tokens
    function finishBridge(
        uint256 amountBridged,
        bytes32 intentionId
    ) external onlyStargateAdapter {
        _finishBridge(amountBridged, address(stargateAdapter()));

        emit BridgeFinished(amountBridged, intentionId);
    }

    function _finishBridge(uint amountBridged, address sender) internal {
        token.safeTransferFrom(sender, address(this), amountBridged);

        _increaseIdle(amountBridged);
    }

    /* ======== INTERNAL ======== */

    function _bridge(
        uint256 _amount,
        uint256 dstEid,
        bytes32 intentionId
    ) internal {
        IStargateAdapter _stargateAdapter = stargateAdapter();

        token.approve(address(_stargateAdapter), _amount);

        _stargateAdapter.sendTokens(
            uint32(dstEid),
            address(token),
            _amount,
            intentionId
        );

        _decreaseIdle(_amount);

        emit Bridged(uint32(dstEid), address(token), _amount, intentionId);
    }

    function _bridgeToUser(
        uint amount,
        address _receiver,
        uint32 dstEid
    ) internal {
        IStargateAdapter _stargateAdapter = stargateAdapter();

        token.approve(address(_stargateAdapter), amount);

        _stargateAdapter.sendTokensToReceiver(
            dstEid,
            address(token),
            amount,
            _receiver
        );

        _decreaseIdle(amount);
    }

    /* ======== MODIFIERS ======== */

    modifier onlyStargateAdapter() {
        require(
            msg.sender == address(stargateAdapter()),
            "MaatVaultV1: Caller is not stargate adapter"
        );
        _;
    }
}

// src/core/execute/Executor.sol

abstract contract Executor is
    Roles,
    BridgeLogic,
    StrategyManager,
    WithdrawRequestLogic,
    IExecutor
{
    constructor(
        address commander,
        address watcher,
        uint32 chainEid
    ) Roles(commander, watcher) WithdrawRequestLogic(chainEid) {}

    /* ======== EXECUTION FUNCTION ======== */

    ///@notice execute multiple actions from commander
    ///@dev arguments of the function are must not be encoded and arrays must be same length
    function execute(
        // TODO: make batching more clear with intention Ids
        ActionType[] calldata actionType,
        ActionInput[] calldata inputs
    ) external onlyCommanderOrAdmin returns (bool) {
        uint length = actionType.length;

        require(length == inputs.length, "MaatVaultV1: Invalid input length");

        for (uint i = 0; i < length; i++) {
            _execute(actionType[i], inputs[i]);
        }

        return true;
    }

    function _execute(ActionType _type, ActionInput memory input) internal {
        uint256 dstEid = input.dstEid;
        bytes32 strategyId = input.strategyId;
        uint256 _amount = input.amount;
        bytes32 intentionId = input.intentionId;

        if (_type == ActionType.DEPOSIT) {
            _depositInStrategy(strategyId, _amount, intentionId);
        } else if (_type == ActionType.WITHDRAW) {
            _withdrawFromStrategy(strategyId, _amount, intentionId);
        } else if (_type == ActionType.BRIDGE) {
            _bridge(_amount, dstEid, intentionId);
        } else if (_type == ActionType.FULFILL_WITHDRAW_REQUEST) {
            _fulfillWithdrawRequest(intentionId);
        }
    }

    // TODO: rename depositToStrategy
    function _depositInStrategy(
        bytes32 _strategyId,
        uint amount,
        bytes32 intentionId
    ) internal returns (uint shares) {
        (address strategyAddress, bool isActive) = getStrategyById(_strategyId);

        require(isActive, "MaatVaultV1: Strategy is not active");

        IStrategy strategy = IStrategy(strategyAddress);

        token.approve(strategyAddress, amount);

        _decreaseIdle(amount);

        shares = strategy.deposit(amount, address(this));

        emit DepositedInStrategy(
            _strategyId,
            address(token),
            amount,
            intentionId
        );
    }

    ///@dev amount is in asset() token
    function _withdrawFromStrategy(
        bytes32 _strategyId,
        uint amount,
        bytes32 intentionId
    ) internal returns (uint shares) {
        (address strategyAddress, ) = getStrategyById(_strategyId);

        IStrategy strategy = IStrategy(strategyAddress);

        shares = strategy.withdraw(amount, address(this), address(this));

        _increaseIdle(amount);

        emit WithdrewFromStrategy(
            _strategyId,
            address(token),
            amount,
            intentionId
        );
    }

    function _fulfillWithdrawRequest(bytes32 intentionId) internal virtual {}
}

// src/core/vault/TokenVault.sol

// Must inherit from most basic ones to most derived contracts!
// Otherwise "Linearization of inheritance graph impossible" will occur
// https://docs.soliditylang.org/en/develop/contracts.html#multiple-inheritance-and-linearization
abstract contract TokenVault is
    Ownable,
    AddressProviderKeeper,
    FeeManager,
    TokenKeeper,
    ERC20,
    IMaatVaultV1,
    ERC165Registry,
    ReentrancyGuard
{
    using Math for uint256;
    using SafeERC20 for ERC20;

    uint public minAmount;

    /* ======== ERRORS ======== */

    error UnauthorizedUser(address user);
    error TokenIsNotSupported(address token);
    error AddressIsNotStrategy(address addr);
    error AmountIsTooLow();

    /* ======== CONSTRUCTOR ======== */
    constructor(
        address admin,
        address assetAddress,
        address addressProvider,
        uint minAmount_
    )
        Ownable(admin)
        AddressProviderKeeper(addressProvider)
        FeeManager(admin)
        ERC20(_getVaultName(assetAddress), _getVaultSymbol(assetAddress))
    {
        minAmount = minAmount_;

        _registerInterface(type(IERC4626).interfaceId);
    }

    /* ======== EXTERNAL ======== */

    ///@dev function is calling by users to deposit their funds. Do not use it to deposit funds from stargate adapter.
    function deposit(
        uint _assets,
        address _receiver
    ) external nonReentrant returns (uint shares) {
        _validateMinAmount(_assets);

        require(_receiver != address(0), "MaatVaultV1: Mint To Zero Address");

        uint sharesWithoutFee = convertToShares(_assets);

        (, shares) = _deposit(_assets, sharesWithoutFee, msg.sender, _receiver);
    }

    function mint(
        uint shares,
        address receiver
    ) external nonReentrant returns (uint assets) {
        require(receiver != address(0), "MaatVaultV1: Mint To Zero Address");

        uint assetsWithoutFee = convertToAssets(shares);

        _validateMinAmount(assetsWithoutFee);

        (assets, ) = _deposit(assetsWithoutFee, shares, msg.sender, receiver);
    }

    function withdraw(
        uint _assets,
        address _receiver,
        address _owner
    ) external nonReentrant returns (uint shares) {
        _validateMinAmount(_assets);
        _validateUser(_owner, msg.sender);

        shares = _withdraw(_assets, _receiver, _owner);
    }

    function redeem(
        uint256 _shares,
        address _receiver,
        address _owner
    ) public nonReentrant returns (uint assets) {
        uint assetsWithoutFee = _convertToAssetsByPrevPPS(_shares);

        _validateMinAmount(assetsWithoutFee);
        _validateUser(_owner, msg.sender);

        assets = _redeem(_shares, _receiver, _owner);
    }

    /* ======== INTERNAL FUNCTIONS ======== */

    function _deposit(
        uint assets,
        uint shares,
        address _owner,
        address receiver
    ) internal returns (uint adjustedAssets, uint adjustedShares) {
        token.safeTransferFrom(_owner, address(this), assets);

        adjustedShares = shares - _calculateFee(shares, feeIn());
        adjustedAssets = convertToAssets(adjustedShares);

        _mint(address(this), shares);
        this.transfer(receiver, adjustedShares);
        _sendFee(shares - adjustedShares);
        _increaseIdle(assets);

        emit Deposit(_owner, receiver, assets, adjustedShares);
    }

    ///@dev burn shares from _owner and transfer assets to _receiver
    function _redeem(
        uint _shares,
        address _receiver,
        address _owner
    ) internal returns (uint assets) {
        ///@dev if condition is not completed => fulfillRequestWithdraw
        if (_owner != address(this)) {
            this.transferFrom(_owner, address(this), _shares);
        }

        uint adjustedShares = _shares - _calculateFee(_shares, feeOut());

        assets = _convertToAssetsByPrevPPS(adjustedShares);

        _sendFunds(_receiver, assets, adjustedShares, _shares - adjustedShares);

        emit Withdraw(msg.sender, _receiver, _owner, assets, adjustedShares);
    }

    function _withdraw(
        uint _assets,
        address _receiver,
        address _owner
    ) internal returns (uint adjustedShares) {
        uint shares = _convertToSharesByPrevPPS(_assets);
        adjustedShares = shares + _calculateFee(shares, feeOut());
        this.transferFrom(_owner, address(this), adjustedShares);

        _sendFunds(_receiver, _assets, shares, adjustedShares - shares);

        emit Withdraw(msg.sender, _receiver, _owner, _assets, adjustedShares);
    }

    function _sendFunds(
        address _receiver,
        uint _assets,
        uint _shares,
        uint fee
    ) internal {
        _burn(address(this), _shares);

        token.safeTransfer(_receiver, _assets);

        _decreaseIdle(_assets);

        _sendFee(fee);
    }

    /* ====== FEES ====== */

    function _sendFee(uint fee) internal {
        if (feeTo() == address(0) || fee == 0) return;

        this.transfer(feeTo(), fee);
    }

    /* ====== ONLY OWNER ====== */

    function setMinAmount(uint amount) external onlyOwner {
        minAmount = amount;
    }

    /* ======== VIEWS ======== */

    function _getVaultName(
        address _asset
    ) internal view returns (string memory) {
        //MAAT USDC VAULT
        return string.concat("MAAT ", ERC20(_asset).symbol(), " MaatVaultV1");
    }

    function _getVaultSymbol(
        address _asset
    ) internal view returns (string memory) {
        //mUSDC
        return string.concat("mt", ERC20(_asset).symbol());
    }

    function oracle() public view returns (IMaatOracleGlobalPPS) {
        return IMaatOracleGlobalPPS(addressProvider().oracle());
    }

    function asset() public view returns (address) {
        return address(token);
    }

    function totalAssets() external view virtual returns (uint) {
        return
            totalSupply().mulDiv(
                oracle().getGlobalPPS(asset()),
                10 ** oracle().decimals()
            );
    }

    function convertToShares(uint assets) public view virtual returns (uint) {
        return
            assets.mulDiv(
                10 ** oracle().decimals(),
                oracle().getGlobalPPS(asset()),
                Math.Rounding.Floor
            );
    }

    function _convertToSharesByPrevPPS(
        uint assets
    ) internal view virtual returns (uint) {
        return
            assets.mulDiv(
                10 ** oracle().decimals(),
                oracle().getPrevGlobalPPS(asset()),
                Math.Rounding.Floor
            );
    }

    function convertToAssets(uint shares) public view virtual returns (uint) {
        return
            shares.mulDiv(
                oracle().getGlobalPPS(asset()),
                10 ** oracle().decimals(),
                Math.Rounding.Floor
            );
    }

    function _convertToAssetsByPrevPPS(
        uint shares
    ) internal view virtual returns (uint) {
        return
            shares.mulDiv(
                oracle().getPrevGlobalPPS(asset()),
                10 ** oracle().decimals(),
                Math.Rounding.Floor
            );
    }

    function maxDeposit(
        address receiver
    ) external view virtual returns (uint256) {
        return type(uint).max;
    }

    function maxMint(address receiver) external view virtual returns (uint256) {
        return type(uint).max;
    }

    function maxRedeem(address receiver) external view virtual returns (uint) {
        return balanceOf(receiver);
    }

    function maxWithdraw(
        address receiver
    ) external view virtual returns (uint) {
        return convertToAssets(balanceOf(receiver));
    }

    function previewDeposit(uint assets) external view virtual returns (uint) {
        uint shares = convertToShares(assets);
        return shares - _calculateFee(shares, feeIn());
    }

    function previewMint(uint shares) external view virtual returns (uint) {
        return convertToAssets(shares + _calculateFee(shares, feeIn()));
    }

    function previewWithdraw(uint assets) public view virtual returns (uint) {
        uint shares = _convertToSharesByPrevPPS(assets);

        return (shares + _calculateFee(shares, feeOut()));
    }

    function previewRedeem(uint shares) public view virtual returns (uint) {
        return
            _convertToAssetsByPrevPPS(shares - _calculateFee(shares, feeOut()));
    }

    function decimals()
        public
        view
        override(ERC20, IERC20Metadata)
        returns (uint8)
    {
        return token.decimals();
    }

    /* ======== VALIDATION ======== */

    function _validateUser(address _owner, address sender) internal pure {
        if (_owner != sender) revert UnauthorizedUser(sender);
    }

    function _validateMinAmount(uint amount) internal view {
        if (amount < minAmount) revert AmountIsTooLow();
    }
}

// src/core/MaatVaultV1.sol

/* ====== External ====== */

/* ====== Interfaces ====== */

/* ====== Contracts ====== */

contract MaatVaultV1 is IMaatVaultV1, TokenVault, Executor {
    using SafeERC20 for ERC20;

    bytes4 constant vaultInterfaceId = type(IMaatVaultV1).interfaceId;

    constructor(
        address owner,
        address assetAddress,
        uint minAmount,
        address addressProvider,
        address commander,
        address watcher,
        uint32 chainEid
    )
        TokenKeeper(assetAddress)
        Executor(commander, watcher, chainEid)
        TokenVault(owner, assetAddress, addressProvider, minAmount)
    {
        _registerInterface(vaultInterfaceId);
        _registerInterface(type(IERC165).interfaceId);
    }

    /* ======== REQUEST FUNCTIONS ======== */

    ///@param shares Amount of shares to burn to withdraw funds
    ///@param dstEid dstEid of stargate adapter of the chain where user want to get tokens
    function requestWithdraw(
        uint shares,
        uint32 dstEid,
        address _owner,
        address receiver
    ) external nonReentrant returns (bytes32 intentionId) {
        uint amountOutTokens = _convertToAssetsByPrevPPS(shares);

        _validateMinAmount(amountOutTokens);
        _validateUser(_owner, msg.sender);

        require(
            _supportedDstEidToWithdraw[dstEid],
            "MaatVaultV1: Chain is not supported for withdrawal"
        );

        intentionId = getIntentionId(address(_owner), RequestType.WITHDRAW);

        this.transferFrom(_owner, address(this), shares);

        _createWithdrawRequest(
            intentionId,
            _owner,
            receiver,
            asset(),
            dstEid,
            shares
        );
    }

    function requestRebalance()
        external
        onlyWatcherOrAdmin
        returns (bytes32 intentionId)
    {
        intentionId = getIntentionId(msg.sender, RequestType.REBALANCE);

        emit RebalanceRequested(intentionId);
    }

    /* ======== CANCEL WITHDRAW FUNCTION ======== */

    function cancelWithdrawal(
        bytes32 intentionId
    ) external nonReentrant returns (address owner, uint shares) {
        (address _owner, uint _shares) = _cancelWithdrawRequest(intentionId);

        this.transfer(_owner, _shares);

        return (_owner, _shares);
    }

    function _fulfillWithdrawRequest(bytes32 intentionId) internal override {
        WithdrawRequestInfo memory request = getWithdrawRequest(intentionId);

        uint amountOut = _redeem(request.shares, address(this), address(this));

        if (request.dstEid == chainEid) {
            token.safeTransfer(request.receiver, amountOut);
        } else {
            _bridgeToUser(amountOut, request.receiver, request.dstEid);
        }

        emit WithdrawRequestFulfilled(
            asset(),
            amountOut,
            request.owner,
            request.receiver,
            intentionId
        );

        _cleanRequestInfo(request.owner, intentionId);
    }

    /* ======== VIEW FUNCTIONS ======== */

    function getIntentionId(
        address sender,
        RequestType _type
    ) public view returns (bytes32) {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }

        return
            // TODO: rework because: ID will repeat for any transactions from one sender in one block of same request type
            keccak256(
                abi.encodePacked(
                    sender,
                    address(token),
                    block.number,
                    block.timestamp,
                    chainId,
                    _type
                )
            );
    }
}

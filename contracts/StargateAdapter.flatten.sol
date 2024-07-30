// SPDX-License-Identifier: MIT
pragma solidity <0.9.0 =0.8.22 >=0.8.0 ^0.8.0 ^0.8.1 ^0.8.20 ^0.8.22;

// dependencies/@stargatefinance-1.0.5/packages/stg-evm-v2/src/interfaces/IStargateFeeLib.sol

/// @notice Parameters used to assess fees to send tokens to a destination endpoint.
struct FeeParams {
    address sender;
    uint32 dstEid;
    uint64 amountInSD;
    uint64 deficitSD;
    bool toOFT;
    bool isTaxi;
}

/// @title Interface for assessing fees to send tokens to a destination endpoint.
interface IStargateFeeLib {
    /// @notice Apply a fee for a given request, allowing for state modification.
    /// @dev This is included for future proofing potential implementations
    /// @dev where state is modified in the feeLib based on a FeeParams

    function applyFee(FeeParams calldata _params) external returns (uint64 amountOutSD);
    /// @notice Apply a fee for a given request, without modifying state.
    function applyFeeView(FeeParams calldata _params) external view returns (uint64 amountOutSD);
}

// dependencies/@stargatefinance-1.0.5/packages/stg-evm-v2/src/libs/Path.sol

/// @dev The Path struct contains the bus base fare multiplier bps and the credit in the same slot for gas saving.
struct Path {
    uint64 credit; // available credit for the path, in SD
}

using PathLib for Path global;

/**
 * @title A library to operate on Paths.
 * @dev A Path is a route through which value can be sent. It entails the local chain and a destination chain, and has
 *      a given amount of credit associated with it. Every time the value is sent from A to B, the credit on A is
 *      decreased and credit on B is increased. If credit hits 0 then the path can no longer be used.
 */
library PathLib {
    uint64 internal constant UNLIMITED_CREDIT = type(uint64).max;

    // solhint-disable-next-line event-name-camelcase
    event Path_CreditBurned(uint64 amountSD);

    error Path_InsufficientCredit();
    error Path_AlreadyHasCredit();
    error Path_UnlimitedCredit();

    /// @notice Increase credit for a given Path.
    /// @dev Reverts with Path_UnlimitedCredit if the increase would hit the maximum amount of credit (reserved value)
    /// @param _path The Path for which to increase credit
    /// @param _amountSD The amount by which to increase credit
    function increaseCredit(Path storage _path, uint64 _amountSD) internal {
        uint64 credit = _path.credit;
        if (credit == UNLIMITED_CREDIT) return;
        credit += _amountSD;
        if (credit == UNLIMITED_CREDIT) revert Path_UnlimitedCredit();
        _path.credit = credit;
    }

    /// @notice Decrease credit for a given Path.
    /// @dev Reverts with InsufficientCredit if there is not enough credit
    /// @param _path The Path for which to decrease credit
    /// @param _amountSD The amount by which to decrease credit
    function decreaseCredit(Path storage _path, uint64 _amountSD) internal {
        uint64 currentCredit = _path.credit;
        if (currentCredit == UNLIMITED_CREDIT) return;
        if (currentCredit < _amountSD) revert Path_InsufficientCredit();
        unchecked {
            _path.credit = currentCredit - _amountSD;
        }
    }

    /// @notice Decrease credit for a given path, even if only a partial amount is possible.
    /// @param _path The Path for which to decrease credit
    /// @param _amountSD The amount by which try to decrease credit
    /// @param _minKept The minimum amount of credit to keep after the decrease
    /// @return decreased The actual amount of credit decreased
    function tryDecreaseCredit(
        Path storage _path,
        uint64 _amountSD,
        uint64 _minKept
    ) internal returns (uint64 decreased) {
        uint64 currentCredit = _path.credit;
        // not allowed to try to decrease unlimited credit
        if (currentCredit == UNLIMITED_CREDIT) revert Path_UnlimitedCredit();
        if (_minKept < currentCredit) {
            unchecked {
                uint64 maxDecreased = currentCredit - _minKept;
                decreased = _amountSD > maxDecreased ? maxDecreased : _amountSD;
                _path.credit = currentCredit - decreased;
            }
        }
    }

    /// @notice Set a given path as OFT or reset an OFT path to 0 credit.
    /// @dev A Path for which the asset is using an OFT on destination gets unlimited credit because value transfers
    /// @dev do not spend value.
    /// @dev Such a path is expected to not have credit before.
    /// @dev Reverts with AlreadyHasCredit if the Path already had credit assigned to it
    /// @param _path The Path to set
    /// @param _oft Whether to set it as OFT or reset it from OFT
    function setOFTPath(Path storage _path, bool _oft) internal {
        uint64 currentCredit = _path.credit;
        if (_oft) {
            // only allow un-limiting from 0
            if (currentCredit != 0) revert Path_AlreadyHasCredit();
            _path.credit = UNLIMITED_CREDIT;
        } else {
            // only allow resetting from unlimited
            if (currentCredit != UNLIMITED_CREDIT) revert Path_AlreadyHasCredit();
            _path.credit = 0;
        }
    }

    /// @notice Check whether a given Path is set as OFT.
    /// @param _path The path to examine
    /// @return whether the Path is set as OFT
    function isOFTPath(Path storage _path) internal view returns (bool) {
        return _path.credit == UNLIMITED_CREDIT;
    }

    /// @notice Burn credit for a given Path during bridged token migration.
    function burnCredit(Path storage _path, uint64 _amountSD) internal {
        decreaseCredit(_path, _amountSD);
        emit Path_CreditBurned(_amountSD);
    }
}

// node_modules/@layerzerolabs/lz-evm-oapp-v2/contracts/oft/libs/OFTComposeMsgCodec.sol

library OFTComposeMsgCodec {
    // Offset constants for decoding composed messages
    uint8 private constant NONCE_OFFSET = 8;
    uint8 private constant SRC_EID_OFFSET = 12;
    uint8 private constant AMOUNT_LD_OFFSET = 44;
    uint8 private constant COMPOSE_FROM_OFFSET = 76;

    /**
     * @dev Encodes a OFT composed message.
     * @param _nonce The nonce value.
     * @param _srcEid The source endpoint ID.
     * @param _amountLD The amount in local decimals.
     * @param _composeMsg The composed message.
     * @return _msg The encoded Composed message.
     */
    function encode(
        uint64 _nonce,
        uint32 _srcEid,
        uint256 _amountLD,
        bytes memory _composeMsg // 0x[composeFrom][composeMsg]
    ) internal pure returns (bytes memory _msg) {
        _msg = abi.encodePacked(_nonce, _srcEid, _amountLD, _composeMsg);
    }

    /**
     * @dev Retrieves the nonce from the composed message.
     * @param _msg The message.
     * @return The nonce value.
     */
    function nonce(bytes calldata _msg) internal pure returns (uint64) {
        return uint64(bytes8(_msg[:NONCE_OFFSET]));
    }

    /**
     * @dev Retrieves the source endpoint ID from the composed message.
     * @param _msg The message.
     * @return The source endpoint ID.
     */
    function srcEid(bytes calldata _msg) internal pure returns (uint32) {
        return uint32(bytes4(_msg[NONCE_OFFSET:SRC_EID_OFFSET]));
    }

    /**
     * @dev Retrieves the amount in local decimals from the composed message.
     * @param _msg The message.
     * @return The amount in local decimals.
     */
    function amountLD(bytes calldata _msg) internal pure returns (uint256) {
        return uint256(bytes32(_msg[SRC_EID_OFFSET:AMOUNT_LD_OFFSET]));
    }

    /**
     * @dev Retrieves the composeFrom value from the composed message.
     * @param _msg The message.
     * @return The composeFrom value.
     */
    function composeFrom(bytes calldata _msg) internal pure returns (bytes32) {
        return bytes32(_msg[AMOUNT_LD_OFFSET:COMPOSE_FROM_OFFSET]);
    }

    /**
     * @dev Retrieves the composed message.
     * @param _msg The message.
     * @return The composed message.
     */
    function composeMsg(bytes calldata _msg) internal pure returns (bytes memory) {
        return _msg[COMPOSE_FROM_OFFSET:];
    }

    /**
     * @dev Converts an address to bytes32.
     * @param _addr The address to convert.
     * @return The bytes32 representation of the address.
     */
    function addressToBytes32(address _addr) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(_addr)));
    }

    /**
     * @dev Converts bytes32 to an address.
     * @param _b The bytes32 value to convert.
     * @return The address representation of bytes32.
     */
    function bytes32ToAddress(bytes32 _b) internal pure returns (address) {
        return address(uint160(uint256(_b)));
    }
}

// node_modules/@layerzerolabs/lz-evm-oapp-v2/contracts/precrime/interfaces/IPreCrime.sol

struct PreCrimePeer {
    uint32 eid;
    bytes32 preCrime;
    bytes32 oApp;
}

// TODO not done yet
interface IPreCrime {
    error OnlyOffChain();

    // for simulate()
    error PacketOversize(uint256 max, uint256 actual);
    error PacketUnsorted();
    error SimulationFailed(bytes reason);

    // for preCrime()
    error SimulationResultNotFound(uint32 eid);
    error InvalidSimulationResult(uint32 eid, bytes reason);
    error CrimeFound(bytes crime);

    function getConfig(bytes[] calldata _packets, uint256[] calldata _packetMsgValues) external returns (bytes memory);

    function simulate(
        bytes[] calldata _packets,
        uint256[] calldata _packetMsgValues
    ) external payable returns (bytes memory);

    function buildSimulationResult() external view returns (bytes memory);

    function preCrime(
        bytes[] calldata _packets,
        uint256[] calldata _packetMsgValues,
        bytes[] calldata _simulations
    ) external;

    function version() external view returns (uint64 major, uint8 minor);
}

// node_modules/@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroComposer.sol

/**
 * @title ILayerZeroComposer
 */
interface ILayerZeroComposer {
    /**
     * @notice Composes a LayerZero message from an OApp.
     * @param _from The address initiating the composition, typically the OApp where the lzReceive was called.
     * @param _guid The unique identifier for the corresponding LayerZero src/dst tx.
     * @param _message The composed message payload in bytes. NOT necessarily the same payload passed via lzReceive.
     * @param _executor The address of the executor for the composed message.
     * @param _extraData Additional arbitrary data in bytes passed by the entity who executes the lzCompose.
     */
    function lzCompose(
        address _from,
        bytes32 _guid,
        bytes calldata _message,
        address _executor,
        bytes calldata _extraData
    ) external payable;
}

// node_modules/@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/IMessageLibManager.sol

struct SetConfigParam {
    uint32 eid;
    uint32 configType;
    bytes config;
}

interface IMessageLibManager {
    struct Timeout {
        address lib;
        uint256 expiry;
    }

    event LibraryRegistered(address newLib);
    event DefaultSendLibrarySet(uint32 eid, address newLib);
    event DefaultReceiveLibrarySet(uint32 eid, address oldLib, address newLib);
    event DefaultReceiveLibraryTimeoutSet(uint32 eid, address oldLib, uint256 expiry);
    event SendLibrarySet(address sender, uint32 eid, address newLib);
    event ReceiveLibrarySet(address receiver, uint32 eid, address oldLib, address newLib);
    event ReceiveLibraryTimeoutSet(address receiver, uint32 eid, address oldLib, uint256 timeout);

    function registerLibrary(address _lib) external;

    function isRegisteredLibrary(address _lib) external view returns (bool);

    function getRegisteredLibraries() external view returns (address[] memory);

    function setDefaultSendLibrary(uint32 _eid, address _newLib) external;

    function defaultSendLibrary(uint32 _eid) external view returns (address);

    function setDefaultReceiveLibrary(uint32 _eid, address _newLib, uint256 _timeout) external;

    function defaultReceiveLibrary(uint32 _eid) external view returns (address);

    function setDefaultReceiveLibraryTimeout(uint32 _eid, address _lib, uint256 _expiry) external;

    function defaultReceiveLibraryTimeout(uint32 _eid) external view returns (address lib, uint256 expiry);

    function isSupportedEid(uint32 _eid) external view returns (bool);

    /// ------------------- OApp interfaces -------------------
    function setSendLibrary(address _oapp, uint32 _eid, address _newLib) external;

    function getSendLibrary(address _sender, uint32 _eid) external view returns (address lib);

    function isDefaultSendLibrary(address _sender, uint32 _eid) external view returns (bool);

    function setReceiveLibrary(address _oapp, uint32 _eid, address _newLib, uint256 _gracePeriod) external;

    function getReceiveLibrary(address _receiver, uint32 _eid) external view returns (address lib, bool isDefault);

    function setReceiveLibraryTimeout(address _oapp, uint32 _eid, address _lib, uint256 _gracePeriod) external;

    function receiveLibraryTimeout(address _receiver, uint32 _eid) external view returns (address lib, uint256 expiry);

    function setConfig(address _oapp, address _lib, SetConfigParam[] calldata _params) external;

    function getConfig(
        address _oapp,
        address _lib,
        uint32 _eid,
        uint32 _configType
    ) external view returns (bytes memory config);
}

// node_modules/@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/IMessagingChannel.sol

interface IMessagingChannel {
    event InboundNonceSkipped(uint32 srcEid, bytes32 sender, address receiver, uint64 nonce);
    event PacketNilified(uint32 srcEid, bytes32 sender, address receiver, uint64 nonce, bytes32 payloadHash);
    event PacketBurnt(uint32 srcEid, bytes32 sender, address receiver, uint64 nonce, bytes32 payloadHash);

    function eid() external view returns (uint32);

    // this is an emergency function if a message cannot be verified for some reasons
    // required to provide _nextNonce to avoid race condition
    function skip(address _oapp, uint32 _srcEid, bytes32 _sender, uint64 _nonce) external;

    function nilify(address _oapp, uint32 _srcEid, bytes32 _sender, uint64 _nonce, bytes32 _payloadHash) external;

    function burn(address _oapp, uint32 _srcEid, bytes32 _sender, uint64 _nonce, bytes32 _payloadHash) external;

    function nextGuid(address _sender, uint32 _dstEid, bytes32 _receiver) external view returns (bytes32);

    function inboundNonce(address _receiver, uint32 _srcEid, bytes32 _sender) external view returns (uint64);

    function outboundNonce(address _sender, uint32 _dstEid, bytes32 _receiver) external view returns (uint64);

    function inboundPayloadHash(
        address _receiver,
        uint32 _srcEid,
        bytes32 _sender,
        uint64 _nonce
    ) external view returns (bytes32);
}

// node_modules/@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/IMessagingComposer.sol

interface IMessagingComposer {
    event ComposeSent(address from, address to, bytes32 guid, uint16 index, bytes message);
    event ComposeDelivered(address from, address to, bytes32 guid, uint16 index);
    event LzComposeAlert(
        address indexed from,
        address indexed to,
        address indexed executor,
        bytes32 guid,
        uint16 index,
        uint256 gas,
        uint256 value,
        bytes message,
        bytes extraData,
        bytes reason
    );

    function composeQueue(
        address _from,
        address _to,
        bytes32 _guid,
        uint16 _index
    ) external view returns (bytes32 messageHash);

    function sendCompose(address _to, bytes32 _guid, uint16 _index, bytes calldata _message) external;

    function lzCompose(
        address _from,
        address _to,
        bytes32 _guid,
        uint16 _index,
        bytes calldata _message,
        bytes calldata _extraData
    ) external payable;
}

// node_modules/@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/IMessagingContext.sol

interface IMessagingContext {
    function isSendingMessage() external view returns (bool);

    function getSendContext() external view returns (uint32 dstEid, address sender);
}

// node_modules/@layerzerolabs/lz-evm-protocol-v2/contracts/libs/CalldataBytesLib.sol

library CalldataBytesLib {
    function toU8(bytes calldata _bytes, uint256 _start) internal pure returns (uint8) {
        return uint8(_bytes[_start]);
    }

    function toU16(bytes calldata _bytes, uint256 _start) internal pure returns (uint16) {
        unchecked {
            uint256 end = _start + 2;
            return uint16(bytes2(_bytes[_start:end]));
        }
    }

    function toU32(bytes calldata _bytes, uint256 _start) internal pure returns (uint32) {
        unchecked {
            uint256 end = _start + 4;
            return uint32(bytes4(_bytes[_start:end]));
        }
    }

    function toU64(bytes calldata _bytes, uint256 _start) internal pure returns (uint64) {
        unchecked {
            uint256 end = _start + 8;
            return uint64(bytes8(_bytes[_start:end]));
        }
    }

    function toU128(bytes calldata _bytes, uint256 _start) internal pure returns (uint128) {
        unchecked {
            uint256 end = _start + 16;
            return uint128(bytes16(_bytes[_start:end]));
        }
    }

    function toU256(bytes calldata _bytes, uint256 _start) internal pure returns (uint256) {
        unchecked {
            uint256 end = _start + 32;
            return uint256(bytes32(_bytes[_start:end]));
        }
    }

    function toAddr(bytes calldata _bytes, uint256 _start) internal pure returns (address) {
        unchecked {
            uint256 end = _start + 20;
            return address(bytes20(_bytes[_start:end]));
        }
    }

    function toB32(bytes calldata _bytes, uint256 _start) internal pure returns (bytes32) {
        unchecked {
            uint256 end = _start + 32;
            return bytes32(_bytes[_start:end]);
        }
    }
}

// node_modules/@layerzerolabs/lz-evm-protocol-v2/contracts/libs/Errors.sol

library Errors {
    error LzTokenUnavailable();
    error OnlyAltToken();
    error InvalidReceiveLibrary();
    error InvalidNonce(uint64 nonce);
    error InvalidArgument();
    error InvalidExpiry();
    error InvalidAmount(uint256 required, uint256 supplied);
    error OnlyRegisteredOrDefaultLib();
    error OnlyRegisteredLib();
    error OnlyNonDefaultLib();
    error Unauthorized();
    error DefaultSendLibUnavailable();
    error DefaultReceiveLibUnavailable();
    error PathNotInitializable();
    error PathNotVerifiable();
    error OnlySendLib();
    error OnlyReceiveLib();
    error UnsupportedEid();
    error UnsupportedInterface();
    error AlreadyRegistered();
    error SameValue();
    error InvalidPayloadHash();
    error PayloadHashNotFound(bytes32 expected, bytes32 actual);
    error ComposeNotFound(bytes32 expected, bytes32 actual);
    error ComposeExists();
    error SendReentrancy();
    error NotImplemented();
    error InvalidAddress();
    error InvalidSizeForAddress();
    error InsufficientFee(
        uint256 requiredNative,
        uint256 suppliedNative,
        uint256 requiredLzToken,
        uint256 suppliedLzToken
    );
    error ZeroLzTokenFee();
}

// node_modules/@layerzerolabs/lz-evm-protocol-v2/contracts/messagelib/libs/BitMaps.sol

// modified from https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/structs/BitMaps.sol

type BitMap256 is uint256;

using BitMaps for BitMap256 global;

library BitMaps {
    /**
     * @dev Returns whether the bit at `index` is set.
     */
    function get(BitMap256 bitmap, uint8 index) internal pure returns (bool) {
        uint256 mask = 1 << index;
        return BitMap256.unwrap(bitmap) & mask != 0;
    }

    /**
     * @dev Sets the bit at `index`.
     */
    function set(BitMap256 bitmap, uint8 index) internal pure returns (BitMap256) {
        uint256 mask = 1 << index;
        return BitMap256.wrap(BitMap256.unwrap(bitmap) | mask);
    }
}

// node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol

// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

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
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
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
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

// node_modules/@openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol

// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/extensions/IERC20Permit.sol)

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
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

// OpenZeppelin Contracts (last updated v4.9.0) (utils/Address.sol)

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     *
     * Furthermore, `isContract` will also return true if the target contract within
     * the same transaction is already scheduled for destruction by `SELFDESTRUCT`,
     * which only has an effect at the end of a transaction.
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

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
     * https://solidity.readthedocs.io/en/v0.8.0/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}

// node_modules/@openzeppelin/contracts/utils/Context.sol

// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

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
}

// node_modules/@openzeppelin/contracts/utils/introspection/IERC165.sol

// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

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

// node_modules/@openzeppelin/contracts/utils/math/SafeCast.sol

// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/SafeCast.sol)
// This file was procedurally generated from scripts/generate/templates/SafeCast.js.

/**
 * @dev Wrappers over Solidity's uintXX/intXX casting operators with added overflow
 * checks.
 *
 * Downcasting from uint256/int256 in Solidity does not revert on overflow. This can
 * easily result in undesired exploitation or bugs, since developers usually
 * assume that overflows raise errors. `SafeCast` restores this intuition by
 * reverting the transaction when such an operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 *
 * Can be combined with {SafeMath} and {SignedSafeMath} to extend it to smaller types, by performing
 * all math on `uint256` and `int256` and then downcasting.
 */
library SafeCast {
    /**
     * @dev Returns the downcasted uint248 from uint256, reverting on
     * overflow (when the input is greater than largest uint248).
     *
     * Counterpart to Solidity's `uint248` operator.
     *
     * Requirements:
     *
     * - input must fit into 248 bits
     *
     * _Available since v4.7._
     */
    function toUint248(uint256 value) internal pure returns (uint248) {
        require(value <= type(uint248).max, "SafeCast: value doesn't fit in 248 bits");
        return uint248(value);
    }

    /**
     * @dev Returns the downcasted uint240 from uint256, reverting on
     * overflow (when the input is greater than largest uint240).
     *
     * Counterpart to Solidity's `uint240` operator.
     *
     * Requirements:
     *
     * - input must fit into 240 bits
     *
     * _Available since v4.7._
     */
    function toUint240(uint256 value) internal pure returns (uint240) {
        require(value <= type(uint240).max, "SafeCast: value doesn't fit in 240 bits");
        return uint240(value);
    }

    /**
     * @dev Returns the downcasted uint232 from uint256, reverting on
     * overflow (when the input is greater than largest uint232).
     *
     * Counterpart to Solidity's `uint232` operator.
     *
     * Requirements:
     *
     * - input must fit into 232 bits
     *
     * _Available since v4.7._
     */
    function toUint232(uint256 value) internal pure returns (uint232) {
        require(value <= type(uint232).max, "SafeCast: value doesn't fit in 232 bits");
        return uint232(value);
    }

    /**
     * @dev Returns the downcasted uint224 from uint256, reverting on
     * overflow (when the input is greater than largest uint224).
     *
     * Counterpart to Solidity's `uint224` operator.
     *
     * Requirements:
     *
     * - input must fit into 224 bits
     *
     * _Available since v4.2._
     */
    function toUint224(uint256 value) internal pure returns (uint224) {
        require(value <= type(uint224).max, "SafeCast: value doesn't fit in 224 bits");
        return uint224(value);
    }

    /**
     * @dev Returns the downcasted uint216 from uint256, reverting on
     * overflow (when the input is greater than largest uint216).
     *
     * Counterpart to Solidity's `uint216` operator.
     *
     * Requirements:
     *
     * - input must fit into 216 bits
     *
     * _Available since v4.7._
     */
    function toUint216(uint256 value) internal pure returns (uint216) {
        require(value <= type(uint216).max, "SafeCast: value doesn't fit in 216 bits");
        return uint216(value);
    }

    /**
     * @dev Returns the downcasted uint208 from uint256, reverting on
     * overflow (when the input is greater than largest uint208).
     *
     * Counterpart to Solidity's `uint208` operator.
     *
     * Requirements:
     *
     * - input must fit into 208 bits
     *
     * _Available since v4.7._
     */
    function toUint208(uint256 value) internal pure returns (uint208) {
        require(value <= type(uint208).max, "SafeCast: value doesn't fit in 208 bits");
        return uint208(value);
    }

    /**
     * @dev Returns the downcasted uint200 from uint256, reverting on
     * overflow (when the input is greater than largest uint200).
     *
     * Counterpart to Solidity's `uint200` operator.
     *
     * Requirements:
     *
     * - input must fit into 200 bits
     *
     * _Available since v4.7._
     */
    function toUint200(uint256 value) internal pure returns (uint200) {
        require(value <= type(uint200).max, "SafeCast: value doesn't fit in 200 bits");
        return uint200(value);
    }

    /**
     * @dev Returns the downcasted uint192 from uint256, reverting on
     * overflow (when the input is greater than largest uint192).
     *
     * Counterpart to Solidity's `uint192` operator.
     *
     * Requirements:
     *
     * - input must fit into 192 bits
     *
     * _Available since v4.7._
     */
    function toUint192(uint256 value) internal pure returns (uint192) {
        require(value <= type(uint192).max, "SafeCast: value doesn't fit in 192 bits");
        return uint192(value);
    }

    /**
     * @dev Returns the downcasted uint184 from uint256, reverting on
     * overflow (when the input is greater than largest uint184).
     *
     * Counterpart to Solidity's `uint184` operator.
     *
     * Requirements:
     *
     * - input must fit into 184 bits
     *
     * _Available since v4.7._
     */
    function toUint184(uint256 value) internal pure returns (uint184) {
        require(value <= type(uint184).max, "SafeCast: value doesn't fit in 184 bits");
        return uint184(value);
    }

    /**
     * @dev Returns the downcasted uint176 from uint256, reverting on
     * overflow (when the input is greater than largest uint176).
     *
     * Counterpart to Solidity's `uint176` operator.
     *
     * Requirements:
     *
     * - input must fit into 176 bits
     *
     * _Available since v4.7._
     */
    function toUint176(uint256 value) internal pure returns (uint176) {
        require(value <= type(uint176).max, "SafeCast: value doesn't fit in 176 bits");
        return uint176(value);
    }

    /**
     * @dev Returns the downcasted uint168 from uint256, reverting on
     * overflow (when the input is greater than largest uint168).
     *
     * Counterpart to Solidity's `uint168` operator.
     *
     * Requirements:
     *
     * - input must fit into 168 bits
     *
     * _Available since v4.7._
     */
    function toUint168(uint256 value) internal pure returns (uint168) {
        require(value <= type(uint168).max, "SafeCast: value doesn't fit in 168 bits");
        return uint168(value);
    }

    /**
     * @dev Returns the downcasted uint160 from uint256, reverting on
     * overflow (when the input is greater than largest uint160).
     *
     * Counterpart to Solidity's `uint160` operator.
     *
     * Requirements:
     *
     * - input must fit into 160 bits
     *
     * _Available since v4.7._
     */
    function toUint160(uint256 value) internal pure returns (uint160) {
        require(value <= type(uint160).max, "SafeCast: value doesn't fit in 160 bits");
        return uint160(value);
    }

    /**
     * @dev Returns the downcasted uint152 from uint256, reverting on
     * overflow (when the input is greater than largest uint152).
     *
     * Counterpart to Solidity's `uint152` operator.
     *
     * Requirements:
     *
     * - input must fit into 152 bits
     *
     * _Available since v4.7._
     */
    function toUint152(uint256 value) internal pure returns (uint152) {
        require(value <= type(uint152).max, "SafeCast: value doesn't fit in 152 bits");
        return uint152(value);
    }

    /**
     * @dev Returns the downcasted uint144 from uint256, reverting on
     * overflow (when the input is greater than largest uint144).
     *
     * Counterpart to Solidity's `uint144` operator.
     *
     * Requirements:
     *
     * - input must fit into 144 bits
     *
     * _Available since v4.7._
     */
    function toUint144(uint256 value) internal pure returns (uint144) {
        require(value <= type(uint144).max, "SafeCast: value doesn't fit in 144 bits");
        return uint144(value);
    }

    /**
     * @dev Returns the downcasted uint136 from uint256, reverting on
     * overflow (when the input is greater than largest uint136).
     *
     * Counterpart to Solidity's `uint136` operator.
     *
     * Requirements:
     *
     * - input must fit into 136 bits
     *
     * _Available since v4.7._
     */
    function toUint136(uint256 value) internal pure returns (uint136) {
        require(value <= type(uint136).max, "SafeCast: value doesn't fit in 136 bits");
        return uint136(value);
    }

    /**
     * @dev Returns the downcasted uint128 from uint256, reverting on
     * overflow (when the input is greater than largest uint128).
     *
     * Counterpart to Solidity's `uint128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     *
     * _Available since v2.5._
     */
    function toUint128(uint256 value) internal pure returns (uint128) {
        require(value <= type(uint128).max, "SafeCast: value doesn't fit in 128 bits");
        return uint128(value);
    }

    /**
     * @dev Returns the downcasted uint120 from uint256, reverting on
     * overflow (when the input is greater than largest uint120).
     *
     * Counterpart to Solidity's `uint120` operator.
     *
     * Requirements:
     *
     * - input must fit into 120 bits
     *
     * _Available since v4.7._
     */
    function toUint120(uint256 value) internal pure returns (uint120) {
        require(value <= type(uint120).max, "SafeCast: value doesn't fit in 120 bits");
        return uint120(value);
    }

    /**
     * @dev Returns the downcasted uint112 from uint256, reverting on
     * overflow (when the input is greater than largest uint112).
     *
     * Counterpart to Solidity's `uint112` operator.
     *
     * Requirements:
     *
     * - input must fit into 112 bits
     *
     * _Available since v4.7._
     */
    function toUint112(uint256 value) internal pure returns (uint112) {
        require(value <= type(uint112).max, "SafeCast: value doesn't fit in 112 bits");
        return uint112(value);
    }

    /**
     * @dev Returns the downcasted uint104 from uint256, reverting on
     * overflow (when the input is greater than largest uint104).
     *
     * Counterpart to Solidity's `uint104` operator.
     *
     * Requirements:
     *
     * - input must fit into 104 bits
     *
     * _Available since v4.7._
     */
    function toUint104(uint256 value) internal pure returns (uint104) {
        require(value <= type(uint104).max, "SafeCast: value doesn't fit in 104 bits");
        return uint104(value);
    }

    /**
     * @dev Returns the downcasted uint96 from uint256, reverting on
     * overflow (when the input is greater than largest uint96).
     *
     * Counterpart to Solidity's `uint96` operator.
     *
     * Requirements:
     *
     * - input must fit into 96 bits
     *
     * _Available since v4.2._
     */
    function toUint96(uint256 value) internal pure returns (uint96) {
        require(value <= type(uint96).max, "SafeCast: value doesn't fit in 96 bits");
        return uint96(value);
    }

    /**
     * @dev Returns the downcasted uint88 from uint256, reverting on
     * overflow (when the input is greater than largest uint88).
     *
     * Counterpart to Solidity's `uint88` operator.
     *
     * Requirements:
     *
     * - input must fit into 88 bits
     *
     * _Available since v4.7._
     */
    function toUint88(uint256 value) internal pure returns (uint88) {
        require(value <= type(uint88).max, "SafeCast: value doesn't fit in 88 bits");
        return uint88(value);
    }

    /**
     * @dev Returns the downcasted uint80 from uint256, reverting on
     * overflow (when the input is greater than largest uint80).
     *
     * Counterpart to Solidity's `uint80` operator.
     *
     * Requirements:
     *
     * - input must fit into 80 bits
     *
     * _Available since v4.7._
     */
    function toUint80(uint256 value) internal pure returns (uint80) {
        require(value <= type(uint80).max, "SafeCast: value doesn't fit in 80 bits");
        return uint80(value);
    }

    /**
     * @dev Returns the downcasted uint72 from uint256, reverting on
     * overflow (when the input is greater than largest uint72).
     *
     * Counterpart to Solidity's `uint72` operator.
     *
     * Requirements:
     *
     * - input must fit into 72 bits
     *
     * _Available since v4.7._
     */
    function toUint72(uint256 value) internal pure returns (uint72) {
        require(value <= type(uint72).max, "SafeCast: value doesn't fit in 72 bits");
        return uint72(value);
    }

    /**
     * @dev Returns the downcasted uint64 from uint256, reverting on
     * overflow (when the input is greater than largest uint64).
     *
     * Counterpart to Solidity's `uint64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     *
     * _Available since v2.5._
     */
    function toUint64(uint256 value) internal pure returns (uint64) {
        require(value <= type(uint64).max, "SafeCast: value doesn't fit in 64 bits");
        return uint64(value);
    }

    /**
     * @dev Returns the downcasted uint56 from uint256, reverting on
     * overflow (when the input is greater than largest uint56).
     *
     * Counterpart to Solidity's `uint56` operator.
     *
     * Requirements:
     *
     * - input must fit into 56 bits
     *
     * _Available since v4.7._
     */
    function toUint56(uint256 value) internal pure returns (uint56) {
        require(value <= type(uint56).max, "SafeCast: value doesn't fit in 56 bits");
        return uint56(value);
    }

    /**
     * @dev Returns the downcasted uint48 from uint256, reverting on
     * overflow (when the input is greater than largest uint48).
     *
     * Counterpart to Solidity's `uint48` operator.
     *
     * Requirements:
     *
     * - input must fit into 48 bits
     *
     * _Available since v4.7._
     */
    function toUint48(uint256 value) internal pure returns (uint48) {
        require(value <= type(uint48).max, "SafeCast: value doesn't fit in 48 bits");
        return uint48(value);
    }

    /**
     * @dev Returns the downcasted uint40 from uint256, reverting on
     * overflow (when the input is greater than largest uint40).
     *
     * Counterpart to Solidity's `uint40` operator.
     *
     * Requirements:
     *
     * - input must fit into 40 bits
     *
     * _Available since v4.7._
     */
    function toUint40(uint256 value) internal pure returns (uint40) {
        require(value <= type(uint40).max, "SafeCast: value doesn't fit in 40 bits");
        return uint40(value);
    }

    /**
     * @dev Returns the downcasted uint32 from uint256, reverting on
     * overflow (when the input is greater than largest uint32).
     *
     * Counterpart to Solidity's `uint32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     *
     * _Available since v2.5._
     */
    function toUint32(uint256 value) internal pure returns (uint32) {
        require(value <= type(uint32).max, "SafeCast: value doesn't fit in 32 bits");
        return uint32(value);
    }

    /**
     * @dev Returns the downcasted uint24 from uint256, reverting on
     * overflow (when the input is greater than largest uint24).
     *
     * Counterpart to Solidity's `uint24` operator.
     *
     * Requirements:
     *
     * - input must fit into 24 bits
     *
     * _Available since v4.7._
     */
    function toUint24(uint256 value) internal pure returns (uint24) {
        require(value <= type(uint24).max, "SafeCast: value doesn't fit in 24 bits");
        return uint24(value);
    }

    /**
     * @dev Returns the downcasted uint16 from uint256, reverting on
     * overflow (when the input is greater than largest uint16).
     *
     * Counterpart to Solidity's `uint16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     *
     * _Available since v2.5._
     */
    function toUint16(uint256 value) internal pure returns (uint16) {
        require(value <= type(uint16).max, "SafeCast: value doesn't fit in 16 bits");
        return uint16(value);
    }

    /**
     * @dev Returns the downcasted uint8 from uint256, reverting on
     * overflow (when the input is greater than largest uint8).
     *
     * Counterpart to Solidity's `uint8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits
     *
     * _Available since v2.5._
     */
    function toUint8(uint256 value) internal pure returns (uint8) {
        require(value <= type(uint8).max, "SafeCast: value doesn't fit in 8 bits");
        return uint8(value);
    }

    /**
     * @dev Converts a signed int256 into an unsigned uint256.
     *
     * Requirements:
     *
     * - input must be greater than or equal to 0.
     *
     * _Available since v3.0._
     */
    function toUint256(int256 value) internal pure returns (uint256) {
        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }

    /**
     * @dev Returns the downcasted int248 from int256, reverting on
     * overflow (when the input is less than smallest int248 or
     * greater than largest int248).
     *
     * Counterpart to Solidity's `int248` operator.
     *
     * Requirements:
     *
     * - input must fit into 248 bits
     *
     * _Available since v4.7._
     */
    function toInt248(int256 value) internal pure returns (int248 downcasted) {
        downcasted = int248(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 248 bits");
    }

    /**
     * @dev Returns the downcasted int240 from int256, reverting on
     * overflow (when the input is less than smallest int240 or
     * greater than largest int240).
     *
     * Counterpart to Solidity's `int240` operator.
     *
     * Requirements:
     *
     * - input must fit into 240 bits
     *
     * _Available since v4.7._
     */
    function toInt240(int256 value) internal pure returns (int240 downcasted) {
        downcasted = int240(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 240 bits");
    }

    /**
     * @dev Returns the downcasted int232 from int256, reverting on
     * overflow (when the input is less than smallest int232 or
     * greater than largest int232).
     *
     * Counterpart to Solidity's `int232` operator.
     *
     * Requirements:
     *
     * - input must fit into 232 bits
     *
     * _Available since v4.7._
     */
    function toInt232(int256 value) internal pure returns (int232 downcasted) {
        downcasted = int232(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 232 bits");
    }

    /**
     * @dev Returns the downcasted int224 from int256, reverting on
     * overflow (when the input is less than smallest int224 or
     * greater than largest int224).
     *
     * Counterpart to Solidity's `int224` operator.
     *
     * Requirements:
     *
     * - input must fit into 224 bits
     *
     * _Available since v4.7._
     */
    function toInt224(int256 value) internal pure returns (int224 downcasted) {
        downcasted = int224(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 224 bits");
    }

    /**
     * @dev Returns the downcasted int216 from int256, reverting on
     * overflow (when the input is less than smallest int216 or
     * greater than largest int216).
     *
     * Counterpart to Solidity's `int216` operator.
     *
     * Requirements:
     *
     * - input must fit into 216 bits
     *
     * _Available since v4.7._
     */
    function toInt216(int256 value) internal pure returns (int216 downcasted) {
        downcasted = int216(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 216 bits");
    }

    /**
     * @dev Returns the downcasted int208 from int256, reverting on
     * overflow (when the input is less than smallest int208 or
     * greater than largest int208).
     *
     * Counterpart to Solidity's `int208` operator.
     *
     * Requirements:
     *
     * - input must fit into 208 bits
     *
     * _Available since v4.7._
     */
    function toInt208(int256 value) internal pure returns (int208 downcasted) {
        downcasted = int208(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 208 bits");
    }

    /**
     * @dev Returns the downcasted int200 from int256, reverting on
     * overflow (when the input is less than smallest int200 or
     * greater than largest int200).
     *
     * Counterpart to Solidity's `int200` operator.
     *
     * Requirements:
     *
     * - input must fit into 200 bits
     *
     * _Available since v4.7._
     */
    function toInt200(int256 value) internal pure returns (int200 downcasted) {
        downcasted = int200(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 200 bits");
    }

    /**
     * @dev Returns the downcasted int192 from int256, reverting on
     * overflow (when the input is less than smallest int192 or
     * greater than largest int192).
     *
     * Counterpart to Solidity's `int192` operator.
     *
     * Requirements:
     *
     * - input must fit into 192 bits
     *
     * _Available since v4.7._
     */
    function toInt192(int256 value) internal pure returns (int192 downcasted) {
        downcasted = int192(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 192 bits");
    }

    /**
     * @dev Returns the downcasted int184 from int256, reverting on
     * overflow (when the input is less than smallest int184 or
     * greater than largest int184).
     *
     * Counterpart to Solidity's `int184` operator.
     *
     * Requirements:
     *
     * - input must fit into 184 bits
     *
     * _Available since v4.7._
     */
    function toInt184(int256 value) internal pure returns (int184 downcasted) {
        downcasted = int184(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 184 bits");
    }

    /**
     * @dev Returns the downcasted int176 from int256, reverting on
     * overflow (when the input is less than smallest int176 or
     * greater than largest int176).
     *
     * Counterpart to Solidity's `int176` operator.
     *
     * Requirements:
     *
     * - input must fit into 176 bits
     *
     * _Available since v4.7._
     */
    function toInt176(int256 value) internal pure returns (int176 downcasted) {
        downcasted = int176(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 176 bits");
    }

    /**
     * @dev Returns the downcasted int168 from int256, reverting on
     * overflow (when the input is less than smallest int168 or
     * greater than largest int168).
     *
     * Counterpart to Solidity's `int168` operator.
     *
     * Requirements:
     *
     * - input must fit into 168 bits
     *
     * _Available since v4.7._
     */
    function toInt168(int256 value) internal pure returns (int168 downcasted) {
        downcasted = int168(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 168 bits");
    }

    /**
     * @dev Returns the downcasted int160 from int256, reverting on
     * overflow (when the input is less than smallest int160 or
     * greater than largest int160).
     *
     * Counterpart to Solidity's `int160` operator.
     *
     * Requirements:
     *
     * - input must fit into 160 bits
     *
     * _Available since v4.7._
     */
    function toInt160(int256 value) internal pure returns (int160 downcasted) {
        downcasted = int160(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 160 bits");
    }

    /**
     * @dev Returns the downcasted int152 from int256, reverting on
     * overflow (when the input is less than smallest int152 or
     * greater than largest int152).
     *
     * Counterpart to Solidity's `int152` operator.
     *
     * Requirements:
     *
     * - input must fit into 152 bits
     *
     * _Available since v4.7._
     */
    function toInt152(int256 value) internal pure returns (int152 downcasted) {
        downcasted = int152(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 152 bits");
    }

    /**
     * @dev Returns the downcasted int144 from int256, reverting on
     * overflow (when the input is less than smallest int144 or
     * greater than largest int144).
     *
     * Counterpart to Solidity's `int144` operator.
     *
     * Requirements:
     *
     * - input must fit into 144 bits
     *
     * _Available since v4.7._
     */
    function toInt144(int256 value) internal pure returns (int144 downcasted) {
        downcasted = int144(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 144 bits");
    }

    /**
     * @dev Returns the downcasted int136 from int256, reverting on
     * overflow (when the input is less than smallest int136 or
     * greater than largest int136).
     *
     * Counterpart to Solidity's `int136` operator.
     *
     * Requirements:
     *
     * - input must fit into 136 bits
     *
     * _Available since v4.7._
     */
    function toInt136(int256 value) internal pure returns (int136 downcasted) {
        downcasted = int136(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 136 bits");
    }

    /**
     * @dev Returns the downcasted int128 from int256, reverting on
     * overflow (when the input is less than smallest int128 or
     * greater than largest int128).
     *
     * Counterpart to Solidity's `int128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     *
     * _Available since v3.1._
     */
    function toInt128(int256 value) internal pure returns (int128 downcasted) {
        downcasted = int128(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 128 bits");
    }

    /**
     * @dev Returns the downcasted int120 from int256, reverting on
     * overflow (when the input is less than smallest int120 or
     * greater than largest int120).
     *
     * Counterpart to Solidity's `int120` operator.
     *
     * Requirements:
     *
     * - input must fit into 120 bits
     *
     * _Available since v4.7._
     */
    function toInt120(int256 value) internal pure returns (int120 downcasted) {
        downcasted = int120(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 120 bits");
    }

    /**
     * @dev Returns the downcasted int112 from int256, reverting on
     * overflow (when the input is less than smallest int112 or
     * greater than largest int112).
     *
     * Counterpart to Solidity's `int112` operator.
     *
     * Requirements:
     *
     * - input must fit into 112 bits
     *
     * _Available since v4.7._
     */
    function toInt112(int256 value) internal pure returns (int112 downcasted) {
        downcasted = int112(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 112 bits");
    }

    /**
     * @dev Returns the downcasted int104 from int256, reverting on
     * overflow (when the input is less than smallest int104 or
     * greater than largest int104).
     *
     * Counterpart to Solidity's `int104` operator.
     *
     * Requirements:
     *
     * - input must fit into 104 bits
     *
     * _Available since v4.7._
     */
    function toInt104(int256 value) internal pure returns (int104 downcasted) {
        downcasted = int104(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 104 bits");
    }

    /**
     * @dev Returns the downcasted int96 from int256, reverting on
     * overflow (when the input is less than smallest int96 or
     * greater than largest int96).
     *
     * Counterpart to Solidity's `int96` operator.
     *
     * Requirements:
     *
     * - input must fit into 96 bits
     *
     * _Available since v4.7._
     */
    function toInt96(int256 value) internal pure returns (int96 downcasted) {
        downcasted = int96(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 96 bits");
    }

    /**
     * @dev Returns the downcasted int88 from int256, reverting on
     * overflow (when the input is less than smallest int88 or
     * greater than largest int88).
     *
     * Counterpart to Solidity's `int88` operator.
     *
     * Requirements:
     *
     * - input must fit into 88 bits
     *
     * _Available since v4.7._
     */
    function toInt88(int256 value) internal pure returns (int88 downcasted) {
        downcasted = int88(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 88 bits");
    }

    /**
     * @dev Returns the downcasted int80 from int256, reverting on
     * overflow (when the input is less than smallest int80 or
     * greater than largest int80).
     *
     * Counterpart to Solidity's `int80` operator.
     *
     * Requirements:
     *
     * - input must fit into 80 bits
     *
     * _Available since v4.7._
     */
    function toInt80(int256 value) internal pure returns (int80 downcasted) {
        downcasted = int80(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 80 bits");
    }

    /**
     * @dev Returns the downcasted int72 from int256, reverting on
     * overflow (when the input is less than smallest int72 or
     * greater than largest int72).
     *
     * Counterpart to Solidity's `int72` operator.
     *
     * Requirements:
     *
     * - input must fit into 72 bits
     *
     * _Available since v4.7._
     */
    function toInt72(int256 value) internal pure returns (int72 downcasted) {
        downcasted = int72(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 72 bits");
    }

    /**
     * @dev Returns the downcasted int64 from int256, reverting on
     * overflow (when the input is less than smallest int64 or
     * greater than largest int64).
     *
     * Counterpart to Solidity's `int64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     *
     * _Available since v3.1._
     */
    function toInt64(int256 value) internal pure returns (int64 downcasted) {
        downcasted = int64(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 64 bits");
    }

    /**
     * @dev Returns the downcasted int56 from int256, reverting on
     * overflow (when the input is less than smallest int56 or
     * greater than largest int56).
     *
     * Counterpart to Solidity's `int56` operator.
     *
     * Requirements:
     *
     * - input must fit into 56 bits
     *
     * _Available since v4.7._
     */
    function toInt56(int256 value) internal pure returns (int56 downcasted) {
        downcasted = int56(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 56 bits");
    }

    /**
     * @dev Returns the downcasted int48 from int256, reverting on
     * overflow (when the input is less than smallest int48 or
     * greater than largest int48).
     *
     * Counterpart to Solidity's `int48` operator.
     *
     * Requirements:
     *
     * - input must fit into 48 bits
     *
     * _Available since v4.7._
     */
    function toInt48(int256 value) internal pure returns (int48 downcasted) {
        downcasted = int48(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 48 bits");
    }

    /**
     * @dev Returns the downcasted int40 from int256, reverting on
     * overflow (when the input is less than smallest int40 or
     * greater than largest int40).
     *
     * Counterpart to Solidity's `int40` operator.
     *
     * Requirements:
     *
     * - input must fit into 40 bits
     *
     * _Available since v4.7._
     */
    function toInt40(int256 value) internal pure returns (int40 downcasted) {
        downcasted = int40(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 40 bits");
    }

    /**
     * @dev Returns the downcasted int32 from int256, reverting on
     * overflow (when the input is less than smallest int32 or
     * greater than largest int32).
     *
     * Counterpart to Solidity's `int32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     *
     * _Available since v3.1._
     */
    function toInt32(int256 value) internal pure returns (int32 downcasted) {
        downcasted = int32(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 32 bits");
    }

    /**
     * @dev Returns the downcasted int24 from int256, reverting on
     * overflow (when the input is less than smallest int24 or
     * greater than largest int24).
     *
     * Counterpart to Solidity's `int24` operator.
     *
     * Requirements:
     *
     * - input must fit into 24 bits
     *
     * _Available since v4.7._
     */
    function toInt24(int256 value) internal pure returns (int24 downcasted) {
        downcasted = int24(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 24 bits");
    }

    /**
     * @dev Returns the downcasted int16 from int256, reverting on
     * overflow (when the input is less than smallest int16 or
     * greater than largest int16).
     *
     * Counterpart to Solidity's `int16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     *
     * _Available since v3.1._
     */
    function toInt16(int256 value) internal pure returns (int16 downcasted) {
        downcasted = int16(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 16 bits");
    }

    /**
     * @dev Returns the downcasted int8 from int256, reverting on
     * overflow (when the input is less than smallest int8 or
     * greater than largest int8).
     *
     * Counterpart to Solidity's `int8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits
     *
     * _Available since v3.1._
     */
    function toInt8(int256 value) internal pure returns (int8 downcasted) {
        downcasted = int8(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 8 bits");
    }

    /**
     * @dev Converts an unsigned uint256 into a signed int256.
     *
     * Requirements:
     *
     * - input must be less than or equal to maxInt256.
     *
     * _Available since v3.0._
     */
    function toInt256(uint256 value) internal pure returns (int256) {
        // Note: Unsafe cast below is okay because `type(int256).max` is guaranteed to be positive
        require(value <= uint256(type(int256).max), "SafeCast: value doesn't fit in an int256");
        return int256(value);
    }
}

// node_modules/solidity-bytes-utils/contracts/BytesLib.sol

/*
 * @title Solidity Bytes Arrays Utils
 * @author Gonçalo Sá <goncalo.sa@consensys.net>
 *
 * @dev Bytes tightly packed arrays utility library for ethereum contracts written in Solidity.
 *      The library lets you concatenate, slice and type cast bytes arrays both in memory and storage.
 */

library BytesLib {
    function concat(
        bytes memory _preBytes,
        bytes memory _postBytes
    )
        internal
        pure
        returns (bytes memory)
    {
        bytes memory tempBytes;

        assembly {
            // Get a location of some free memory and store it in tempBytes as
            // Solidity does for memory variables.
            tempBytes := mload(0x40)

            // Store the length of the first bytes array at the beginning of
            // the memory for tempBytes.
            let length := mload(_preBytes)
            mstore(tempBytes, length)

            // Maintain a memory counter for the current write location in the
            // temp bytes array by adding the 32 bytes for the array length to
            // the starting location.
            let mc := add(tempBytes, 0x20)
            // Stop copying when the memory counter reaches the length of the
            // first bytes array.
            let end := add(mc, length)

            for {
                // Initialize a copy counter to the start of the _preBytes data,
                // 32 bytes into its memory.
                let cc := add(_preBytes, 0x20)
            } lt(mc, end) {
                // Increase both counters by 32 bytes each iteration.
                mc := add(mc, 0x20)
                cc := add(cc, 0x20)
            } {
                // Write the _preBytes data into the tempBytes memory 32 bytes
                // at a time.
                mstore(mc, mload(cc))
            }

            // Add the length of _postBytes to the current length of tempBytes
            // and store it as the new length in the first 32 bytes of the
            // tempBytes memory.
            length := mload(_postBytes)
            mstore(tempBytes, add(length, mload(tempBytes)))

            // Move the memory counter back from a multiple of 0x20 to the
            // actual end of the _preBytes data.
            mc := end
            // Stop copying when the memory counter reaches the new combined
            // length of the arrays.
            end := add(mc, length)

            for {
                let cc := add(_postBytes, 0x20)
            } lt(mc, end) {
                mc := add(mc, 0x20)
                cc := add(cc, 0x20)
            } {
                mstore(mc, mload(cc))
            }

            // Update the free-memory pointer by padding our last write location
            // to 32 bytes: add 31 bytes to the end of tempBytes to move to the
            // next 32 byte block, then round down to the nearest multiple of
            // 32. If the sum of the length of the two arrays is zero then add
            // one before rounding down to leave a blank 32 bytes (the length block with 0).
            mstore(0x40, and(
              add(add(end, iszero(add(length, mload(_preBytes)))), 31),
              not(31) // Round down to the nearest 32 bytes.
            ))
        }

        return tempBytes;
    }

    function concatStorage(bytes storage _preBytes, bytes memory _postBytes) internal {
        assembly {
            // Read the first 32 bytes of _preBytes storage, which is the length
            // of the array. (We don't need to use the offset into the slot
            // because arrays use the entire slot.)
            let fslot := sload(_preBytes.slot)
            // Arrays of 31 bytes or less have an even value in their slot,
            // while longer arrays have an odd value. The actual length is
            // the slot divided by two for odd values, and the lowest order
            // byte divided by two for even values.
            // If the slot is even, bitwise and the slot with 255 and divide by
            // two to get the length. If the slot is odd, bitwise and the slot
            // with -1 and divide by two.
            let slength := div(and(fslot, sub(mul(0x100, iszero(and(fslot, 1))), 1)), 2)
            let mlength := mload(_postBytes)
            let newlength := add(slength, mlength)
            // slength can contain both the length and contents of the array
            // if length < 32 bytes so let's prepare for that
            // v. http://solidity.readthedocs.io/en/latest/miscellaneous.html#layout-of-state-variables-in-storage
            switch add(lt(slength, 32), lt(newlength, 32))
            case 2 {
                // Since the new array still fits in the slot, we just need to
                // update the contents of the slot.
                // uint256(bytes_storage) = uint256(bytes_storage) + uint256(bytes_memory) + new_length
                sstore(
                    _preBytes.slot,
                    // all the modifications to the slot are inside this
                    // next block
                    add(
                        // we can just add to the slot contents because the
                        // bytes we want to change are the LSBs
                        fslot,
                        add(
                            mul(
                                div(
                                    // load the bytes from memory
                                    mload(add(_postBytes, 0x20)),
                                    // zero all bytes to the right
                                    exp(0x100, sub(32, mlength))
                                ),
                                // and now shift left the number of bytes to
                                // leave space for the length in the slot
                                exp(0x100, sub(32, newlength))
                            ),
                            // increase length by the double of the memory
                            // bytes length
                            mul(mlength, 2)
                        )
                    )
                )
            }
            case 1 {
                // The stored value fits in the slot, but the combined value
                // will exceed it.
                // get the keccak hash to get the contents of the array
                mstore(0x0, _preBytes.slot)
                let sc := add(keccak256(0x0, 0x20), div(slength, 32))

                // save new length
                sstore(_preBytes.slot, add(mul(newlength, 2), 1))

                // The contents of the _postBytes array start 32 bytes into
                // the structure. Our first read should obtain the `submod`
                // bytes that can fit into the unused space in the last word
                // of the stored array. To get this, we read 32 bytes starting
                // from `submod`, so the data we read overlaps with the array
                // contents by `submod` bytes. Masking the lowest-order
                // `submod` bytes allows us to add that value directly to the
                // stored value.

                let submod := sub(32, slength)
                let mc := add(_postBytes, submod)
                let end := add(_postBytes, mlength)
                let mask := sub(exp(0x100, submod), 1)

                sstore(
                    sc,
                    add(
                        and(
                            fslot,
                            0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00
                        ),
                        and(mload(mc), mask)
                    )
                )

                for {
                    mc := add(mc, 0x20)
                    sc := add(sc, 1)
                } lt(mc, end) {
                    sc := add(sc, 1)
                    mc := add(mc, 0x20)
                } {
                    sstore(sc, mload(mc))
                }

                mask := exp(0x100, sub(mc, end))

                sstore(sc, mul(div(mload(mc), mask), mask))
            }
            default {
                // get the keccak hash to get the contents of the array
                mstore(0x0, _preBytes.slot)
                // Start copying to the last used word of the stored array.
                let sc := add(keccak256(0x0, 0x20), div(slength, 32))

                // save new length
                sstore(_preBytes.slot, add(mul(newlength, 2), 1))

                // Copy over the first `submod` bytes of the new data as in
                // case 1 above.
                let slengthmod := mod(slength, 32)
                let mlengthmod := mod(mlength, 32)
                let submod := sub(32, slengthmod)
                let mc := add(_postBytes, submod)
                let end := add(_postBytes, mlength)
                let mask := sub(exp(0x100, submod), 1)

                sstore(sc, add(sload(sc), and(mload(mc), mask)))

                for {
                    sc := add(sc, 1)
                    mc := add(mc, 0x20)
                } lt(mc, end) {
                    sc := add(sc, 1)
                    mc := add(mc, 0x20)
                } {
                    sstore(sc, mload(mc))
                }

                mask := exp(0x100, sub(mc, end))

                sstore(sc, mul(div(mload(mc), mask), mask))
            }
        }
    }

    function slice(
        bytes memory _bytes,
        uint256 _start,
        uint256 _length
    )
        internal
        pure
        returns (bytes memory)
    {
        require(_length + 31 >= _length, "slice_overflow");
        require(_bytes.length >= _start + _length, "slice_outOfBounds");

        bytes memory tempBytes;

        assembly {
            switch iszero(_length)
            case 0 {
                // Get a location of some free memory and store it in tempBytes as
                // Solidity does for memory variables.
                tempBytes := mload(0x40)

                // The first word of the slice result is potentially a partial
                // word read from the original array. To read it, we calculate
                // the length of that partial word and start copying that many
                // bytes into the array. The first word we copy will start with
                // data we don't care about, but the last `lengthmod` bytes will
                // land at the beginning of the contents of the new array. When
                // we're done copying, we overwrite the full first word with
                // the actual length of the slice.
                let lengthmod := and(_length, 31)

                // The multiplication in the next line is necessary
                // because when slicing multiples of 32 bytes (lengthmod == 0)
                // the following copy loop was copying the origin's length
                // and then ending prematurely not copying everything it should.
                let mc := add(add(tempBytes, lengthmod), mul(0x20, iszero(lengthmod)))
                let end := add(mc, _length)

                for {
                    // The multiplication in the next line has the same exact purpose
                    // as the one above.
                    let cc := add(add(add(_bytes, lengthmod), mul(0x20, iszero(lengthmod))), _start)
                } lt(mc, end) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } {
                    mstore(mc, mload(cc))
                }

                mstore(tempBytes, _length)

                //update free-memory pointer
                //allocating the array padded to 32 bytes like the compiler does now
                mstore(0x40, and(add(mc, 31), not(31)))
            }
            //if we want a zero-length slice let's just return a zero-length array
            default {
                tempBytes := mload(0x40)
                //zero out the 32 bytes slice we are about to return
                //we need to do it because Solidity does not garbage collect
                mstore(tempBytes, 0)

                mstore(0x40, add(tempBytes, 0x20))
            }
        }

        return tempBytes;
    }

    function toAddress(bytes memory _bytes, uint256 _start) internal pure returns (address) {
        require(_bytes.length >= _start + 20, "toAddress_outOfBounds");
        address tempAddress;

        assembly {
            tempAddress := div(mload(add(add(_bytes, 0x20), _start)), 0x1000000000000000000000000)
        }

        return tempAddress;
    }

    function toUint8(bytes memory _bytes, uint256 _start) internal pure returns (uint8) {
        require(_bytes.length >= _start + 1 , "toUint8_outOfBounds");
        uint8 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x1), _start))
        }

        return tempUint;
    }

    function toUint16(bytes memory _bytes, uint256 _start) internal pure returns (uint16) {
        require(_bytes.length >= _start + 2, "toUint16_outOfBounds");
        uint16 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x2), _start))
        }

        return tempUint;
    }

    function toUint32(bytes memory _bytes, uint256 _start) internal pure returns (uint32) {
        require(_bytes.length >= _start + 4, "toUint32_outOfBounds");
        uint32 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x4), _start))
        }

        return tempUint;
    }

    function toUint64(bytes memory _bytes, uint256 _start) internal pure returns (uint64) {
        require(_bytes.length >= _start + 8, "toUint64_outOfBounds");
        uint64 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x8), _start))
        }

        return tempUint;
    }

    function toUint96(bytes memory _bytes, uint256 _start) internal pure returns (uint96) {
        require(_bytes.length >= _start + 12, "toUint96_outOfBounds");
        uint96 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0xc), _start))
        }

        return tempUint;
    }

    function toUint128(bytes memory _bytes, uint256 _start) internal pure returns (uint128) {
        require(_bytes.length >= _start + 16, "toUint128_outOfBounds");
        uint128 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x10), _start))
        }

        return tempUint;
    }

    function toUint256(bytes memory _bytes, uint256 _start) internal pure returns (uint256) {
        require(_bytes.length >= _start + 32, "toUint256_outOfBounds");
        uint256 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x20), _start))
        }

        return tempUint;
    }

    function toBytes32(bytes memory _bytes, uint256 _start) internal pure returns (bytes32) {
        require(_bytes.length >= _start + 32, "toBytes32_outOfBounds");
        bytes32 tempBytes32;

        assembly {
            tempBytes32 := mload(add(add(_bytes, 0x20), _start))
        }

        return tempBytes32;
    }

    function equal(bytes memory _preBytes, bytes memory _postBytes) internal pure returns (bool) {
        bool success = true;

        assembly {
            let length := mload(_preBytes)

            // if lengths don't match the arrays are not equal
            switch eq(length, mload(_postBytes))
            case 1 {
                // cb is a circuit breaker in the for loop since there's
                //  no said feature for inline assembly loops
                // cb = 1 - don't breaker
                // cb = 0 - break
                let cb := 1

                let mc := add(_preBytes, 0x20)
                let end := add(mc, length)

                for {
                    let cc := add(_postBytes, 0x20)
                // the next line is the loop condition:
                // while(uint256(mc < end) + cb == 2)
                } eq(add(lt(mc, end), cb), 2) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } {
                    // if any of these checks fails then arrays are not equal
                    if iszero(eq(mload(mc), mload(cc))) {
                        // unsuccess:
                        success := 0
                        cb := 0
                    }
                }
            }
            default {
                // unsuccess:
                success := 0
            }
        }

        return success;
    }

    function equal_nonAligned(bytes memory _preBytes, bytes memory _postBytes) internal pure returns (bool) {
        bool success = true;

        assembly {
            let length := mload(_preBytes)

            // if lengths don't match the arrays are not equal
            switch eq(length, mload(_postBytes))
            case 1 {
                // cb is a circuit breaker in the for loop since there's
                //  no said feature for inline assembly loops
                // cb = 1 - don't breaker
                // cb = 0 - break
                let cb := 1

                let endMinusWord := add(_preBytes, length)
                let mc := add(_preBytes, 0x20)
                let cc := add(_postBytes, 0x20)

                for {
                // the next line is the loop condition:
                // while(uint256(mc < endWord) + cb == 2)
                } eq(add(lt(mc, endMinusWord), cb), 2) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } {
                    // if any of these checks fails then arrays are not equal
                    if iszero(eq(mload(mc), mload(cc))) {
                        // unsuccess:
                        success := 0
                        cb := 0
                    }
                }

                // Only if still successful
                // For <1 word tail bytes
                if gt(success, 0) {
                    // Get the remainder of length/32
                    // length % 32 = AND(length, 32 - 1)
                    let numTailBytes := and(length, 0x1f)
                    let mcRem := mload(mc)
                    let ccRem := mload(cc)
                    for {
                        let i := 0
                    // the next line is the loop condition:
                    // while(uint256(i < numTailBytes) + cb == 2)
                    } eq(add(lt(i, numTailBytes), cb), 2) {
                        i := add(i, 1)
                    } {
                        if iszero(eq(byte(i, mcRem), byte(i, ccRem))) {
                            // unsuccess:
                            success := 0
                            cb := 0
                        }
                    }
                }
            }
            default {
                // unsuccess:
                success := 0
            }
        }

        return success;
    }

    function equalStorage(
        bytes storage _preBytes,
        bytes memory _postBytes
    )
        internal
        view
        returns (bool)
    {
        bool success = true;

        assembly {
            // we know _preBytes_offset is 0
            let fslot := sload(_preBytes.slot)
            // Decode the length of the stored array like in concatStorage().
            let slength := div(and(fslot, sub(mul(0x100, iszero(and(fslot, 1))), 1)), 2)
            let mlength := mload(_postBytes)

            // if lengths don't match the arrays are not equal
            switch eq(slength, mlength)
            case 1 {
                // slength can contain both the length and contents of the array
                // if length < 32 bytes so let's prepare for that
                // v. http://solidity.readthedocs.io/en/latest/miscellaneous.html#layout-of-state-variables-in-storage
                if iszero(iszero(slength)) {
                    switch lt(slength, 32)
                    case 1 {
                        // blank the last byte which is the length
                        fslot := mul(div(fslot, 0x100), 0x100)

                        if iszero(eq(fslot, mload(add(_postBytes, 0x20)))) {
                            // unsuccess:
                            success := 0
                        }
                    }
                    default {
                        // cb is a circuit breaker in the for loop since there's
                        //  no said feature for inline assembly loops
                        // cb = 1 - don't breaker
                        // cb = 0 - break
                        let cb := 1

                        // get the keccak hash to get the contents of the array
                        mstore(0x0, _preBytes.slot)
                        let sc := keccak256(0x0, 0x20)

                        let mc := add(_postBytes, 0x20)
                        let end := add(mc, mlength)

                        // the next line is the loop condition:
                        // while(uint256(mc < end) + cb == 2)
                        for {} eq(add(lt(mc, end), cb), 2) {
                            sc := add(sc, 1)
                            mc := add(mc, 0x20)
                        } {
                            if iszero(eq(sload(sc), mload(mc))) {
                                // unsuccess:
                                success := 0
                                cb := 0
                            }
                        }
                    }
                }
            }
            default {
                // unsuccess:
                success := 0
            }
        }

        return success;
    }
}

// src/interfaces/IStargateAdapter.sol

interface IStargateAdapter {
    event BridgeTokens(
        bytes32 guid,
        bytes32 intentionId,
        uint32 dstEid,
        uint32 poolId,
        address token,
        uint256 amountIn,
        uint256 lzFee
    );

    event BridgeTokensToReceiver(
        bytes32 guid,
        uint32 dstEid,
        uint32 poolId,
        uint256 amountIn,
        address receiver
    );

    event ReceivedOnDestination(
        address from,
        bytes32 guid,
        uint256 receivedAmountLD,
        address executor,
        bytes extraData,
        bytes32 intentionId
    );

    event DepositedOnDestination(bool success);

    event SetDstAdapter(uint32 dstEid, address dstAdapter);

    event SetStargate(uint32 poolId, address stargate);

    event SetVault(address token, address srcVault);

    event SetPoolId(uint32 poolId, address token);

    /// @notice sends token to StargateAdapter on destination chain
    function sendTokens(
        uint32 dstEid, // endpoint ID on destination chain
        address srcToken, // token address on source chain
        uint amountLD, // amount in in Local Decimals
        bytes32 intentionId // encoded data for the Vault on destination chain
    ) external;

    function sendTokensToReceiver(
        uint32 dstEid, // endpoint ID on destination chain
        address srcToken, // token address on source chain
        uint amountLD, // amount in in Local Decimals
        address receiver // receiver address on destination chain
    ) external;

    function depositOnDstChain(
        address _token,
        uint _amount,
        bytes32 _intentionId
    ) external returns (bool success);

    function setDstAdapter(uint32 _dstEid, address _dstAdapterAddress) external;

    function setStargate(address _stargate) external;

    function setVault(address _token, address _vault) external;

    function setPoolId(uint32 _poolId, address _token) external;

    function setLzExtraOptions(
        uint16 _index,
        uint128 _gas,
        uint128 _value
    ) external;

    function setCommander(address _commander) external;

    function isDstEidSupported(uint32 dstEid) external view returns (bool);

    function getDstAdapter(uint32 dstEid) external view returns (address);

    function getStargateByPoolId(uint32 poolId) external view returns (address);

    function getStargateByToken(address token) external view returns (address);

    function getVault(address token) external view returns (address);

    function getTokenByPoolId(uint32 poolId) external view returns (address);

    function getPoolIdByToken(address token) external view returns (uint32);

    function withdraw(address to, uint amount) external;

    function sweep(address to, address token, uint amount) external;
}

// node_modules/@layerzerolabs/lz-evm-protocol-v2/contracts/libs/AddressCast.sol

library AddressCast {
    function toBytes32(bytes calldata _addressBytes) internal pure returns (bytes32 result) {
        if (_addressBytes.length > 32) revert Errors.InvalidAddress();
        result = bytes32(_addressBytes);
        unchecked {
            uint256 offset = 32 - _addressBytes.length;
            result = result >> (offset * 8);
        }
    }

    function toBytes32(address _address) internal pure returns (bytes32 result) {
        result = bytes32(uint256(uint160(_address)));
    }

    function toBytes(bytes32 _addressBytes32, uint256 _size) internal pure returns (bytes memory result) {
        if (_size == 0 || _size > 32) revert Errors.InvalidSizeForAddress();
        result = new bytes(_size);
        unchecked {
            uint256 offset = 256 - _size * 8;
            assembly {
                mstore(add(result, 32), shl(offset, _addressBytes32))
            }
        }
    }

    function toAddress(bytes32 _addressBytes32) internal pure returns (address result) {
        result = address(uint160(uint256(_addressBytes32)));
    }

    function toAddress(bytes calldata _addressBytes) internal pure returns (address result) {
        if (_addressBytes.length != 20) revert Errors.InvalidAddress();
        result = address(bytes20(_addressBytes));
    }
}

// node_modules/@layerzerolabs/lz-evm-protocol-v2/contracts/messagelib/libs/ExecutorOptions.sol

library ExecutorOptions {
    using CalldataBytesLib for bytes;

    uint8 internal constant WORKER_ID = 1;

    uint8 internal constant OPTION_TYPE_LZRECEIVE = 1;
    uint8 internal constant OPTION_TYPE_NATIVE_DROP = 2;
    uint8 internal constant OPTION_TYPE_LZCOMPOSE = 3;
    uint8 internal constant OPTION_TYPE_ORDERED_EXECUTION = 4;

    error InvalidLzReceiveOption();
    error InvalidNativeDropOption();
    error InvalidLzComposeOption();

    /// @dev decode the next executor option from the options starting from the specified cursor
    /// @param _options [executor_id][executor_option][executor_id][executor_option]...
    ///        executor_option = [option_size][option_type][option]
    ///        option_size = len(option_type) + len(option)
    ///        executor_id: uint8, option_size: uint16, option_type: uint8, option: bytes
    /// @param _cursor the cursor to start decoding from
    /// @return optionType the type of the option
    /// @return option the option of the executor
    /// @return cursor the cursor to start decoding the next executor option
    function nextExecutorOption(
        bytes calldata _options,
        uint256 _cursor
    ) internal pure returns (uint8 optionType, bytes calldata option, uint256 cursor) {
        unchecked {
            // skip worker id
            cursor = _cursor + 1;

            // read option size
            uint16 size = _options.toU16(cursor);
            cursor += 2;

            // read option type
            optionType = _options.toU8(cursor);

            // startCursor and endCursor are used to slice the option from _options
            uint256 startCursor = cursor + 1; // skip option type
            uint256 endCursor = cursor + size;
            option = _options[startCursor:endCursor];
            cursor += size;
        }
    }

    function decodeLzReceiveOption(bytes calldata _option) internal pure returns (uint128 gas, uint128 value) {
        if (_option.length != 16 && _option.length != 32) revert InvalidLzReceiveOption();
        gas = _option.toU128(0);
        value = _option.length == 32 ? _option.toU128(16) : 0;
    }

    function decodeNativeDropOption(bytes calldata _option) internal pure returns (uint128 amount, bytes32 receiver) {
        if (_option.length != 48) revert InvalidNativeDropOption();
        amount = _option.toU128(0);
        receiver = _option.toB32(16);
    }

    function decodeLzComposeOption(
        bytes calldata _option
    ) internal pure returns (uint16 index, uint128 gas, uint128 value) {
        if (_option.length != 18 && _option.length != 34) revert InvalidLzComposeOption();
        index = _option.toU16(0);
        gas = _option.toU128(2);
        value = _option.length == 34 ? _option.toU128(18) : 0;
    }

    function encodeLzReceiveOption(uint128 _gas, uint128 _value) internal pure returns (bytes memory) {
        return _value == 0 ? abi.encodePacked(_gas) : abi.encodePacked(_gas, _value);
    }

    function encodeNativeDropOption(uint128 _amount, bytes32 _receiver) internal pure returns (bytes memory) {
        return abi.encodePacked(_amount, _receiver);
    }

    function encodeLzComposeOption(uint16 _index, uint128 _gas, uint128 _value) internal pure returns (bytes memory) {
        return _value == 0 ? abi.encodePacked(_index, _gas) : abi.encodePacked(_index, _gas, _value);
    }
}

// node_modules/@openzeppelin/contracts/access/Ownable.sol

// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
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
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
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

// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
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

// OpenZeppelin Contracts (last updated v4.9.0) (utils/introspection/ERC165Checker.sol)

/**
 * @dev Library used to query support of an interface declared via {IERC165}.
 *
 * Note that these functions return the actual result of the query: they do not
 * `revert` if an interface is not supported. It is up to the caller to decide
 * what to do in these cases.
 */
library ERC165Checker {
    // As per the EIP-165 spec, no interface should ever match 0xffffffff
    bytes4 private constant _INTERFACE_ID_INVALID = 0xffffffff;

    /**
     * @dev Returns true if `account` supports the {IERC165} interface.
     */
    function supportsERC165(address account) internal view returns (bool) {
        // Any contract that implements ERC165 must explicitly indicate support of
        // InterfaceId_ERC165 and explicitly indicate non-support of InterfaceId_Invalid
        return
            supportsERC165InterfaceUnchecked(account, type(IERC165).interfaceId) &&
            !supportsERC165InterfaceUnchecked(account, _INTERFACE_ID_INVALID);
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
     *
     * _Available since v3.4._
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
        bytes memory encodedParams = abi.encodeWithSelector(IERC165.supportsInterface.selector, interfaceId);

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

// node_modules/@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/IMessageLib.sol

enum MessageLibType {
    Send,
    Receive,
    SendAndReceive
}

interface IMessageLib is IERC165 {
    function setConfig(address _oapp, SetConfigParam[] calldata _config) external;

    function getConfig(uint32 _eid, address _oapp, uint32 _configType) external view returns (bytes memory config);

    function isSupportedEid(uint32 _eid) external view returns (bool);

    // message libs of same major version are compatible
    function version() external view returns (uint64 major, uint8 minor, uint8 endpointVersion);

    function messageLibType() external view returns (MessageLibType);
}

// dependencies/@stargatefinance-1.0.5/packages/stg-evm-v2/src/libs/Transfer.sol

/// @dev WARNING: Transferring tokens, when the token address is wrong, will fail silently.
contract Transfer is Ownable {
    error Transfer_TransferFailed();
    error Transfer_ApproveFailed();

    // @dev default this to 2300, but it is modifiable
    // @dev this is intended to provide just enough gas to receive native tokens.
    // @dev ie. empty fallbacks or EOA addresses
    uint256 internal transferGasLimit = 2300;

    function getTransferGasLimit() external view returns (uint256) {
        return transferGasLimit;
    }

    function setTransferGasLimit(uint256 _gasLimit) external onlyOwner {
        transferGasLimit = _gasLimit;
    }

    /// @notice Transfer native coin to an account
    /// @dev If gas is unlimited, we pass 63/64 of the gasleft()
    /// @dev This call may revert due to out of gas instead of returning false.
    /// @param _to The account to transfer native coin to
    /// @param _value The amount of native coin to transfer
    /// @param _gasLimited Whether to limit gas available for the 'fall-back'
    /// @return success Whether the transfer was successful
    function transferNative(address _to, uint256 _value, bool _gasLimited) internal returns (bool success) {
        uint256 gasForCall = _gasLimited ? transferGasLimit : gasleft();

        // @dev We dont care about the data returned here, only success or not.
        assembly {
            success := call(gasForCall, _to, _value, 0, 0, 0, 0)
        }
    }

    /// @notice Transfer an ERC20 token from the sender to an account
    /// @param _token The address of the ERC20 token to send
    /// @param _to The receiving account
    /// @param _value The amount of tokens to transfer
    /// @return success Whether the transfer was successful or not
    function transferToken(address _token, address _to, uint256 _value) internal returns (bool success) {
        success = _call(_token, abi.encodeWithSelector(IERC20(_token).transfer.selector, _to, _value));
    }

    /// @notice Transfer an ERC20 token from one account to another
    /// @param _token The address of the ERC20 token to send
    /// @param _from The source account
    /// @param _to The destination account
    /// @param _value The amount of tokens to transfer
    /// @return success Whether the transfer was successful or not
    function transferTokenFrom(
        address _token,
        address _from,
        address _to,
        uint256 _value
    ) internal returns (bool success) {
        success = _call(_token, abi.encodeWithSelector(IERC20(_token).transferFrom.selector, _from, _to, _value));
    }

    /// @notice Transfer either native coin or ERC20 token from the sender to an account
    /// @param _token The ERC20 address or 0x0 if native is desired
    /// @param _to The destination account
    /// @param _value the amount to transfer
    /// @param _gasLimited Whether to limit the amount of gas when doing a native transfer
    /// @return success Whether the transfer was successful or not
    function transfer(address _token, address _to, uint256 _value, bool _gasLimited) internal returns (bool success) {
        if (_token == address(0)) {
            success = transferNative(_to, _value, _gasLimited);
        } else {
            success = transferToken(_token, _to, _value);
        }
    }

    /// @notice Approve a given amount of token for an account
    /// @param _token The OFT contract to use for approval
    /// @param _spender The account to approve
    /// @param _value The amount of tokens to approve
    /// @return success Whether the approval succeeded
    function approveToken(address _token, address _spender, uint256 _value) internal returns (bool success) {
        success = _call(_token, abi.encodeWithSelector(IERC20(_token).approve.selector, _spender, _value));
    }

    /// @notice Transfer native coin to an account or revert
    /// @dev Reverts with TransferFailed if the transfer failed
    /// @param _to The account to transfer native coin to
    /// @param _value The amount of native coin to transfer
    /// @param _gasLimited Whether to limit the amount of gas to 2300
    function safeTransferNative(address _to, uint256 _value, bool _gasLimited) internal {
        if (!transferNative(_to, _value, _gasLimited)) revert Transfer_TransferFailed();
    }

    /// @notice Transfer an ERC20 token from one account to another or revert
    /// @dev Reverts with TransferFailed when the transfer fails
    /// @param _token The address of the ERC20 token to send
    /// @param _to The destination account
    /// @param _value The amount of tokens to transfer
    function safeTransferToken(address _token, address _to, uint256 _value) internal {
        if (!transferToken(_token, _to, _value)) revert Transfer_TransferFailed();
    }

    /// @notice Transfer an ERC20 token from one account to another
    /// @dev Reverts with TransferFailed when the transfer fails
    /// @param _token The address of the ERC20 token to send
    /// @param _from The source account
    /// @param _to The destination account
    /// @param _value The amount of tokens to transfer
    function safeTransferTokenFrom(address _token, address _from, address _to, uint256 _value) internal {
        if (!transferTokenFrom(_token, _from, _to, _value)) revert Transfer_TransferFailed();
    }

    /// @notice Transfer either native coin or ERC20 token from the sender to an account
    /// @dev Reverts with TransferFailed when the transfer fails
    /// @param _token The ERC20 address or 0x0 if native is desired
    /// @param _to The destination account
    /// @param _value the amount to transfer
    /// @param _gasLimited Whether to limit the amount of gas when doing a native transfer
    function safeTransfer(address _token, address _to, uint256 _value, bool _gasLimited) internal {
        if (!transfer(_token, _to, _value, _gasLimited)) revert Transfer_TransferFailed();
    }

    /// @notice Approve a given amount of token for an account or revert
    /// @dev Reverts with ApproveFailed if the approval failed
    /// @dev Consider using forceApproveToken(...) to ensure the approval is set correctly.
    /// @param _token The OFT contract to use for approval
    /// @param _spender The account to approve
    /// @param _value The amount of tokens to approve
    function safeApproveToken(address _token, address _spender, uint256 _value) internal {
        if (!approveToken(_token, _spender, _value)) revert Transfer_ApproveFailed();
    }

    /// @notice Force approve a given amount of token for an account by first resetting the approval
    /// @dev Some tokens that require the approval to be set to zero before setting it to a non-zero value, e.g. USDT.
    /// @param _token The OFT contract to use for approval
    /// @param _spender The account to approve
    /// @param _value The amount of tokens to approve
    function forceApproveToken(address _token, address _spender, uint256 _value) internal {
        if (!approveToken(_token, _spender, _value)) {
            safeApproveToken(_token, _spender, 0);
            safeApproveToken(_token, _spender, _value);
        }
    }

    function _call(address _token, bytes memory _data) private returns (bool success) {
        // solhint-disable-next-line avoid-low-level-calls
        (bool s, bytes memory returndata) = _token.call(_data);
        success = s ? returndata.length == 0 || abi.decode(returndata, (bool)) : false;
    }
}

// node_modules/@layerzerolabs/lz-evm-messagelib-v2/contracts/uln/libs/DVNOptions.sol

library DVNOptions {
    using CalldataBytesLib for bytes;
    using BytesLib for bytes;

    uint8 internal constant WORKER_ID = 2;
    uint8 internal constant OPTION_TYPE_PRECRIME = 1;

    error InvalidDVNIdx();
    error InvalidDVNOptions(uint256 cursor);

    /// @dev group dvn options by its idx
    /// @param _options [dvn_id][dvn_option][dvn_id][dvn_option]...
    ///        dvn_option = [option_size][dvn_idx][option_type][option]
    ///        option_size = len(dvn_idx) + len(option_type) + len(option)
    ///        dvn_id: uint8, dvn_idx: uint8, option_size: uint16, option_type: uint8, option: bytes
    /// @return dvnOptions the grouped options, still share the same format of _options
    /// @return dvnIndices the dvn indices
    function groupDVNOptionsByIdx(
        bytes memory _options
    ) internal pure returns (bytes[] memory dvnOptions, uint8[] memory dvnIndices) {
        if (_options.length == 0) return (dvnOptions, dvnIndices);

        uint8 numDVNs = getNumDVNs(_options);

        // if there is only 1 dvn, we can just return the whole options
        if (numDVNs == 1) {
            dvnOptions = new bytes[](1);
            dvnOptions[0] = _options;

            dvnIndices = new uint8[](1);
            dvnIndices[0] = _options.toUint8(3); // dvn idx
            return (dvnOptions, dvnIndices);
        }

        // otherwise, we need to group the options by dvn_idx
        dvnIndices = new uint8[](numDVNs);
        dvnOptions = new bytes[](numDVNs);
        unchecked {
            uint256 cursor = 0;
            uint256 start = 0;
            uint8 lastDVNIdx = 255; // 255 is an invalid dvn_idx

            while (cursor < _options.length) {
                ++cursor; // skip worker_id

                // optionLength asserted in getNumDVNs (skip check)
                uint16 optionLength = _options.toUint16(cursor);
                cursor += 2;

                // dvnIdx asserted in getNumDVNs (skip check)
                uint8 dvnIdx = _options.toUint8(cursor);

                // dvnIdx must equal to the lastDVNIdx for the first option
                // so it is always skipped in the first option
                // this operation slices out options whenever the scan finds a different lastDVNIdx
                if (lastDVNIdx == 255) {
                    lastDVNIdx = dvnIdx;
                } else if (dvnIdx != lastDVNIdx) {
                    uint256 len = cursor - start - 3; // 3 is for worker_id and option_length
                    bytes memory opt = _options.slice(start, len);
                    _insertDVNOptions(dvnOptions, dvnIndices, lastDVNIdx, opt);

                    // reset the start and lastDVNIdx
                    start += len;
                    lastDVNIdx = dvnIdx;
                }

                cursor += optionLength;
            }

            // skip check the cursor here because the cursor is asserted in getNumDVNs
            // if we have reached the end of the options, we need to process the last dvn
            uint256 size = cursor - start;
            bytes memory op = _options.slice(start, size);
            _insertDVNOptions(dvnOptions, dvnIndices, lastDVNIdx, op);

            // revert dvnIndices to start from 0
            for (uint8 i = 0; i < numDVNs; ++i) {
                --dvnIndices[i];
            }
        }
    }

    function _insertDVNOptions(
        bytes[] memory _dvnOptions,
        uint8[] memory _dvnIndices,
        uint8 _dvnIdx,
        bytes memory _newOptions
    ) internal pure {
        // dvnIdx starts from 0 but default value of dvnIndices is 0,
        // so we tell if the slot is empty by adding 1 to dvnIdx
        if (_dvnIdx == 255) revert InvalidDVNIdx();
        uint8 dvnIdxAdj = _dvnIdx + 1;

        for (uint256 j = 0; j < _dvnIndices.length; ++j) {
            uint8 index = _dvnIndices[j];
            if (dvnIdxAdj == index) {
                _dvnOptions[j] = abi.encodePacked(_dvnOptions[j], _newOptions);
                break;
            } else if (index == 0) {
                // empty slot, that means it is the first time we see this dvn
                _dvnIndices[j] = dvnIdxAdj;
                _dvnOptions[j] = _newOptions;
                break;
            }
        }
    }

    /// @dev get the number of unique dvns
    /// @param _options the format is the same as groupDVNOptionsByIdx
    function getNumDVNs(bytes memory _options) internal pure returns (uint8 numDVNs) {
        uint256 cursor = 0;
        BitMap256 bitmap;

        // find number of unique dvn_idx
        unchecked {
            while (cursor < _options.length) {
                ++cursor; // skip worker_id

                uint16 optionLength = _options.toUint16(cursor);
                cursor += 2;
                if (optionLength < 2) revert InvalidDVNOptions(cursor); // at least 1 byte for dvn_idx and 1 byte for option_type

                uint8 dvnIdx = _options.toUint8(cursor);

                // if dvnIdx is not set, increment numDVNs
                // max num of dvns is 255, 255 is an invalid dvn_idx
                // The order of the dvnIdx is not required to be sequential, as enforcing the order may weaken
                // the composability of the options. e.g. if we refrain from enforcing the order, an OApp that has
                // already enforced certain options can append additional options to the end of the enforced
                // ones without restrictions.
                if (dvnIdx == 255) revert InvalidDVNIdx();
                if (!bitmap.get(dvnIdx)) {
                    ++numDVNs;
                    bitmap = bitmap.set(dvnIdx);
                }

                cursor += optionLength;
            }
        }
        if (cursor != _options.length) revert InvalidDVNOptions(cursor);
    }

    /// @dev decode the next dvn option from _options starting from the specified cursor
    /// @param _options the format is the same as groupDVNOptionsByIdx
    /// @param _cursor the cursor to start decoding
    /// @return optionType the type of the option
    /// @return option the option
    /// @return cursor the cursor to start decoding the next option
    function nextDVNOption(
        bytes calldata _options,
        uint256 _cursor
    ) internal pure returns (uint8 optionType, bytes calldata option, uint256 cursor) {
        unchecked {
            // skip worker id
            cursor = _cursor + 1;

            // read option size
            uint16 size = _options.toU16(cursor);
            cursor += 2;

            // read option type
            optionType = _options.toU8(cursor + 1); // skip dvn_idx

            // startCursor and endCursor are used to slice the option from _options
            uint256 startCursor = cursor + 2; // skip option type and dvn_idx
            uint256 endCursor = cursor + size;
            option = _options[startCursor:endCursor];
            cursor += size;
        }
    }
}

// node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol

// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/ERC20.sol)

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
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
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

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
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
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
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
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
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
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
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}
}

// node_modules/@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol

// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/utils/SafeERC20.sol)

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
     * @dev Transfer `value` amount of `token` from the calling contract to `to`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    /**
     * @dev Transfer `value` amount of `token` from `from` to `to`, spending the approval given by `from` to the
     * calling contract. If `token` returns no value, non-reverting calls are assumed to be successful.
     */
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    /**
     * @dev Increase the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, oldAllowance + value));
    }

    /**
     * @dev Decrease the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, oldAllowance - value));
        }
    }

    /**
     * @dev Set the calling contract's allowance toward `spender` to `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful. Compatible with tokens that require the approval to be set to
     * 0 before setting it to a non-zero value.
     */
    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeWithSelector(token.approve.selector, spender, value);

        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, 0));
            _callOptionalReturn(token, approvalCall);
        }
    }

    /**
     * @dev Use a ERC-2612 signature to set the `owner` approval toward `spender` on `token`.
     * Revert on invalid signature.
     */
    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
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

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        require(returndata.length == 0 || abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
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
        return
            success && (returndata.length == 0 || abi.decode(returndata, (bool))) && Address.isContract(address(token));
    }
}

// node_modules/@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroEndpointV2.sol

struct MessagingParams {
    uint32 dstEid;
    bytes32 receiver;
    bytes message;
    bytes options;
    bool payInLzToken;
}

struct MessagingReceipt {
    bytes32 guid;
    uint64 nonce;
    MessagingFee fee;
}

struct MessagingFee {
    uint256 nativeFee;
    uint256 lzTokenFee;
}

struct Origin {
    uint32 srcEid;
    bytes32 sender;
    uint64 nonce;
}

enum ExecutionState {
    NotExecutable,
    Executable,
    Executed
}

interface ILayerZeroEndpointV2 is IMessageLibManager, IMessagingComposer, IMessagingChannel, IMessagingContext {
    event PacketSent(bytes encodedPayload, bytes options, address sendLibrary);

    event PacketVerified(Origin origin, address receiver, bytes32 payloadHash);

    event PacketDelivered(Origin origin, address receiver);

    event LzReceiveAlert(
        address indexed receiver,
        address indexed executor,
        Origin origin,
        bytes32 guid,
        uint256 gas,
        uint256 value,
        bytes message,
        bytes extraData,
        bytes reason
    );

    event LzTokenSet(address token);

    function quote(MessagingParams calldata _params, address _sender) external view returns (MessagingFee memory);

    function send(
        MessagingParams calldata _params,
        address _refundAddress
    ) external payable returns (MessagingReceipt memory);

    function verify(Origin calldata _origin, address _receiver, bytes32 _payloadHash) external;

    function verifiable(
        Origin calldata _origin,
        address _receiver,
        address _receiveLib,
        bytes32 _payloadHash
    ) external view returns (bool);

    function executable(Origin calldata _origin, address _receiver) external view returns (ExecutionState);

    function lzReceive(
        Origin calldata _origin,
        address _receiver,
        bytes32 _guid,
        bytes calldata _message,
        bytes calldata _extraData
    ) external payable;

    // oapp can burn messages partially by calling this function with its own business logic if messages are verified in order
    function clear(address _oapp, Origin calldata _origin, bytes32 _guid, bytes calldata _message) external;

    function setLzToken(address _lzToken) external;

    function lzToken() external view returns (address);

    function nativeToken() external view returns (address);

    function setDelegate(address _delegate) external;
}

// node_modules/@layerzerolabs/lz-evm-oapp-v2/contracts/oapp/interfaces/IOAppCore.sol

/**
 * @title IOAppCore
 */
interface IOAppCore {
    // Custom error messages
    error OnlyPeer(uint32 eid, bytes32 sender);
    error NoPeer(uint32 eid);
    error InvalidEndpointCall();
    error InvalidDelegate();

    // Event emitted when a peer (OApp) is set for a corresponding endpoint
    event PeerSet(uint32 eid, bytes32 peer);

    /**
     * @notice Retrieves the OApp version information.
     * @return senderVersion The version of the OAppSender.sol contract.
     * @return receiverVersion The version of the OAppReceiver.sol contract.
     */
    function oAppVersion() external view returns (uint64 senderVersion, uint64 receiverVersion);

    /**
     * @notice Retrieves the LayerZero endpoint associated with the OApp.
     * @return iEndpoint The LayerZero endpoint as an interface.
     */
    function endpoint() external view returns (ILayerZeroEndpointV2 iEndpoint);

    /**
     * @notice Retrieves the peer (OApp) associated with a corresponding endpoint.
     * @param _eid The endpoint ID.
     * @return peer The peer address (OApp instance) associated with the corresponding endpoint.
     */
    function peers(uint32 _eid) external view returns (bytes32 peer);

    /**
     * @notice Sets the peer address (OApp instance) for a corresponding endpoint.
     * @param _eid The endpoint ID.
     * @param _peer The address of the peer to be associated with the corresponding endpoint.
     */
    function setPeer(uint32 _eid, bytes32 _peer) external;

    /**
     * @notice Sets the delegate address for the OApp Core.
     * @param _delegate The address of the delegate to be set.
     */
    function setDelegate(address _delegate) external;
}

// node_modules/@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroReceiver.sol

interface ILayerZeroReceiver {
    function allowInitializePath(Origin calldata _origin) external view returns (bool);

    // todo: move to OAppReceiver? it is just convention for executor. we may can change it in a new Receiver version
    function nextNonce(uint32 _eid, bytes32 _sender) external view returns (uint64);

    function lzReceive(
        Origin calldata _origin,
        bytes32 _guid,
        bytes calldata _message,
        address _executor,
        bytes calldata _extraData
    ) external payable;
}

// node_modules/@layerzerolabs/lz-evm-oapp-v2/contracts/oapp/interfaces/IOAppReceiver.sol

interface IOAppReceiver is ILayerZeroReceiver {
    /**
     * @notice Indicates whether an address is an approved composeMsg sender to the Endpoint.
     * @param _origin The origin information containing the source endpoint and sender address.
     *  - srcEid: The source chain endpoint ID.
     *  - sender: The sender address on the src chain.
     *  - nonce: The nonce of the message.
     * @param _message The lzReceive payload.
     * @param _sender The sender address.
     * @return isSender Is a valid sender.
     *
     * @dev Applications can optionally choose to implement a separate composeMsg sender that is NOT the bridging layer.
     * @dev The default sender IS the OAppReceiver implementer.
     */
    function isComposeMsgSender(
        Origin calldata _origin,
        bytes calldata _message,
        address _sender
    ) external view returns (bool isSender);
}

// node_modules/@layerzerolabs/lz-evm-oapp-v2/contracts/oapp/libs/OptionsBuilder.sol

/**
 * @title OptionsBuilder
 * @dev Library for building and encoding various message options.
 */
library OptionsBuilder {
    using SafeCast for uint256;
    using BytesLib for bytes;

    // Constants for options types
    uint16 internal constant TYPE_1 = 1; // legacy options type 1
    uint16 internal constant TYPE_2 = 2; // legacy options type 2
    uint16 internal constant TYPE_3 = 3;

    // Custom error message
    error InvalidSize(uint256 max, uint256 actual);
    error InvalidOptionType(uint16 optionType);

    // Modifier to ensure only options of type 3 are used
    modifier onlyType3(bytes memory _options) {
        if (_options.toUint16(0) != TYPE_3) revert InvalidOptionType(_options.toUint16(0));
        _;
    }

    /**
     * @dev Creates a new options container with type 3.
     * @return options The newly created options container.
     */
    function newOptions() internal pure returns (bytes memory) {
        return abi.encodePacked(TYPE_3);
    }

    /**
     * @dev Adds an executor LZ receive option to the existing options.
     * @param _options The existing options container.
     * @param _gas The gasLimit used on the lzReceive() function in the OApp.
     * @param _value The msg.value passed to the lzReceive() function in the OApp.
     * @return options The updated options container.
     *
     * @dev When multiples of this option are added, they are summed by the executor
     * eg. if (_gas: 200k, and _value: 1 ether) AND (_gas: 100k, _value: 0.5 ether) are sent in an option to the LayerZeroEndpoint,
     * that becomes (300k, 1.5 ether) when the message is executed on the remote lzReceive() function.
     */
    function addExecutorLzReceiveOption(
        bytes memory _options,
        uint128 _gas,
        uint128 _value
    ) internal pure onlyType3(_options) returns (bytes memory) {
        bytes memory option = ExecutorOptions.encodeLzReceiveOption(_gas, _value);
        return addExecutorOption(_options, ExecutorOptions.OPTION_TYPE_LZRECEIVE, option);
    }

    /**
     * @dev Adds an executor native drop option to the existing options.
     * @param _options The existing options container.
     * @param _amount The amount for the native value that is airdropped to the 'receiver'.
     * @param _receiver The receiver address for the native drop option.
     * @return options The updated options container.
     *
     * @dev When multiples of this option are added, they are summed by the executor on the remote chain.
     */
    function addExecutorNativeDropOption(
        bytes memory _options,
        uint128 _amount,
        bytes32 _receiver
    ) internal pure onlyType3(_options) returns (bytes memory) {
        bytes memory option = ExecutorOptions.encodeNativeDropOption(_amount, _receiver);
        return addExecutorOption(_options, ExecutorOptions.OPTION_TYPE_NATIVE_DROP, option);
    }

    /**
     * @dev Adds an executor LZ compose option to the existing options.
     * @param _options The existing options container.
     * @param _index The index for the lzCompose() function call.
     * @param _gas The gasLimit for the lzCompose() function call.
     * @param _value The msg.value for the lzCompose() function call.
     * @return options The updated options container.
     *
     * @dev When multiples of this option are added, they are summed PER index by the executor on the remote chain.
     * @dev If the OApp sends N lzCompose calls on the remote, you must provide N incremented indexes starting with 0.
     * ie. When your remote OApp composes (N = 3) messages, you must set this option for index 0,1,2
     */
    function addExecutorLzComposeOption(
        bytes memory _options,
        uint16 _index,
        uint128 _gas,
        uint128 _value
    ) internal pure onlyType3(_options) returns (bytes memory) {
        bytes memory option = ExecutorOptions.encodeLzComposeOption(_index, _gas, _value);
        return addExecutorOption(_options, ExecutorOptions.OPTION_TYPE_LZCOMPOSE, option);
    }

    /**
     * @dev Adds an executor ordered execution option to the existing options.
     * @param _options The existing options container.
     * @return options The updated options container.
     */
    function addExecutorOrderedExecutionOption(
        bytes memory _options
    ) internal pure onlyType3(_options) returns (bytes memory) {
        return addExecutorOption(_options, ExecutorOptions.OPTION_TYPE_ORDERED_EXECUTION, bytes(""));
    }

    /**
     * @dev Adds a DVN pre-crime option to the existing options.
     * @param _options The existing options container.
     * @param _dvnIdx The DVN index for the pre-crime option.
     * @return options The updated options container.
     */
    function addDVNPreCrimeOption(
        bytes memory _options,
        uint8 _dvnIdx
    ) internal pure onlyType3(_options) returns (bytes memory) {
        return addDVNOption(_options, _dvnIdx, DVNOptions.OPTION_TYPE_PRECRIME, bytes(""));
    }

    /**
     * @dev Adds an executor option to the existing options.
     * @param _options The existing options container.
     * @param _optionType The type of the executor option.
     * @param _option The encoded data for the executor option.
     * @return options The updated options container.
     */
    function addExecutorOption(
        bytes memory _options,
        uint8 _optionType,
        bytes memory _option
    ) internal pure onlyType3(_options) returns (bytes memory) {
        return
            abi.encodePacked(
                _options,
                ExecutorOptions.WORKER_ID,
                _option.length.toUint16() + 1, // +1 for optionType
                _optionType,
                _option
            );
    }

    /**
     * @dev Adds a DVN option to the existing options.
     * @param _options The existing options container.
     * @param _dvnIdx The DVN index for the DVN option.
     * @param _optionType The type of the DVN option.
     * @param _option The encoded data for the DVN option.
     * @return options The updated options container.
     */
    function addDVNOption(
        bytes memory _options,
        uint8 _dvnIdx,
        uint8 _optionType,
        bytes memory _option
    ) internal pure onlyType3(_options) returns (bytes memory) {
        return
            abi.encodePacked(
                _options,
                DVNOptions.WORKER_ID,
                _option.length.toUint16() + 2, // +2 for optionType and dvnIdx
                _dvnIdx,
                _optionType,
                _option
            );
    }

    /**
     * @dev Encodes legacy options of type 1.
     * @param _executionGas The gasLimit value passed to lzReceive().
     * @return legacyOptions The encoded legacy options.
     */
    function encodeLegacyOptionsType1(uint256 _executionGas) internal pure returns (bytes memory) {
        if (_executionGas > type(uint128).max) revert InvalidSize(type(uint128).max, _executionGas);
        return abi.encodePacked(TYPE_1, _executionGas);
    }

    /**
     * @dev Encodes legacy options of type 2.
     * @param _executionGas The gasLimit value passed to lzReceive().
     * @param _nativeForDst The amount of native air dropped to the receiver.
     * @param _receiver The _nativeForDst receiver address.
     * @return legacyOptions The encoded legacy options of type 2.
     */
    function encodeLegacyOptionsType2(
        uint256 _executionGas,
        uint256 _nativeForDst,
        bytes memory _receiver // @dev Use bytes instead of bytes32 in legacy type 2 for _receiver.
    ) internal pure returns (bytes memory) {
        if (_executionGas > type(uint128).max) revert InvalidSize(type(uint128).max, _executionGas);
        if (_nativeForDst > type(uint128).max) revert InvalidSize(type(uint128).max, _nativeForDst);
        if (_receiver.length > 32) revert InvalidSize(32, _receiver.length);
        return abi.encodePacked(TYPE_2, _executionGas, _nativeForDst, _receiver);
    }
}

// node_modules/@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ISendLib.sol

struct Packet {
    uint64 nonce;
    uint32 srcEid;
    address sender;
    uint32 dstEid;
    bytes32 receiver;
    bytes32 guid;
    bytes message;
}

interface ISendLib is IMessageLib {
    function send(
        Packet calldata _packet,
        bytes calldata _options,
        bool _payInLzToken
    ) external returns (MessagingFee memory, bytes memory encodedPacket);

    function quote(
        Packet calldata _packet,
        bytes calldata _options,
        bool _payInLzToken
    ) external view returns (MessagingFee memory);

    function setTreasury(address _treasury) external;

    function withdrawFee(address _to, uint256 _amount) external;

    function withdrawLzTokenFee(address _lzToken, address _to, uint256 _amount) external;
}

// node_modules/@layerzerolabs/lz-evm-oapp-v2/contracts/oapp/OAppCore.sol

/**
 * @title OAppCore
 * @dev Abstract contract implementing the IOAppCore interface with basic OApp configurations.
 */
abstract contract OAppCore is IOAppCore, Ownable {
    // The LayerZero endpoint associated with the given OApp
    ILayerZeroEndpointV2 public immutable endpoint;

    // Mapping to store peers associated with corresponding endpoints
    mapping(uint32 eid => bytes32 peer) public peers;

    /**
     * @dev Constructor to initialize the OAppCore with the provided endpoint and delegate.
     * @param _endpoint The address of the LOCAL Layer Zero endpoint.
     * @param _delegate The delegate capable of making OApp configurations inside of the endpoint.
     *
     * @dev The delegate typically should be set as the owner of the contract.
     */
    constructor(address _endpoint, address _delegate) {
        endpoint = ILayerZeroEndpointV2(_endpoint);

        if (_delegate == address(0)) revert InvalidDelegate();
        endpoint.setDelegate(_delegate);
    }

    /**
     * @notice Sets the peer address (OApp instance) for a corresponding endpoint.
     * @param _eid The endpoint ID.
     * @param _peer The address of the peer to be associated with the corresponding endpoint.
     *
     * @dev Only the owner/admin of the OApp can call this function.
     * @dev Indicates that the peer is trusted to send LayerZero messages to this OApp.
     * @dev Set this to bytes32(0) to remove the peer address.
     * @dev Peer is a bytes32 to accommodate non-evm chains.
     */
    function setPeer(uint32 _eid, bytes32 _peer) public virtual onlyOwner {
        _setPeer(_eid, _peer);
    }

    /**
     * @notice Sets the peer address (OApp instance) for a corresponding endpoint.
     * @param _eid The endpoint ID.
     * @param _peer The address of the peer to be associated with the corresponding endpoint.
     *
     * @dev Indicates that the peer is trusted to send LayerZero messages to this OApp.
     * @dev Set this to bytes32(0) to remove the peer address.
     * @dev Peer is a bytes32 to accommodate non-evm chains.
     */
    function _setPeer(uint32 _eid, bytes32 _peer) internal virtual {
        peers[_eid] = _peer;
        emit PeerSet(_eid, _peer);
    }

    /**
     * @notice Internal function to get the peer address associated with a specific endpoint; reverts if NOT set.
     * ie. the peer is set to bytes32(0).
     * @param _eid The endpoint ID.
     * @return peer The address of the peer associated with the specified endpoint.
     */
    function _getPeerOrRevert(uint32 _eid) internal view virtual returns (bytes32) {
        bytes32 peer = peers[_eid];
        if (peer == bytes32(0)) revert NoPeer(_eid);
        return peer;
    }

    /**
     * @notice Sets the delegate address for the OApp.
     * @param _delegate The address of the delegate to be set.
     *
     * @dev Only the owner/admin of the OApp can call this function.
     * @dev Provides the ability for a delegate to set configs, on behalf of the OApp, directly on the Endpoint contract.
     */
    function setDelegate(address _delegate) public onlyOwner {
        endpoint.setDelegate(_delegate);
    }
}

// node_modules/@layerzerolabs/lz-evm-protocol-v2/contracts/messagelib/libs/PacketV1Codec.sol

library PacketV1Codec {
    using AddressCast for address;
    using AddressCast for bytes32;

    uint8 internal constant PACKET_VERSION = 1;

    // header (version + nonce + path)
    // version
    uint256 private constant PACKET_VERSION_OFFSET = 0;
    //    nonce
    uint256 private constant NONCE_OFFSET = 1;
    //    path
    uint256 private constant SRC_EID_OFFSET = 9;
    uint256 private constant SENDER_OFFSET = 13;
    uint256 private constant DST_EID_OFFSET = 45;
    uint256 private constant RECEIVER_OFFSET = 49;
    // payload (guid + message)
    uint256 private constant GUID_OFFSET = 81; // keccak256(nonce + path)
    uint256 private constant MESSAGE_OFFSET = 113;

    function encode(Packet memory _packet) internal pure returns (bytes memory encodedPacket) {
        encodedPacket = abi.encodePacked(
            PACKET_VERSION,
            _packet.nonce,
            _packet.srcEid,
            _packet.sender.toBytes32(),
            _packet.dstEid,
            _packet.receiver,
            _packet.guid,
            _packet.message
        );
    }

    function encodePacketHeader(Packet memory _packet) internal pure returns (bytes memory) {
        return
            abi.encodePacked(
                PACKET_VERSION,
                _packet.nonce,
                _packet.srcEid,
                _packet.sender.toBytes32(),
                _packet.dstEid,
                _packet.receiver
            );
    }

    function encodePayload(Packet memory _packet) internal pure returns (bytes memory) {
        return abi.encodePacked(_packet.guid, _packet.message);
    }

    function header(bytes calldata _packet) internal pure returns (bytes calldata) {
        return _packet[0:GUID_OFFSET];
    }

    function version(bytes calldata _packet) internal pure returns (uint8) {
        return uint8(bytes1(_packet[PACKET_VERSION_OFFSET:NONCE_OFFSET]));
    }

    function nonce(bytes calldata _packet) internal pure returns (uint64) {
        return uint64(bytes8(_packet[NONCE_OFFSET:SRC_EID_OFFSET]));
    }

    function srcEid(bytes calldata _packet) internal pure returns (uint32) {
        return uint32(bytes4(_packet[SRC_EID_OFFSET:SENDER_OFFSET]));
    }

    function sender(bytes calldata _packet) internal pure returns (bytes32) {
        return bytes32(_packet[SENDER_OFFSET:DST_EID_OFFSET]);
    }

    function senderAddressB20(bytes calldata _packet) internal pure returns (address) {
        return sender(_packet).toAddress();
    }

    function dstEid(bytes calldata _packet) internal pure returns (uint32) {
        return uint32(bytes4(_packet[DST_EID_OFFSET:RECEIVER_OFFSET]));
    }

    function receiver(bytes calldata _packet) internal pure returns (bytes32) {
        return bytes32(_packet[RECEIVER_OFFSET:GUID_OFFSET]);
    }

    function receiverB20(bytes calldata _packet) internal pure returns (address) {
        return receiver(_packet).toAddress();
    }

    function guid(bytes calldata _packet) internal pure returns (bytes32) {
        return bytes32(_packet[GUID_OFFSET:MESSAGE_OFFSET]);
    }

    function message(bytes calldata _packet) internal pure returns (bytes calldata) {
        return bytes(_packet[MESSAGE_OFFSET:]);
    }

    function payload(bytes calldata _packet) internal pure returns (bytes calldata) {
        return bytes(_packet[GUID_OFFSET:]);
    }

    function payloadHash(bytes calldata _packet) internal pure returns (bytes32) {
        return keccak256(payload(_packet));
    }
}

// node_modules/@layerzerolabs/lz-evm-oapp-v2/contracts/oapp/OAppReceiver.sol

/**
 * @title OAppReceiver
 * @dev Abstract contract implementing the ILayerZeroReceiver interface and extending OAppCore for OApp receivers.
 */
abstract contract OAppReceiver is IOAppReceiver, OAppCore {
    // Custom error message for when the caller is not the registered endpoint/
    error OnlyEndpoint(address addr);

    // @dev The version of the OAppReceiver implementation.
    // @dev Version is bumped when changes are made to this contract.
    uint64 internal constant RECEIVER_VERSION = 2;

    /**
     * @notice Retrieves the OApp version information.
     * @return senderVersion The version of the OAppSender.sol contract.
     * @return receiverVersion The version of the OAppReceiver.sol contract.
     *
     * @dev Providing 0 as the default for OAppSender version. Indicates that the OAppSender is not implemented.
     * ie. this is a RECEIVE only OApp.
     * @dev If the OApp uses both OAppSender and OAppReceiver, then this needs to be override returning the correct versions.
     */
    function oAppVersion() public view virtual returns (uint64 senderVersion, uint64 receiverVersion) {
        return (0, RECEIVER_VERSION);
    }

    /**
     * @notice Indicates whether an address is an approved composeMsg sender to the Endpoint.
     * @dev _origin The origin information containing the source endpoint and sender address.
     *  - srcEid: The source chain endpoint ID.
     *  - sender: The sender address on the src chain.
     *  - nonce: The nonce of the message.
     * @dev _message The lzReceive payload.
     * @param _sender The sender address.
     * @return isSender Is a valid sender.
     *
     * @dev Applications can optionally choose to implement separate composeMsg senders that are NOT the bridging layer.
     * @dev The default sender IS the OAppReceiver implementer.
     */
    function isComposeMsgSender(
        Origin calldata /*_origin*/,
        bytes calldata /*_message*/,
        address _sender
    ) public view virtual returns (bool) {
        return _sender == address(this);
    }

    /**
     * @notice Checks if the path initialization is allowed based on the provided origin.
     * @param origin The origin information containing the source endpoint and sender address.
     * @return Whether the path has been initialized.
     *
     * @dev This indicates to the endpoint that the OApp has enabled msgs for this particular path to be received.
     * @dev This defaults to assuming if a peer has been set, its initialized.
     * Can be overridden by the OApp if there is other logic to determine this.
     */
    function allowInitializePath(Origin calldata origin) public view virtual returns (bool) {
        return peers[origin.srcEid] == origin.sender;
    }

    /**
     * @notice Retrieves the next nonce for a given source endpoint and sender address.
     * @dev _srcEid The source endpoint ID.
     * @dev _sender The sender address.
     * @return nonce The next nonce.
     *
     * @dev The path nonce starts from 1. If 0 is returned it means that there is NO nonce ordered enforcement.
     * @dev Is required by the off-chain executor to determine the OApp expects msg execution is ordered.
     * @dev This is also enforced by the OApp.
     * @dev By default this is NOT enabled. ie. nextNonce is hardcoded to return 0.
     */
    function nextNonce(uint32 /*_srcEid*/, bytes32 /*_sender*/) public view virtual returns (uint64 nonce) {
        return 0;
    }

    /**
     * @dev Entry point for receiving messages or packets from the endpoint.
     * @param _origin The origin information containing the source endpoint and sender address.
     *  - srcEid: The source chain endpoint ID.
     *  - sender: The sender address on the src chain.
     *  - nonce: The nonce of the message.
     * @param _guid The unique identifier for the received LayerZero message.
     * @param _message The payload of the received message.
     * @param _executor The address of the executor for the received message.
     * @param _extraData Additional arbitrary data provided by the corresponding executor.
     *
     * @dev Entry point for receiving msg/packet from the LayerZero endpoint.
     */
    function lzReceive(
        Origin calldata _origin,
        bytes32 _guid,
        bytes calldata _message,
        address _executor,
        bytes calldata _extraData
    ) public payable virtual {
        // Ensures that only the endpoint can attempt to lzReceive() messages to this OApp.
        if (address(endpoint) != msg.sender) revert OnlyEndpoint(msg.sender);

        // Ensure that the sender matches the expected peer for the source endpoint.
        if (_getPeerOrRevert(_origin.srcEid) != _origin.sender) revert OnlyPeer(_origin.srcEid, _origin.sender);

        // Call the internal OApp implementation of lzReceive.
        _lzReceive(_origin, _guid, _message, _executor, _extraData);
    }

    /**
     * @dev Internal function to implement lzReceive logic without needing to copy the basic parameter validation.
     */
    function _lzReceive(
        Origin calldata _origin,
        bytes32 _guid,
        bytes calldata _message,
        address _executor,
        bytes calldata _extraData
    ) internal virtual;
}

// node_modules/@layerzerolabs/lz-evm-oapp-v2/contracts/precrime/libs/Packet.sol

/**
 * @title InboundPacket
 * @dev Structure representing an inbound packet received by the contract.
 */
struct InboundPacket {
    Origin origin; // Origin information of the packet.
    uint32 dstEid; // Destination endpointId of the packet.
    address receiver; // Receiver address for the packet.
    bytes32 guid; // Unique identifier of the packet.
    uint256 value; // msg.value of the packet.
    address executor; // Executor address for the packet.
    bytes message; // Message payload of the packet.
    bytes extraData; // Additional arbitrary data for the packet.
}

/**
 * @title PacketDecoder
 * @dev Library for decoding LayerZero packets.
 */
library PacketDecoder {
    using PacketV1Codec for bytes;

    /**
     * @dev Decode an inbound packet from the given packet data.
     * @param _packet The packet data to decode.
     * @return packet An InboundPacket struct representing the decoded packet.
     */
    function decode(bytes calldata _packet) internal pure returns (InboundPacket memory packet) {
        packet.origin = Origin(_packet.srcEid(), _packet.sender(), _packet.nonce());
        packet.dstEid = _packet.dstEid();
        packet.receiver = _packet.receiverB20();
        packet.guid = _packet.guid();
        packet.message = _packet.message();
    }

    /**
     * @dev Decode multiple inbound packets from the given packet data and associated message values.
     * @param _packets An array of packet data to decode.
     * @param _packetMsgValues An array of associated message values for each packet.
     * @return packets An array of InboundPacket structs representing the decoded packets.
     */
    function decode(
        bytes[] calldata _packets,
        uint256[] memory _packetMsgValues
    ) internal pure returns (InboundPacket[] memory packets) {
        packets = new InboundPacket[](_packets.length);
        for (uint256 i = 0; i < _packets.length; i++) {
            bytes calldata packet = _packets[i];
            packets[i] = PacketDecoder.decode(packet);
            // @dev Allows the verifier to specify the msg.value that gets passed in lzReceive.
            packets[i].value = _packetMsgValues[i];
        }
    }
}

// node_modules/@layerzerolabs/lz-evm-oapp-v2/contracts/precrime/interfaces/IOAppPreCrimeSimulator.sol

// @dev Import the Origin so it's exposed to OAppPreCrimeSimulator implementers.
// solhint-disable-next-line no-unused-import

/**
 * @title IOAppPreCrimeSimulator Interface
 * @dev Interface for the preCrime simulation functionality in an OApp.
 */
interface IOAppPreCrimeSimulator {
    // @dev simulation result used in PreCrime implementation
    error SimulationResult(bytes result);
    error OnlySelf();

    /**
     * @dev Emitted when the preCrime contract address is set.
     * @param preCrimeAddress The address of the preCrime contract.
     */
    event PreCrimeSet(address preCrimeAddress);

    /**
     * @dev Retrieves the address of the preCrime contract implementation.
     * @return The address of the preCrime contract.
     */
    function preCrime() external view returns (address);

    /**
     * @dev Retrieves the address of the OApp contract.
     * @return The address of the OApp contract.
     */
    function oApp() external view returns (address);

    /**
     * @dev Sets the preCrime contract address.
     * @param _preCrime The address of the preCrime contract.
     */
    function setPreCrime(address _preCrime) external;

    /**
     * @dev Mocks receiving a packet, then reverts with a series of data to infer the state/result.
     * @param _packets An array of LayerZero InboundPacket objects representing received packets.
     */
    function lzReceiveAndRevert(InboundPacket[] calldata _packets) external payable;

    /**
     * @dev checks if the specified peer is considered 'trusted' by the OApp.
     * @param _eid The endpoint Id to check.
     * @param _peer The peer to check.
     * @return Whether the peer passed is considered 'trusted' by the OApp.
     */
    function isPeer(uint32 _eid, bytes32 _peer) external view returns (bool);
}

// node_modules/@layerzerolabs/lz-evm-oapp-v2/contracts/oapp/OAppSender.sol

/**
 * @title OAppSender
 * @dev Abstract contract implementing the OAppSender functionality for sending messages to a LayerZero endpoint.
 */
abstract contract OAppSender is OAppCore {
    using SafeERC20 for IERC20;

    // Custom error messages
    error NotEnoughNative(uint256 msgValue);
    error LzTokenUnavailable();

    // @dev The version of the OAppSender implementation.
    // @dev Version is bumped when changes are made to this contract.
    uint64 internal constant SENDER_VERSION = 1;

    /**
     * @notice Retrieves the OApp version information.
     * @return senderVersion The version of the OAppSender.sol contract.
     * @return receiverVersion The version of the OAppReceiver.sol contract.
     *
     * @dev Providing 0 as the default for OAppReceiver version. Indicates that the OAppReceiver is not implemented.
     * ie. this is a SEND only OApp.
     * @dev If the OApp uses both OAppSender and OAppReceiver, then this needs to be override returning the correct versions
     */
    function oAppVersion() public view virtual returns (uint64 senderVersion, uint64 receiverVersion) {
        return (SENDER_VERSION, 0);
    }

    /**
     * @dev Internal function to interact with the LayerZero EndpointV2.quote() for fee calculation.
     * @param _dstEid The destination endpoint ID.
     * @param _message The message payload.
     * @param _options Additional options for the message.
     * @param _payInLzToken Flag indicating whether to pay the fee in LZ tokens.
     * @return fee The calculated MessagingFee for the message.
     *      - nativeFee: The native fee for the message.
     *      - lzTokenFee: The LZ token fee for the message.
     */
    function _quote(
        uint32 _dstEid,
        bytes memory _message,
        bytes memory _options,
        bool _payInLzToken
    ) internal view virtual returns (MessagingFee memory fee) {
        return
            endpoint.quote(
                MessagingParams(_dstEid, _getPeerOrRevert(_dstEid), _message, _options, _payInLzToken),
                address(this)
            );
    }

    /**
     * @dev Internal function to interact with the LayerZero EndpointV2.send() for sending a message.
     * @param _dstEid The destination endpoint ID.
     * @param _message The message payload.
     * @param _options Additional options for the message.
     * @param _fee The calculated LayerZero fee for the message.
     *      - nativeFee: The native fee.
     *      - lzTokenFee: The lzToken fee.
     * @param _refundAddress The address to receive any excess fee values sent to the endpoint.
     * @return receipt The receipt for the sent message.
     *      - guid: The unique identifier for the sent message.
     *      - nonce: The nonce of the sent message.
     *      - fee: The LayerZero fee incurred for the message.
     */
    function _lzSend(
        uint32 _dstEid,
        bytes memory _message,
        bytes memory _options,
        MessagingFee memory _fee,
        address _refundAddress
    ) internal virtual returns (MessagingReceipt memory receipt) {
        // @dev Push corresponding fees to the endpoint, any excess is sent back to the _refundAddress from the endpoint.
        uint256 messageValue = _payNative(_fee.nativeFee);
        if (_fee.lzTokenFee > 0) _payLzToken(_fee.lzTokenFee);

        return
            // solhint-disable-next-line check-send-result
            endpoint.send{ value: messageValue }(
                MessagingParams(_dstEid, _getPeerOrRevert(_dstEid), _message, _options, _fee.lzTokenFee > 0),
                _refundAddress
            );
    }

    /**
     * @dev Internal function to pay the native fee associated with the message.
     * @param _nativeFee The native fee to be paid.
     * @return nativeFee The amount of native currency paid.
     *
     * @dev If the OApp needs to initiate MULTIPLE LayerZero messages in a single transaction,
     * this will need to be overridden because msg.value would contain multiple lzFees.
     * @dev Should be overridden in the event the LayerZero endpoint requires a different native currency.
     * @dev Some EVMs use an ERC20 as a method for paying transactions/gasFees.
     * @dev The endpoint is EITHER/OR, ie. it will NOT support both types of native payment at a time.
     */
    function _payNative(uint256 _nativeFee) internal virtual returns (uint256 nativeFee) {
        if (msg.value != _nativeFee) revert NotEnoughNative(msg.value);
        return _nativeFee;
    }

    /**
     * @dev Internal function to pay the LZ token fee associated with the message.
     * @param _lzTokenFee The LZ token fee to be paid.
     *
     * @dev If the caller is trying to pay in the specified lzToken, then the lzTokenFee is passed to the endpoint.
     * @dev Any excess sent, is passed back to the specified _refundAddress in the _lzSend().
     */
    function _payLzToken(uint256 _lzTokenFee) internal virtual {
        // @dev Cannot cache the token because it is not immutable in the endpoint.
        address lzToken = endpoint.lzToken();
        if (lzToken == address(0)) revert LzTokenUnavailable();

        // Pay LZ token fee by sending tokens to the endpoint.
        IERC20(lzToken).safeTransferFrom(msg.sender, address(endpoint), _lzTokenFee);
    }
}

// node_modules/@layerzerolabs/lz-evm-oapp-v2/contracts/oft/interfaces/IOFT.sol

/**
 * @dev Struct representing token parameters for the OFT send() operation.
 */
struct SendParam {
    uint32 dstEid; // Destination endpoint ID.
    bytes32 to; // Recipient address.
    uint256 amountLD; // Amount to send in local decimals.
    uint256 minAmountLD; // Minimum amount to send in local decimals.
    bytes extraOptions; // Additional options supplied by the caller to be used in the LayerZero message.
    bytes composeMsg; // The composed message for the send() operation.
    bytes oftCmd; // The OFT command to be executed, unused in default OFT implementations.
}

/**
 * @dev Struct representing OFT limit information.
 * @dev These amounts can change dynamically and are up the the specific oft implementation.
 */
struct OFTLimit {
    uint256 minAmountLD; // Minimum amount in local decimals that can be sent to the recipient.
    uint256 maxAmountLD; // Maximum amount in local decimals that can be sent to the recipient.
}

/**
 * @dev Struct representing OFT receipt information.
 */
struct OFTReceipt {
    uint256 amountSentLD; // Amount of tokens ACTUALLY debited from the sender in local decimals.
    // @dev In non-default implementations, the amountReceivedLD COULD differ from this value.
    uint256 amountReceivedLD; // Amount of tokens to be received on the remote side.
}

/**
 * @dev Struct representing OFT fee details.
 * @dev Future proof mechanism to provide a standardized way to communicate fees to things like a UI.
 */
struct OFTFeeDetail {
    int256 feeAmountLD; // Amount of the fee in local decimals.
    string description; // Description of the fee.
}

/**
 * @title IOFT
 * @dev Interface for the OftChain (OFT) token.
 * @dev Does not inherit ERC20 to accommodate usage by OFTAdapter as well.
 * @dev This specific interface ID is '0x02e49c2c'.
 */
interface IOFT {
    // Custom error messages
    error InvalidLocalDecimals();
    error SlippageExceeded(uint256 amountLD, uint256 minAmountLD);

    // Events
    event OFTSent(
        bytes32 indexed guid, // GUID of the OFT message.
        uint32 dstEid, // Destination Endpoint ID.
        address indexed fromAddress, // Address of the sender on the src chain.
        uint256 amountSentLD, // Amount of tokens sent in local decimals.
        uint256 amountReceivedLD // Amount of tokens received in local decimals.
    );
    event OFTReceived(
        bytes32 indexed guid, // GUID of the OFT message.
        uint32 srcEid, // Source Endpoint ID.
        address indexed toAddress, // Address of the recipient on the dst chain.
        uint256 amountReceivedLD // Amount of tokens received in local decimals.
    );

    /**
     * @notice Retrieves interfaceID and the version of the OFT.
     * @return interfaceId The interface ID.
     * @return version The version.
     *
     * @dev interfaceId: This specific interface ID is '0x02e49c2c'.
     * @dev version: Indicates a cross-chain compatible msg encoding with other OFTs.
     * @dev If a new feature is added to the OFT cross-chain msg encoding, the version will be incremented.
     * ie. localOFT version(x,1) CAN send messages to remoteOFT version(x,1)
     */
    function oftVersion() external view returns (bytes4 interfaceId, uint64 version);

    /**
     * @notice Retrieves the address of the token associated with the OFT.
     * @return token The address of the ERC20 token implementation.
     */
    function token() external view returns (address);

    /**
     * @notice Indicates whether the OFT contract requires approval of the 'token()' to send.
     * @return requiresApproval Needs approval of the underlying token implementation.
     *
     * @dev Allows things like wallet implementers to determine integration requirements,
     * without understanding the underlying token implementation.
     */
    function approvalRequired() external view returns (bool);

    /**
     * @notice Retrieves the shared decimals of the OFT.
     * @return sharedDecimals The shared decimals of the OFT.
     */
    function sharedDecimals() external view returns (uint8);

    /**
     * @notice Provides a quote for OFT-related operations.
     * @param _sendParam The parameters for the send operation.
     * @return limit The OFT limit information.
     * @return oftFeeDetails The details of OFT fees.
     * @return receipt The OFT receipt information.
     */
    function quoteOFT(
        SendParam calldata _sendParam
    ) external view returns (OFTLimit memory, OFTFeeDetail[] memory oftFeeDetails, OFTReceipt memory);

    /**
     * @notice Provides a quote for the send() operation.
     * @param _sendParam The parameters for the send() operation.
     * @param _payInLzToken Flag indicating whether the caller is paying in the LZ token.
     * @return fee The calculated LayerZero messaging fee from the send() operation.
     *
     * @dev MessagingFee: LayerZero msg fee
     *  - nativeFee: The native fee.
     *  - lzTokenFee: The lzToken fee.
     */
    function quoteSend(SendParam calldata _sendParam, bool _payInLzToken) external view returns (MessagingFee memory);

    /**
     * @notice Executes the send() operation.
     * @param _sendParam The parameters for the send operation.
     * @param _fee The fee information supplied by the caller.
     *      - nativeFee: The native fee.
     *      - lzTokenFee: The lzToken fee.
     * @param _refundAddress The address to receive any excess funds from fees etc. on the src.
     * @return receipt The LayerZero messaging receipt from the send() operation.
     * @return oftReceipt The OFT receipt information.
     *
     * @dev MessagingReceipt: LayerZero msg receipt
     *  - guid: The unique identifier for the sent message.
     *  - nonce: The nonce of the sent message.
     *  - fee: The LayerZero fee incurred for the message.
     */
    function send(
        SendParam calldata _sendParam,
        MessagingFee calldata _fee,
        address _refundAddress
    ) external payable returns (MessagingReceipt memory, OFTReceipt memory);
}

// dependencies/@stargatefinance-1.0.5/packages/stg-evm-v2/src/interfaces/ICreditMessaging.sol

/// @notice Stores the information related to a batch of credit transfers.
struct TargetCreditBatch {
    uint16 assetId;
    TargetCredit[] credits;
}

/// @notice Stores the information related to a single credit transfer.
struct TargetCredit {
    uint32 srcEid;
    uint64 amount; // the amount of credits to intended to send
    uint64 minAmount; // the minimum amount of credits to keep on local chain after sending
}

/// @title Credit Messaging API
/// @dev This interface defines the API for quoting and sending credits to other chains.
interface ICreditMessaging {
    /// @notice Sends credits to the destination endpoint.
    /// @param _dstEid The destination LayerZero endpoint ID.
    /// @param _creditBatches The credit batch payloads to send to the destination LayerZero endpoint ID.
    function sendCredits(uint32 _dstEid, TargetCreditBatch[] calldata _creditBatches) external payable;

    /// @notice Quotes the fee for sending credits to the destination endpoint.
    /// @param _dstEid The destination LayerZero endpoint ID.
    /// @param _creditBatches The credit batch payloads to send to the destination LayerZero endpoint ID.
    /// @return fee The fee for sending the credits to the destination endpoint.
    function quoteSendCredits(
        uint32 _dstEid,
        TargetCreditBatch[] calldata _creditBatches
    ) external view returns (MessagingFee memory fee);
}

// dependencies/@stargatefinance-1.0.5/packages/stg-evm-v2/src/interfaces/IStargate.sol

// Solidity does not support splitting import across multiple lines
// solhint-disable-next-line max-line-length

/// @notice Stargate implementation type.
enum StargateType {
    Pool,
    OFT
}

/// @notice Ticket data for bus ride.
struct Ticket {
    uint72 ticketId;
    bytes passengerBytes;
}

/// @title Interface for Stargate.
/// @notice Defines an API for sending tokens to destination chains.
interface IStargate is IOFT {
    /// @dev This function is same as `send` in OFT interface but returns the ticket data if in the bus ride mode,
    /// which allows the caller to ride and drive the bus in the same transaction.
    function sendToken(
        SendParam calldata _sendParam,
        MessagingFee calldata _fee,
        address _refundAddress
    ) external payable returns (MessagingReceipt memory msgReceipt, OFTReceipt memory oftReceipt, Ticket memory ticket);

    /// @notice Returns the Stargate implementation type.
    function stargateType() external pure returns (StargateType);
}

// dependencies/@stargatefinance-1.0.5/packages/stg-evm-v2/src/interfaces/ICreditMessagingHandler.sol

struct Credit {
    uint32 srcEid;
    uint64 amount;
}

/// @dev This is an internal interface, defining functions to handle messages/calls from the credit messaging contract.
interface ICreditMessagingHandler {
    function sendCredits(uint32 _dstEid, TargetCredit[] calldata _credits) external returns (Credit[] memory);

    function receiveCredits(uint32 _srcEid, Credit[] calldata _credits) external;
}

// dependencies/@stargatefinance-1.0.5/packages/stg-evm-v2/src/interfaces/ITokenMessaging.sol

/// @notice Payload for sending a taxi message.
/// @dev A taxi message is sent immediately and is not stored on the bus.
struct TaxiParams {
    address sender;
    uint32 dstEid;
    bytes32 receiver;
    uint64 amountSD;
    bytes composeMsg;
    bytes extraOptions;
}

/// @notice Payload for riding the bus.
/// @dev Riding the bus is a two-step process:
/// @dev - The message is sent to the bus,
/// @dev - The bus is driven to the destination.
struct RideBusParams {
    address sender;
    uint32 dstEid;
    bytes32 receiver;
    uint64 amountSD;
    bool nativeDrop;
}

/// @title Token Messaging API.
/// @notice This interface defines the API for sending a taxi message, riding the bus, and driving the bus, along with
/// corresponding quote functions.
interface ITokenMessaging {
    /// @notice Sends a taxi message
    /// @param _params The taxi message payload
    /// @param _messagingFee The messaging fee for sending a taxi message
    /// @param _refundAddress The address to refund excess LayerZero MessagingFees
    /// @return receipt The MessagingReceipt resulting from sending the taxi
    function taxi(
        TaxiParams calldata _params,
        MessagingFee calldata _messagingFee,
        address _refundAddress
    ) external payable returns (MessagingReceipt memory receipt);

    /// @notice Quotes the messaging fee for sending a taxi message
    /// @param _params The taxi message payload
    /// @param _payInLzToken Whether to pay the fee in LZ token
    /// @return fee The MessagingFee for sending the taxi message
    function quoteTaxi(TaxiParams calldata _params, bool _payInLzToken) external view returns (MessagingFee memory fee);

    /// @notice Sends a message to ride the bus, queuing the passenger in preparation for the drive.
    /// @notice The planner will later driveBus to the destination endpoint.
    /// @param _params The rideBus message payload
    /// @return receipt The MessagingReceipt resulting from sending the rideBus message
    /// @return ticket The Ticket for riding the bus
    function rideBus(
        RideBusParams calldata _params
    ) external returns (MessagingReceipt memory receipt, Ticket memory ticket);

    /// @notice Quotes the messaging fee for riding the bus
    /// @param _dstEid The destination LayerZero endpoint ID.
    /// @param _nativeDrop Whether to pay for a native drop on the destination.
    /// @return fee The MessagingFee for riding the bus
    function quoteRideBus(uint32 _dstEid, bool _nativeDrop) external view returns (MessagingFee memory fee);

    /// @notice Drives the bus to the destination.
    /// @param _dstEid The destination LayerZero endpoint ID.
    /// @param _passengers The passengers to drive to the destination.
    /// @return receipt The MessagingReceipt resulting from driving the bus
    function driveBus(
        uint32 _dstEid,
        bytes calldata _passengers
    ) external payable returns (MessagingReceipt memory receipt);

    /// @notice Quotes the messaging fee for driving the bus to the destination.
    /// @param _dstEid The destination LayerZero endpoint ID.
    /// @param _passengers The passengers to drive to the destination.
    /// @return fee The MessagingFee for driving the bus
    function quoteDriveBus(uint32 _dstEid, bytes calldata _passengers) external view returns (MessagingFee memory fee);
}

// node_modules/@layerzerolabs/lz-evm-oapp-v2/contracts/precrime/OAppPreCrimeSimulator.sol

/**
 * @title OAppPreCrimeSimulator
 * @dev Abstract contract serving as the base for preCrime simulation functionality in an OApp.
 */
abstract contract OAppPreCrimeSimulator is IOAppPreCrimeSimulator, Ownable {
    // The address of the preCrime implementation.
    address public preCrime;

    /**
     * @dev Retrieves the address of the OApp contract.
     * @return The address of the OApp contract.
     *
     * @dev The simulator contract is the base contract for the OApp by default.
     * @dev If the simulator is a separate contract, override this function.
     */
    function oApp() external view virtual returns (address) {
        return address(this);
    }

    /**
     * @dev Sets the preCrime contract address.
     * @param _preCrime The address of the preCrime contract.
     */
    function setPreCrime(address _preCrime) public virtual onlyOwner {
        preCrime = _preCrime;
        emit PreCrimeSet(_preCrime);
    }

    /**
     * @dev Interface for pre-crime simulations. Always reverts at the end with the simulation results.
     * @param _packets An array of InboundPacket objects representing received packets to be delivered.
     *
     * @dev WARNING: MUST revert at the end with the simulation results.
     * @dev Gives the preCrime implementation the ability to mock sending packets to the lzReceive function,
     * WITHOUT actually executing them.
     */
    function lzReceiveAndRevert(InboundPacket[] calldata _packets) public payable virtual {
        for (uint256 i = 0; i < _packets.length; i++) {
            InboundPacket calldata packet = _packets[i];

            // Ignore packets that are not from trusted peers.
            if (!isPeer(packet.origin.srcEid, packet.origin.sender)) continue;

            // @dev Because a verifier is calling this function, it doesnt have access to executor params:
            //  - address _executor
            //  - bytes calldata _extraData
            // preCrime will NOT work for OApps that rely on these two parameters inside of their _lzReceive().
            // They are instead stubbed to default values, address(0) and bytes("")
            // @dev Calling this.lzReceiveSimulate removes ability for assembly return 0 callstack exit,
            // which would cause the revert to be ignored.
            this.lzReceiveSimulate{ value: packet.value }(
                packet.origin,
                packet.guid,
                packet.message,
                packet.executor,
                packet.extraData
            );
        }

        // @dev Revert with the simulation results. msg.sender must implement IPreCrime.buildSimulationResult().
        revert SimulationResult(IPreCrime(msg.sender).buildSimulationResult());
    }

    /**
     * @dev Is effectively an internal function because msg.sender must be address(this).
     * Allows resetting the call stack for 'internal' calls.
     * @param _origin The origin information containing the source endpoint and sender address.
     *  - srcEid: The source chain endpoint ID.
     *  - sender: The sender address on the src chain.
     *  - nonce: The nonce of the message.
     * @param _guid The unique identifier of the packet.
     * @param _message The message payload of the packet.
     * @param _executor The executor address for the packet.
     * @param _extraData Additional data for the packet.
     */
    function lzReceiveSimulate(
        Origin calldata _origin,
        bytes32 _guid,
        bytes calldata _message,
        address _executor,
        bytes calldata _extraData
    ) external payable virtual {
        // @dev Ensure ONLY can be called 'internally'.
        if (msg.sender != address(this)) revert OnlySelf();
        _lzReceiveSimulate(_origin, _guid, _message, _executor, _extraData);
    }

    /**
     * @dev Internal function to handle the OAppPreCrimeSimulator simulated receive.
     * @param _origin The origin information.
     *  - srcEid: The source chain endpoint ID.
     *  - sender: The sender address from the src chain.
     *  - nonce: The nonce of the LayerZero message.
     * @param _guid The GUID of the LayerZero message.
     * @param _message The LayerZero message.
     * @param _executor The address of the off-chain executor.
     * @param _extraData Arbitrary data passed by the msg executor.
     *
     * @dev Enables the preCrime simulator to mock sending lzReceive() messages,
     * routes the msg down from the OAppPreCrimeSimulator, and back up to the OAppReceiver.
     */
    function _lzReceiveSimulate(
        Origin calldata _origin,
        bytes32 _guid,
        bytes calldata _message,
        address _executor,
        bytes calldata _extraData
    ) internal virtual;

    /**
     * @dev checks if the specified peer is considered 'trusted' by the OApp.
     * @param _eid The endpoint Id to check.
     * @param _peer The peer to check.
     * @return Whether the peer passed is considered 'trusted' by the OApp.
     */
    function isPeer(uint32 _eid, bytes32 _peer) public view virtual returns (bool);
}

// node_modules/@layerzerolabs/lz-evm-oapp-v2/contracts/oapp/OApp.sol

// @dev Import the 'MessagingFee' and 'MessagingReceipt' so it's exposed to OApp implementers
// solhint-disable-next-line no-unused-import

// @dev Import the 'Origin' so it's exposed to OApp implementers
// solhint-disable-next-line no-unused-import

/**
 * @title OApp
 * @dev Abstract contract serving as the base for OApp implementation, combining OAppSender and OAppReceiver functionality.
 */
abstract contract OApp is OAppSender, OAppReceiver {
    /**
     * @dev Constructor to initialize the OApp with the provided endpoint and owner.
     * @param _endpoint The address of the LOCAL LayerZero endpoint.
     * @param _delegate The delegate capable of making OApp configurations inside of the endpoint.
     */
    constructor(address _endpoint, address _delegate) OAppCore(_endpoint, _delegate) {}

    /**
     * @notice Retrieves the OApp version information.
     * @return senderVersion The version of the OAppSender.sol implementation.
     * @return receiverVersion The version of the OAppReceiver.sol implementation.
     */
    function oAppVersion()
        public
        pure
        virtual
        override(OAppSender, OAppReceiver)
        returns (uint64 senderVersion, uint64 receiverVersion)
    {
        return (SENDER_VERSION, RECEIVER_VERSION);
    }
}

// dependencies/@stargatefinance-1.0.5/packages/stg-evm-v2/src/interfaces/ITokenMessagingHandler.sol

/// @dev This is an internal interface, defining the function to handle token message from the token messaging contract.
interface ITokenMessagingHandler {
    function receiveTokenBus(
        Origin calldata _origin,
        bytes32 _guid,
        uint8 _seatNumber,
        address _receiver,
        uint64 _amountSD
    ) external;

    function receiveTokenTaxi(
        Origin calldata _origin,
        bytes32 _guid,
        address _receiver,
        uint64 _amountSD,
        bytes calldata _composeMsg
    ) external;
}

// dependencies/@stargatefinance-1.0.5/packages/stg-evm-v2/src/messaging/MessagingBase.sol

abstract contract MessagingBase is OApp, OAppPreCrimeSimulator {
    // max asset id, for the off-chain to get the range of asset id and get the list of stargate impls
    uint16 public maxAssetId;
    mapping(address stargateImpl => uint16 assetId) public assetIds;
    mapping(uint16 assetId => address stargateImpl) public stargateImpls;

    address public planner;

    event AssetIdSet(address stargateImpl, uint16 assetId);
    event MaxAssetIdSet(uint16 maxAssetId);
    event PlannerSet(address planner);

    error Messaging_Unauthorized();
    error Messaging_Unavailable();
    error Messaging_InvalidAssetId();

    modifier onlyPlanner() {
        if (msg.sender != planner) revert Messaging_Unauthorized();
        _;
    }

    constructor(address _endpoint, address _owner) OApp(_endpoint, _owner) {}

    // ---------------------------------- Only Owner ------------------------------------------

    function setAssetId(address _stargateImpl, uint16 _assetId) external onlyOwner {
        if (_assetId == 0) revert Messaging_InvalidAssetId();
        if (_assetId > maxAssetId) {
            maxAssetId = _assetId;
            emit MaxAssetIdSet(_assetId);
        }

        // clean up the old stargate
        uint16 oldAssetId = assetIds[_stargateImpl];
        address oldStargateImpl = stargateImpls[_assetId];
        if (oldAssetId != 0) delete stargateImpls[oldAssetId];
        if (oldStargateImpl != address(0)) delete assetIds[oldStargateImpl];

        // if stargateImpl is address(0) then delete stargateImpls[_assetId]
        if (_stargateImpl == address(0)) {
            delete stargateImpls[_assetId];
        } else {
            // set the new stargate
            assetIds[_stargateImpl] = _assetId;
            stargateImpls[_assetId] = _stargateImpl;
        }
        emit AssetIdSet(_stargateImpl, _assetId);
    }

    /// @dev Update the max asset id manually if it is not set correctly
    function setMaxAssetId(uint16 _maxAssetId) external onlyOwner {
        maxAssetId = _maxAssetId;
        emit MaxAssetIdSet(_maxAssetId);
    }

    function setPlanner(address _planner) external onlyOwner {
        planner = _planner;
        emit PlannerSet(_planner);
    }

    // ---------------------------------- Internal Functions ------------------------------------------

    function _safeGetStargateImpl(uint16 _assetId) internal view returns (address stargate) {
        stargate = stargateImpls[_assetId];
        if (stargate == address(0)) revert Messaging_Unavailable();
    }

    function _safeGetAssetId(address _stargateImpl) internal view returns (uint16 assetId) {
        assetId = assetIds[_stargateImpl];
        if (assetId == 0) revert Messaging_Unavailable();
    }

    /// @dev Lz token is payed in the stargate contract and do nothing here.
    /// Function meant to be overridden
    // solhint-disable-next-line no-empty-blocks
    function _payLzToken(uint256 /*_lzTokenFee*/) internal pure override {}

    // ---------------------------------- PreCrime Functions ------------------------------------------
    function _lzReceiveSimulate(
        Origin calldata _origin,
        bytes32 _guid,
        bytes calldata _message,
        address _executor,
        bytes calldata _extraData
    ) internal override {
        _lzReceive(_origin, _guid, _message, _executor, _extraData);
    }

    function isPeer(uint32 _eid, bytes32 _peer) public view override returns (bool) {
        return _peer == peers[_eid];
    }
}

// dependencies/@stargatefinance-1.0.5/packages/stg-evm-v2/src/StargateBase.sol

// Solidity does not support splitting import across multiple lines
// solhint-disable-next-line max-line-length

/// @title The base contract for StargateOFT, StargatePool, StargatePoolMigratable, and StargatePoolNative.
abstract contract StargateBase is Transfer, IStargate, ITokenMessagingHandler, ICreditMessagingHandler {
    using SafeCast for uint256;

    // Stargate status
    uint8 internal constant NOT_ENTERED = 1;
    uint8 internal constant ENTERED = 2;
    uint8 internal constant PAUSED = 3;

    /// @dev The token for the Pool or OFT.
    /// @dev address(0) indicates native coin, such as ETH.
    address public immutable override token;
    /// @dev The shared decimals (lowest common decimals between chains).
    uint8 public immutable override sharedDecimals;
    /// @dev The rate between local decimals and shared decimals.
    uint256 internal immutable convertRate;

    /// @dev The local LayerZero EndpointV2.
    ILayerZeroEndpointV2 public immutable endpoint;
    /// @dev The local LayerZero endpoint ID
    uint32 public immutable localEid;

    address internal feeLib;
    /// @dev The StargateBase status.  Options include 1. NOT_ENTERED 2. ENTERED and 3. PAUSED.
    uint8 public status = NOT_ENTERED;
    /// @dev The treasury accrued fees, stored in SD.
    uint64 public treasuryFee;

    address internal creditMessaging;
    address internal lzToken;
    address internal planner;
    address internal tokenMessaging;
    address internal treasurer;

    /// @dev Mapping of paths from this chain to other chains identified by their endpoint ID.
    mapping(uint32 eid => Path path) public paths;

    /// @dev A store for tokens that could not be delivered because _outflow() failed.
    /// @dev retryReceiveToken() can be called to retry the receive.
    mapping(bytes32 guid => mapping(uint8 index => bytes32 hash)) public unreceivedTokens;

    modifier onlyCaller(address _caller) {
        if (msg.sender != _caller) revert Stargate_Unauthorized();
        _;
    }

    modifier nonReentrantAndNotPaused() {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        if (status != NOT_ENTERED) {
            if (status == ENTERED) revert Stargate_ReentrantCall();
            revert Stargate_Paused();
        }
        // Any calls to nonReentrant after this point will fail
        status = ENTERED;
        _;
        status = NOT_ENTERED;
    }

    error Stargate_ReentrantCall();
    error Stargate_InvalidTokenDecimals();
    error Stargate_Unauthorized();
    error Stargate_SlippageTooHigh();
    error Stargate_UnreceivedTokenNotFound();
    error Stargate_OutflowFailed();
    error Stargate_InvalidAmount();
    error Stargate_InsufficientFare();
    error Stargate_InvalidPath();
    error Stargate_LzTokenUnavailable();
    error Stargate_Paused();
    error Stargate_RecoverTokenUnsupported();

    event AddressConfigSet(AddressConfig config);
    event CreditsSent(uint32 dstEid, Credit[] credits);
    event CreditsReceived(uint32 srcEid, Credit[] credits);
    event UnreceivedTokenCached(
        bytes32 guid,
        uint8 index,
        uint32 srcEid,
        address receiver,
        uint256 amountLD,
        bytes composeMsg
    );
    event OFTPathSet(uint32 dstEid, bool oft);
    event PauseSet(bool paused);
    event PlannerFeeWithdrawn(uint256 amount);
    event TreasuryFeeAdded(uint64 amountSD);
    event TreasuryFeeWithdrawn(address to, uint64 amountSD);

    struct AddressConfig {
        address feeLib;
        address planner;
        address treasurer;
        address tokenMessaging;
        address creditMessaging;
        address lzToken;
    }

    /// @notice Create a new Stargate contract
    /// @dev Reverts with InvalidTokenDecimals if the token decimals are smaller than the shared decimals.
    /// @param _token The token for the pool or oft. If the token is address(0), it is the native coin
    /// @param _tokenDecimals The number of decimals for this tokens implementation on this chain
    /// @param _sharedDecimals The number of decimals shared between all implementations of the OFT
    /// @param _endpoint The LZ endpoint contract
    /// @param _owner The owner of this contract
    constructor(address _token, uint8 _tokenDecimals, uint8 _sharedDecimals, address _endpoint, address _owner) {
        token = _token;
        if (_tokenDecimals < _sharedDecimals) revert Stargate_InvalidTokenDecimals();
        convertRate = 10 ** (_tokenDecimals - _sharedDecimals);
        sharedDecimals = _sharedDecimals;

        endpoint = ILayerZeroEndpointV2(_endpoint);
        localEid = endpoint.eid();
        _transferOwnership(_owner);
    }

    // ---------------------------------- Only Owner ------------------------------------------

    /// @notice Configure the roles for this contract.
    /// @param _config An AddressConfig object containing the addresses for the different roles used by Stargate.
    function setAddressConfig(AddressConfig calldata _config) external onlyOwner {
        feeLib = _config.feeLib;
        planner = _config.planner;
        treasurer = _config.treasurer;
        tokenMessaging = _config.tokenMessaging;
        creditMessaging = _config.creditMessaging;
        lzToken = _config.lzToken;
        emit AddressConfigSet(_config);
    }

    /// @notice Sets a given Path as using OFT or resets it from OFT.
    /// @dev Set the path as OFT if the remote chain is using OFT.
    /// @dev When migrating from OFT to pool on remote chain (e.g. migrate USDC to circles), reset the path to non-OFT.
    /// @dev Reverts with InvalidPath if the destination chain is the same as local.
    /// @param _dstEid The destination chain endpoint ID
    /// @param _oft Whether to set or reset the path
    function setOFTPath(uint32 _dstEid, bool _oft) external onlyOwner {
        if (_dstEid == localEid) revert Stargate_InvalidPath();
        paths[_dstEid].setOFTPath(_oft);
        emit OFTPathSet(_dstEid, _oft);
    }

    // ---------------------------------- Only Treasurer ------------------------------------------

    /// @notice Withdraw from the accrued fees in the treasury.
    /// @param _to The destination account
    /// @param _amountSD The amount to withdraw in SD
    function withdrawTreasuryFee(address _to, uint64 _amountSD) external onlyCaller(treasurer) {
        treasuryFee -= _amountSD;
        _safeOutflow(_to, _sd2ld(_amountSD));
        emit TreasuryFeeWithdrawn(_to, _amountSD);
    }

    /// @notice Add tokens to the treasury, from the senders account.
    /// @dev Only used for increasing the overall budget for transaction rewards
    /// @dev The treasuryFee is essentially the reward pool.
    /// @dev Rewards are capped to the treasury amount, which limits exposure so
    /// @dev Stargate does not pay beyond what it's charged.
    /// @param _amountLD The amount to add in LD
    function addTreasuryFee(uint256 _amountLD) external payable onlyCaller(treasurer) {
        _assertMsgValue(_amountLD);
        uint64 amountSD = _inflow(msg.sender, _amountLD);
        treasuryFee += amountSD;
        emit TreasuryFeeAdded(amountSD);
    }

    /// @dev Recover tokens sent to this contract by mistake.
    /// @dev Only the treasurer can recover the token.
    /// @dev Reverts with Stargate_RecoverTokenUnsupported if the treasurer attempts to withdraw StargateBase.token().
    /// @param _token the token to recover. if 0x0 then it is native token
    /// @param _to the address to send the token to
    /// @param _amount the amount to send
    function recoverToken(
        address _token,
        address _to,
        uint256 _amount
    ) public virtual nonReentrantAndNotPaused onlyCaller(treasurer) returns (uint256) {
        /// @dev Excess native is considered planner accumulated fees.
        if (_token == address(0)) revert Stargate_RecoverTokenUnsupported();
        Transfer.safeTransfer(_token, _to, _amount, false);
        return _amount;
    }

    // ---------------------------------- Only Planner ------------------------------------------

    /// @notice Pause or unpause a Stargate
    /// @dev Be careful with this call, as it unsets the re-entry guard.
    /// @param _paused Whether to pause or unpause the stargate
    function setPause(bool _paused) external onlyCaller(planner) {
        if (status == ENTERED) revert Stargate_ReentrantCall();
        status = _paused ? PAUSED : NOT_ENTERED;
        emit PauseSet(_paused);
    }

    function _plannerFee() internal view virtual returns (uint256) {
        return address(this).balance;
    }

    function plannerFee() external view returns (uint256 available) {
        available = _plannerFee();
    }

    /// @notice Withdraw planner fees accumulated in StargateBase.
    /// @dev The planner fee is accumulated in StargateBase to avoid the cost of passing msg.value to TokenMessaging.
    function withdrawPlannerFee() external virtual onlyCaller(planner) {
        uint256 available = _plannerFee();
        Transfer.safeTransferNative(msg.sender, available, false);
        emit PlannerFeeWithdrawn(available);
    }

    // ------------------------------- Public Functions ---------------------------------------

    /// @notice Send tokens through the Stargate
    /// @dev Emits OFTSent when the send is successful
    /// @param _sendParam The SendParam object detailing the transaction
    /// @param _fee The MessagingFee object describing the fee to pay
    /// @param _refundAddress The address to refund any LZ fees paid in excess
    /// @return msgReceipt The receipt proving the message was sent
    /// @return oftReceipt The receipt proving the OFT swap
    function send(
        SendParam calldata _sendParam,
        MessagingFee calldata _fee,
        address _refundAddress
    ) external payable override returns (MessagingReceipt memory msgReceipt, OFTReceipt memory oftReceipt) {
        (msgReceipt, oftReceipt, ) = sendToken(_sendParam, _fee, _refundAddress);
    }

    function sendToken(
        SendParam calldata _sendParam,
        MessagingFee calldata _fee,
        address _refundAddress
    )
        public
        payable
        override
        nonReentrantAndNotPaused
        returns (MessagingReceipt memory msgReceipt, OFTReceipt memory oftReceipt, Ticket memory ticket)
    {
        // step 1: assets inflows and apply the fee to the input amount
        (bool isTaxi, uint64 amountInSD, uint64 amountOutSD) = _inflowAndCharge(_sendParam);

        // step 2: generate the oft receipt
        oftReceipt = OFTReceipt(_sd2ld(amountInSD), _sd2ld(amountOutSD));

        // step 3: assert the messaging fee
        MessagingFee memory messagingFee = _assertMessagingFee(_fee, oftReceipt.amountSentLD);

        // step 4: send the token depending on the mode Taxi or Bus
        if (isTaxi) {
            msgReceipt = _taxi(_sendParam, messagingFee, amountOutSD, _refundAddress);
        } else {
            (msgReceipt, ticket) = _rideBus(_sendParam, messagingFee, amountOutSD, _refundAddress);
        }

        emit OFTSent(
            msgReceipt.guid,
            _sendParam.dstEid,
            msg.sender,
            oftReceipt.amountSentLD,
            oftReceipt.amountReceivedLD
        );
    }

    /// @notice Retry receiving a token that initially failed.
    /// @dev The message has been delivered by the Messaging layer, so it is ok for anyone to retry.
    /// @dev try to receive the token if the previous attempt failed in lzReceive
    /// @dev Reverts with UnreceivedTokenNotFound if the message is not found in the cache
    /// @dev Emits OFTReceived if the receive succeeds
    /// @param _guid The global unique ID for the message that failed
    /// @param _index The index of the message that failed
    /// @param _srcEid The source endpoint ID for the message that failed
    /// @param _receiver The account receiver for the message that failed
    /// @param _amountLD The amount of tokens in LD to transfer to the account
    /// @param _composeMsg The bytes representing the compose message in the message that failed
    function retryReceiveToken(
        bytes32 _guid,
        uint8 _index,
        uint32 _srcEid,
        address _receiver,
        uint256 _amountLD,
        bytes calldata _composeMsg
    ) external nonReentrantAndNotPaused {
        if (unreceivedTokens[_guid][_index] != keccak256(abi.encodePacked(_srcEid, _receiver, _amountLD, _composeMsg)))
            revert Stargate_UnreceivedTokenNotFound();
        delete unreceivedTokens[_guid][_index];

        _safeOutflow(_receiver, _amountLD);
        _postOutflow(_ld2sd(_amountLD));
        if (_composeMsg.length > 0) {
            endpoint.sendCompose(_receiver, _guid, 0, _composeMsg);
        }
        emit OFTReceived(_guid, _srcEid, _receiver, _amountLD);
    }

    // ------------------------------- Only Messaging ---------------------------------------

    /// @notice Entrypoint for receiving tokens
    /// @dev Emits OFTReceived when the OFT token is correctly received
    /// @dev Emits UnreceivedTokenCached when the OFT token is not received
    /// @param _origin The Origin struct describing the origin, useful for composing
    /// @param _guid The global unique ID for this message, useful for composing
    function receiveTokenBus(
        Origin calldata _origin,
        bytes32 _guid,
        uint8 _seatNumber,
        address _receiver,
        uint64 _amountSD
    ) external nonReentrantAndNotPaused onlyCaller(tokenMessaging) {
        uint256 amountLD = _sd2ld(_amountSD);

        bool success = _outflow(_receiver, amountLD);
        if (success) {
            _postOutflow(_amountSD);
            emit OFTReceived(_guid, _origin.srcEid, _receiver, amountLD);
        } else {
            /**
             * @dev The busRide mode does not support composeMsg in any form. Thus we hardcode it to ""
             */
            unreceivedTokens[_guid][_seatNumber] = keccak256(abi.encodePacked(_origin.srcEid, _receiver, amountLD, ""));
            emit UnreceivedTokenCached(_guid, _seatNumber, _origin.srcEid, _receiver, amountLD, "");
        }
    }

    // taxi mode
    function receiveTokenTaxi(
        Origin calldata _origin,
        bytes32 _guid,
        address _receiver,
        uint64 _amountSD,
        bytes calldata _composeMsg
    ) external nonReentrantAndNotPaused onlyCaller(tokenMessaging) {
        uint256 amountLD = _sd2ld(_amountSD);
        bool hasCompose = _composeMsg.length > 0;
        bytes memory composeMsg;
        if (hasCompose) {
            composeMsg = OFTComposeMsgCodec.encode(_origin.nonce, _origin.srcEid, amountLD, _composeMsg);
        }

        bool success = _outflow(_receiver, amountLD);
        if (success) {
            _postOutflow(_amountSD);
            // send the composeMsg to the endpoint
            if (hasCompose) {
                endpoint.sendCompose(_receiver, _guid, 0, composeMsg);
            }
            emit OFTReceived(_guid, _origin.srcEid, _receiver, amountLD);
        } else {
            /**
             * @dev We use the '0' index to represent the seat number. This is because for a type 'taxi' msg,
             *      there is only ever one corresponding receiveTokenTaxi function per GUID.
             */
            unreceivedTokens[_guid][0] = keccak256(abi.encodePacked(_origin.srcEid, _receiver, amountLD, composeMsg));
            emit UnreceivedTokenCached(_guid, 0, _origin.srcEid, _receiver, amountLD, composeMsg);
        }
    }

    function sendCredits(
        uint32 _dstEid,
        TargetCredit[] calldata _credits
    ) external nonReentrantAndNotPaused onlyCaller(creditMessaging) returns (Credit[] memory) {
        Credit[] memory credits = new Credit[](_credits.length);
        uint256 index = 0;
        for (uint256 i = 0; i < _credits.length; i++) {
            TargetCredit calldata c = _credits[i];
            uint64 decreased = paths[c.srcEid].tryDecreaseCredit(c.amount, c.minAmount);
            if (decreased > 0) credits[index++] = Credit(c.srcEid, decreased);
        }
        // resize the array to the actual number of credits
        assembly {
            mstore(credits, index)
        }
        emit CreditsSent(_dstEid, credits);
        return credits;
    }

    /// @notice Entrypoint for receiving credits into paths
    /// @dev Emits CreditsReceived when credits are received
    /// @param _srcEid The endpoint ID of the source of credits
    /// @param _credits An array indicating to which paths and how much credits to add
    function receiveCredits(
        uint32 _srcEid,
        Credit[] calldata _credits
    ) external nonReentrantAndNotPaused onlyCaller(creditMessaging) {
        for (uint256 i = 0; i < _credits.length; i++) {
            Credit calldata c = _credits[i];
            paths[c.srcEid].increaseCredit(c.amount);
        }
        emit CreditsReceived(_srcEid, _credits);
    }

    // ---------------------------------- View Functions ------------------------------------------

    /// @notice Provides a quote for sending OFT to another chain.
    /// @dev Implements the IOFT interface
    /// @param _sendParam The parameters for the send operation
    /// @return limit The information on OFT transfer limits
    /// @return oftFeeDetails The details of OFT transaction cost or reward
    /// @return receipt The OFT receipt information, indicating how many tokens would be sent and received
    function quoteOFT(
        SendParam calldata _sendParam
    ) external view returns (OFTLimit memory limit, OFTFeeDetail[] memory oftFeeDetails, OFTReceipt memory receipt) {
        // cap the transfer to the paths limit
        limit = OFTLimit(_sd2ld(1), _sd2ld(paths[_sendParam.dstEid].credit));

        // get the expected amount in the destination chain from FeeLib
        uint64 amountInSD = _ld2sd(_sendParam.amountLD > limit.maxAmountLD ? limit.maxAmountLD : _sendParam.amountLD);
        FeeParams memory params = _buildFeeParams(_sendParam.dstEid, amountInSD, _isTaxiMode(_sendParam.oftCmd));
        uint64 amountOutSD = IStargateFeeLib(feeLib).applyFeeView(params);

        // fill in the FeeDetails if there is a fee or reward
        if (amountOutSD != amountInSD) {
            oftFeeDetails = new OFTFeeDetail[](1);
            if (amountOutSD < amountInSD) {
                // fee
                oftFeeDetails[0] = OFTFeeDetail(-1 * _sd2ld(amountInSD - amountOutSD).toInt256(), "protocol fee");
            } else if (amountOutSD > amountInSD) {
                // reward
                uint64 reward = amountOutSD - amountInSD;
                (amountOutSD, reward) = _capReward(amountOutSD, reward);
                if (amountOutSD == amountInSD) {
                    // hide the Fee detail if the reward is capped to 0
                    oftFeeDetails = new OFTFeeDetail[](0);
                } else {
                    oftFeeDetails[0] = OFTFeeDetail(_sd2ld(reward).toInt256(), "reward");
                }
            }
        }

        receipt = OFTReceipt(_sd2ld(amountInSD), _sd2ld(amountOutSD));
    }

    /// @notice Provides a quote for the send() operation.
    /// @dev Implements the IOFT interface.
    /// @dev Reverts with InvalidAmount if send mode is drive but value is specified.
    /// @param _sendParam The parameters for the send() operation
    /// @param _payInLzToken Flag indicating whether the caller is paying in the LZ token
    /// @return fee The calculated LayerZero messaging fee from the send() operation
    /// @dev MessagingFee: LayerZero message fee
    ///   - nativeFee: The native fee.
    ///   - lzTokenFee: The LZ token fee.
    function quoteSend(
        SendParam calldata _sendParam,
        bool _payInLzToken
    ) external view returns (MessagingFee memory fee) {
        uint64 amountSD = _ld2sd(_sendParam.amountLD);
        if (amountSD == 0) revert Stargate_InvalidAmount();

        bool isTaxi = _isTaxiMode(_sendParam.oftCmd);
        if (isTaxi) {
            fee = ITokenMessaging(tokenMessaging).quoteTaxi(
                TaxiParams({
                    sender: msg.sender,
                    dstEid: _sendParam.dstEid,
                    receiver: _sendParam.to,
                    amountSD: amountSD,
                    composeMsg: _sendParam.composeMsg,
                    extraOptions: _sendParam.extraOptions
                }),
                _payInLzToken
            );
        } else {
            bool nativeDrop = _sendParam.extraOptions.length > 0;
            fee = ITokenMessaging(tokenMessaging).quoteRideBus(_sendParam.dstEid, nativeDrop);
        }
    }

    /// @notice Returns the current roles configured.
    /// @return An AddressConfig struct containing the current configuration
    function getAddressConfig() external view returns (AddressConfig memory) {
        return
            AddressConfig({
                feeLib: feeLib,
                planner: planner,
                treasurer: treasurer,
                tokenMessaging: tokenMessaging,
                creditMessaging: creditMessaging,
                lzToken: lzToken
            });
    }

    /// @notice Get the OFT version information
    /// @dev Implements the IOFT interface.
    /// @dev 0 version means the message encoding is not compatible with the default OFT.
    /// @return interfaceId The ERC165 interface ID for this contract
    /// @return version The cross-chain compatible message encoding version.
    function oftVersion() external pure override returns (bytes4 interfaceId, uint64 version) {
        return (type(IOFT).interfaceId, 0);
    }

    /// @notice Indicates whether the OFT contract requires approval of the 'token()' to send.
    /// @dev Implements the IOFT interface.
    /// @return Whether approval of the underlying token implementation is required
    function approvalRequired() external pure override returns (bool) {
        return true;
    }

    // ---------------------------------- Internal Functions ------------------------------------------

    /// @notice Ingest value into the contract and charge the Stargate fee.
    /// @dev This is triggered when value is transferred from an account into Stargate to execute a swap.
    /// @param _sendParam A SendParam struct containing the swap information
    function _inflowAndCharge(
        SendParam calldata _sendParam
    ) internal returns (bool isTaxi, uint64 amountInSD, uint64 amountOutSD) {
        isTaxi = _isTaxiMode(_sendParam.oftCmd);
        amountInSD = _inflow(msg.sender, _sendParam.amountLD);

        FeeParams memory feeParams = _buildFeeParams(_sendParam.dstEid, amountInSD, isTaxi);

        amountOutSD = _chargeFee(feeParams, _ld2sd(_sendParam.minAmountLD));

        paths[_sendParam.dstEid].decreaseCredit(amountOutSD); // remove the credit from the path
        _postInflow(amountOutSD); // post inflow actions with the amount deducted by the fee
    }

    /// @notice Consult the FeeLib the fee/reward for sending this token
    /// @dev Reverts with SlippageTooHigh when the slippage amount sent would be below the desired minimum or zero.
    /// @return amountOutSD The actual amount that would be sent after applying fees/rewards
    function _chargeFee(FeeParams memory _feeParams, uint64 _minAmountOutSD) internal returns (uint64 amountOutSD) {
        // get the output amount from the fee library
        amountOutSD = IStargateFeeLib(feeLib).applyFee(_feeParams);

        uint64 amountInSD = _feeParams.amountInSD;
        if (amountOutSD < amountInSD) {
            // fee
            treasuryFee += amountInSD - amountOutSD;
        } else if (amountOutSD > amountInSD) {
            // reward
            uint64 reward = amountOutSD - amountInSD;
            (amountOutSD, reward) = _capReward(amountOutSD, reward);
            if (reward > 0) treasuryFee -= reward;
        }

        if (amountOutSD < _minAmountOutSD || amountOutSD == 0) revert Stargate_SlippageTooHigh(); // 0 not allowed
    }

    function _taxi(
        SendParam calldata _sendParam,
        MessagingFee memory _messagingFee,
        uint64 _amountSD,
        address _refundAddress
    ) internal returns (MessagingReceipt memory receipt) {
        if (_messagingFee.lzTokenFee > 0) _payLzToken(_messagingFee.lzTokenFee); // handle lz token fee

        receipt = ITokenMessaging(tokenMessaging).taxi{ value: _messagingFee.nativeFee }(
            TaxiParams({
                sender: msg.sender,
                dstEid: _sendParam.dstEid,
                receiver: _sendParam.to,
                amountSD: _amountSD,
                composeMsg: _sendParam.composeMsg,
                extraOptions: _sendParam.extraOptions
            }),
            _messagingFee,
            _refundAddress
        );
    }

    function _rideBus(
        SendParam calldata _sendParam,
        MessagingFee memory _messagingFee,
        uint64 _amountSD,
        address _refundAddress
    ) internal virtual returns (MessagingReceipt memory receipt, Ticket memory ticket) {
        if (_messagingFee.lzTokenFee > 0) revert Stargate_LzTokenUnavailable();

        (receipt, ticket) = ITokenMessaging(tokenMessaging).rideBus(
            RideBusParams({
                sender: msg.sender,
                dstEid: _sendParam.dstEid,
                receiver: _sendParam.to,
                amountSD: _amountSD,
                nativeDrop: _sendParam.extraOptions.length > 0
            })
        );

        uint256 busFare = receipt.fee.nativeFee;
        uint256 providedFare = _messagingFee.nativeFee;

        // assert sufficient nativeFee was provided to cover the fare
        if (busFare == providedFare) {
            // return; Do nothing in this case
        } else if (providedFare > busFare) {
            uint256 refund;
            unchecked {
                refund = providedFare - busFare;
            }
            Transfer.transferNative(_refundAddress, refund, false); // no gas limit to refund
        } else {
            revert Stargate_InsufficientFare();
        }
    }

    /// @notice Pay the LZ fee in LZ tokens.
    /// @dev Reverts with LzTokenUnavailable if the LZ token OFT has not been set.
    /// @param _lzTokenFee The fee to pay in LZ tokens
    function _payLzToken(uint256 _lzTokenFee) internal {
        address lzTkn = lzToken;
        if (lzTkn == address(0)) revert Stargate_LzTokenUnavailable();
        Transfer.safeTransferTokenFrom(lzTkn, msg.sender, address(endpoint), _lzTokenFee);
    }

    /// @notice Translate an amount in SD to LD
    /// @dev Since SD <= LD by definition, convertRate >= 1, so there is no rounding errors in this function.
    /// @param _amountSD The amount in SD
    /// @return amountLD The same value expressed in LD
    function _sd2ld(uint64 _amountSD) internal view returns (uint256 amountLD) {
        unchecked {
            amountLD = _amountSD * convertRate;
        }
    }

    /// @notice Translate an value in LD to SD
    /// @dev Since SD <= LD by definition, convertRate >= 1, so there might be rounding during the cast.
    /// @param _amountLD The value in LD
    /// @return amountSD The same value expressed in SD
    function _ld2sd(uint256 _amountLD) internal view returns (uint64 amountSD) {
        unchecked {
            amountSD = SafeCast.toUint64(_amountLD / convertRate);
        }
    }

    /// @dev if _cmd is empty, Taxi mode. Otherwise, Bus mode
    function _isTaxiMode(bytes calldata _oftCmd) internal pure returns (bool) {
        return _oftCmd.length == 0;
    }

    // ---------------------------------- Virtual Functions ------------------------------------------

    /// @notice Limits the reward awarded when withdrawing value.
    /// @param _amountOutSD The amount of expected on the destination chain in SD
    /// @param _reward The initial calculated reward by FeeLib
    /// @return newAmountOutSD The actual amount to be delivered on the destination chain
    /// @return newReward The actual reward after applying any caps
    function _capReward(
        uint64 _amountOutSD,
        uint64 _reward
    ) internal view virtual returns (uint64 newAmountOutSD, uint64 newReward);

    /// @notice Hook called when there is ingress of value into the contract.
    /// @param _from The account from which to obtain the value
    /// @param _amountLD The amount of tokens to get from the account in LD
    /// @return amountSD The actual amount of tokens in SD that got into the Stargate
    function _inflow(address _from, uint256 _amountLD) internal virtual returns (uint64 amountSD);

    /// @notice Hook called when there is egress of value out of the contract.
    /// @return success Whether the outflow was successful
    function _outflow(address _to, uint256 _amountLD) internal virtual returns (bool success);

    /// @notice Hook called when there is egress of value out of the contract.
    /// @dev Reverts with OutflowFailed when the outflow hook fails
    function _safeOutflow(address _to, uint256 _amountLD) internal virtual {
        bool success = _outflow(_to, _amountLD);
        if (!success) revert Stargate_OutflowFailed();
    }

    /// @notice Ensure that the value passed through the message equals the native fee
    /// @dev the native fee should be the same as msg value by default
    /// @dev Reverts with InvalidAmount if the native fee does not match the value passed.
    /// @param _fee The MessagingFee object containing the expected fee
    /// @return The messaging fee object
    function _assertMessagingFee(
        MessagingFee memory _fee,
        uint256 /*_amountInLD*/
    ) internal view virtual returns (MessagingFee memory) {
        if (_fee.nativeFee != msg.value) revert Stargate_InvalidAmount();
        return _fee;
    }

    /// @notice Ensure the msg.value is as expected.
    /// @dev Override this contract to provide a specific validation.
    /// @dev This implementation will revert if value is passed, because we do not expect value except for
    /// @dev the native token when adding to the treasury.
    /// @dev Reverts with InvalidAmount if msg.value > 0
    function _assertMsgValue(uint256 /*_amountLD*/) internal view virtual {
        if (msg.value > 0) revert Stargate_InvalidAmount();
    }

    /// @dev Build the FeeParams object for the FeeLib
    /// @param _dstEid The destination endpoint ID
    /// @param _amountInSD The amount to send in SD
    /// @param _isTaxi Whether this send is riding the bus or taxing
    function _buildFeeParams(
        uint32 _dstEid,
        uint64 _amountInSD,
        bool _isTaxi
    ) internal view virtual returns (FeeParams memory);

    /// @notice Hook called after the inflow of value into the contract by sendToken().
    /// Function meant to be overridden
    // solhint-disable-next-line no-empty-blocks
    function _postInflow(uint64 _amountSD) internal virtual {}

    /// @notice Hook called after the outflow of value out of the contract by receiveToken().
    /// Function meant to be overridden
    // solhint-disable-next-line no-empty-blocks
    function _postOutflow(uint64 _amountSD) internal virtual {}
}

// src/StargateAdapter.sol

contract StargateAdapter is
    IStargateAdapter,
    ILayerZeroComposer,
    ERC165Registry,
    Ownable
{
    using SafeERC20 for ERC20;
    using OptionsBuilder for bytes;
    using ERC165Checker for address;

    bytes4 constant StargateAdapterInterfaceId =
        bytes4(keccak256("MAAT.V1.StargateAdapter"));
    bytes4 constant TokenVaultInterfaceId =
        bytes4(keccak256("MAAT.V1.TokenVault"));

    error AddressIsNotATokenVault(address);
    error AddressIsNotAStargatePool(address);

    uint32 public srcEid;
    bytes internal lzExtraOptions;
    address public lzEndpoint;

    address public commander;

    mapping(uint32 dstEid => address) internal _dstAdapters;

    mapping(uint32 poolId => address) internal _stargateByPoolId;
    mapping(address token => address) internal _stargateByToken;

    mapping(address token => address) internal _srcVaults;

    mapping(uint32 poolId => address token) internal _srcTokens;
    mapping(address token => uint32 poolId) internal _poolIds;

    /* ======== MODIFIERS ======== */

    modifier onlyVault(address sender, address token) {
        require(
            sender == _srcVaults[token],
            "StargateAdapter: Caller is not vault"
        );
        _;
    }

    modifier onlyVaultOrAdmin(address sender, address token) {
        require(
            sender == _srcVaults[token] || sender == owner(),
            "StargateAdapter: Caller is not vault or admin"
        );
        _;
    }

    modifier onlyLzEndpoint(address srcSender) {
        require(
            srcSender == lzEndpoint,
            "StargateAdapter: Caller is not endpoint"
        );
        _;
    }
    /* ======== CONSTRUCTOR ======== */

    constructor(
        address _admin,
        uint32 _srcEid,
        address _commander,
        address _lzEndpoint
    ) Ownable() {
        srcEid = _srcEid;
        commander = _commander;
        lzEndpoint = _lzEndpoint;

        setLzExtraOptions(0, 300_000, 0);
        _registerInterface(StargateAdapterInterfaceId);

        transferOwnership(_admin);
    }

    /* ======== SEND TOKENS FUNCTION ======== */

    function sendTokens(
        uint32 _dstEid,
        address _token,
        uint _amountLD,
        bytes32 _intentionId
    ) external onlyVaultOrAdmin(msg.sender, _token) {
        require(
            _dstAdapters[_dstEid] != address(0),
            "StargateAdapter: dstAdapter for eid not set."
        );

        bytes memory composeMsg = abi.encode(_poolIds[_token], _intentionId);

        (MessagingReceipt memory msgReceipt, ) = _sendTokens(
            _dstEid,
            _token,
            _amountLD,
            composeMsg,
            _dstAdapters[_dstEid]
        );
        emit BridgeTokens(
            msgReceipt.guid,
            _intentionId,
            _dstEid,
            _poolIds[_token],
            _token,
            _amountLD,
            msgReceipt.fee.nativeFee
        );
    }

    function sendTokensToReceiver(
        uint32 _dstEid,
        address _token,
        uint _amountLD,
        address _receiver
    ) external onlyVaultOrAdmin(msg.sender, _token) {
        (MessagingReceipt memory msgReceipt, ) = _sendTokens(
            _dstEid,
            _token,
            _amountLD,
            "",
            _receiver
        );
        emit BridgeTokensToReceiver(
            msgReceipt.guid,
            _dstEid,
            _poolIds[_token],
            _amountLD,
            _receiver
        );
    }

    /* ======== RECEIVE TOKENS FUNCTION ======== */
    function lzCompose(
        address _from,
        bytes32 _guid,
        bytes calldata _message,
        address _executor,
        bytes calldata _extraData
    ) external payable onlyLzEndpoint(msg.sender) {
        uint256 receivedAmountLD = OFTComposeMsgCodec.amountLD(_message);
        bytes memory _composeMessage = OFTComposeMsgCodec.composeMsg(_message);
        (uint32 poolId, bytes32 intentionId) = abi.decode(
            _composeMessage,
            (uint32, bytes32)
        );

        address srcErc20 = IStargate(_stargateByPoolId[poolId]).token();
        uint erc20Balance = ERC20(srcErc20).balanceOf(address(this));

        require(
            erc20Balance >= receivedAmountLD,
            "StargateAdapter: Insufficient balance for bridge."
        );

        emit ReceivedOnDestination(
            _from,
            _guid,
            receivedAmountLD,
            _executor,
            _extraData,
            intentionId
        );

        _depositOnDstChain(srcErc20, receivedAmountLD, intentionId);
    }

    /* ======== ADMIN FUNCTIONS ======== */

    function depositOnDstChain(
        address _token,
        uint _amount,
        bytes32 _intentionId
    ) external onlyVaultOrAdmin(msg.sender, _token) returns (bool success) {
        success = _depositOnDstChain(_token, _amount, _intentionId);
    }

    function withdraw(address to, uint amount) external onlyOwner {
        require(
            amount <= address(this).balance,
            "StargateAdapter: Insufficient balance for withdraw."
        );
        (bool success, ) = payable(to).call{value: amount}("");
        require(success, "StargateAdapter: withdrawal failed");
    }

    function sweep(address to, address token, uint amount) external onlyOwner {
        require(
            amount <= ERC20(token).balanceOf(address(this)),
            "StargateAdapter: Insufficient token balance for sweep."
        );
        ERC20(token).safeTransfer(to, amount);
    }

    /* ======== SETUP FUNCTIONS ======== */

    function setDstAdapter(
        uint32 _dstEid,
        address _dstAdapterAddress
    ) external onlyOwner {
        _dstAdapters[_dstEid] = _dstAdapterAddress;
        emit SetDstAdapter(_dstEid, _dstAdapterAddress);
    }

    function setStargate(address _stargate) external onlyOwner {
        // _validateStargatePool(_stargate);

        uint32 poolId = _getPoolIdFromStargate(_stargate);
        address token = _getTokenFromStargate(_stargate);
        _setStargate(poolId, token, _stargate);
        setPoolId(poolId, token);
    }

    function setVault(address _token, address _vault) external onlyOwner {
        _validateTokenVaultInterface(_vault);

        _srcVaults[_token] = _vault;
        emit SetVault(_token, _vault);
    }

    function setPoolId(uint32 _poolId, address _token) public onlyOwner {
        _srcTokens[_poolId] = _token;
        _poolIds[_token] = _poolId;

        emit SetPoolId(_poolId, _token);
    }

    function setLzExtraOptions(
        uint16 _index,
        uint128 _gas,
        uint128 _value
    ) public onlyOwner {
        lzExtraOptions = OptionsBuilder.newOptions().addExecutorLzComposeOption(
            _index,
            _gas,
            _value
        );
    }

    function setCommander(address _commander) external onlyOwner {
        commander = _commander;
    }

    /* ======== VIEW FUNCTIONS ======== */
    function isDstEidSupported(uint32 dstEid) external view returns (bool) {
        return _dstAdapters[dstEid] != address(0);
    }

    function getDstAdapter(uint32 dstEid) external view returns (address) {
        return _dstAdapters[dstEid];
    }

    function getStargateByPoolId(
        uint32 poolId
    ) external view returns (address) {
        return _stargateByPoolId[poolId];
    }

    function getStargateByToken(address token) external view returns (address) {
        return _stargateByToken[token];
    }

    function getVault(address token) external view returns (address) {
        return _srcVaults[token];
    }

    function getTokenByPoolId(uint32 poolId) external view returns (address) {
        return _srcTokens[poolId];
    }

    function getPoolIdByToken(address token) external view returns (uint32) {
        return _poolIds[token];
    }

    /* ======== INTERNAL FUNCTIONS ======== */

    function _sendTokens(
        uint32 _dstEid,
        address _token,
        uint _amountLD,
        bytes memory composeMsg,
        address _receiver
    )
        internal
        returns (
            MessagingReceipt memory msgReceipt,
            OFTReceipt memory oftReceipt
        )
    {
        require(
            _stargateByToken[_token] != address(0),
            "StargateAdapter: stargate not set for token."
        );

        address stargate = _stargateByToken[_token];
        ERC20 srcERC20 = ERC20(_token);

        require(
            srcERC20.allowance(msg.sender, address(this)) >= _amountLD,
            "StargateAdapter: Insufficient allowance for bridge."
        );
        srcERC20.safeTransferFrom(msg.sender, address(this), _amountLD);
        srcERC20.approve(stargate, _amountLD);

        (
            uint256 valueToSend,
            SendParam memory sendParam,
            MessagingFee memory messagingFee
        ) = _prepareSendParams(
                stargate,
                _dstEid,
                _amountLD,
                _receiver,
                composeMsg
            );

        require(
            address(this).balance >= valueToSend,
            "StargateAdapter: Insufficient balance for bridge."
        );

        (msgReceipt, oftReceipt) = IStargate(stargate).send{value: valueToSend}(
            sendParam,
            messagingFee,
            _receiver
        );
    }

    function _prepareSendParams(
        address _stargate,
        uint32 _dstEid,
        uint _amountLD,
        address _receiver,
        bytes memory _composeMsg
    )
        internal
        view
        returns (
            uint256 valueToSend,
            SendParam memory sendParam,
            MessagingFee memory messagingFee
        )
    {
        IStargate stargate = IStargate(_stargate);
        bytes memory extraOptions = _composeMsg.length > 0
            ? lzExtraOptions
            : bytes("");

        sendParam = SendParam({
            dstEid: _dstEid,
            to: _addressToBytes32(_receiver),
            amountLD: _amountLD,
            minAmountLD: _amountLD,
            extraOptions: extraOptions,
            composeMsg: _composeMsg,
            oftCmd: ""
        });

        (, , OFTReceipt memory receipt) = stargate.quoteOFT(sendParam);
        sendParam.minAmountLD = receipt.amountReceivedLD;

        messagingFee = stargate.quoteSend(sendParam, false);
        valueToSend = messagingFee.nativeFee;

        if (stargate.token() == address(0x0)) {
            valueToSend += sendParam.amountLD;
        }
    }

    function _addressToBytes32(address _addr) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(_addr)));
    }

    function _depositOnDstChain(
        address _token,
        uint _amount,
        bytes32 _intentionId
    ) internal returns (bool success) {
        address vault = _srcVaults[_token];
        ERC20(_token).approve(vault, _amount);
        (success, ) = vault.call(
            abi.encodeWithSignature(
                "finishBridge(uint256,bytes32)",
                _amount,
                _intentionId
            )
        );
        require(success, "StargateAdapter: Deposit failed.");
    }

    function _setStargate(
        uint32 _poolId,
        address _token,
        address _stargate
    ) internal {
        _stargateByPoolId[_poolId] = _stargate;
        _stargateByToken[_token] = _stargate;

        emit SetStargate(_poolId, _stargate);
    }

    function _getPoolIdFromStargate(
        address _stargate
    ) internal view returns (uint32 poolId) {
        StargateBase.AddressConfig memory addressConfig = StargateBase(
            _stargate
        ).getAddressConfig();
        address tokenMessaging = addressConfig.tokenMessaging;

        poolId = MessagingBase(tokenMessaging).assetIds(_stargate);
    }

    function _getTokenFromStargate(
        address _stargate
    ) internal view returns (address token) {
        token = IStargate(_stargate).token();
    }

    function _getLzEndpointFromStargate(
        address _stargate
    ) internal returns (address endpoint) {
        (bool success, bytes memory data) = _stargate.call("endpoint()");
        require(
            success,
            "StargateAdapter: Could not get lzEndpoint from Stargate"
        );
        endpoint = abi.decode(data, (address));
    }

    /* ======== VALIDATION ======== */
    function _validateTokenVaultInterface(address vault) internal view {
        if (!vault.supportsInterface(TokenVaultInterfaceId))
            revert AddressIsNotATokenVault(vault);
    }

    function _validateStargatePool(address stargate) internal {
        if (_getLzEndpointFromStargate(stargate) != lzEndpoint)
            revert AddressIsNotAStargatePool(stargate);
    }

    // fallback() external payable {}
    receive() external payable {}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20 ^0.8.25;

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

// src/periphery/MaatOracleGlobalPPS.sol

contract MaatOracleGlobalPPS is IMaatOracleGlobalPPS, Ownable, ERC165Registry {
    bytes4 constant MaatOracleGlobalPPSInterfaceId =
        bytes4(keccak256("MAAT.V1.MaatOracle"));

    ///@dev DELTA_PPS_PER_SECOND determines how much the PPS can change over time
    uint public DELTA_PPS_PER_SECOND; //RECOMMENDED VALUE: 116 (116 -> 10% APR Per Day)

    uint private constant _decimals = 8;

    mapping(address token => bool) public isInitialized;

    mapping(address => PricePerShare) public globalPricePerShare;

    constructor(address admin, uint delta) Ownable(admin) {
        DELTA_PPS_PER_SECOND = delta;
        _registerInterface(MaatOracleGlobalPPSInterfaceId);
    }

    /* ========== INIT ========== */
    function initPPS(address token) external {
        require(
            !isInitialized[token],
            "[OracleGlobalPPS]: PricePerShare for this token already initialized"
        );
        _updatePPS(10 ** 8, token);
        _updatePPS(10 ** 8, token);

        isInitialized[token] = true;

        uint32 _lastUpdateTime = globalPricePerShare[token].lastUpdateTime;

        emit UpdatePPS(
            token,
            globalPricePerShare[token].pricePerShare,
            globalPricePerShare[token].prevPricePerShare,
            _lastUpdateTime
        );
    }

    /* ========== UPDATE PPS FUNCTION ========== */
    function updateGlobalPPS(
        address token,
        uint112 newPricePerShare
    ) external onlyOwner {
        uint112 pricePerShare = globalPricePerShare[token].pricePerShare;
        uint32 _lastUpdateTime = globalPricePerShare[token].lastUpdateTime;

        require(
            _checkDeltaPPS(newPricePerShare, pricePerShare, _lastUpdateTime),
            "[OracleGlobalPPS]: Insufficient value of price per share"
        );

        _updatePPS(newPricePerShare, token);

        emit UpdatePPS(
            token,
            globalPricePerShare[token].pricePerShare,
            globalPricePerShare[token].prevPricePerShare,
            _lastUpdateTime
        );
    }

    /* ========== EXTERNAL ========== */
    function getPrevGlobalPPS(address token) external view returns (uint) {
        return globalPricePerShare[token].prevPricePerShare;
    }

    function getGlobalPPS(address token) external view returns (uint) {
        return globalPricePerShare[token].pricePerShare;
    }

    function decimals() external pure returns (uint) {
        return _decimals;
    }

    function synchronize() external {}

    /* ========== INTERNAL ========== */
    function _checkDeltaPPS(
        uint112 newPPS,
        uint112 prevPPS,
        uint32 _lastUpdateTime
    ) internal view returns (bool) {
        uint deltaTime = block.timestamp - _lastUpdateTime;

        if (_subAbs(newPPS, prevPPS) < deltaTime * DELTA_PPS_PER_SECOND)
            return true;
        else return false;
    }

    function _updatePPS(uint112 newPricePerShare, address token) internal {
        globalPricePerShare[token].prevPricePerShare = globalPricePerShare[
            token
        ].pricePerShare;

        globalPricePerShare[token].pricePerShare = newPricePerShare;

        globalPricePerShare[token].prevUpdateTime = globalPricePerShare[token]
            .lastUpdateTime;

        globalPricePerShare[token].lastUpdateTime = uint32(block.timestamp);
    }

    function _subAbs(uint x, uint y) private pure returns (uint) {
        if (x > y) return x - y;
        else return y - x;
    }
}

// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20 ^0.8.25;

// node_modules/@openzeppelin/contracts/proxy/utils/Initializable.sol

// OpenZeppelin Contracts (last updated v5.0.0) (proxy/utils/Initializable.sol)

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```solidity
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 *
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Storage of the initializable contract.
     *
     * It's implemented on a custom ERC-7201 namespace to reduce the risk of storage collisions
     * when using with upgradeable contracts.
     *
     * @custom:storage-location erc7201:openzeppelin.storage.Initializable
     */
    struct InitializableStorage {
        /**
         * @dev Indicates that the contract has been initialized.
         */
        uint64 _initialized;
        /**
         * @dev Indicates that the contract is in the process of being initialized.
         */
        bool _initializing;
    }

    // keccak256(abi.encode(uint256(keccak256("openzeppelin.storage.Initializable")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant INITIALIZABLE_STORAGE = 0xf0c57e16840df040f15088dc2f81fe391c3923bec73e23a9662efc9c229c6a00;

    /**
     * @dev The contract is already initialized.
     */
    error InvalidInitialization();

    /**
     * @dev The contract is not initializing.
     */
    error NotInitializing();

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint64 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts.
     *
     * Similar to `reinitializer(1)`, except that in the context of a constructor an `initializer` may be invoked any
     * number of times. This behavior in the constructor can be useful during testing and is not expected to be used in
     * production.
     *
     * Emits an {Initialized} event.
     */
    modifier initializer() {
        // solhint-disable-next-line var-name-mixedcase
        InitializableStorage storage $ = _getInitializableStorage();

        // Cache values to avoid duplicated sloads
        bool isTopLevelCall = !$._initializing;
        uint64 initialized = $._initialized;

        // Allowed calls:
        // - initialSetup: the contract is not in the initializing state and no previous version was
        //                 initialized
        // - construction: the contract is initialized at version 1 (no reininitialization) and the
        //                 current contract is just being deployed
        bool initialSetup = initialized == 0 && isTopLevelCall;
        bool construction = initialized == 1 && address(this).code.length == 0;

        if (!initialSetup && !construction) {
            revert InvalidInitialization();
        }
        $._initialized = 1;
        if (isTopLevelCall) {
            $._initializing = true;
        }
        _;
        if (isTopLevelCall) {
            $._initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * A reinitializer may be used after the original initialization step. This is essential to configure modules that
     * are added through upgrades and that require initialization.
     *
     * When `version` is 1, this modifier is similar to `initializer`, except that functions marked with `reinitializer`
     * cannot be nested. If one is invoked in the context of another, execution will revert.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     *
     * WARNING: Setting the version to 2**64 - 1 will prevent any future reinitialization.
     *
     * Emits an {Initialized} event.
     */
    modifier reinitializer(uint64 version) {
        // solhint-disable-next-line var-name-mixedcase
        InitializableStorage storage $ = _getInitializableStorage();

        if ($._initializing || $._initialized >= version) {
            revert InvalidInitialization();
        }
        $._initialized = version;
        $._initializing = true;
        _;
        $._initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        _checkInitializing();
        _;
    }

    /**
     * @dev Reverts if the contract is not in an initializing state. See {onlyInitializing}.
     */
    function _checkInitializing() internal view virtual {
        if (!_isInitializing()) {
            revert NotInitializing();
        }
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     *
     * Emits an {Initialized} event the first time it is successfully executed.
     */
    function _disableInitializers() internal virtual {
        // solhint-disable-next-line var-name-mixedcase
        InitializableStorage storage $ = _getInitializableStorage();

        if ($._initializing) {
            revert InvalidInitialization();
        }
        if ($._initialized != type(uint64).max) {
            $._initialized = type(uint64).max;
            emit Initialized(type(uint64).max);
        }
    }

    /**
     * @dev Returns the highest version that has been initialized. See {reinitializer}.
     */
    function _getInitializedVersion() internal view returns (uint64) {
        return _getInitializableStorage()._initialized;
    }

    /**
     * @dev Returns `true` if the contract is currently initializing. See {onlyInitializing}.
     */
    function _isInitializing() internal view returns (bool) {
        return _getInitializableStorage()._initializing;
    }

    /**
     * @dev Returns a pointer to the storage namespace.
     */
    // solhint-disable-next-line var-name-mixedcase
    function _getInitializableStorage() private pure returns (InitializableStorage storage $) {
        assembly {
            $.slot := INITIALIZABLE_STORAGE
        }
    }
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

// src/interfaces/ITokenVault.sol

interface ITokenVault is IERC4626 {
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

    event Bridged(
        uint32 dstEid,
        address asset,
        uint256 amount,
        bytes32 indexed intentionId
    );

    event BridgeFinished(uint amount, bytes32 intentionId);

    event WithdrawalRequested(
        address token,
        uint256 shares,
        address owner,
        bytes32 indexed intentionId,
        uint32 dstEid
    );

    event RebalanceRequested(bytes32 intentionId);

    event WithdrawRequestFulfilled(
        address token,
        uint256 assets,
        address owner,
        address receiver,
        bytes32 indexed intentionId
    );

    event WithdrawRequestCancelled(bytes32 indexed intentionId);

    event StrategyAdded(bytes32 strategyId);
    event StrategyRemoved(bytes32 strategyId);
    event StrategyToggled(bytes32 strategyId, bool isActive);

    ///@dev Used to Deposit/Withdraw from strategy, Bridge assets between Vault, Fulfill Requests
    enum ActionType {
        DEPOSIT,
        WITHDRAW,
        BRIDGE,
        FULFILL_WITHDRAW_REQUEST
    }

    enum RequestType {
        WITHDRAW,
        REBALANCE
    }

    ///@notice Not all fields are required for all actions
    struct ActionInput {
        uint32 dstEid;
        bytes32 strategyId;
        uint256 amount;
        bytes32 intentionId;
    }

    struct WithdrawRequestInfo {
        address owner;
        address receiver;
        address token;
        uint32 dstEid;
        uint32 creationTime;
        uint256 shares;
    }

    struct RebalanceRequestInfo {
        uint32 lastRebalanceTime;
        bytes32 intentionId;
    }

    struct Strategy {
        address strategyAddress;
        bool isActive;
    }

    function deposit(uint _assets, address _receiver) external returns (uint);

    function requestWithdraw(
        uint shares,
        uint32 dstEid,
        address receiver,
        address owner
    ) external returns (bytes32);

    function requestRebalance() external returns (bytes32 intentionId);

    function execute(
        ActionType[] calldata actionType,
        ActionInput[] calldata inputs
    ) external returns (bool);

    function finishBridge(uint256 amountBridged, bytes32 intentionId) external;

    function getSupportedDstEidToWithdraw(
        uint32 _dstEid
    ) external view returns (bool);

    function getWithdrawRequest(
        bytes32 intentionId
    ) external view returns (WithdrawRequestInfo memory);

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

    function setAddressProvider(address _oracle) external;

    function setCommander(address _commander) external;

    function setMinAmount(uint amount) external;

    function addChainToWithdraw(uint32 _dstEid) external;

    function removeChainToWithdraw(uint32 _dstEid) external;
}

// src/periphery/MaatAddressProvider.sol

contract MaatAddressProvider is
    IMaatAddressProvider,
    Initializable,
    ERC165Registry
{
    event AddStrategy(address strategy);
    event RemoveStrategy(address strategy);

    event AddVault(address vault);
    event RemoveVault(address vault);

    event ChangeAdmin(address prevAdmin, address newAdmin);
    event ChangeOracle(address prevOracle, address newOracle);
    event ChangeIncentiveController(
        address prevIncentiveController,
        address newIncentiveController
    );
    event ChangeStargateAdapter(
        address prevStargateAdapter,
        address newStargateAdapter
    );

    bytes4 constant AddressProviderInterfaceId =
        bytes4(keccak256("MAAT.V1.AddressProvider"));
    bytes4 constant TokenVaultInterfaceId =
        bytes4(keccak256("MAAT.V1.TokenVault"));
    bytes4 constant StrategyInterfaceId = bytes4(keccak256("MAAT.V0.Strategy"));
    bytes4 constant MaatOracleGlobalPPSInterfaceId =
        bytes4(keccak256("MAAT.V1.MaatOracle"));

    address[] _vaults;
    address[] _strategies;

    address public override oracle;
    address public override stargateAdapter;
    address public override incentiveController;

    address public override admin;

    mapping(address vault => bool isVault) public override isVault;
    mapping(address strategy => bool isStrategy) public override isStrategy;

    // ======================
    //        Constructor
    // ======================

    constructor() {
        _registerInterface(AddressProviderInterfaceId);
    }

    function initialize(address _admin) public initializer {
        admin = _admin;
    }

    // ======================
    //        External
    // ======================

    function addStrategy(address strategy) external override onlyAdmin {
        if (isStrategy[strategy]) revert AlreadyAdded();
        _validateStrategyInterface(strategy);

        isStrategy[strategy] = true;
        _strategies.push(strategy);

        emit AddStrategy(strategy);
    }

    function removeStrategy(address strategy) external override onlyAdmin {
        if (!isStrategy[strategy]) revert NotAdded();

        isStrategy[strategy] = false;
        _removeAddress(_strategies, strategy);

        emit RemoveStrategy(strategy);
    }

    function addVault(address vault) external override onlyAdmin {
        if (isVault[vault]) revert AlreadyAdded();
        _validateVaultInterface(vault);

        isVault[vault] = true;
        _vaults.push(vault);

        emit AddVault(vault);
    }

    function removeVault(address vault) external override onlyAdmin {
        if (!isVault[vault]) revert NotAdded();

        isVault[vault] = false;
        _removeAddress(_vaults, vault);

        emit RemoveVault(vault);
    }

    function changeOracle(address newOracle) external override onlyAdmin {
        _validateOracleInterface(newOracle);
        oracle = newOracle;

        emit ChangeOracle(oracle, newOracle);
    }

    function changeIncentiveController(
        address newIncentiveController
    ) external override onlyAdmin {
        emit ChangeIncentiveController(
            incentiveController,
            newIncentiveController
        );

        incentiveController = newIncentiveController;
    }

    function changeStargateAdapter(
        address newStargateAdapter
    ) external override onlyAdmin {
        emit ChangeStargateAdapter(stargateAdapter, newStargateAdapter);

        stargateAdapter = newStargateAdapter;
    }

    function changeAdmin(address newAdmin) external override onlyAdmin {
        emit ChangeAdmin(admin, newAdmin);
        admin = newAdmin;
    }

    // ======================
    //          View
    // ======================

    function getVaults()
        external
        view
        override
        returns (address[] memory vaults)
    {
        return _vaults;
    }

    function getStrategies()
        external
        view
        override
        returns (address[] memory strategies)
    {
        return _strategies;
    }

    // ======================
    //        Internal
    // ======================

    function _removeAddress(
        address[] storage array,
        address addressToRemove
    ) internal {
        uint256 arrayLength = array.length;
        address[] memory _array = array;
        if (arrayLength == 1) {
            array.pop();
            return;
        }
        for (uint i = 0; i < arrayLength; i++) {
            if (_array[i] == addressToRemove) {
                array[i] = _array[arrayLength - 1];
                array.pop();
                break;
            }
        }
    }

    // ======================
    //        Validation
    // ======================

    function _validateVaultInterface(address _vault) internal view {
        if (!ERC165Registry(_vault).supportsInterface(TokenVaultInterfaceId))
            revert AddressIsNotTokenVault(_vault);
    }

    function _validateStrategyInterface(address strategy) internal view {
        if (!ERC165Registry(strategy).supportsInterface(StrategyInterfaceId))
            revert AddressIsNotStrategy(strategy);
    }

    function _validateOracleInterface(address _oracle) internal view {
        if (
            !ERC165Registry(_oracle).supportsInterface(
                MaatOracleGlobalPPSInterfaceId
            )
        ) revert AddressIsNotOracle(_oracle);
    }

    // ======================
    //        Modifier
    // ======================

    error NotAdmin();
    error AlreadyAdded();
    error NotAdded();
    error AddressIsNotTokenVault(address addr);
    error AddressIsNotStrategy(address addr);
    error AddressIsNotOracle(address addr);

    modifier onlyAdmin() {
        if (msg.sender != admin) revert NotAdmin();
        _;
    }
}

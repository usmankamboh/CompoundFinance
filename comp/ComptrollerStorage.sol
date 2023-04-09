// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
import "./Token.sol";
import "./Price.sol";
contract UnitrollerAdminStorage {
    address public admin;
    address public pendingAdmin;
    address public comptrollerImplementation;
    address public pendingComptrollerImplementation;
}
contract ComptrollerV1Storage is UnitrollerAdminStorage {
    Price public price;
    uint public closeFactorMantissa;
    uint public liquidationIncentiveMantissa;
    uint public maxAssets;
    mapping(address => Token[]) public accountAssets;
}
contract ComptrollerV2Storage is ComptrollerV1Storage {
    struct Market {
        // @notice Whether or not this market is listed
        bool isListed;
        uint collateralFactorMantissa;
        // @notice Per-market mapping of "accounts in this asset"
        mapping(address => bool) accountMembership;
        // @notice Whether or not this market receives COMP
        bool isComped;
    }
    mapping(address => Market) public markets;
    address public pauseGuardian;
    bool public _mintGuardianPaused;
    bool public _borrowGuardianPaused;
    bool public transferGuardianPaused;
    bool public seizeGuardianPaused;
    mapping(address => bool) public mintGuardianPaused;
    mapping(address => bool) public borrowGuardianPaused;
}
contract ComptrollerV3Storage is ComptrollerV2Storage {
    struct CompMarketState {
        // @notice The market's last updated compBorrowIndex or compSupplyIndex
        uint224 index;
        // @notice The block number the index was last updated at
        uint32 block;
    }
    // @notice A list of all markets
    Token[] public allMarkets;
    // @notice The rate at which the flywheel distributes COMP, per block
    uint public compRate;
    // @notice The portion of compRate that each market currently receives
    mapping(address => uint) public compSpeeds;
    // @notice The COMP market supply state for each market
    mapping(address => CompMarketState) public compSupplyState;
    // @notice The COMP market borrow state for each market
    mapping(address => CompMarketState) public compBorrowState;
    // @notice The COMP borrow index for each market for each supplier as of the last time they accrued COMP
    mapping(address => mapping(address => uint)) public compSupplierIndex;
    // @notice The COMP borrow index for each market for each borrower as of the last time they accrued COMP
    mapping(address => mapping(address => uint)) public compBorrowerIndex;
    // @notice The COMP accrued but not yet transferred to each user
    mapping(address => uint) public compAccrued;
}
contract ComptrollerV4Storage is ComptrollerV3Storage {
    // @notice The borrowCapGuardian can set borrowCaps to any number for any market. Lowering the borrow cap could disable borrowing on the given market.
    address public borrowCapGuardian;
    // @notice Borrow caps enforced by borrowAllowed for each token address. Defaults to zero which corresponds to unlimited borrowing.
    mapping(address => uint) public borrowCaps;
}
contract ComptrollerV5Storage is ComptrollerV4Storage {
    // @notice The portion of COMP that each contributor receives per block
    mapping(address => uint) public compContributorSpeeds;
    // @notice Last block at which a contributor's COMP rewards have been allocated
    mapping(address => uint) public lastContributorBlock;
}
contract ComptrollerV6Storage is ComptrollerV5Storage {
    // @notice The rate at which comp is distributed to the corresponding borrow market (per block)
    mapping(address => uint) public compBorrowSpeeds;
    // @notice The rate at which comp is distributed to the corresponding supply market (per block)
    mapping(address => uint) public compSupplySpeeds;
}
contract ComptrollerV7Storage is ComptrollerV6Storage {
    // @notice Flag indicating whether the function to fix COMP accruals has been executed (RE: proposal 62 bug)
    bool public proposal65FixExecuted;
    // @notice Accounting storage mapping account addresses to how much COMP they owe the protocol.
    mapping(address => uint) public compReceivable;
}
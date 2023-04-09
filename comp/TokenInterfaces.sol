// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
import "ComptrollerInterface.sol";
import "InterestRateModel.sol";
import "EIP20NonStandardInterface.sol";
contract TokenStorage {
    bool internal _notEntered;
    string public name;
    string public symbol;
    uint8 public decimals;
    uint internal constant borrowRateMaxMantissa = 0.0005e16;
    uint internal constant reserveFactorMaxMantissa = 1e18;
    address payable public admin;
    address payable public pendingAdmin;
    ComptrollerInterface public comptroller;
    InterestRateModel public interestRateModel;
    uint internal initialExchangeRateMantissa;
    uint public reserveFactorMantissa;
    uint public accrualBlockNumber;
    uint public borrowIndex;
    uint public totalBorrows;
    uint public totalReserves;
    uint public totalSupply;
    mapping (address => uint) internal accountTokens;
    mapping (address => mapping (address => uint)) internal transferAllowances;
    struct BorrowSnapshot {
        uint principal;
        uint interestIndex;
    }
    mapping(address => BorrowSnapshot) internal accountBorrows;
    uint public constant protocolSeizeShareMantissa = 2.8e16; //2.8%

}
 abstract contract TokenInterface is TokenStorage {
    bool public constant istoken = true;
    event AccrueInterest(uint cashPrior, uint interestAccumulated, uint borrowIndex, uint totalBorrows);
    event Mint(address minter, uint mintAmount, uint mintTokens);
    event Redeem(address redeemer, uint redeemAmount, uint redeemTokens);
    event Borrow(address borrower, uint borrowAmount, uint accountBorrows, uint totalBorrows);
    event RepayBorrow(address payer, address borrower, uint repayAmount, uint accountBorrows, uint totalBorrows);
    event LiquidateBorrow(address liquidator, address borrower, uint repayAmount, address tokenCollateral, uint seizeTokens);
    event NewPendingAdmin(address oldPendingAdmin, address newPendingAdmin);
    event NewAdmin(address oldAdmin, address newAdmin);
    event NewComptroller(ComptrollerInterface oldComptroller, ComptrollerInterface newComptroller);
    event NewMarketInterestRateModel(InterestRateModel oldInterestRateModel, InterestRateModel newInterestRateModel);
    event NewReserveFactor(uint oldReserveFactorMantissa, uint newReserveFactorMantissa);
    event ReservesAdded(address benefactor, uint addAmount, uint newTotalReserves);
    event ReservesReduced(address admin, uint reduceAmount, uint newTotalReserves);
    event Transfer(address indexed from, address indexed to, uint amount);
    event Approval(address indexed owner, address indexed spender, uint amount);
    event Failure(uint error, uint info, uint detail);
    // User Interface 
    function transfer(address dst, uint amount) external   virtual  returns (bool);
    function transferFrom(address src, address dst, uint amount) external   virtual  returns (bool);
    function approve(address spender, uint amount) external   virtual  returns (bool);
    function allowance(address owner, address spender) external   view virtual  returns (uint);
    function balanceOf(address owner) external   view virtual  returns (uint);
    function balanceOfUnderlying(address owner) external   virtual  returns (uint);
    function getAccountSnapshot(address account) external   view virtual  returns (uint, uint, uint, uint);
    function borrowRatePerBlock() external   view virtual  returns (uint);
    function supplyRatePerBlock() external   view virtual  returns (uint);
    function totalBorrowsCurrent() external   virtual  returns (uint);
    function borrowBalanceCurrent(address account) external   virtual  returns (uint);
    function borrowBalanceStored(address account) public   view virtual  returns (uint);
    function exchangeRateCurrent() public   virtual  returns (uint);
    function exchangeRateStored() public   view virtual  returns (uint);
    function getCash() external   view virtual  returns (uint);
    function accrueInterest() public   virtual  returns (uint);
    function seize(address liquidator, address borrower, uint seizeTokens) external   virtual  returns (uint);
    // Admin Functions 
    function _setPendingAdmin(address payable newPendingAdmin) external   virtual  returns (uint);
    function _acceptAdmin() external   virtual  returns (uint);
    function _setComptroller(ComptrollerInterface newComptroller) public   virtual  returns (uint);
    function _setReserveFactor(uint newReserveFactorMantissa) external   virtual  returns (uint);
    function _reduceReserves(uint reduceAmount) external   virtual  returns (uint);
    function _setInterestRateModel(InterestRateModel newInterestRateModel) public   virtual  returns (uint);
}
contract ERC20Storage {
    address public underlying;
}
 abstract contract ERC20Interface is ERC20Storage {
    // User Interface 
    function mint(uint mintAmount) external   virtual  returns (uint);
    function redeem(uint redeemTokens) external   virtual  returns (uint);
    function redeemUnderlying(uint redeemAmount) external   virtual  returns (uint);
    function borrow(uint borrowAmount) external   virtual  returns (uint);
    function repayBorrow(uint repayAmount) external   virtual  returns (uint);
    function repayBorrowBehalf(address borrower, uint repayAmount) external   virtual  returns (uint);
    function liquidateBorrow(address borrower, uint repayAmount, TokenInterface TokenCollateral) external   virtual  returns (uint);
    function sweepToken(EIP20NonStandardInterface token) virtual  external  ;
    // Admin Functions
    function _addReserves(uint addAmount) external   virtual  returns (uint);
}
contract DelegationStorage {
    address public implementation;
}
abstract contract DelegatorInterface is DelegationStorage {
    event NewImplementation(address oldImplementation, address newImplementation);
    function _setImplementation(address implementation_, bool allowResign, bytes memory becomeImplementationData) public virtual ;
}
 abstract contract DelegateInterface is DelegationStorage {
    function _becomeImplementation(bytes memory data) public virtual  ;
    function _resignImplementation() public virtual ;
}

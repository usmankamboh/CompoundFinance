// SPDX-License-Identifier: MIT
pragma solidity 0.5.16;
import "TokenInterfaces.sol";
contract ERC20Delegator is TokenInterface, ERC20Interface, DelegatorInterface {
    constructor(address underlying_,
                ComptrollerInterface comptroller_,
                InterestRateModel interestRateModel_,
                uint initialExchangeRateMantissa_,
                string memory name_,
                string memory symbol_,
                uint8 decimals_,
                address payable admin_,
                address implementation_,
                bytes memory becomeImplementationData) public {
        // Creator of the contract is admin during initialization
        admin = msg.sender;
        // First delegate gets to initialize the delegator (i.e. storage contract)
        delegateTo(implementation_, abi.encodeWithSignature("initialize(address,address,address,uint256,string,string,uint8)",
                                                            underlying_,
                                                            comptroller_,
                                                            interestRateModel_,
                                                            initialExchangeRateMantissa_,
                                                            name_,
                                                            symbol_,
                                                            decimals_));
        // New implementations always get set via the settor (post-initialize)
        _setImplementation(implementation_, false, becomeImplementationData);
        // Set the proper admin now that initialization is done
        admin = admin_;
    }
    function _setImplementation(address implementation_, bool allowResign, bytes memory becomeImplementationData) public {
        require(msg.sender == admin, "CErc20Delegator::_setImplementation: Caller must be admin");
        if (allowResign) {
            delegateToImplementation(abi.encodeWithSignature("_resignImplementation()"));
        }
        address oldImplementation = implementation;
        implementation = implementation_;
        delegateToImplementation(abi.encodeWithSignature("_becomeImplementation(bytes)", becomeImplementationData));
        emit NewImplementation(oldImplementation, implementation);
    }
    function mint(uint mintAmount) external returns (uint) {
        bytes memory data = delegateToImplementation(abi.encodeWithSignature("mint(uint256)", mintAmount));
        return abi.decode(data, (uint));
    }
    function redeem(uint redeemTokens) external returns (uint) {
        bytes memory data = delegateToImplementation(abi.encodeWithSignature("redeem(uint256)", redeemTokens));
        return abi.decode(data, (uint));
    }
    function redeemUnderlying(uint redeemAmount) external returns (uint) {
        bytes memory data = delegateToImplementation(abi.encodeWithSignature("redeemUnderlying(uint256)", redeemAmount));
        return abi.decode(data, (uint));
    }
    function borrow(uint borrowAmount) external returns (uint) {
        bytes memory data = delegateToImplementation(abi.encodeWithSignature("borrow(uint256)", borrowAmount));
        return abi.decode(data, (uint));
    }
    function repayBorrow(uint repayAmount) external returns (uint) {
        bytes memory data = delegateToImplementation(abi.encodeWithSignature("repayBorrow(uint256)", repayAmount));
        return abi.decode(data, (uint));
    }
    function repayBorrowBehalf(address borrower, uint repayAmount) external returns (uint) {
        bytes memory data = delegateToImplementation(abi.encodeWithSignature("repayBorrowBehalf(address,uint256)", borrower, repayAmount));
        return abi.decode(data, (uint));
    }
    function liquidateBorrow(address borrower, uint repayAmount, TokenInterface TokenCollateral) external returns (uint) {
        bytes memory data = delegateToImplementation(abi.encodeWithSignature("liquidateBorrow(address,uint256,address)", borrower, repayAmount, TokenCollateral));
        return abi.decode(data, (uint));
    }
    function transfer(address dst, uint amount) external returns (bool) {
        bytes memory data = delegateToImplementation(abi.encodeWithSignature("transfer(address,uint256)", dst, amount));
        return abi.decode(data, (bool));
    }
    function transferFrom(address src, address dst, uint256 amount) external returns (bool) {
        bytes memory data = delegateToImplementation(abi.encodeWithSignature("transferFrom(address,address,uint256)", src, dst, amount));
        return abi.decode(data, (bool));
    }
    function approve(address spender, uint256 amount) external returns (bool) {
        bytes memory data = delegateToImplementation(abi.encodeWithSignature("approve(address,uint256)", spender, amount));
        return abi.decode(data, (bool));
    }
    function allowance(address owner, address spender) external view returns (uint) {
        bytes memory data = delegateToViewImplementation(abi.encodeWithSignature("allowance(address,address)", owner, spender));
        return abi.decode(data, (uint));
    }
    function balanceOf(address owner) external view returns (uint) {
        bytes memory data = delegateToViewImplementation(abi.encodeWithSignature("balanceOf(address)", owner));
        return abi.decode(data, (uint));
    }
    function balanceOfUnderlying(address owner) external returns (uint) {
        bytes memory data = delegateToImplementation(abi.encodeWithSignature("balanceOfUnderlying(address)", owner));
        return abi.decode(data, (uint));
    }
    function getAccountSnapshot(address account) external view returns (uint, uint, uint, uint) {
        bytes memory data = delegateToViewImplementation(abi.encodeWithSignature("getAccountSnapshot(address)", account));
        return abi.decode(data, (uint, uint, uint, uint));
    }
    function borrowRatePerBlock() external view returns (uint) {
        bytes memory data = delegateToViewImplementation(abi.encodeWithSignature("borrowRatePerBlock()"));
        return abi.decode(data, (uint));
    }
    function supplyRatePerBlock() external view returns (uint) {
        bytes memory data = delegateToViewImplementation(abi.encodeWithSignature("supplyRatePerBlock()"));
        return abi.decode(data, (uint));
    }
    function totalBorrowsCurrent() external returns (uint) {
        bytes memory data = delegateToImplementation(abi.encodeWithSignature("totalBorrowsCurrent()"));
        return abi.decode(data, (uint));
    }
    function borrowBalanceCurrent(address account) external returns (uint) {
        bytes memory data = delegateToImplementation(abi.encodeWithSignature("borrowBalanceCurrent(address)", account));
        return abi.decode(data, (uint));
    }
    function borrowBalanceStored(address account) public view returns (uint) {
        bytes memory data = delegateToViewImplementation(abi.encodeWithSignature("borrowBalanceStored(address)", account));
        return abi.decode(data, (uint));
    }
    function exchangeRateCurrent() public returns (uint) {
        bytes memory data = delegateToImplementation(abi.encodeWithSignature("exchangeRateCurrent()"));
        return abi.decode(data, (uint));
    }
    function exchangeRateStored() public view returns (uint) {
        bytes memory data = delegateToViewImplementation(abi.encodeWithSignature("exchangeRateStored()"));
        return abi.decode(data, (uint));
    }
    function getCash() external view returns (uint) {
        bytes memory data = delegateToViewImplementation(abi.encodeWithSignature("getCash()"));
        return abi.decode(data, (uint));
    }
    function accrueInterest() public returns (uint) {
        bytes memory data = delegateToImplementation(abi.encodeWithSignature("accrueInterest()"));
        return abi.decode(data, (uint));
    }
    function seize(address liquidator, address borrower, uint seizeTokens) external returns (uint) {
        bytes memory data = delegateToImplementation(abi.encodeWithSignature("seize(address,address,uint256)", liquidator, borrower, seizeTokens));
        return abi.decode(data, (uint));
    }
    function sweepToken(EIP20NonStandardInterface token) external {
        delegateToImplementation(abi.encodeWithSignature("sweepToken(address)", token));
    }
    // Admin Functions
    function _setPendingAdmin(address payable newPendingAdmin) external returns (uint) {
        bytes memory data = delegateToImplementation(abi.encodeWithSignature("_setPendingAdmin(address)", newPendingAdmin));
        return abi.decode(data, (uint));
    }
    function _setComptroller(ComptrollerInterface newComptroller) public returns (uint) {
        bytes memory data = delegateToImplementation(abi.encodeWithSignature("_setComptroller(address)", newComptroller));
        return abi.decode(data, (uint));
    }
    function _setReserveFactor(uint newReserveFactorMantissa) external returns (uint) {
        bytes memory data = delegateToImplementation(abi.encodeWithSignature("_setReserveFactor(uint256)", newReserveFactorMantissa));
        return abi.decode(data, (uint));
    }
    function _acceptAdmin() external returns (uint) {
        bytes memory data = delegateToImplementation(abi.encodeWithSignature("_acceptAdmin()"));
        return abi.decode(data, (uint));
    }
    function _addReserves(uint addAmount) external returns (uint) {
        bytes memory data = delegateToImplementation(abi.encodeWithSignature("_addReserves(uint256)", addAmount));
        return abi.decode(data, (uint));
    }
    function _reduceReserves(uint reduceAmount) external returns (uint) {
        bytes memory data = delegateToImplementation(abi.encodeWithSignature("_reduceReserves(uint256)", reduceAmount));
        return abi.decode(data, (uint));
    }
    function _setInterestRateModel(InterestRateModel newInterestRateModel) public returns (uint) {
        bytes memory data = delegateToImplementation(abi.encodeWithSignature("_setInterestRateModel(address)", newInterestRateModel));
        return abi.decode(data, (uint));
    }
    function delegateTo(address callee, bytes memory data) internal returns (bytes memory) {
        (bool success, bytes memory returnData) = callee.delegatecall(data);
        assembly {
            if eq(success, 0) {
           //     revert(add(returnData, 0x20) returndatasize)
            }
        }
        return returnData;
    }
    function delegateToImplementation(bytes memory data) public returns (bytes memory) {
        return delegateTo(implementation, data);
    }
    function delegateToViewImplementation(bytes memory data) public view returns (bytes memory) {
        (bool success, bytes memory returnData) = address(this).staticcall(abi.encodeWithSignature("delegateToImplementation(bytes)", data));
        assembly {
            if eq(success, 0) {
            //    revert(add(returnData, 0x20), returndatasize)
            }
        }
        return abi.decode(returnData, (bytes));
    }
    function pay() external payable {
        require(msg.value == 0,"CErc20Delegator:fallback: cannot send value to fallback");
        // delegate all other functions to current implementation
        (bool success, ) = implementation.delegatecall(msg.data);
        assembly {
            let free_mem_ptr := mload(0x40)
            returndatacopy(free_mem_ptr, 0, returndatasize)
            switch success
            case 0 { revert(free_mem_ptr, returndatasize) }
            default { return(free_mem_ptr, returndatasize) }
        }
    }
}

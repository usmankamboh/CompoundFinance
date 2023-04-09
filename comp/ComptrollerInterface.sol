// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
 abstract contract ComptrollerInterface {
    /// @notice Indicator that this is a Comptroller contract (for inspection)
    bool public constant isComptroller = true;
    /*** Assets You Are In ***/
    function enterMarkets(address[] calldata  tokens) external  virtual returns (uint[] memory);
    function exitMarket(address  token) external  virtual returns (uint);
    /*** Policy Hooks ***/
    function mintAllowed(address  token, address minter, uint mintAmount) external  virtual returns (uint);
    function mintVerify(address  token, address minter, uint mintAmount, uint mintTokens)virtual  external  ;
    function redeemAllowed(address  token, address redeemer, uint redeemTokens) external  virtual returns (uint);
    function redeemVerify(address  token, address redeemer, uint redeemAmount, uint redeemTokens)virtual  external  ;
    function borrowAllowed(address  token, address borrower, uint borrowAmount) external  virtual returns (uint);
    function borrowVerify(address  token, address borrower, uint borrowAmount)virtual  external  ;
    function repayBorrowAllowed(address  token,address payer, address borrower,uint repayAmount) external  virtual returns (uint);
    function repayBorrowVerify(address  token,address payer,address borrower,uint repayAmount, uint borrowerIndex)virtual  external  ;
    function liquidateBorrowAllowed(address  tokenBorrowed,address  tokenCollateral,address liquidator,
        address borrower, uint repayAmount) external  virtual returns (uint);
    function liquidateBorrowVerify(address  tokenBorrowed,address  tokenCollateral,address liquidator,
        address borrower,uint repayAmount, uint seizeTokens)virtual  external  ;
    function seizeAllowed(address  tokenCollateral,address  tokenBorrowed,address liquidator,address borrower,
        uint seizeTokens) external  virtual returns (uint);
    function seizeVerify(address  tokenCollateral, address  tokenBorrowed,address liquidator, address borrower,
        uint seizeTokens)virtual  external  ;
    function transferAllowed(address  token, address src, address dst, uint transferTokens) external  virtual returns (uint);
    function transferVerify(address  token, address src, address dst, uint transferTokens)virtual  external  ;
    /*** Liquidity/Liquidation Calculations ***/
    function liquidateCalculateSeizeTokens(address  tokenBorrowed, address  tokenCollateral,uint repayAmount) external   view virtual returns (uint, uint);
}

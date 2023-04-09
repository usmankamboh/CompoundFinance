// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
abstract contract InterestRateModel {
    /// @notice Indicator that this is an InterestRateModel contract (for inspection)
    bool public constant isInterestRateModel = true;
    function getBorrowRate(uint cash, uint borrows, uint reserves) external virtual view returns (uint);
    function getSupplyRate(uint cash, uint borrows, uint reserves, uint reserveFactorMantissa) external virtual view returns (uint);

}

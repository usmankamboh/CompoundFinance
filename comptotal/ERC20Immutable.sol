// SPDX-License-Identifier: MIT
pragma solidity 0.5.16;
import "ERC20.sol";
contract ERC20Immutable is ERC20 {
    constructor(address underlying_,
                ComptrollerInterface comptroller_,
                InterestRateModel interestRateModel_,
                uint initialExchangeRateMantissa_,
                string memory name_,
                string memory symbol_,
                uint8 decimals_,
                address payable admin_)public  {
        // Creator of the contract is admin during initialization
        admin = msg.sender;
        // Initialize the market
        initialize(underlying_, comptroller_, interestRateModel_, initialExchangeRateMantissa_, name_, symbol_, decimals_);
        // Set the proper admin now that initialization is done
        admin = admin_;
    }
}

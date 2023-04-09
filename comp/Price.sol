// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
import "Token.sol";
abstract contract Price {
    bool public constant isPrice = true;
    function getUnderlyingPrice(Token token) external view virtual returns (uint);
}

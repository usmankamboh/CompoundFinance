// SPDX-License-Identifier: MIT
pragma solidity 0.5.16;
import "ERC20.sol";
contract ERC20Delegate is ERC20, DelegateInterface {
    constructor() public {}
    function _becomeImplementation(bytes memory data) public {
        // Shh -- currently unused
        data;
        // Shh -- we don't ever want this hook to be marked pure
        if (false) {
            implementation = address(0);
        }
        require(msg.sender == admin, "only the admin may call _becomeImplementation");
    }
    function _resignImplementation() public {
        // Shh -- we don't ever want this hook to be marked pure
        if (false) {
            implementation = address(0);
        }
        require(msg.sender == admin, "only the admin may call _resignImplementation");
    }
}

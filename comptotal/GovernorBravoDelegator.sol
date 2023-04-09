// SPDX-License-Identifier: MIT
pragma solidity 0.5.16;
import "GovernorBravoInterfaces.sol";
contract GovernorBravoDelegator is GovernorBravoDelegatorStorage, GovernorBravoEvents {
	constructor(
			address timelock_,
			address comp_,
			address admin_,
	        address implementation_,
	        uint votingPeriod_,
	        uint votingDelay_,
            uint proposalThreshold_) public {
        // Admin set to msg.sender for initialization
        admin = msg.sender;
        delegateTo(implementation_, abi.encodeWithSignature("initialize(address,address,uint256,uint256,uint256)",
                                                            timelock_,
                                                            comp_,
                                                            votingPeriod_,
                                                            votingDelay_,
                                                            proposalThreshold_));

        _setImplementation(implementation_);
		admin = admin_;
	}
    function _setImplementation(address implementation_) public {
        require(msg.sender == admin, "GovernorBravoDelegator::_setImplementation: admin only");
        require(implementation_ != address(0), "GovernorBravoDelegator::_setImplementation: invalid implementation address");
        address oldImplementation = implementation;
        implementation = implementation_;
        emit NewImplementation(oldImplementation, implementation);
    }
    function delegateTo(address callee, bytes memory data) internal {
        (bool success, bytes memory returnData) = callee.delegatecall(data);
        assembly {
            if eq(success, 0) {
        //        revert(add(returnData, 0x20), returndatasize)
            }
        }
    }
    function pay () external payable {
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
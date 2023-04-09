// SPDX-License-Identifier: MIT
pragma solidity 0.5.16;
import "ERC20Delegate.sol";
contract DaiDelegate is ERC20Delegate {
    address public daiJoinAddress;
    address public potAddress;
    address public vatAddress;
    function _becomeImplementation(bytes memory data) public {
        require(msg.sender == admin, "only the admin may initialize the implementation");
        (address daiJoinAddress_, address potAddress_) = abi.decode(data, (address, address));
        return _becomeImplementation(daiJoinAddress_, potAddress_);
    }
    function _becomeImplementation(address daiJoinAddress_, address potAddress_) internal {
        // Get dai and vat and sanity check the underlying
        DaiJoinLike daiJoin = DaiJoinLike(daiJoinAddress_);
        PotLike pot = PotLike(potAddress_);
        GemLike dai = daiJoin.dai();
        VatLike vat = daiJoin.vat();
        require(address(dai) == underlying, "DAI must be the same as underlying");
        // Remember the relevant addresses
        daiJoinAddress = daiJoinAddress_;
        potAddress = potAddress_;
        vatAddress = address(vat);
        // Approve moving our DAI into the vat through daiJoin
        dai.approve(daiJoinAddress, uint(-1));
        // Approve the pot to transfer our funds within the vat
        vat.hope(potAddress);
        vat.hope(daiJoinAddress);
        // Accumulate DSR interest -- must do this in order to doTransferIn
        pot.drip();
        // Transfer all cash in (doTransferIn does this regardless of amount)
        doTransferIn(address(this), 0);
    }
    function _resignImplementation() public {
        require(msg.sender == admin, "only the admin may abandon the implementation");
        // Transfer all cash out of the DSR - note that this relies on self-transfer
        DaiJoinLike daiJoin = DaiJoinLike(daiJoinAddress);
        PotLike pot = PotLike(potAddress);
        VatLike vat = VatLike(vatAddress);
        // Accumulate interest
        pot.drip();
        // Calculate the total amount in the pot, and move it out
        uint pie = pot.pie(address(this));
        pot.exit(pie);
        // Checks the actual balance of DAI in the vat after the pot exit
        uint bal = vat.dai(address(this));
        // Remove our whole balance
        daiJoin.exit(address(this), bal / RAY);
    }
    function accrueInterest() public returns (uint) {
        // Accumulate DSR interest
        PotLike(potAddress).drip();
        // Accumulate CToken interest
        return super.accrueInterest();
    }
    function getCashPrior() internal view returns (uint) {
        PotLike pot = PotLike(potAddress);
        uint pie = pot.pie(address(this));
        return mul(pot.chi(), pie) / RAY;
    }
    function doTransferIn(address from, uint amount) internal returns (uint) {
        // Perform the EIP-20 transfer in
        EIP20Interface token = EIP20Interface(underlying);
        require(token.transferFrom(from, address(this), amount), "unexpected EIP-20 transfer in return");
        DaiJoinLike daiJoin = DaiJoinLike(daiJoinAddress);
        GemLike dai = GemLike(underlying);
        PotLike pot = PotLike(potAddress);
        VatLike vat = VatLike(vatAddress);
        // Convert all our DAI to internal DAI in the vat
        daiJoin.join(address(this), dai.balanceOf(address(this)));
        // Checks the actual balance of DAI in the vat after the join
        uint bal = vat.dai(address(this));
        // Calculate the percentage increase to th pot for the entire vat, and move it in
        // Note: We may leave a tiny bit of DAI in the vat...but we do the whole thing every time
        uint pie = bal / pot.chi();
        pot.join(pie);
        return amount;
    }
    function doTransferOut(address payable to, uint amount) internal {
        DaiJoinLike daiJoin = DaiJoinLike(daiJoinAddress);
        PotLike pot = PotLike(potAddress);
        // Calculate the percentage decrease from the pot, and move that much out
        // Note: Use a slightly larger pie size to ensure that we get at least amount in the vat
        uint pie = add(mul(amount, RAY) / pot.chi(), 1);
        pot.exit(pie);
        daiJoin.exit(to, amount);
    }
    uint256 constant RAY = 10 ** 27;
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, "add-overflow");
    }
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, "mul-overflow");
    }
}
interface PotLike {
    function chi() external view returns (uint);
    function pie(address) external view returns (uint);
    function drip() external returns (uint);
    function join(uint) external;
    function exit(uint) external;
}
interface GemLike {
    function approve(address, uint) external;
    function balanceOf(address) external view returns (uint);
    function transferFrom(address, address, uint) external returns (bool);
}
interface VatLike {
    function dai(address) external view returns (uint);
    function hope(address) external;
}
interface DaiJoinLike {
    function vat() external returns (VatLike);
    function dai() external returns (GemLike);
    function join(address, uint) external payable;
    function exit(address, uint) external;
}

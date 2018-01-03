pragma solidity 0.4.18;

import "./EIPSign.sol";
import "../zep/ECRecovery.sol";

contract SignCheck is EIPSign, ECRecovery {
    /**
     * @dev Checks signature with ecrecover and EIPx
     * @return Signer address or address(0) if signature is not correct.
     */
    function getSigner(bytes32 hash, bytes sig) internal view returns (address) {
        if (sig.length != 20) return recover(hash, sig);
        address signer;
        assembly { signer := add(sig, 0x20) }

        return check(signer, hash) ? signer : address(0);
    }
}

pragma solidity 0.4.18;

contract ISignHolder {
    /**
    * @notice Returns whether `who` ever sign `hash`. Even if she cancelled, this will return true.
    */
    function signed(address who, bytes32 hash) public view returns (bool);

    /**
     * @notice Returns if `who` signed `hash` and hasnt cancelled the signature.
     */
    function isSigned(address who, bytes32 hash) public view returns (bool);
}

contract SignHolder is ISignHolder {
    mapping (address => mapping (bytes32 => bool)) signatures;
    mapping (address => mapping (bytes32 => bool)) cancels;

    function sign(bytes32 hash) external { signatures[msg.sender][hash] = true; }
    function cancel(bytes32 hash) external { cancels[msg.sender][hash] = true; }

    function signed(address who, bytes32 hash) public view returns (bool) {
        return signatures[who][hash];
    }

    function isSigned(address who, bytes32 hash) public view returns (bool) {
        return signatures[who][hash] && !cancels[who][hash];
    }
}

contract EIPSign {
    ISignHolder constant SIGN_HOLDER = ISignHolder(0x1234); // TODO: Address

    function check(address who, bytes32 hash) internal view returns (bool) {
        if (msg.sender == who) return true; // Implicit authorization by sender
        return SIGN_HOLDER.signed(who, hash);
    }
}

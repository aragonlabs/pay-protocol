pragma solidity 0.4.18;

contract PayConstants {
    // EIP712

    // TODO: UNCOMMENT DEPS ARRAY
    bytes32 constant public SCHEMA_HASH = keccak256('address protocol', 'address token', 'address from', 'address to', 'uint256 value', 'uint256 expires', 'bool pull', 'bool push', 'bytes32 depsHash');
    address constant public TO_SENDER = address(-1); // 0xffff...

    bytes32 constant MINT_HOUSE_ROLE = bytes32(1);
}

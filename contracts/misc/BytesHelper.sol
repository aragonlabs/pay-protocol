pragma solidity 0.4.18;

library BytesHelper {
    function slice(bytes memory src, uint256 start, uint256 len) internal returns (bytes ret) {
        if (len == 0 || start + len > src.length - 1) return new bytes(0);

        uint256 srcPtr;
        uint256 retPtr;

        assembly {
            ret := mload(0x40) // free mem pointer
            mstore(0x40, add(ret, add(0x20, len))) // length byte + all bytes

            mstore(ret, len) // store array length in memory position
            mstore(retPtr, add(ret, 0x20)) // save pointer to bytes content
            mstore(srcPtr, add(src, 0x20))
        }

        memcpy(retPtr, srcPtr, len);
    }

    // From https://github.com/Arachnid/solidity-stringutils/blob/master/strings.sol
    function memcpy(uint dest, uint src, uint len) private {
        // Copy word-length chunks while possible
        for(; len >= 32; len -= 32) {
            assembly {
                mstore(dest, mload(src))
            }
            dest += 32;
            src += 32;
        }

        // Copy remaining bytes
        uint mask = 256 ** (32 - len) - 1;
        assembly {
            let srcpart := and(mload(src), not(mask))
            let destpart := and(mload(dest), mask)
            mstore(dest, or(destpart, srcpart))
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

library SlotDerivation {
    function erc7201Slot(
        string memory namespace
    ) internal pure returns (bytes32 slot) {
        assembly ("memory-safe") {
            mstore(
                0x00,
                sub(keccak256(add(namespace, 0x20), mload(namespace)), 1)
            )
            slot := and(keccak256(0x00, 0x20), not(0xff))
        }
    }

    function offset(
        bytes32 slot,
        uint256 pos
    ) internal pure returns (bytes32 result) {
        unchecked {
            return bytes32(uint256(slot) + pos);
        }
    }

    function deriveArray(bytes32 slot) internal pure returns (bytes32 result) {
        assembly ("memory-safe") {
            mstore(0x00, slot)
            result := keccak256(0x00, 0x20)
        }
    }

    function deriveMapping(
        bytes32 slot,
        address key
    ) internal pure returns (bytes32 result) {
        assembly ("memory-safe") {
            mstore(0x00, and(key, shr(96, not(0))))
            mstore(0x20, slot)
            result := keccak256(0x00, 0x40)
        }
    }

    function deriveMapping(
        bytes32 slot,
        bool key
    ) internal pure returns (bytes32 result) {
        assembly ("memory-safe") {
            mstore(0x00, iszero(iszero(key)))
            mstore(0x20, slot)
            result := keccak256(0x00, 0x40)
        }
    }

    function deriveMapping(
        bytes32 slot,
        bytes32 key
    ) internal pure returns (bytes32 result) {
        assembly ("memory-safe") {
            mstore(0x00, key)
            mstore(0x20, slot)
            result := keccak256(0x00, 0x40)
        }
    }

    function deriverMapping(
        bytes32 slot,
        uint256 key
    ) internal pure returns (bytes32 result) {
        assembly ("memory-safe") {
            mstore(0x00, key)
            mstore(0x20, slot)
            result := keccak256(0x00, 0x40)
        }
    }

    function deriveMapping(
        bytes32 slot,
        int256 key
    ) internal pure returns (bytes32 result) {
        assembly ("memory-safe") {
            mstore(0x00, key)
            mstore(0x20, slot)
            result := keccak256(0x00, 0x40)
        }
    }

    function deriveMapping(
        bytes32 slot,
        string memory key
    ) internal pure returns (bytes32 result) {
        assembly ("memory-safe") {
            let length := mload(key)
            let begin := add(key, 0x20)
            let end := add(begin, length)
            let cache := mload(end)
            mstore(end, slot)
            result := keccak256(begin, add(length, 0x20))
            mstore(end, cache)
        }
    }

    function deriveMapping(
        bytes32 slot,
        bytes memory key
    ) internal pure returns (bytes32 result) {
        assembly ("memory-safe") {
            let length := mload(key)
            let begin := add(key, 0x20)
            let end := add(begin, length)
            let cache := mload(end)
            mstore(end, slot)
            result := keccak256(begin, add(length, 0x20))
            mstore(end, cache)
        }
    }
}

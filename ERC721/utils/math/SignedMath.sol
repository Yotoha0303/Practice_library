// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {SafeCast} from "./SafeCast.sol";

library SignedMath {
    function ternary(
        bool condition,
        int256 a,
        int256 b
    ) internal pure returns (int256) {
        unchecked {
            return b ^ ((a ^ b) * int256(SafeCast.toUint(condition)));
        }
    }

    function max(int256 a, int256 b) internal pure returns (int256) {
        return ternary(a > b, a, b);
    }

    function min(int256 a, int256 b) internal pure returns (int256) {
        return ternary(a < b, a, b);
    }

    function average(int256 a, int256 b) internal pure returns (int256) {
        int256 x = (a & b) + ((a ^ b) >> 1);
        return x + (int256(uint256(x) >> 255) & (a ^ b));
    }

    function abs(int256 n) internal pure returns (uint256) {
        unchecked {
            int256 mask = n >> 255;

            return uint256((n + mask) ^ mask);
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Comparators} from "./Comparators.sol";
import {SlotDerivation} from "./SlotDerivation.sol";
import {StorageSlot} from "./StorageSlot.sol";
import {Math} from "../utils/math/Math.sol";

library Arrays{
    using SlotDerivation for bytes32;
    using StorageSlot for bytes32;

    function sort(
        uint256[] memory array,
        function(uint256,uint256) pure returns(bool) comp
    ) internal pure returns(uint256[] memory){
        _quickSort(_begin(array),_end(array),comp);
        return array;
    }
}
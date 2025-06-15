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

    function sort(uint256[] memory array) internal pure returns(uint256[] memory){
        sort(array, Comparators.lt);
        return array;
    }

    function sort(
        address[] memory array,
        function(address,address) pure returns(bool) comp
    ) internal pure returns(address[] memory){
        sort(_castToUint256Array(array),_castToUint256Comp(comp));
        return array;
    }

    function sort(address[] memory array) internal pure returns(address[] memory){
        sort(_castToUint256Array(array),Comparators.lt);
        return array;
    }

    function sort(
        bytes32[] memory array,
        function(bytes32,bytes32) pure returns(bool) comp
    ) internal pure returns(bytes32[] memory){
        sort(_castToUint256Array(array),_castToUint256Comp(comp));
        return array;
    }

    function sort(bytes32[] memory array) internal pure returns(bytes32[] memory){
        sort(_castToUint256Array(array),Comparators.lt);
        return array;
    }

    function _quickSort(uint256 begin,uint256 end,function(uint256,uint256) pure returns(bool) comp) private pure {
        unchecked {
            if(end-begin <0x40) return;

            uint256 pivot = _mload(begin);

            uint256 pos = begin;

            for(uint256 it = begin + 0x20;it<end;it+=0x20){
                if(comp(_mload(it),pivot)){
                    pos+= 0x20;
                    _swap(pos,it);
                }
            }

            _swap(begin,pos);
            _quickSort(begin, end, comp);
            _quickSort(pos+0x20, end, comp);
        }
    }

    function _begin(uint256[] memory array) private pure returns(uint256 ptr){
        assembly("memory-safe") {
            ptr := add(array,0x20)
        }
    }

    function _end(uint256[] memory array) private pure returns(uint256 ptr){
        unchecked {
            return _begin(array) +array.length * 0x20;
        }
    }

    function _mload(uint256 ptr) private pure returns(uint256 value){
        assembly {
            value := mload(ptr)
        }
    }

    function _swap(uint256 ptr1,uint256 ptr2) private pure{
        assembly {
            let value1 := mload(ptr1)
            let value2 := mload(ptr2)
            mstore(ptr1,value2)
            mstore(ptr2,value1)
        }
    }

    function _castToUint256Array(address[] memory input) private pure returns(uint256[] memory output){
        assembly {
            output:=input
        }
    }

    function _castToUint256Array(bytes32[] memory input) private pure returns(uint256[] memory output){
        assembly {
            output := input
        }
    }

    function _castToUint256Comp(function(bytes32,bytes32) pure returns(bool) input) private pure returns (function(uint256,uint256) pure returns(bool) output) {
        assembly {
            output := input
        }
    }

    function _castToUint256Comp(function(address,address) pure returns(bool) input) private pure returns (function(uint256,uint256) pure returns(bool) output) {
        assembly {
            output := input
        }
    }

    function findUpperBound(uint256[] storage array,uint256 element) internal view returns(uint256){
        uint256 low = 0;
        uint256 high = array.length;

        if(high == 0){
            return 0;
        }

        while(low < high){
            uint256 mid = Math.average(low,high);

            if(unsafeAccess(array,mid).value > element){
                high = mid;
            }else{
                low = mid + 1;
            }
        }

        if(low >0 && unsafeAccess(array,low-1).value == element){
            return low - 1;
        }else{
            return low;
        }
    }

    function lowerBound(uint256[] storage array,uint256 element) view internal returns (uint256) {
        uint256 low = 0;
        uint256 high = array.length;

        if(high == 0){
            return 0;
        }

        while(low < high){
            uint256 mid = Math.average(low,high);

            if(unsafeAccess(array,mid).value < element){
                unchecked {
                    low = mid + 1;
                }
            }else{
                high = mid;
            }
        }
        return low;
    }

    function upperBound(uint256[] storage array,uint256 element) view internal returns (uint256) {
        uint256 low = 0;
        uint256 high = array.length;

        if(high == 0){
            return 0;
        }

        while(low < high){
            uint256 mid = Math.average(low,high);

            if(unsafeAccess(array,mid).value > element){
                high = mid;
            }else{
                unchecked {
                    low = mid + 1;
                }
            }
        }
        return low;
    }
    
    function lowerBoundMemory(uint256[] memory array,uint256 element) internal pure returns (uint256) {
        uint256 low = 0;
        uint256 high = array.length;

        if(high == 0){
            return 0;
        }

        while(low < high){
            uint256 mid = Math.average(low,high);

            if(unsafeMemoryAccess(array,mid)<element){
                unchecked {
                    low = mid + 1;
                }
            }else{
                high = mid;
            }
        }
        return low;
    }

    function upperBoundMemory(uint256[] memory array,uint256 element) internal pure returns(uint256){
        uint256 low = 0;
        uint256 high = array.length;

        if(high == 0){
            return 0;
        }

        while(low < high){
            uint256 mid = Math.average(low,high);

            if(unsafeMemoryAccess(array,mid) > element){
                high = mid;
            }else{
                unchecked {
                    low = mid + 1;
                }
            }
        }
        return low;
    }

    function unsafeAccess(address[] storage arr,uint256 pos) internal pure returns(StorageSlot.AddressSlot storage){
        bytes32 slot;
        assembly("memory-safe") {
            slot := arr.slot
        }
        return slot.deriveArray().offset(pos).getAddressSlot();
    }

    function unsafeAccess(bytes32[] storage arr,uint256 pos) internal pure returns(StorageSlot.Bytes32Slot storage){
        bytes32 slot;
        assembly("memory-safe") {
            slot := arr.slot
        }
        return slot.deriveArray().offset(pos).getBytes32Slot();
    }

    function unsafeAccess(uint256[] storage arr,uint256 pos) internal pure returns(StorageSlot.Uint256Slot storage){
        bytes32 slot;
        assembly("memory-safe") {
            slot := arr.slot
        }
        return slot.deriveArray().offset(pos).getUint256Slot();
    }

    function unsafeAccess(bytes[] storage arr,uint256 pos) internal pure returns(StorageSlot.BytesSlot storage){
        bytes32 slot;
        assembly("memory-safe") {
            slot := arr.slot
        }
        return slot.deriveArray().offset(pos).getBytesSlot();
    }

    function unsafeAccess(string[] storage arr,uint256 pos) internal pure returns(StorageSlot.StringSlot storage){
        bytes32 slot;
        assembly("memory-safe") {
            slot := arr.slot
        }
        return slot.deriveArray().offset(pos).getStringSlot();
    }

    function unsafeMemoryAccess(address[] memory arr,uint256 pos) internal pure returns(address res){
        assembly {
            res := mload(add(add(arr,0x20),mul(pos,0x20)))
        }
    }

    function unsafeMemoryAccess(bytes32[] memory arr,uint256 pos) internal pure returns(bytes32 res){
        assembly {
            res := mload(add(add(arr,0x20),mul(pos,0x20)))
        }
    }

    function unsafeMemoryAccess(uint256[] memory arr,uint256 pos) internal pure returns(uint256 res){
        assembly {
            res := mload(add(add(arr,0x20),mul(pos,0x20)))
        }
    }

    function unsafeMemoryAccess(bytes[] memory arr,uint256 pos) internal pure returns(bytes memory res){
        assembly {
            res := mload(add(add(arr,0x20),mul(pos,0x20)))
        }
    }

    function unsafeMemoryAccess(string[] memory arr,uint256 pos) internal pure returns(string memory res){
        assembly {
            res := mload(add(add(arr,0x20),mul(pos,0x20)))
        }
    }

    function unsafeSetLength(address[] storage array,uint256 len) internal{
        assembly("memory-safe") {
            sstore(array.slot,len)
        }
    }

    function unsafeSetLength(bytes32[] storage array,uint256 len) internal{
        assembly("memory-safe") {
            sstore(array.slot,len)
        }
    }

    function unsafeSetLength(uint256[] storage array,uint256 len) internal{
        assembly("memory-safe") {
            sstore(array.slot,len)
        }
    }

    function unsafeSetLength(bytes[] storage array,uint256 len) internal{
        assembly("memory-safe") {
            sstore(array.slot,len)
        }
    }

    function unsafeSetLength(string[] storage array,uint256 len) internal{
        assembly("memory-safe") {
            sstore(array.slot,len)
        }
    }

}
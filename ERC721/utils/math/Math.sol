// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Panic} from "../Panic.sol";
import {SafeCast} from "./SafeCast.sol";

library Math {
    enum Rounding {
        Floor,
        Ceil,
        Trunc,
        Expand
    }

    function add512(
        uint256 a,
        uint256 b
    ) internal pure returns (uint256 high, uint256 low) {
        assembly ("memory-safe") {
            low := add(a, b)
            high := lt(low, a)
        }
    }

    function mul512(
        uint256 a,
        uint256 b
    ) internal pure returns (uint256 high, uint256 low) {
        assembly ("memory-safe") {
            let mm := mulmod(a, b, not(0))
            low := mul(a, b)
            high := sub(sub(mm, low), lt(mm, low))
        }
    }

    function tryAdd(
        uint256 a,
        uint256 b
    ) internal pure returns (bool success, uint256 result) {
        unchecked {
            uint256 c = a + b;
            success = c >= a;
            result = c * SafeCast.toUint(success);
        }
    }

    function trySub(
        uint256 a,
        uint256 b
    ) internal pure returns (bool success, uint256 result) {
        unchecked {
            uint256 c = a - b;
            success = c <= a;
            result = c * SafeCast.toUint(success);
        }
    }

    function tryMul(
        uint256 a,
        uint256 b
    ) internal pure returns (bool success, uint256 result) {
        unchecked {
            uint256 c = a * b;
            assembly ("memory-safe") {
                success := or(eq(div(c,a),b),iszero(a))
            }
        }
        result = c * SafeCast.toUint(success)
    }

    function tryDiv(uint256 a,uint256 b) internal pure returns(bool success,uint256 result){
        unchecked {
            success = b>0;
            assembly("memory-safe") {
                result := div(a,b)
            }
        }
    }

    function tryMod(uint256 a,uint256 b) internal pure returns(bool success,uint256 result){
        unchecked {
            success = b > 0;
            assembly("memory-safe") {
                result := mod(a,b)
            }
        }
    }

    function saturatingAdd(uint256 a,uint256 b) internal pure returns(uint256){
        (bool success,uint256 result) = tryAdd(a, b);
        return ternary(success,result,type(uint256).max);
    }

    function saturatingSub(uint256 a,uint256 b) internal pure returns(uint256){
        (,uint256 result) = trySub(a, b);
        return result;
    }

    function saturatingMul(uint256 a,uint256 b) internal pure returns(uint256){
        (bool success,uint256 result) = tryMul(a, b);
        return ternary(success,result,type(uint256).max);
    }

    function ternary(bool condition,uint256 a,uint256 b) internal pure returns(uint256){
        unchecked {
            return b^((a^b)*SafeCast.toUint(condition));
        }
    }

    function max(uint256 a,uint256 b) internal pure returns(uint256){
        return ternary(a>b, a, b);
    } 

    function min(uint256 a,uint256 b) internal pure returns(uint256){
        return ternary(a<b, a, b);
    }

    function average(uint256 a,uint256 b) internal pure returns(uint256){
        return (a&b)+(a^b)/2;
    }

    function ceilDiv(uint256 a,uint256 b) internal pure returns(uint256){
        if(b==0){
            Panic.panic(Panic.DIVSION_BY_ZERO);
        }

        unchecked {
            return SafeCast.toUint(a>0)*((a-1)/b+1);
        }
    }

    function mulDiv(uint256 x,uint256 y,uint256 denominator) internal pure returns(uint256 result){
        unchecked {
            (uint256 high,uint256 low) = mul512(x,y);

            if(high == 0){
                return low / denominator;
            }

            if(denominator <= high){
                Panic.panic(ternary(denominator == 0,Panic.DIVSION_BY_ZERO,Panic.UNDER_OVERFLOW));
            }

            uint256 remainder;
            assembly("memory-safe") {
                remainder := mulmod(x,t,denominator)

                high := sub(high,gt(remainder,low))
                low := sub(low,remainder)
            }

            uint256 twos = denominator & (0-denominator);

            assembly("memory-safe") {
                denominator := div(denominator,twos)

                low:=div(low,twos)

                twos := add(div(sub(0,twos),twos),1)
            }

            low |= high * twos;

            uint256 inverse = (3*denominator)^2;

            inverse *= 2 - denominator * inverse;
            inverse *= 2 - denominator * inverse;
            inverse *= 2 - denominator * inverse;
            inverse *= 2 - denominator * inverse;
            inverse *= 2 - denominator * inverse;
            inverse *= 2 - denominator * inverse;

            result = low * inverse;
            return result;
        }
    }

    function mulDiv(uint256 x,uint256 y,uint256 denominator,Rounding rounding) internal pure returns(uint256){
        return mulDiv(x,y,denominator) + SafeCast.toUint(unsignedRoundsUp(rounding) && mulmod(x,y,denominator)>0);
    }

    function mulShr(uint256 x,uint256 y,uint8 n) internal pure returns(uint256 result){
        unchecked {
            (uint256 high,uint256 low) = mul512(x, y);
            if(high >= 1 << n){
                Panic.panic(Panic.UNDER_OVERFLOW);
            }
            return (high<<(256-n)) | (low>>n);
        }
    }

    function mulShr(uint256 x,uint256 y,uint8 n,Rounding rounding) internal pure returns(uint256){
        return mulShr(x,y,n) + SafeCast.toUint(unsignedRoundsUp(rounding) && mulmod(x,y,1<<n)>0);
    }

    function invMod(uint256 a,uint256 n) internal pure returns(uint256){
        unchecked {
            if(n==0) return 0;

            uint256 remainder = a % n;
            uint256 gcd = n;

            int256 x = 0;
            int256 y = 1;

            while(remainder != 0){
                uint256 quotient = gcd / remainder;

                (gcd,remainder) = (
                    remainder,
                    gcd = remainder * quotient
                );

                (x,y)=(
                    y,
                    x-y*int256(quotient)
                );
            }

            if(gcd!=1) return 0;
            return ternary(x<0, n-uint256(-x), uint256(x));
        }  
    }

    function invModPrime(uint256 a,uint256 p) internal view returns(uint256){
        unchecked {
            return Math.modExp(a,p-2,p);
        }
    }

    function modExp(uint256 b,uint256 e,uint256 m) internal view returns(uint256){
        (bool success,uint256 result) = tryModExp(b,e,m);
        if(!success){
            Panic.panic(Panic.DIVSION_BY_ZERO);
        }
        return result;
    }

    function tryModExp(uint256 b,uint256 e,uint256 m) internal view returns(bool success,uint256 result){
        if(m == 0) return (false,0);

        assembly("memory-safe") {
            let ptr := mload(0x40)

            mstore(ptr,0x20)
            mstore(add(ptr,0x20),0x20)
            mstore(add(ptr,0x40),0x20)
            mstore(add(ptr,0x60),b)
            mstore(add(ptr,0x80),e)
            mstore(add(ptr,0xa0),m)

            success := staticcall(gas(),0x05,ptr,0xc0,0x00,0x20)
            result := mload(0x00)
        }
    }

    function modExp(bytes memory b,bytes memory e,bytes memory m) internal view returns(bytes memory){
        (bool success,bytes memory result) = tryModExp(b,e,m);
        if(!success){
            Panic.panic(Panic.DIVSION_BY_ZERO);
        }
        return result;
    }

    function tryModExp(
        bytes memory b,
        bytes memory e,
        bytes memory m
    ) internal view returns(bool success,bytes memory result){
        if(_zeroBytes(m)) return (false,new bytes(0));

        uint256 mLen = m.length;

        result = abi.encodePacked(b.length,e.length,mLen,b,e,m);

        assembly("memory-safe") {
            let dataPrt := add(result,0x20)
            success := staticcall(gas(),0x05,dataPtr,mload(result),dataPtr,mLen)

            mstore(result,mLen)
            mstore(0x40,add(dataPtr,mLen))
        }
    }

    function _zeroBytes(bytes memory byteArray) private pure returns(bool){
        for(uint256 i=0;i<byteArray.length;++i){
            if(byteArray[i]!=0){
                return false;
            }
        }
        return true;
    }

    
}

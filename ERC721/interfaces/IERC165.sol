// SPDX-License-Identifier: MIT

pragma solidity >=0.4.16;

//接口支持
interface IERC165 {
    
    function supportsInterface(bytes4 interfaceId) external view returns(bool);
}
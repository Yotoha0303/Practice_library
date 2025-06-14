// SPDX-License-Identifier: MIT

pragma solidity >=0.4.16;

interface IERC165 {
    
    function supportsInterface(bytes4 interfaceId) external view returns(bool);
}
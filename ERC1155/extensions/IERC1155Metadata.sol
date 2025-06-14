// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2;

import {IERC1155} from "../interfaces/IERC1155.sol";

interface IERC1155MetadataURI is IERC1155{
    
    function uri(uint256 id) external view returns(string memory);
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2;

import {IERC721} from "../interfaces/IERC721.sol";

interface IERC721Metadata is IERC721 {
    
    function name() external view returns(string memory);

    function symbol() external view returns(string memory);

    function tokenURI(uint256 tokenId) external view returns(string memory);
}
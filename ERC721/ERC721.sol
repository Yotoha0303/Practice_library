// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {IERC721} from "./interfaces/IERC721.sol";
import {IERC721Metadata} from "./extensions/IERC721Metadata.sol";
import {IERC721Utils} from "./utils/ERC721Utils.sol";
import {Context} from "./utils/Context.sol";
import {strings} from "./utils/Strings.sol";
import {IERC165,ERC165} from "./introspection/ERC165.sol";
import {IERC721Errors} from "./interfaces/draft-IERC6093.sol";

//非同质化合约
abstract contract ERC721 is Context,ERC165,IERC165,IERC721,IERC721Metadata,IERC721Errors{

    using string for uint256;

    
}


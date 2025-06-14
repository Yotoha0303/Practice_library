// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {IERC1155} from "./interfaces/IERC1155.sol";
import {IERC1155MetadataURI} from "./extensions/IERC1155Metadata.sol";
import {ERC1155Utils} from "./utils/ERC1155Utils.sol";
import {Context} from "./utils/Context.sol";
import {IERC165,ERC165} from "./introspection/ERC165.sol";
import {Arrays} from "./utils/Array.sol";
import {IERC1155Errors} from "./interfaces/draft-IERC6093.sol";

abstract contract ERC1155 is Context,ERC165,IERC1155,IERC1155MetadataURI,IERC1155Errors {

    using Arrays for uint256[];
    using Arrays for address[];

}
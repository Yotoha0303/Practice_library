// SPDX-License-Identifier: MIT

import {IERC165} from "../interfaces/IERC165.sol";

abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual returns(bool){
        return interfaceId == type(IERC165).interfaceId;
    }
}
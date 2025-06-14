// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {IERC1155Receiver} from "../interfaces/IERC1155Receiver";
import {IERC1155Errors} from "../interfaces/draft-IERC6093";

library ERC1155Utils{
    function checkOnERC1155Received(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 value,
        bytes memory data
    ) internal{
        if(to.code.length > 0){
            try IERC1155Receiver(to).onERC1155Received(operator,from,id,value,data) returns(bytes4 response){
                if(response !=IERC1155Receiver.onERC1155Received.selector){
                    revert IERC1155Errors.ERC1155InvalidReceiver(to);
                }
            }catch(bytes memory reason){
                if(reason.length == 0){
                    revert IERC1155Errors.ERC1155InvalidReceiver(to);
                }else{
                    assembly("memory-safe") {
                        revert(add(reason,0x20),mload(reason))
                    }
                }
            }
        }
    }

    function checkOnERC1155BatchReceived(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values,
        bytes memory data
    ) internal{
        if(to.code.length > 0){
            try IERC1155Receiver(to).onERC1155BatchReceived(operator,from,ids,values,data) returns(bytes4 response){
                if(response!=IERC1155Receiver.onERC1155BatchReceived.selector){
                    revert IERC1155Errors.ERC1155InvalidReceiver(to);
                }
            }catch(bytes memory reason){
                if(reason.length ==0){
                    revert IERC1155Errors.ERC1155InvalidReceiver(to);
                }else{
                    assembly("memory-safe") {
                        revert(add(reason,0x20),mload(reason));
                    }
                }
            }
        }
    }
}
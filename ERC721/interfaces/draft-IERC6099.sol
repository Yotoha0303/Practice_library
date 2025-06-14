// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2;

import {IERC165} from "./IERC165.sol";

interface IERC6909 is IERC165 {
    
    event Approval(address indexed owner,address indexed spender,uint256 indexed id,uint256 amount);

    event OperatorSet(address indexed owner,address indexed spender,bool approved);

    event Transfer(
        address caller,
        address indexed sender,
        address indexed receiver,
        uint256 indexed id,
        uint256 amount
    );

    function balanceOf(address owner,uint256 id) external view returns(uint256);

    function allowance(address owner,address spender,uint256 id) external view returns(uint256);

    function isOperator(address owner,address spender) external view returns(bool);

    function approve(address spender,uint256 id,uint256 amount) external returns(bool);

    function setOperator(address spender,bool approved) external returns(bool);

    function transfer(address receiver,uint256 id,uint256 amount) external returns(bool);

    function transferFrom(address sender,address receiver,uint256 id,uint256 amount) external returns(bool);
}

interface IERC6909Metadta is IERC6909 {
    
    function name(uint256 id) external view returns(string memory);

    function symbol(uint256 id) external view returns(string memory);

    function decimals(uint256 id) external view returns(uint8);
}

interface IERC6909ContentURI is IERC6909 {
    
    function contractURI() external view returns(string memory);

    function tokenURI(uint256 id) external view returns(string memory);
}

interface IERC6909TokenSupply is IERC6909 {
    
    function totalSupply(uint256 id) external view returns(uint256);
}
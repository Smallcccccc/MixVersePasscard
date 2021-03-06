// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GameModel {
    struct ZverseItem {
        uint256 cryptoFaceIndex;
        string name;
        string description;
        string imageURI;
        uint256 legendaryHypeLevel;
        uint256 hypeLevel;
        uint256 hypeValue;
    }
}
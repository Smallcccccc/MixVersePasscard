// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

// Helper functions OpenZeppelin provides.
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./model/Game.sol";

// Helper we wrote to encode in Base64
import "./libraries/Base64.sol";

// Hardhat util for console output
import "hardhat/console.sol";

contract MxiVerseNFT is ERC721URIStorage,GameModel{

 string constant description="blah";  //这是nft描述

 mapping(address=>uint256) public holders;
 mapping(uint256=>ZverseItem) public zverseItemNFTs;

 using Counters for Counters.Counter;
 Counters.Counter private _tokenIds;  //当前的tokenId计数

 event InfoUpdated(uint256 tokenId,ZverseItem item);

 constructor(string memory name,string memory symbol) ERC721(name,symbol)
 {
     console.log("NFT initialized");
 }

 //获取当前token的总数量
 function getTotalCollection() public view returns (uint256) {
    return _tokenIds.current();
 }

 //铸造NFT
 function mintNFT(ZverseItem memory item )public returns (uint256)
 {
    address owner =tx.origin;   //返回最初发送调用的账户

    uint256 tokenId=_tokenIds.current(); //获取当前的tokenid

    // 保存铸造数据
        zverseItemNFTs[tokenId] = ZverseItem({
        cryptoFaceIndex : tokenId,
        name : item.name,
        description : item.description,
        imageURI : item.imageURI,
        legendaryHypeLevel : item.legendaryHypeLevel,
        hypeLevel : item.hypeLevel,
        hypeValue : item.hypeValue
        });

    // 添加token到创世者
    _safeMint(owner, tokenId);   

    holders[owner] = tokenId;

    _tokenIds.increment();  //增加id计数

    console.log("NFT minted by %s, tokenId: %s", owner, tokenId);

    return tokenId; 

 }

//获取改地址持有的nft
function getOwnerNFTs(address _owner) public view returns (ZverseItem[] memory) {
        ZverseItem[] memory result = new ZverseItem[](balanceOf(_owner));

        uint256 counter = 0;
        for (uint256 i = 0; i < _tokenIds.current(); i++) {
            if (ownerOf(i) == _owner) {
                result[counter] = zverseItemNFTs[i];
                counter++;
            }
        }

        return result;
}

//通过id获得nft
function getById(uint256 id) public view returns (ZverseItem memory) {
        return zverseItemNFTs[id];
}


//更新nft描述信息
function updateInfo(uint256 tokenId, string memory zvereName,string memory zverseDescription) external payable {
        require(ownerOf(tokenId) == msg.sender);
        require(bytes(zvereName).length != 0);
        require(bytes(zverseDescription).length != 0);

        ZverseItem storage item = zverseItemNFTs[tokenId];

        item.name = zvereName;
        item.description = zverseDescription;

        emit InfoUpdated(tokenId, item);
}


}

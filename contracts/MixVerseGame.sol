// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import "./model/Game.sol";
import "./NFT.sol";

import "hardhat/console.sol";

contract MixVerseGame is ERC721,GameModel{

  string private constant nameOfToken="Zverse";
  string private constant symbolOfToken="ZVS";

  event ZverseNFTMinted(address sender, uint256 tokenId, uint256 Index, ZverseItem item);

  ZverseItem[] defaultItems;

  MxiVerseNFT private nft;

  constructor(MxiVerseNFT _nft,string[] memory zverseName,string[] memory zverseDescription,string[] memory zverseImage) payable ERC721(nameOfToken,symbolOfToken){
     console.log("MixVerseGame initializing...");

     nft=_nft;

     // Initialize the game with default characters
        for (uint i = 0; i < zverseName.length; i++) {
            ZverseItem memory item = ZverseItem({
            cryptoFaceIndex : i,
            name : zverseName[i],
            description : zverseDescription[i],
            imageURI : zverseImage[i],
            legendaryHypeLevel : 0,
            hypeLevel : 1,
            hypeValue : 10
            });

            defaultItems.push(item);

            console.log("Done initializing %s w/, img %s", item.name, item.imageURI);
        }
        console.log("Game initialized :)");
   }


   //铸造默认NFT
   function mintCharacterNFT(uint itemIndex) external {
        require(
            itemIndex >= 0 && itemIndex < defaultItems.length,
            "Character index out of bounds."
        );

        ZverseItem memory item = defaultItems[itemIndex];

        uint256 tokenId = nft.mintNFT(item);

        emit ZverseNFTMinted(msg.sender, tokenId, itemIndex, item);
    }

    //获取所有默认nft
    function getDefaultCharacters() public view returns (ZverseItem[] memory)  {
        return defaultItems;
    }

    //获取nft总的铸造数量
    function getTotalNFTMinted() public view returns (uint256) {
        return nft.getTotalCollection();
    }

    //获取某个地址持有nft
    function getOwnedZverseItems() public view returns (ZverseItem[] memory) {
        address ownerAddress = msg.sender;

        return nft.getOwnerNFTs(ownerAddress);
    }

}
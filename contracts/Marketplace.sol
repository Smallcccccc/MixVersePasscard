// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./model/Game.sol";
import "./NFT.sol";

//NFT售卖商店
contract Marketplace is GameModel{

   //商品结构
   struct Offer{
       address payable seller;
       uint256 price;
       uint256 index;
       uint256 tokenId;
       bool active;
   }

   event MarketTransaction(string TxType, address owner, uint256 tokenId);

   MxiVerseNFT private _nftContract;

   Offer[] offers;

   mapping(uint256=> Offer)  tokenIdToOffer;

   mapping(uint256=>uint256) tokenIdToOfferId;
   

   //获取当前合约地址
   function getContractAddress() external view returns(address)
   {
       return address(this);
   }

   constructor(MxiVerseNFT _nft){
        _nftContract = MxiVerseNFT(_nft);
   } 

   //获取某件商品信息
   function getOffer(uint256 tokenId) external view returns(address,uint256,uint256,uint256,bool)
   {
      Offer storage  offer = tokenIdToOffer[tokenId];  //获取商品引用

      require(offer.active==true,"Marketplace: There is no active offer for this token");

      return(
        offer.seller,
        offer.price,
        offer.index,
        offer.tokenId,
        offer.active
      );


   }

   //获取商店里的所有tokenid
   function getOfferIds() external view returns(uint256[] memory)
   {
       uint256 offerNum=offers.length;

       if(offerNum==0)
       return new uint256[](0);

       uint256[] memory listOfOffers=new uint256[](offerNum);

       for(uint i=0;i<offerNum;i++)
       {
            listOfOffers[i]=offers[i].tokenId;
       }

       return listOfOffers;

   }

    //获取多个商品信息
    function getOffers() external view returns (Offer[] memory) {
        uint256 numOfOffers = offers.length;

        Offer[] memory result = new Offer[](numOfOffers);
        for (uint256 i = 0; i < numOfOffers; i++) {
            result[i] = offers[i];
        }

        return result;
    }

    //此地址是否持有此nft
    function ownerOfNft(address theAddress, uint256 theTokenId) internal view returns (bool){
        return (_nftContract.ownerOf(theTokenId) == theAddress);
    }


    //上架商品
    function createOffer(uint256 _price, uint256 _tokenId) public {
        require(ownerOfNft(msg.sender, _tokenId), "You must own the nft you want to sell");
        require(tokenIdToOffer[_tokenId].active == false, "There is currently an active offer");

        _createOffer(_price, _tokenId, msg.sender);
    }
     
    function _createOffer(uint256 _price, uint256 _tokenId, address _seller) internal {
        Offer memory _offer = Offer({
        seller : payable(_seller),
        price : _price,
        index : offers.length,
        tokenId : _tokenId,
        active : true
        });

        tokenIdToOffer[_tokenId] = _offer;
        offers.push(_offer);

        emit MarketTransaction("Create offer", msg.sender, _tokenId);
    } 


    //下架某个商品
    function removeOffer(uint256 _tokenId) public {
        Offer memory offer = tokenIdToOffer[_tokenId];
        require(offer.seller == msg.sender, "You need to be the seller of that nft");

        _removeOffer(_tokenId, msg.sender);
    }

    function _removeOffer(uint256 _tokenId, address _seller) internal {
        uint256 targetIndex = tokenIdToOffer[_tokenId].index;
        uint256 lastIndex = offers.length - 1;

        if (lastIndex > 0) {
            offers[targetIndex] = offers[lastIndex];
            offers[targetIndex].index = targetIndex;
            tokenIdToOffer[offers[targetIndex].tokenId] = offers[targetIndex];
        }

        offers.pop();

        delete tokenIdToOffer[_tokenId];

        emit MarketTransaction("Remove offer", _seller, _tokenId);
    }

    //购买nft
    function buyToken(uint256 _tokenId) external payable {
        Offer memory offer = tokenIdToOffer[_tokenId];
        require(msg.value == offer.price, "The price doesnt match");
        require(offer.seller != msg.sender, "Marketplace: Cannot by your own token!");
        require(offer.active == true, "No active orders");

        _buyToken(_tokenId, msg.sender);
    }

    function _buyToken(uint256 _tokenId, address _buyer) internal {
        Offer memory offer = tokenIdToOffer[_tokenId];
        address seller = offer.seller;
        uint256 price = offer.price;

        (bool success,) = payable(seller).call{value : price}("");

        require(success, "Marketplace: Failed to send funds to the seller");

        _nftContract.transferFrom(seller, _buyer, _tokenId);

        removeOffer(_tokenId);

        emit MarketTransaction("Buy", msg.sender, _tokenId);
    }

}
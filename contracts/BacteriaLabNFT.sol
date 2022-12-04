// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import { BacteriaLabGameManager } from "./BacteriaLabGameManager.sol";

library BacteriaLabNFT {
    struct NFT {
        // map tile index to color (the same as the id of tile owner)
        mapping(uint8 => uint8) contentMap;
        address ownerAddress;
    }

    function _createNFT(BacteriaLabGameManager.gameManagerType storage gameManager, address ownerAddress) public {
        uint8 nftID = gameManager.NFTCount;
        gameManager.NFTCollection[nftID].ownerAddress = ownerAddress;
        for (uint8 i = 0; i < 64; i++) {
            gameManager.NFTCollection[nftID].contentMap[i]=gameManager.map[i].ownerID;
        }
        gameManager.NFTCount += 1;
    }
}
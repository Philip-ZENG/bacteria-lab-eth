// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import { BacteriaLabGameManager } from "./BacteriaLabGameManager.sol";

library BacteriaLabNFT {
    struct NFT {
        uint[] content;
        address ownerAddress;
    }

    function createNFT(BacteriaLabGameManager.gameManagerType storage gameManager, address ownerAddress, uint nftID) public {
        gameManager.NFTCollection[nftID].ownerAddress = ownerAddress;
        for (uint i = 0; i < gameManager.totalColonyCount; i++) {
            gameManager.NFTCollection[nftID].content.push(gameManager.map[i].ownerID);
        }
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import { BacteriaLabColony } from "./BacteriaLabColony.sol";
import { BacteriaLabPlayer } from "./BacteriaLabPlayer.sol";
import { BacteriaLabGameManager } from "./BacteriaLabGameManager.sol";
import { BacteriaLabNFT } from "./BacteriaLabNFT.sol";

contract BacteriaLabCore {
    /// Storagte Space ///
    // Define game world variables here
    BacteriaLabGameManager.gameManagerType public gameManager;
    BacteriaLabGameManager.gameInitVarType public gameInitVar;

    /// Initializer ///
    // Initializer function: executed when the contract is created
    constructor(address creator) {
        gameManager.adminAddress = creator;

        BacteriaLabGameManager.setGameInitVariable({
            gameInitVar: gameInitVar, 
            mapWidth: 16,
            mapLength: 16,
            playerInitialNutrition: 100,
            colonyMaxAbsorptionRate: 20,
            colonyMaxDefenseNutrition: 50,
            colonyMaxOccupyNutrition: 20,
            nutritionAbsorptionRandomSeed: 13,
            defenseNutritionRandomSeed: 37,
            occupyNutritionRandomSeed: 53
        });
    }

    /// Access Control ///
    modifier onlyAdmin() {
        require(msg.sender == gameManager.adminAddress, "Only admin can call this function");
        _;
    }

    modifier isPlayer() {
        require(gameManager.isPlayer[msg.sender] == true, "Only player can call this function");
        _;
    }

    modifier managerIsInit() {
        require(gameManager.isInit, "This function can only be called after game manager initialize");
        _;
    }

    modifier isNotStart() {
        require(!gameManager.isStart, "This function can only be called before game starts");
        _;
    }

    modifier isStart() {
        require(gameManager.isStart, "This function can only be called when game is on going");
        _;
    }

    modifier isNotEnd() {
        require(!gameManager.isEnd, "This function can only be called when game is not end");
        _;
    }

    modifier isEnd() {
        require(gameManager.isEnd, "This function can only be called after game ends");
        _;
    }

    /// GameManager Caller ///
    // remix-pass, 
    function initializeGameManager() public onlyAdmin isNotStart {
        BacteriaLabGameManager._initializeGameManager(gameManager, gameInitVar);
    }

    function enterGame() public managerIsInit isStart{
        require(gameManager.isPlayer[msg.sender] == false, "Palyer has already enter the game");
        BacteriaLabGameManager._enterGame(gameManager, gameInitVar);
    }

    function initializeGame(uint8 startID) public onlyAdmin isNotStart {
        BacteriaLabGameManager._initializeGame(gameManager, gameInitVar, startID);
    }

    function startGame() public onlyAdmin isNotStart {
        gameManager.isStart = true;
    }

    function updateState() public onlyAdmin isStart {
        BacteriaLabGameManager._updateState(gameManager);
    }

    function endGame() public onlyAdmin isStart {
        BacteriaLabGameManager._endGame(gameManager);
    }

    function pickWinner() public onlyAdmin isEnd view returns(address) {
        return BacteriaLabGameManager._pickWinner(gameManager);
    }

    function attack(uint8 playerID, uint8 attackNutrition, uint8 targetColonyID) public isPlayer isStart isNotEnd {
        require(msg.sender == gameManager.playerList[playerID].playerAddress);
        require(gameManager.map[targetColonyID].isOwned, "You cannot attack a colony that has no owner");
        uint8 enemyID = gameManager.map[targetColonyID].ownerID;
        bool succeed = BacteriaLabPlayer._attack(gameManager.playerList[playerID], attackNutrition, gameManager.playerList[enemyID], gameManager.map[targetColonyID], gameManager.mapLength);
        if(succeed) {
            // Successful attack turn the colony from owned status to non-owned status
            gameManager.colonyOwned[targetColonyID] = false;
        }
    }

    function occupy(uint8 playerID, uint8 targetColonyID) public isPlayer isStart isNotEnd {
        require(msg.sender == gameManager.playerList[playerID].playerAddress);
        require(!gameManager.map[targetColonyID].isOwned, "You cannot occupy a colony that has owner, you need to attack it before occupy it");
        bool succeed = BacteriaLabPlayer._occupy(gameManager.playerList[playerID], gameManager.map[targetColonyID], gameManager.mapLength);
        if(succeed) {
            // Successful occupy turn colony from non-owned state to owned state
            gameManager.colonyOwned[targetColonyID] = true;
        }
    }

    function createNFT(address ownerAddress) public {
        BacteriaLabNFT._createNFT(gameManager, ownerAddress);
    }

    /// Getter Function ///
    function getColonyInfo(uint8 colonyID) public view
    returns(uint8, uint8, uint8, uint8, uint8, bool) 
    {
        return(
            gameManager.map[colonyID].id,
            gameManager.map[colonyID].ownerID,
            gameManager.map[colonyID].absorptionRate,
            gameManager.map[colonyID].defenseNutrition,
            gameManager.map[colonyID].occupyNutrition,
            gameManager.map[colonyID].isOwned
        );
    }

    function getPlayerInfo(uint8 playerID) public view
    returns(uint8, address, uint8, uint8, uint8, uint8)
    {
        return(
            gameManager.playerList[playerID].id,
            gameManager.playerList[playerID].playerAddress,
            gameManager.playerList[playerID].nutrition,
            gameManager.playerList[playerID].absorptionRate,
            gameManager.playerList[playerID].color,
            gameManager.playerList[playerID].colonyCount
        );
    }

    function getPlayerID(address playerAddress) public view returns(uint8) {
        uint8 playerID = gameManager.playerIdLookUp[playerAddress];
        return playerID;
    }

    function getNftTileInfo(uint8 nftID, uint8 tileID) public view returns(uint8) {
        uint8 tileColor = gameManager.NFTCollection[nftID].contentMap[tileID];
        return tileColor;
    }

    function getLatestGeneratedNFTID() public view returns(uint8) {
        uint8 newNFTID;
        if(gameManager.NFTCount > 0) {
            newNFTID = gameManager.NFTCount - 1;
        } else {
            newNFTID = 0;
        }
        return newNFTID;
    }
}
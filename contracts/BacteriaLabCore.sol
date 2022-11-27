// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import { BacteriaLabColony } from "./BacteriaLabColony.sol";
import { BacteriaLabPlayer } from "./BacteriaLabPlayer.sol";
import { BacteriaLabGameManager } from "./BacteriaLabGameManager.sol";

contract BacteriaLabCore {
    /// Storagte Space ///
    // Define game world variables here
    BacteriaLabGameManager.gameManagerType public gameManager;
    BacteriaLabGameManager.gameInitVarType public gameInitVar;


    /// Initializer ///
    // Initializer function: executed when the contract is created
    constructor() {
        gameManager.adminAddress = msg.sender;

        BacteriaLabGameManager.setGameInitVariable({
        gameInitVar: gameInitVar, 
        mapWidth: 3,
        mapLength: 3,
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

    modifier isEnd() {
        require(gameManager.isEnd, "This function can only be called after game ends");
        _;
    }

    /// GameManager Caller ///
    // remix-pass, 
    function initializeGameManager() public onlyAdmin isNotStart {
        BacteriaLabGameManager._initializeGameManager(gameManager, gameInitVar);
    }

    function enterGame() public isNotStart managerIsInit {
        require(gameManager.isPlayer[msg.sender] == false, "Palyer has already enter the game");
        BacteriaLabGameManager._enterGame(gameManager, gameInitVar);
    }

    function initializeGame() public onlyAdmin isNotStart {
        BacteriaLabGameManager._initializeGame(gameManager, gameInitVar);
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

    /// Getter Function ///
    function getColonyInfo(uint colonyID) public view
    returns(uint, uint, uint, uint, uint, bool) 
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

    function getPlayerInfo(uint playerID) public view
    returns(uint, address, uint, uint, uint, uint)
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
}
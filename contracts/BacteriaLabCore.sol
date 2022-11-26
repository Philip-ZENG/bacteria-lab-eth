// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import { BacteriaLabColony } from "./BacteriaLabColony.sol";
import { BacteriaLabPlayer } from "./BacteriaLabPlayer.sol";
import { BacteriaLabGameManager } from "./BacteriaLabGameManager.sol";

contract BacteriaLabCore {
    /// Storagte Space ///
    // Define game world variables here
    BacteriaLabGameManager.gameManagerType gameManager;
    BacteriaLabGameManager.gameInitVarType gameInitVar;


    /// Initializer ///
    // Initializer function: executed when the contract is created
    constructor() {
        gameManager.adminAddress = msg.sender;

        BacteriaLabGameManager.setGameInitVariable({
        gameInitVar: gameInitVar, 
        mapWidth: 10,
        mapLength: 10,
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
    function initializeGameManager() public onlyAdmin isNotStart {
        BacteriaLabGameManager._initializeGameManager(gameManager, gameInitVar);
    }

    function enterGame() public isNotStart {
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

}
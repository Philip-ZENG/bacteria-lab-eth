// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import { BacteriaLabColony } from "./BacteriaLabColony.sol";
import { BacteriaLabPlayer } from "./BacteriaLabPlayer.sol";

library BacteriaLabGameManager {

    // Attributes
    struct gameManagerType {
        address adminAddress;
        uint time; // block.timestamp
        uint mapWidth;
        uint mapLength;
        uint totalColonyCount;
        mapping(uint => BacteriaLabColony.Colony) map;
        mapping(uint => BacteriaLabPlayer.Player) playerList;
        bool isStart;
        bool isEnd;
        mapping(uint => address) playerAddressList; // mapping from player id to player address
        mapping(address => bool) isPlayer;
        uint playerCount;
    }

    // for initialization purpose only
    struct gameInitVarType {
        uint MAP_WIDTH;
        uint MAP_LENGTH;
        uint PLAYER_INITIAL_NUTRITION;
        uint COLONY_MAX_ABSORPTION_RATE;
        uint COLONY_MAX_DEFENSE_NUTRITION;
        uint COLONY_MAX_OCCUPY_NUTRITION;
        uint COLONY_NUTRITION_ABSORPTION_INIT_RANDOM_SEED; // Random seed input for generating colony absorptionRate
        uint COLONY_DEFENSE_NUTRITION_INIT_RANDOM_SEED;
        uint COLONY_OCCUPY_NUTRITION_INTI_RANDOM_SEED;
        mapping(uint => bool) colonyOwned; 
        mapping(uint => uint) colonyOwnerIDMapping; // map colony id to owner id
    }


    function setGameInitVariable(
        gameInitVarType storage gameInitVar,
        uint mapWidth,
        uint mapLength,
        uint playerInitialNutrition,
        uint colonyMaxAbsorptionRate,
        uint colonyMaxDefenseNutrition,
        uint colonyMaxOccupyNutrition,
        uint nutritionAbsorptionRandomSeed,
        uint defenseNutritionRandomSeed,
        uint occupyNutritionRandomSeed
    ) public {
        gameInitVar.MAP_WIDTH = mapWidth;
        gameInitVar.MAP_LENGTH = mapLength;
        gameInitVar.PLAYER_INITIAL_NUTRITION = playerInitialNutrition;
        gameInitVar.COLONY_MAX_ABSORPTION_RATE = colonyMaxAbsorptionRate;
        gameInitVar.COLONY_MAX_DEFENSE_NUTRITION = colonyMaxDefenseNutrition;
        gameInitVar.COLONY_MAX_OCCUPY_NUTRITION = colonyMaxOccupyNutrition;
        gameInitVar.COLONY_NUTRITION_ABSORPTION_INIT_RANDOM_SEED = nutritionAbsorptionRandomSeed;
        gameInitVar.COLONY_DEFENSE_NUTRITION_INIT_RANDOM_SEED = defenseNutritionRandomSeed;
        gameInitVar.COLONY_OCCUPY_NUTRITION_INTI_RANDOM_SEED = occupyNutritionRandomSeed;
    }

    // Called by the game admin before player can enter the game
    function _initializeGameManager(gameManagerType storage gameManager, gameInitVarType storage gameInitVar) public {
        gameManager.adminAddress = msg.sender;
        gameManager.time = block.timestamp;
        gameManager.mapWidth = gameInitVar.MAP_WIDTH;
        gameManager.mapLength = gameInitVar.MAP_LENGTH;
        gameManager.isEnd = false;
        gameManager.playerCount = 0;
        gameManager.totalColonyCount = gameManager.mapWidth * gameManager.mapLength;
    }

    // Called by players who want to join the game
    function _enterGame(gameManagerType storage gameManager, gameInitVarType storage gameInitVar) public {
        uint playerID = gameManager.playerCount;
        gameManager.isPlayer[msg.sender] = true;
        gameManager.playerAddressList[playerID] = msg.sender;

        uint initialColonyID = generateRandomNumber3(gameManager.totalColonyCount);
        // Check if a collision happens, if collision happens, increase id by 1
        while (gameInitVar.colonyOwned[initialColonyID]) {
            initialColonyID += 1;
        }

        gameInitVar.colonyOwned[initialColonyID] = true;
        gameInitVar.colonyOwnerIDMapping[initialColonyID] = gameManager.playerCount;

        gameManager.playerList[playerID].id = gameManager.playerCount;
        gameManager.playerList[playerID].playerAddress = msg.sender;
        gameManager.playerList[playerID].nutrition = gameInitVar.PLAYER_INITIAL_NUTRITION;
        gameManager.playerList[playerID].color = gameManager.playerCount;
        gameManager.playerList[playerID].colonyIDList.push(initialColonyID);
        gameManager.playerList[playerID].colonyCount = 1;

        gameManager.playerCount += 1;
    }

    // Take 3 input for the hash function
    function generateRandomNumber3(uint maxValue) private view returns (uint) {
        uint randomNumber = uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, msg.sender))) % maxValue;
        return randomNumber;
    }

    // Take 4 inputs for the hash function
    function generateRandomNumber4(uint maxValue, uint randomSeed1, uint randomSeed2) private view returns (uint) {
        uint randomNumber = uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, randomSeed1, randomSeed2))) % maxValue;
        return randomNumber;
    }

    // Called by the game admin when he want to start the game
    function _initializeGame(gameManagerType storage gameManager, gameInitVarType storage gameInitVar) public {
        gameManager.isStart = true;
        for (uint id = 0; id < gameManager.totalColonyCount; id += 1 ) {
            uint absorptionRate = generateRandomNumber4(gameInitVar.COLONY_MAX_ABSORPTION_RATE, id, gameInitVar.COLONY_NUTRITION_ABSORPTION_INIT_RANDOM_SEED);
            uint defenseNutrition = generateRandomNumber4(gameInitVar.COLONY_MAX_ABSORPTION_RATE, id, gameInitVar.COLONY_DEFENSE_NUTRITION_INIT_RANDOM_SEED);
            uint occupyNutrition = generateRandomNumber4(gameInitVar.COLONY_MAX_ABSORPTION_RATE, id, gameInitVar.COLONY_OCCUPY_NUTRITION_INTI_RANDOM_SEED);

            gameManager.map[id].id = id;
            gameManager.map[id].absorptionRate = absorptionRate;
            gameManager.map[id].defenseNutrition = defenseNutrition;
            gameManager.map[id].occupyNutrition = occupyNutrition;
            gameManager.map[id].isOwned = gameInitVar.colonyOwned[id];

            if(gameInitVar.colonyOwned[id]) {
                gameManager.map[id].ownerID = gameInitVar.colonyOwnerIDMapping[id];
            }
        }
    }

    function _updateState(gameManagerType storage gameManager) public {
        for(uint playerID = 0; playerID < gameManager.playerCount; playerID+=1) {
            gameManager.playerList[playerID].nutrition += gameManager.playerList[playerID].absorptionRate;
        }
    }

    function _endGame(gameManagerType storage gameManager) public {
        gameManager.isEnd = true;
    }

    function _pickWinner(gameManagerType storage gameManager) public view returns (address) {
        uint largestColonyCount = 0;
        uint winnerID = 0;
        for(uint id = 0; id < gameManager.playerCount; id+=1) {
            if (largestColonyCount < gameManager.playerList[id].colonyCount) {
                largestColonyCount = gameManager.playerList[id].colonyCount;
                winnerID = id;
            }
        }
        return gameManager.playerList[winnerID].playerAddress;
    }

}
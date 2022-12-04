// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import { BacteriaLabColony } from "./BacteriaLabColony.sol";
import { BacteriaLabPlayer } from "./BacteriaLabPlayer.sol";
import { BacteriaLabNFT } from "./BacteriaLabNFT.sol";

library BacteriaLabGameManager {

  // Attributes
  struct gameManagerType {
    address adminAddress;
    uint8 time; // block.timestamp
    uint8 mapWidth;
    uint8 mapLength;
    uint8 totalColonyCount;
    mapping(uint8 => BacteriaLabColony.Colony) map;
    mapping(uint8 => BacteriaLabPlayer.Player) playerList;
    bool isInit;
    bool isStart;
    bool isEnd;
    mapping(address => uint8) playerIdLookUp; 
    mapping(address => bool) isPlayer;
    uint8 playerCount;
    mapping(uint8 => bool) colonyOwned; // Used for player initialization (pick initial colony that has not been owned)
    mapping(uint8 => BacteriaLabNFT.NFT) NFTCollection;
    uint8 NFTCount;
  }

  // for initialization purpose only
  struct gameInitVarType {
    uint8 MAP_WIDTH;
    uint8 MAP_LENGTH;
    uint8 PLAYER_INITIAL_NUTRITION;
    uint8 COLONY_MAX_ABSORPTION_RATE;
    uint8 COLONY_MAX_DEFENSE_NUTRITION;
    uint8 COLONY_MAX_OCCUPY_NUTRITION;
    uint8 COLONY_NUTRITION_ABSORPTION_INIT_RANDOM_SEED; // Random seed input for generating colony absorptionRate
    uint8 COLONY_DEFENSE_NUTRITION_INIT_RANDOM_SEED;
    uint8 COLONY_OCCUPY_NUTRITION_INTI_RANDOM_SEED;
  }

  function setGameInitVariable(
    gameInitVarType storage gameInitVar,
    uint8 mapWidth,
    uint8 mapLength,
    uint8 playerInitialNutrition,
    uint8 colonyMaxAbsorptionRate,
    uint8 colonyMaxDefenseNutrition,
    uint8 colonyMaxOccupyNutrition,
    uint8 nutritionAbsorptionRandomSeed,
    uint8 defenseNutritionRandomSeed,
    uint8 occupyNutritionRandomSeed
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
    gameManager.mapWidth = gameInitVar.MAP_WIDTH;
    gameManager.mapLength = gameInitVar.MAP_LENGTH;
    gameManager.isInit = true;
    gameManager.playerCount = 1;
    gameManager.totalColonyCount = 255;
  }


  // Called by players who want to join the game
  function _enterGame(gameManagerType storage gameManager, gameInitVarType storage gameInitVar) public {
    uint8 playerID = gameManager.playerCount;
    gameManager.isPlayer[msg.sender] = true;
    gameManager.playerIdLookUp[msg.sender] = playerID;

    uint8 initialColonyID = generateRandomNumber3(64);
    // Check if a collision happens, if collision happens, increase id by 1
    while (gameManager.colonyOwned[initialColonyID]) {
      initialColonyID += 1;
    }
    gameManager.colonyOwned[initialColonyID] = true;

    gameManager.playerList[playerID].id = gameManager.playerCount;
    gameManager.playerList[playerID].playerAddress = msg.sender;
    gameManager.playerList[playerID].nutrition = gameInitVar.PLAYER_INITIAL_NUTRITION;
    gameManager.playerList[playerID].color = gameManager.playerCount;
    gameManager.playerList[playerID].colonyCount = 1;

    changeNeighbor(gameManager, playerID, initialColonyID, gameManager.mapLength, true);

    gameManager.map[initialColonyID].ownerID = playerID;
    gameManager.map[initialColonyID].isOwned = true;
    gameManager.playerList[playerID].absorptionRate += gameManager.map[initialColonyID].absorptionRate;

    gameManager.playerCount += 1;
  }

  // Take 3 input for the hash function
  function generateRandomNumber3(uint8 maxValue) private view returns (uint8) {
    // Originally block.timestamp is used in the position of `one`, we simplify it to reduce computation cost
    uint8 one = 1;
    uint8 randomNumber = uint8(uint(keccak256(abi.encodePacked(block.difficulty, one, msg.sender))) % 255 ) % maxValue;
    return randomNumber;
  }

  // Take 4 inputs for the hash function
  function generateRandomNumber4(uint8 maxValue, uint8 randomSeed1, uint8 randomSeed2) private view returns (uint8) {
    // Originally block.timestamp is used in the position of `one`, we simplify it to reduce computation cost
    uint8 one = 1;
    uint8 randomNumber = uint8(uint(keccak256(abi.encodePacked(block.difficulty, one, randomSeed1, randomSeed2))) % 255 ) % maxValue;
    return randomNumber;
  }

  // Change neighbor of a colony used for player initialization
  function changeNeighbor(gameManagerType storage gameManager, uint8 playerID, uint8 targetID, uint8 length, bool neighbor) private {

    if(targetID % length == (length - 1)) {
      gameManager.playerList[playerID].isNeighbor[targetID - 1] = neighbor;
    }
    else if(targetID % length == 0) {
      gameManager.playerList[playerID].isNeighbor[targetID + 1] = neighbor;
    }
    else {
      gameManager.playerList[playerID].isNeighbor[targetID + 1] = neighbor;
      gameManager.playerList[playerID].isNeighbor[targetID - 1] = neighbor;
    }
    if(targetID < length) {
      gameManager.playerList[playerID].isNeighbor[targetID + length] = neighbor;
    }
    else {
      gameManager.playerList[playerID].isNeighbor[targetID + length] = neighbor;
      gameManager.playerList[playerID].isNeighbor[targetID - length] = neighbor;
    }
  }

  // Called by the game admin when he want to start the game
  function _initializeGame(gameManagerType storage gameManager, gameInitVarType storage gameInitVar, uint8 startID) public {
    for (uint8 id = startID; id < startID + 16; id += 1 ) {
      uint8 absorptionRate = generateRandomNumber4(gameInitVar.COLONY_MAX_ABSORPTION_RATE, id, gameInitVar.COLONY_NUTRITION_ABSORPTION_INIT_RANDOM_SEED);
      uint8 defenseNutrition = generateRandomNumber4(gameInitVar.COLONY_MAX_ABSORPTION_RATE, id, gameInitVar.COLONY_DEFENSE_NUTRITION_INIT_RANDOM_SEED);
      uint8 occupyNutrition = generateRandomNumber4(gameInitVar.COLONY_MAX_ABSORPTION_RATE, id, gameInitVar.COLONY_OCCUPY_NUTRITION_INTI_RANDOM_SEED);

      gameManager.map[id].id = id;
      gameManager.map[id].ownerID = 0xff;
      gameManager.map[id].absorptionRate = absorptionRate;
      gameManager.map[id].defenseNutrition = defenseNutrition;
      gameManager.map[id].occupyNutrition = occupyNutrition;
      gameManager.map[id].isOwned = false;
    }
  }

function _updateState(gameManagerType storage gameManager) public {
    for(uint8 playerID = 1; playerID <= gameManager.playerCount; playerID+=1) {
      gameManager.playerList[playerID].nutrition += gameManager.playerList[playerID].absorptionRate;
    }
  }

  function _endGame(gameManagerType storage gameManager) public {
    gameManager.isEnd = true;
  }

  function _pickWinner(gameManagerType storage gameManager) public view returns (address) {
    uint8 largestColonyCount = 0;
    uint8 winnerID = 0;
    for(uint8 id = 1; id <= gameManager.playerCount; id+=1) {
      if (largestColonyCount < gameManager.playerList[id].colonyCount) {
        largestColonyCount = gameManager.playerList[id].colonyCount;
        winnerID = id;
      }
    }
    return gameManager.playerList[winnerID].playerAddress;
  }
    
}
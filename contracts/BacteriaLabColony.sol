// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// This is the library containing functions related to bacteria colony operations
// For example, the population and resource moving

library BacteriaLabColony {
  struct Colony {
    uint8 id;
    uint8 ownerID;
    uint8 absorptionRate;
    uint8 defenseNutrition;
    uint8 occupyNutrition;
    bool isOwned;
  }  
}
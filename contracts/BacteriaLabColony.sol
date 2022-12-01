// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// This is the library containing functions related to bacteria colony operations
// For example, the population and resource moving

library BacteriaLabColony {
  struct Colony {
    uint id;
    uint ownerID;
    uint absorptionRate;
    uint defenseNutrition;
    uint occupyNutrition;
    bool isOwned;
  }  
}
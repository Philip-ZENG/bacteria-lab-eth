// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

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
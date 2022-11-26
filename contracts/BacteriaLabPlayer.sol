// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// This is the library containing functions related to world state updates

library BacteriaLabPlayer {
    struct Player {
        uint id;
        address playerAddress; 
        uint nutrition;
        uint absorptionRate;
        uint color;
        uint[] colonyIDList;
        uint colonyCount;
    }
}
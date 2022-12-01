// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import {BacteriaLabColony} from"./BacteriaLabColony.sol";

library BacteriaLabPlayer {
  struct Player {
    uint id;
    address playerAddress;
    uint nutrition;
    uint absorptionRate;
    uint color;
    uint colonyCount;
    mapping (uint => bool) isNeighbor;
  }

  function _attack(Player storage self, uint attackNutrition, Player storage enemy, BacteriaLabColony.Colony storage target, uint length) public{
    require(attackNutrition <= self.nutrition, "Your attack nutrition cannot exceed the total nutrition you owned.");
    require(self.isNeighbor[target.id] == true, "You can only attack your neighbor colony.");

    bool succeed;
    if(attackNutrition > target.defenseNutrition) {
      succeed = true;
    }
    else {
      succeed = false;
    }

    self.nutrition -= attackNutrition;

    if(succeed) {
      changeNeighbor(enemy, target.id, length, false);

      enemy.colonyCount -= 1;
      enemy.absorptionRate-=target.absorptionRate;

      target.isOwned = false;
      target.ownerID = 0xffffffffffffffffffffffffffffffff;
    }
  }

  function _occupy(Player storage self, BacteriaLabColony.Colony storage target, uint length) public{
    require(target.isOwned == false, "You can only occupy colony that has no owner.");
    require(self.isNeighbor[target.id] == true, "You can only occupy neighbor colony.");

    bool succeed;
    if(self.nutrition >= target.occupyNutrition) {
      succeed = true;
    }
    else {
      succeed = false;
    }

    self.nutrition -= target.occupyNutrition;

    if(succeed) {
      target.isOwned = true;
      target.ownerID = self.id;

      self.absorptionRate = self.absorptionRate + target.absorptionRate;
      self.colonyCount += 1;

      //change neighbor information
      changeNeighbor(self, target.id, length, true);
    }
  }

  function changeNeighbor(Player storage player, uint targetID, uint length, bool neighbor) private {
    if(targetID % length == (length - 1)) {
      player.isNeighbor[targetID - 1] = neighbor;
    }
    else if(targetID % length == 0) {
      player.isNeighbor[targetID + 1] = neighbor;
    }
    else {
      player.isNeighbor[targetID + 1] = neighbor;
      player.isNeighbor[targetID - 1] = neighbor;
    }
    if(targetID < length) {
      player.isNeighbor[targetID + length] = neighbor;
    }
    else {
      player.isNeighbor[targetID + length] = neighbor;
      player.isNeighbor[targetID - length] = neighbor;
    }
  }
}
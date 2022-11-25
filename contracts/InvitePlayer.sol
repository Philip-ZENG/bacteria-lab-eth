// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract InvitePlayer {
  /// Storagte Space ///
  // Define game world variables here

  address public adminAddress;
  mapping(address => bool) public playerAddressMapping;
  address[] public playerList;
  uint public playerCount;

  /// Initializer ///
  // Initializer function: executed when the contract is created
  constructor() {
    adminAddress = msg.sender;
  }

  /// ACCESS CONTROL ///
  // Define access modifier here
  modifier onlyAdmin() {
    require(msg.sender == adminAddress, "Sender is not a game admin");
    _;
  }

  /// Administrative Engine ///
  // Admin functions
  function invitePlayer(address playerAddress) public onlyAdmin {
    require(playerAddressMapping[playerAddress] == false, "Palyer has already been invited");
    playerAddressMapping[playerAddress] = true;
    playerList.push(playerAddress);
    playerCount += 1;
  }
}
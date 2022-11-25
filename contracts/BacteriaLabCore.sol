// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// This is the main contract where the front-end web page will interact with.
// Game world initialization, World state update, Admin management happens here

// Import base Initializable contract
import "./Verifier.sol";
import "./BacteriaLabcolony.sol";
import "./BacteriaLabInitialize.sol";
import "./BacteriaLabUpdate.sol";

contract BacteriaLabCore {
  /// Storagte Space ///
  // Define game world variables here

  address public adminAddress;
  mapping(address => bool) public playerAddress;
  uint public playerCount;

  mapping(address => bool) public turnFinished; // Record which player has finished their action in this turn
  uint public numFinishedTurn; // Number of player who finished the turn
  uint public turnNumber; // Count the number of turn curretly is in
  mapping(uint => bool) public colonyActed; // Record which player owned colony has finished their action in this turn

  /// Initializer ///
  // Initializer function: executed when the contract is created
  function BacteriaLabCore(address creater) public {
    adminAddress = creator;
  }

  /// ACCESS CONTROL ///
  // Define access modifier here
  modifier onlyAdmin() {
    require(msg.sender == adminAddress, "Sender is not a game admin");
  }

  modifier onlyPlayer() {
    require(playerAddress[msg.sender] == true, "Sender is not a registered player");
  }

  /// Administrative Engine ///
  // Admin functions
  function invitePlayer(address player) public onlyAdmin {
    playerAddress[player] = true;
    playerCount += 1;
  }

  /// Game Mechanics ///
  // Functions related to game update
  function updateState() private {
    // Require all players to finish their turn
    require(turnNumber == playerCount);
    // Update the world state according to each players action in this turn
  }

  // The action the colony would take in this turn
  function makeAMove(uint colonyID) public onlyPlayer {
    // Each colony can only make 1 move in 1 turn
    require(colonyActed[colonyID] == false, "This colony has already made a move in this turn");

    colonyActed[colonyID] = true;
  }

  // The player inform the system he finish this turn
  function finishTurn() public onlyPlayer {
    // Each player can only finish a specific turn for 1 time
    require(turnFinished[msg.sender] == false, "You have already finished this turn");

    turnFinished[msg.sender] = true;
    numFinishedTurn += 1;
  }

  /// User Interface Information Display ///
  // Getter function for user interface to get all kinds of game data
  function getcolonyInfo(uint colonyID) public view returns() {

  }
}
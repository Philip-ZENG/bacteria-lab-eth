// Standard library built into nodejs runtime
const assert = require('assert');
const ganache = require('ganache-cli');
// Uppercase `Web3` is a constructor to create instances of the web3 library
const Web3 = require('web3');

// abi for interface, evm for bytecode
// const {abi, evm} = require('../compile');
const compiledInvitePlayer = require('../build/InvitePlayer.json');

// Create an instance of Web3 which use the provider of our local ganache network
// ganache creates a set of accounts for us to use
const web3 = new Web3(ganache.provider());

let accounts
// Contract reference object
let InvitePlayer

// Code inside this `beforeEach` block will be executed before each `it` testing block
// We should deploy a new contract in our ganache local network before each test case
// `async` means we will use asynchronous function
beforeEach(async () => {
  // Get a list of all accounts
  // `await` wait for the line to finish execution before moving on to the next line
  accounts = await web3.eth.getAccounts();

  // Deploy the contract byptecode with web3 library
  // Teach web3 about the methods in our smart contract (interface)
  // The return value (an JavaScript Object) is a direct reference to the deployed contract
  // We can use the returned object to call functions within the deployed contract
  InvitePlayer = await new web3.eth.Contract(compiledInvitePlayer.abi)
    // Tell web3 we want to deploy a new copy of this contract (create an object that can be deployed to the network)
    .deploy({
      data: compiledInvitePlayer.evm.bytecode.object
    })
    // instruct web3 to send a transaction that deploys(creates) the contract from accounts[0] address, with gas limit set
    .send({ from: accounts[0], gas: '1000000' });
});

// Group a series of test case into one `describe` block
describe('Invite Player', () => {
  // Each `it` block is an independent test cases
  // We manipulate the contract and assert the contract
  it('deploys a contract', () => {
    // console.log(accounts);
    // console.log(InvitePlayer);

    // Check if an address is assigned to the contract
    assert.ok(InvitePlayer.options.address);
  });

  it('has a admin', async ()  => {
    // Calling a function to retrieve data from the contract
    // `call()` means we do not want to modify contract's data but only read form it
    // If `send()` is used, it means we want to modify contract's data
    const adminAddress = await InvitePlayer.methods.adminAddress().call();
    // Check if the adminAddress is the contract creator's address
    assert.equal(adminAddress, accounts[0]);
  });

  it('can invite player', async () => {
    const playerCountBefore = await InvitePlayer.methods.playerCount().call();
    await InvitePlayer.methods.invitePlayer(accounts[1]).send({ from: accounts[0], gas: '1000000' });
    const playerInvited = await InvitePlayer.methods.playerAddressMapping(accounts[1]).call();
    const playerCountAfter = await InvitePlayer.methods.playerCount().call();

    assert.equal(playerInvited, true);
    assert.equal(parseInt(playerCountBefore,10)+1, parseInt(playerCountAfter,10));
  });

  it('only admin can invite player', async() => {
    try {
      // We expect here to throw an error
      await InvitePlayer.methods.invitePlayer(accounts[2]).send({ from: accounts[1], gas: '1000000' });
      // If error does not occur, then the test failed
      assert(false);
    } catch (err) {
      // Check there is indeed an error thrown
      assert(err);
    }
  });

  it('can only invite player for 1 time', async () => {
    try {
      await InvitePlayer.methods.invitePlayer(accounts[1]).send({ from: accounts[0], gas: '1000000' });
      // Invite the same address for the second time
      await InvitePlayer.methods.invitePlayer(accounts[1]).send({ from: accounts[0], gas: '1000000' });
      assert(false);
    } catch (err) {
      // Check there is indeed an error thrown
      assert(err);
    }
  })

});
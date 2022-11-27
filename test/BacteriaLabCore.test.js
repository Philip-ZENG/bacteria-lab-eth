const assert = require('assert');
const ganache = require('ganache-cli');
const Web3 = require('web3');

// abi for interface, evm for bytecode
// const {abi, evm} = require('../compile');
const compiledContract = require('../build/BacteriaLabCore.json');

// Create an instance of Web3 which use the provider of our local ganache network
// ganache creates a set of accounts for us to use
const web3 = new Web3(ganache.provider());

let accounts


beforeEach(async () => {
  // Get a list of all accounts
  // `await` wait for the line to finish execution before moving on to the next line
  accounts = await web3.eth.getAccounts();

  // Deploy the contract byptecode with web3 library
  // Teach web3 about the methods in our smart contract (interface)
  // The return value (an JavaScript Object) is a direct reference to the deployed contract
  // We can use the returned object to call functions within the deployed contract
  BacteriaLabCore = await new web3.eth.Contract(compiledContract.abi)
    // Tell web3 we want to deploy a new copy of this contract (create an object that can be deployed to the network)
    .deploy({
      data: compiledContract.evm.bytecode.object
    })
    // instruct web3 to send a transaction that deploys(creates) the contract from accounts[0] address, with gas limit set
    .send({ from: accounts[0], gas: '1000000' });
});


describe('Invite Player', () => {
  it('can deploy', async ()  => {
    assert.ok(BacteriaLabCore.options.address);
  });


  it('has a admin', async ()  => {
    const adminAddress = await BacteriaLabCore.methods.gameManager().call();
    assert.equal(adminAddress, accounts[0]);
  });

});
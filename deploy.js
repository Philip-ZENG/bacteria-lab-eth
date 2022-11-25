const HDWalletProvider = require('@truffle/hdwallet-provider');
const Web3 = require('web3');
// const {abi, evm} = require('./compile');
const compiledInvitePlayer = require('./build/InvitePlayer.json');

// Account Mnemonic allows us to derieve both the public and private key 
// so that we can unlock our accounts
const provider = new HDWalletProvider(
  "YOUR_METAMASK_MNEMONIC",
  "YOUR_INFURA_URL"
);

const web3 = new Web3(provider);

const deploy = async () => {
  // Get list of accounts available in our metamask wallet
  const accounts = await web3.eth.getAccounts();

  console.log('Attempting to deploy from account', accounts[0]);

  // Use the first account in our metamask wallet account list to deploy our smart contract
  const result = await new web3.eth.Contract(compiledInvitePlayer.abi)
    .deploy({ data: compiledInvitePlayer.evm.bytecode.object })
    .send({ gas: '1400000', from: accounts[0] });

  console.log('Contract deployed to', result.options.address);
  provider.engine.stop();
};

deploy();
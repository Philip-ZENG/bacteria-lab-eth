## File Structure

This `\eth` folder contains the code related to Ethereum.

- `\eth\contracts` contains all the smart contract source code
  - `\eth\contracts\InvitePlayer.sol` is a demo smart contract that invites players into the game, its functionality should be merged into the `BacteriaLabCore` in the final version

- `\eth\test` contains the testing code for smart contracts using `mocha` library
  - `\eth\test\InvitePlayer.test.js` is the testing file for the contract `\eth\contracts\InvitePlaeyr.sol`

- `\eth\compile.js` is the file used to compile smart contract into binary code and its interface file
- `\eth\deploy.js` is the file used to deploy our smart contract to the real testing network 
  - not the local network created with Ganache, we use the Goerli test network

- `\eth\package.json` defines the dependencies and several development scripts

- `\eth\build` contains compiled smart contract written in json format, we will use it for our contract deployment to the test network and to create web3 instance in testing/frontend.



## How to Use

- To install all dependencies, 
  - open terminal in the `\eth` directory
  - run the following command `npm install`, corresponding packages will be installed

- To compile the smart contract, 
  - first configure the target smart contract file path in `\eth\compile.js`
  - go to `\eth` directory
  - run the following command  `ndoe compile.js`, smart contract code will be compiled
  - The compile process will generate smart contract ABI and bytecode
  - `File import callback not supported` problem occurred during local compile using `solc`：
    - https://ethereum.stackexchange.com/questions/103975/solc-compiler-file-import-callback-not-supported
  - contract can be successfully deployed through Remix directly
  
- To run the tests,
  - go to `\eth` directory
  - run the following command `npm run test`

- To deploy the smart contract to the Goerli testing network,
  - Remember to compile the contract first before deploy it
  - change your metamask account mnemonic and Infura URL in the file `\eth\compile.js`
  - go to `\eth` directory
  - run the following command `node deploy.js`, smart contract will be deployed to the test network
  - remember the address where the smart contract has been deployed to from the console log
  - we can observe our deployed contract on Etherscan: https://goerli.etherscan.io/
  - We can interact with our deployed contract using Remix easily, see video NO.61
    - Connect remix to your metamask account first
    - Need to compile the exact same deployed contract in remix first before clicking the `At Address` button
    - See video NO.10 to get free Goerli ethers for your accounts
  



## How it Works

- For testing,
  - The compile process will generate smart contract ABI and bytecode
  - The bytecode is deployed to a local test network created with `ganache-cli` library (The local test network is running on our computer)
  - The ABI is connected with `web3` library so that we can access and interacted with the deployed block chain with JavaScript code
  - For detail explanation of how `web3` connect to `ganache` with `provider`, see video NO.44

- For deploying contract to Goerli test network,
  - Check more details and explanations on video NO.54
  - Infura API is a service we used to help us deploy our compiled smart contract to the testing network
  - A package called `truffle/hdwallet-provider` is used to help us get access to our metamask wallet provider during the deployment



## For More Detailed Explanation

- See https://www.udemy.com/course/ethereum-and-solidity-the-complete-developers-guide/ Section 2
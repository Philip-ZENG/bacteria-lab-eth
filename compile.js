// Read in smart contract content with standard modules
const path = require('path');
const fs = require('fs-extra');
// Require solidity compiler (with the version=0.8.9)
const solc = require('solc');


// Clear the build directory before each compilation
const buildPath = path.resolve(__dirname, 'build');
fs.removeSync(buildPath);

// ! Get the path to the smart contract file that we want to compile
// ! If want to compile another smart contract modify here
const contractPath = path.resolve(__dirname,'contract_for_compile','BacteriaLabCore.sol');
// Read in the raw content of the smart contract file, utf8 is the encoding type
const source = fs.readFileSync(contractPath, 'utf8');

// console.log(source);

const input = {
  language: 'Solidity',
  sources: {
    'BacteriaLabCore.sol': {
      content: source,
    },
  },
  settings: {
    outputSelection: {
      '*': {
        '*': ['*'],
      },
    },
  },
};

// To see the compile output structure
// console.log(JSON.parse(solc.compile(JSON.stringify(input))));

// Compiler will produce the ABI (interface between solidity and javascript code) and bytecode (for actual deployment on chain)
// The exproted data is the bytecode and ABI

const output = JSON.parse(solc.compile(JSON.stringify(input))).contracts[
  "BacteriaLabCore.sol"
];

fs.ensureDirSync(buildPath);

// Write the complied output into a json file
for (let contract in output) {
  fs.outputJsonSync(
    path.resolve(buildPath, contract.replace(":", "") + ".json"),
    output[contract]
  );
}
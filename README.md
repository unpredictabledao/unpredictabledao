<div align="center">
	<br/>
	<img src="./assets/logo.png"/>
	<br/>
</div>

## Use Unpredictable DAO's random number generator in your contract

If you are here for how to integrate Unpredictable DAO's random number generator in your smart contracts, consider checking out the sample contract here: https://github.com/undao/undao/blob/main/contracts/TestUser.sol


## Auto-participate

You can run a bot to particpate automatically (addressed here: https://github.com/undao/undao/blob/main/auto-participate.md).


## Dependencies

* npm
* node.js


## Setup

1. Clone this repository.

2. Install the required packages:
```
npm install
```

3. Edit private key in `hardhat.config.js`.


## Compile

```
npx hardhat compile
```


## Deploy

```
npx hardhat run --network localhost scripts/deploy.js
```


## Test

```
npx hardhat test
```


## App

To run the dapp, open your terminal and insert this in:

```
npm install -g live-server
live-server
```

Go to config.js if you need to change contract addresses and ABIs.

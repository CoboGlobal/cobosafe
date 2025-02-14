# Cobo Safe Contracts

Cobo Safe is an on-chain access-control framework for smart contract wallets. 

# Installation and Testing

```sh
# Clone the repo
git clone https://github.com/coboglobal/cobosafe

# Install python requirements.
cd cobosafe
pip install -r ./requirements.txt

# Import the network configuration.
brownie networks import ./network-config.yaml True

# Run the test
brownie test
```

# Deploy

```sh
# Set env and SCAN TOKEN 
touch .env

# Add account
brownie accounts new ACCOUNT_ID

# Deploy
brownie run deploy.py FUNC_NAME --network NETWORK_ID
```

# Documentations

Read the documents [here](./docs/README.md). 

Head to learn more about Cobo Safe and Cobo Argus at [Cobo Developer Hub](https://www.cobo.com/developers/smart-contract-wallet/cobosafe).

# License

All smart contracts are released under [LGPL-3.0](./LICENSE).

# Discussion

For any concerns with the protocol, open an issue or visit us on Discord to discuss.

For security concerns, please email argussupport@cobo.com
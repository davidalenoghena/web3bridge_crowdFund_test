require('dotenv').config()
require("@nomiclabs/hardhat-ethers");

const { EndPointURL, PrivateKEY } = process.env;

module.exports = {
    solidity: "0.8.0",
    defaultNetwork: "sepolia",
    networks: {
        hardhat: {},
        sepolia: {
            url: EndPointURL,
            accounts: [`0x${PrivateKEY}`]
        }
    },
}
const {ethers} = require("hardhat")

module.exports = async ({deployments, getNamedAccounts}) => {
    const { deploy, log} = deployments
    const {deployer, user} = await getNamedAccounts()

    const AuctionFactory = await deploy("Nft", {
    from: deployer,
    log: true,
    args: [],
    })
}
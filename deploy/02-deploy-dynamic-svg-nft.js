const { network, ethers } = require("hardhat")
const { developmentChains, networkConfig } = require("../helper-hardhat-config")
const { verify } = require("../utils/verify")
const fs = require("fs")

module.exports = async function ({ getNamedAccounts, deployments }) {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()

    const chainId = network.config.chainId
    let ethUsdPriceFeedAddress

    if (developmentChains.includes(network.name)) {
        const EthUsdAggregator = await ethers.getContract("MockV3Aggregator")
        ethUsdPriceFeedAddress = EthUsdAggregator.address
    } else {
        ethUsdPriceFeedAddress = networkConfig[chainId].ethUsdPriceFeed
    }
    log("--------------------------------")
    const lowSVG = await fs.readFileSync("./images/frown.svg", { encoding: "utf8" })
    const highSVG = await fs.readFileSync("./images/wolf.svg", { encoding: "utf8" })
    args = [ethUsdPriceFeedAddress, lowSVG, highSVG]
    const dynamicSvgNft = await deploy("DynamicSvgNft", {
        from: deployer,
        args: args,
        log: true,
        waitConfirmations: network.config.waitConfirmations || 1,
        overrides: {
            gasLimit: 5000000, // Set your gas limit here
        },
    })

    if (!developmentChains.includes(network.name) && process.env.ETHERSCAN_API_KEY) {
        log("verifying...")
        await verify(dynamicSvgNft.address, args)
    }
}

module.exports.tags = ["all", "dynamicsvg", "main"]

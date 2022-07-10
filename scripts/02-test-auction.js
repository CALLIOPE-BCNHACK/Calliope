const { expect, assert } = require("chai")
const { ethers } = require("hardhat")

async function main() {
    // DEPLOY LOG
    auction = await ethers.getContractAt(
        "Auction",
        "0xa16E02E87b7454126E5E10d957A927A7F5B5d2be"
    )
    await auction.newAuction()
}

// Call the main function
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error)
        process.exit(1)
    })

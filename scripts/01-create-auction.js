const { ethers } = require("hardhat")

async function main() {
    // DEPLOY LOG
    song = await ethers.getContract("SongNFT")
    console.log("log loaded from", song.address)

    const auction = await song.createAuction(song.address)
    const auctionAdd = await song.getAuctionAddress()
    console.log("auction deployed at:", auctionAdd)
}

// Call the main function
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error)
        process.exit(1)
    })

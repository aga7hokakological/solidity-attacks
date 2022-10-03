const { expect } = require("chai");

describe("Test", async () => {
    const name = "MyNFToken";
    const symbol = "MYNFT";
    let owner, acc1, acc2, acc3, hacker;
    let nftFactory, nftContract;

    before(async () => {
        [owner, acc1, acc2, acc3, hacker] = await ethers.getSigners();

        nftFactory = await ethers.getContractFactory("SafeNFTMinting");
        nftContract = await nftFactory.deploy(name, symbol);
    })

    describe("Test", async () => {
        it("get contract details", async () => {
            expect(await nftContract.name()).to.be.equal("MyNFToken");
            expect(await nftContract.symbol()).to.be.equal("MYNFT");
        })

        it("Exploit should not work", async () => {
            await nftContract.addToWhitelist(acc1.address);
            await nftContract.addToWhitelist(acc2.address);
            await nftContract.addToWhitelist(acc3.address);

            // whitelisted accounts mint the nft
            await nftContract.connect(acc1).mint();
            await nftContract.connect(acc2).mint();
            await nftContract.connect(acc3).mint();

            // Hacker attacking the contract
            // await nftContract.connect(hacker).addToWhitelist(hacker.address);
            expect (await nftContract.connect(hacker).addToWhitelist(hacker.address)).to.be.revertedWith("Ownable: caller is not the owner");
            // Hacker minting the NFT
            // await nftContract.connect(hacker).mint();
        })
    })
})
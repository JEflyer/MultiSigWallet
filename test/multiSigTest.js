const {ethers} = require("hardhat");
const {expect} = require("chai");
const { inputToConfig } = require("@ethereum-waffle/compiler");

let addr1, addr2, addr3, addr4, addr5, addr6, addr7;
let minter,Minter;
let multi, Multi;
let tx,Tx;
let provider;


describe("Testing", () => {

    beforeEach(async() => {
        provider = ethers.provider;

        [addr1, addr2, addr3, addr4, addr5, addr6, addr7] = await ethers.getSigners()

        Minter = await ethers.getContractFactory("Minter")

        minter = await Minter.deploy(ethers.utils.parseEther("1"))

        await minter.deployed();

        Multi = await ethers.getContractFactory("MultiSig")

        multi = await Multi.deploy(
            [
                addr2.address,
                addr3.address,
                addr4.address,
                addr5.address,
                addr6.address
            ]
        )

        await multi.deployed()

        Tx = await ethers.getContractFactory("Transaction")

        tx = await Tx.deploy(
            multi.address
        )

        await tx.deployed()
    })

    it("Should allow the admin to add a wallet", async() => {
        expect(await multi.connect(addr1).addWallet(addr7.address));
    })

    it("Should not allow a different wallet to add a wallet", async() => {
        expect(multi.connect(addr3).addWallet(addr1.address)).to.be.revertedWith("OA")
    })
    
    it("Should allow the admin to remove a wallet", async() => {
        expect(await multi.connect(addr1).removeWallet(addr2.address));
    })
    
    it("Should not allow a different wallet to remove a wallet", async() => {
        expect(multi.connect(addr3).removeWallet(addr2.address)).to.be.revertedWith("OAp")
    })
    
    it("Should allow any approved wallet to propose a transaction", async() => {
        const params = [{
            from: addr1,
            to: multi.address,
            value: ethers.utils.parseEther("1")
        }]
        //send 1 eth to the contract for minting 
        await provider.send("eth_sendTransaction", params)

        expect(await multi.connect(addr2).proposeTransaction(tx.address, minter.address, ethers.utils.parseEther("1")))
    })
    
    it("Should not allow the admin to propose a transaction", async() => {
        
    })
    
    it("Should let a approved wallet to sign a proposal", async() => {

    })
    
    it("Should not let the admin sign a proposal", async() => {

    })
    
    it("Should allow the proposer to cancel the proposal", async() => {

    })
    
    it("Should not allow a different approved wallet to cancel the proposal", async() => {

    })
    
    it("Should not allow the admin to cancel a proposal", async() => {

    })
    
    it("Should return correct TxInfo", async() => {

    })
    
    it("Should Mint a NFT correctly & send this to the multisig wallet", async() => {

    })
    
    it("Should allow a approved wallet to send a NFT to a wallet ", async() => {

    })
})
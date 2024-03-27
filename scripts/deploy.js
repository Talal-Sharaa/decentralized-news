const hre = require("hardhat");

async function main() {
  const Donations = await hre.ethers.getContractFactory("Donations");
  const donations = await Donations.deploy();
  console.log("Donations contract deployed at:", donations.target);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

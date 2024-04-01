const hre = require("hardhat");

async function main() {
  const NewsPlatform = await hre.ethers.getContractFactory("NewsPlatform");
  const newsPlatform = await NewsPlatform.deploy();
  console.log("NewsPlatform contract deployed at:", newsPlatform.target);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

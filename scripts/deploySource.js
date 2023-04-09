// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
  let lzEndpoint = "";
  let stargateRouter = "";
  let dstChainId = "";
  let srcPoolId = "";
  let dstPoolId = "";
  let usdc = "";
  let startTime = "";
  let endTime = "";
  let minAmount = "";

  const Source = await hre.ethers.getContractFactory("Source");
  const source = await Source.deploy(
    lzEndpoint,
    stargateRouter,
    dstChainId,
    srcPoolId,
    dstPoolId,
    usdc,
    startTime,
    endTime,
    minAmount
  );

  await source.deployed();

  console.log(
    `Deployed The Contract on Source Chain: ${source.address}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

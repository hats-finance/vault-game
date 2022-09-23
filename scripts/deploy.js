async function main() {
  const Vault = await ethers.getContractFactory("Vault");
  console.log("Deploying Vault...");
  const vault = await Vault.deploy({ value: ethers.utils.parseEther("1") });
  await vault.deployed();
  console.log("Vault deployed to:", vault.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

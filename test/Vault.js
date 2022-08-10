const { expect } = require("chai");

describe("Vault contract", function () {
  let vault;
  let deployer;
  beforeEach(async function () {
    const Vault = await ethers.getContractFactory("Vault");
    vault = await Vault.deploy({ value: ethers.utils.parseEther("1") });
  });

  it("Deposit", async function () {
    [deployer, depositor] = await ethers.getSigners();

    const flagHolder = await vault.flagHolder();
    expect(flagHolder).to.equal("0x0000000000000000000000000000000000000000");

    const tx = await vault.connect(depositor).deposit(
      ethers.utils.parseEther("1"),
      depositor.address,
      { value: ethers.utils.parseEther("1") }
    );
    await tx.wait();
    expect(await vault.balanceOf(depositor.address)).to.equal(ethers.utils.parseEther("1"));

    await expect(
      vault.connect(depositor).captureTheFlag(depositor.address)
    ).to.be.revertedWith("Balance is not 0");
  });

  it("Withdraw", async function () {
    [deployer, depositor] = await ethers.getSigners();

    const flagHolder = await vault.flagHolder();
    expect(flagHolder).to.equal("0x0000000000000000000000000000000000000000");

    let tx = await vault.connect(depositor).deposit(
      ethers.utils.parseEther("1"),
      depositor.address,
      { value: ethers.utils.parseEther("1") }
    );
    await tx.wait();
    expect(await vault.balanceOf(depositor.address)).to.equal(ethers.utils.parseEther("1"));
  
     tx = await vault.connect(depositor).withdraw(
      ethers.utils.parseEther("1"),
      depositor.address,
      depositor.address,
    );

    await tx.wait();
    expect(await vault.balanceOf(depositor.address)).to.equal(ethers.utils.parseEther("0"));

    await expect(
      vault.connect(depositor).captureTheFlag(depositor.address)
    ).to.be.revertedWith("Balance is not 0");
  });
});

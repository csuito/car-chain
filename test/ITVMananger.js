const { assert } = require("chai");

const ITVManager = artifacts.require("ITVManager");
const CarAsset = artifacts.require("CarAsset");
const Authorizer = artifacts.require("Authorizer");

contract("ITVManager", (accounts) => {
  let authorizerContract;
  let ITVManagerContract;
  let CarAssetContract;

  const owner = accounts[0];
  const itvAuthorized = accounts[1];

  const carId = 12342314123454;
  const updateITVMethod = "updateITV(uint256,uint256)";

  const ITV_PASSED = 0;

  beforeEach(async () => {
    authorizerContract = await Authorizer.new();
    CarAssetContract = await CarAsset.new();
    ITVManagerContract = await ITVManager.new(authorizerContract.address, CarAssetContract.address);
  });

  it("Sets deploying account as root", async () => {
    const rootAccount = await ITVManagerContract.owner();
    assert.equal(rootAccount, owner, "Error: invalid root account");
  });

  it("Update car ITV without permissions", async () => {
    try {
      await ITVManagerContract.updateITV(carId, ITV_PASSED, {
        from: itvAuthorized,
      });
    } catch (e) {
      assert.include(e.message, "Unauthorized");
      return;
    }
    assert.fail("Error checking authorization");
  });

  it("Update car ITV without permissions", async () => {
    await authorizerContract.addPermission(ITVManagerContract.address, updateITVMethod, itvAuthorized);
    await ITVManagerContract.updateITV(carId, ITV_PASSED, {
      from: itvAuthorized,
    });
  });
});

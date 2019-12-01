const sol = artifacts.require("./Trade.sol");
module.exports = function(deployer) {
  deployer.deploy(sol);
};


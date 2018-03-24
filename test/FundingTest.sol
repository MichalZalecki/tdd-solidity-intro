// contracts/FundingTest.sol
pragma solidity ^0.4.19;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Funding.sol";

contract FundingTest {
  Funding funding;
  uint public initialBalance = 10 ether;

  function () public payable {}

  function beforeEach() public {
    funding = new Funding(1 days, 100 finney);
  }

  function testSettingAnOwnerDuringCreation() public {
    Assert.equal(funding.owner(), this, "An owner is different than a deployer");
  }

  function testSettingAnOwnerOfDeployedContract() public {
    funding = Funding(DeployedAddresses.Funding());
    Assert.equal(funding.owner(), msg.sender, "An owner is different than a deployer");
  }

  function testAcceptingDonations() public {
    Assert.equal(funding.raised(), 0, "Initial raised amount is different than 0");
    funding.donate.value(10 finney)();
    funding.donate.value(20 finney)();
    Assert.equal(funding.raised(), 30 finney, "Raised amount is different than sum of donations");
  }

  function testTrackingDonatorsBalance() public {
    funding.donate.value(5 finney)();
    funding.donate.value(15 finney)();
    Assert.equal(funding.balances(this), 20 finney, "Donator balance is different than sum of donations");
  }

  function testDonatingAfterTimeIsUp() public {
    funding = new Funding(0, 100 finney);
    bool result = funding.call.value(10 finney)(bytes4(keccak256("donate()")));
    Assert.equal(result, false, "Allows for donations when time is up");
  }

  function testWithdrawalByAnOwner() public {
    uint initBalance = this.balance;
    funding.donate.value(50 finney)();
    bool result = funding.call(bytes4(keccak256("withdraw()")));
    Assert.equal(result, false, "Allows for withdrawal before reaching the goal");
    funding.donate.value(50 finney)();
    Assert.equal(this.balance, initBalance - 100 finney, "Balance before withdrawal doesn't correspond to the sum of donations");
    result = funding.call(bytes4(keccak256("withdraw()")));
    Assert.equal(result, true, "Doesn't allow for withdrawal after reaching the goal");
    Assert.equal(this.balance, initBalance, "Balance after withdrawal doesn't correspond to the sum of donations");
  }

  function testWithdrawalByNotAnOwner() public {
    funding = Funding(DeployedAddresses.Funding());
    funding.donate.value(100 finney)();
    bool result = funding.call(bytes4(keccak256("withdraw()")));
    Assert.equal(result, false, "Allows for withdrawal by not an owner");
  }
}

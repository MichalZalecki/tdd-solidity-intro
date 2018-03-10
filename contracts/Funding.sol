// contracts/Funding.sol
pragma solidity ^0.4.17;

import "zeppelin-solidity/contracts/ownership/Ownable.sol";

contract Funding is Ownable {
  uint public raised;
  uint public goal;
  uint public finishesAt;
  mapping(address => uint) public balances;

  modifier onlyNotFinished() {
    require(!isFinished());
    _;
  }

  modifier onlyFinished() {
    require(isFinished());
    _;
  }

  modifier onlyNotFunded() {
    require(!isFunded());
    _;
  }

  modifier onlyFunded() {
    require(isFunded());
    _;
  }

  function () public payable {}

  function Funding(uint _duration, uint _goal) public {
    finishesAt = now + _duration;
    goal = _goal;
  }

  function isFinished() public view returns (bool) {
    return finishesAt <= now;
  }

  function isFunded() public view returns (bool) {
    return raised >= goal;
  }

  function donate() public onlyNotFinished payable {
    balances[msg.sender] += msg.value;
    raised += msg.value;
  }

  function withdraw() public onlyOwner onlyFunded {
    owner.transfer(this.balance);
  }

  function refund() public onlyFinished onlyNotFunded {
    uint amount = balances[msg.sender];
    require(amount > 0);
    balances[msg.sender] = 0;
    msg.sender.transfer(amount);
  }
}
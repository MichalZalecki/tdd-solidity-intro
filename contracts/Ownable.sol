// contracts/Ownable.sol
pragma solidity ^0.4.17;

contract Ownable {
  address public owner;

  modifier onlyOwner() {
    require(owner == msg.sender);
    _;
  }

  function Ownable() public {
    owner = msg.sender;
  }
}

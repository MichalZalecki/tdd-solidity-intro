// contracts/Ownable.sol
pragma solidity ^0.4.19;

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

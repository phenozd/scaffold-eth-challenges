pragma solidity 0.8.4;  //Do not change the solidity version as it negativly impacts submission grading
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {

  event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);

  YourToken public yourToken;

  constructor(address tokenAddress) {
    yourToken = YourToken(tokenAddress);
  }
  
  uint256 public constant tokensPerEth = 100;
  
  function buyTokens() public payable {
	  yourToken.transfer(msg.sender, msg.value * tokensPerEth);
	  emit BuyTokens(msg.sender, msg.value, msg.value * tokensPerEth);
  }
  
  function withdraw() public onlyOwner {
	(bool sent,) = msg.sender.call{value: address(this).balance}("");
  }

  // ToDo: create a payable buyTokens() function:

  // ToDo: create a withdraw() function that lets the owner withdraw ETH

  // ToDo: create a sellTokens(uint256 _amount) function:
  
  function sellTokens(uint256 _amount) public {
	  yourToken.transferFrom(msg.sender, address(this), _amount);
	  (bool success,) = msg.sender.call{value: _amount / tokensPerEth}("");
	  require(success, "Failed to send Ether");
  }

}

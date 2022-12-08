// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;  //Do not change the solidity version as it negativly impacts submission grading

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {

  ExampleExternalContract public exampleExternalContract;

  constructor(address exampleExternalContractAddress) {
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }
  
  mapping ( address => uint256 ) public balances;

  uint256 public constant threshold = 1 ether;
  uint256 public deadline = block.timestamp + 72 hours;
  bool public openForWithdraw = false;
  
  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  // ( Make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )
  
  event Stake(address indexed sender, uint256 amount);
  
  modifier checkDeadline() {
        require(block.timestamp > deadline, "too early to call execute");
        _;
    }
	
  modifier notCompleted() {
        require(exampleExternalContract.completed() != true, "not completed");
        _;
    }
  
  function stake() public payable  {
	  balances[msg.sender] += msg.value;
	  emit Stake(msg.sender, msg.value);
  }
  
  // After some `deadline` allow anyone to call an `execute()` function
  // If the deadline has passed and the threshold is met, it should call `exampleExternalContract.complete{value: address(this).balance}()`
  
  function execute() public checkDeadline notCompleted {  	  
	  if (address(this).balance > threshold) {
		  exampleExternalContract.complete{value: address(this).balance}();
	  }
	  else {
		  openForWithdraw = true;
	  }	  
  }
  
  // If the `threshold` was not met, allow everyone to call a `withdraw()` function to withdraw their balance
  
  function withdraw() public notCompleted {
		require(openForWithdraw == true,"threshold not met, cant withdraw yet");
		uint256 temp = balances[msg.sender];
		balances[msg.sender] = 0;
		
		(bool sent,) = msg.sender.call{value: temp}("");
		balances[msg.sender]=0;
	}


  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
  
  function timeLeft() public view returns (uint256) {
	  
	  if (block.timestamp >= deadline) {
		  return 0;
	  }
	  else {
		  return deadline - block.timestamp;
	  }  
  }


  // Add the `receive()` special function that receives eth and calls stake()
  
  receive() external payable {
	stake();
  }

}

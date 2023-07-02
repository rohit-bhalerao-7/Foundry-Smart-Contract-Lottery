//SPDX-License-Identifier: MIT
/*Layout of Contract:
version
imports
errors
interfaces, libraries, contracts
Type declarations
State variables
Events
Modifiers
Functions

Layout of Functions:
constructor
receive function (if exists)
fallback function (if exists)
external
public
internal
private
internal & private view & pure functions
external & public view & pure functions*/

pragma solidity ^0.8.18;
/**
 * @title A sample Raffle Contract
 * @author Rohit Bhalerao
 * @notice This contract is for creating a sample raffle
 * @dev Implements Chainlink VRFv2
 */
contract Raffle {
    
    error Raffle_NotEnoughEthSent();

    uint256 private immutable i_entranceFee; //Since we don't want to change the entrance fee once the contract is deployed, saving gas by making it immutable
    // @dev Duration of lottery in seconds
    uint256 private immutable i_interval;
    uint256 private s_lastTimeStamp; 
    address payable[] private s_players; //array of addresses of players
    
    event EnteredRaffle(address indexed player);

    constructor(uint256 entranceFee, uint256 interval) {
        i_entranceFee = entranceFee;
        i_interval = interval;
        s_lastTimeStamp = block.timestamp;
    }

//we can't loop through mapping, so we need to create an array of all the addresses
//Whenever we make storage update, we shoudl emit an event

    function enterRaffle() external payable{ // external is used to save gas
        //require(msg.value >= i_entranceFee, "Not enough ETH to enter the raffle");
        if(msg.value < i_entranceFee){           //if & error are more gas efficient than require
            revert Raffle_NotEnoughEthSent();
        }
        s_players.push(payable(msg.sender));
        //1. Makes migration/updating contracts easier
        //2. Makes front-end "indexing" easier,storing data about contracts easier
        emit EnteredRaffle(msg.sender);
    }
     

    //1. Get a Random Number
    //2. Use the random no to pick a winner
    //3. Automatically called, we don't want to call it manually to pick a winner 
    function pickWinner() public {
        //1. Check if enough time has passed
       if((block.timestamp - s_lastTimeStamp) < i_interval){
         revert();
       }

    }

    /** Getter Functions */
    function getEntranceFee() public view returns(uint256){
        return i_entranceFee;
    }

}
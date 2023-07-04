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

import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import {VRFConsumerBaseV2} from "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

/**
 * @title A sample Raffle Contract
 * @author Rohit Bhalerao
 * @notice This contract is for creating a sample raffle
 * @dev Implements Chainlink VRFv2
 */
contract Raffle is VRFConsumerBaseV2 {
    error Raffle_NotEnoughEthSent();
    error Raffle_TransferFailed();

    /** State Variables */
    uint16 private constant REQUEST_CONFIRMATIONS = 3; // no of confirmations for RNG to be considered good
    uint32 private constant NUM_WORDS = 1; // number of words to generate/ number of random numbers to generate

    uint256 private immutable i_entranceFee; //Since we don't want to change the entrance fee once the contract is deployed, saving gas by making it immutable
    uint256 private immutable i_interval; // @dev Duration of lottery in seconds
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    bytes32 private immutable i_gasLane;
    uint64 private immutable i_subscriptionId;
    uint32 private immutable i_callbackGasLimit;

    uint256 private s_lastTimeStamp;
    address payable[] private s_players; //array of addresses of players
    address private s_recentWinner;

    event EnteredRaffle(address indexed player);

    constructor(
        uint256 entranceFee,
        uint256 interval,
        address vrfCoordinator,
        bytes32 gasLane,
        uint64 subscriptionId,
        uint32 callbackGasLimit
    ) VRFConsumerBaseV2(vrfCoordinator) { //Since inheritance is used, we need to pass the constructor arguments to the parent contract
        i_entranceFee = entranceFee;
        i_interval = interval;
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinator);
        i_gasLane = gasLane;
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;
        s_lastTimeStamp = block.timestamp;
    }

    //we can't loop through mapping, so we need to create an array of all the addresses
    //Whenever we make storage update, we shoudl emit an event

    function enterRaffle() external payable {
        // external is used to save gas
        //require(msg.value >= i_entranceFee, "Not enough ETH to enter the raffle");
        if (msg.value < i_entranceFee) {
            //if & error are more gas efficient than require
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
        if ((block.timestamp - s_lastTimeStamp) < i_interval) {
            revert();
        }
        // Will revert if subscription is not set and funded.
        uint256 requestId = i_vrfCoordinator.requestRandomWords( //COORDINATOR Is VRF coordinator address
            i_gasLane, // Keyhash is gas lane
            i_subscriptionId, // ID that you've funded with LINK
            REQUEST_CONFIRMATIONS, // no of confirmations for RNG to be considered good
            i_callbackGasLimit, // gas limit for callback to prevent out of gas exceptions
            NUM_WORDS // number of words to generate/ number of random numbers to generate
        );
    }

    function fulfillRandomWords(
        uint256 requestId, 
        uint256[] memory randomWords
        ) internal override{
            //To pick a winner, take mod of random no with no of players eg: RNG % 10 = 2, 2nd player in the array wins
            uint256 indexOfWinner = randomWords[0] % s_players.length;
            address payable winner = s_players[indexOfWinner];
            s_recentWinner= winner;
            (bool success,) = winner.call{value: address(this).balance}("");
            if (!success) {
                revert Raffle_TransferFailed();
            }
        } //override is used to override the function in the parent contract/exists in inheritance
    
    
    //Chainlink VRF is two transactions, one to request a random no and one to receive it

    /** Getter Functions */
    function getEntranceFee() public view returns (uint256) {
        return i_entranceFee;
    }
}

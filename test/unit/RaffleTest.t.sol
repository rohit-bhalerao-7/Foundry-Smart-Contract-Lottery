//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {DeployRaffle} from "../../script/DeployRaffle.s.sol";
import {Raffle} from "../../src/Raffle.sol";
import {Test, console} from "forge-std/Test.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";

contract RaffleTest is Test {
    Raffle raffle;
    HelperConfig helperConfig;
    uint256 entranceFee;
    uint256 interval;
    address vrfCoordinator;
    bytes32 gasLane;
    uint64 subscriptionId;
    uint32 callbackGasLimit;

    address public PLAYER = makeAddr("player");
    uint256 public constant STARTING_USER_BALANCE = 10 ether;

    function setUp() external {
        DeployRaffle deployRaffle = new DeployRaffle();
        (raffle, helperConfig) = deployRaffle.run();
        (
            entranceFee,
            interval,
            vrfCoordinator,
            gasLane,
            subscriptionId,
            callbackGasLimit
        ) = helperConfig.activeNetworkConfig();
    }
    
    function testRaffleInitializesInOpenState() public view {
        assert(raffle.getRaffleState() == Raffle.RaffleState.OPEN); //It should initialize in the open state
    } // Raffle.RaffleState.OPEN means for any Raffle contract instance, the RaffleState type is OPEN
    
    ////////////// ENTER RAFFLE TESTS //////////////\
    function testRaffleRevertWhenYouDontPayEnough() public {
        //Arrange
        vm.prank(PLAYER); //We're going to pretend to be player

        //Act /Assert
        vm.expectRevert(Raffle.Raffle_NotEnoughEthSent.selector);
        raffle.enterRaffle(); //not sending any value
    }

    function testRaffleRecordsPlayerWhenTheyEnter() public {
        //Arrange
        vm.prank(PLAYER); //We're going to pretend to be player

        //Act
        raffle.enterRaffle{value: entranceFee}(); //sending the entrance fee
        address playerRecorded = raffle.getPlayer(0); //We're going to get the player that was recorded   
        
        //Assert
        //assert(raffle.getPlayer().length == 1); //We should have one player in the raffle
        assert(playerRecorded == PLAYER); //The player recorded should be the player that we sent in
    }
}
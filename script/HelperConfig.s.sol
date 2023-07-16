//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";

contract HelperConfig is Script{
    struct NetworkConfig{
        uint256 entranceFee;
        uint256 interval;
        address vrfCoordinator;
        bytes32 gasLane;
        uint64 subscriptionId;
        uint32 callbackGasLimit;
    }

    constructor(){
        if(block.chainid == 11155111){
            activeNetworkConfig = getSepoliaEthConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory){
        return NetworkConfig({
            entranceFee: 0.01 ether,
            interval: 30,
            vrfCoordinator: 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625,
            gasLane: 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c,
            subscriptionId: 0, //Update with our subID
            callbackGasLimit: 500000 //500k gas
        });
    }

    function getOrCreateAnvilEthConfig() public returns(NetworkConfig memory){
         if (activeNetworkConfig.vrfCoordinator != address(0)){
            return activeNetworkConfig;
         } 
     //For chainlink VRF it gets paid in chainlink tokens, whenever you req RNG, you need to pay chainlink tokens
     //base fee is the flat fee that chainlink charges for the request, gas price is the gas price that chainlink charges for the request
     //chainlink node calls fulfill random words on our contract, chainlink node is paying for the gas
     //And the gas price is reimbursed through the gas price link
         uint96 baseFee = 0.25 ether; // 0.25 LINK 
         uint96 gasPriceLink = 1e9; // 1 gwei LINK

    
    vm.startBroadcast(); // to deploy to any network, we need to start a broadcast
    VRFCoordinatorV2Mock vrfCoordinator =  new VRFCoordinatorV2Mock(
        baseFee,
        gasPriceLink
    );
    vm.stopBroadcast();

    
   return NetworkConfig({
            entranceFee: 0.01 ether,
            interval: 30,
            vrfCoordinator: address(vrfCoordinatorMock), // what it does is it takes the address of the vrf coordinator mock and puts it in the network config
            gasLane: 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c,
            subscriptionId: 0, //Our Script will add this
            callbackGasLimit: 500000 //500k gas
        });
    }

    NetworkConfig public activeNetworkConfig;

    function run() returns (NetworkConfig){
        return activeNetworkConfig;
    }
}
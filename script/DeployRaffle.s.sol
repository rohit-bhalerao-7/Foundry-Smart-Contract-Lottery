//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployRaffle is Script {
    function run() external returns (Raffle) {
        HelperConfig helperConfig = HelperConfig();
        (
            uint256 entranceFee,
            uint256 interval,
            address vrfCoordinator,
            bytes32 gasLane,
            uint64 subscriptionId,
            uint32 callbackGasLimit
        ) = helperConfig.activeNetworkConfig();
    }
}

//  (
//             uint256 entranceFee,
//             uint256 interval,
//             address vrfCoordinator,
//             bytes32 gasLane,
//             uint64 subscriptionId,
//             uint32 callbackGasLimit
//         ) = helperConfig.activeNetworkConfig();
//         This can be similiar to when we import NetworkConfig from HelperConfig.s.sol
//         and then // NetworkConfig memory networkConfig = helperConfig.activeNetworkConfig();
//         But we are destructuring the networkconfig object into its underlying parameters
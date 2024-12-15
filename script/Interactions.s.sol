// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";

contract FundFundMe is Script {
    uint256 constant SEND_VALUE = 0.0001 ether;

    function fundFundMe(address recentlyAddress) public {
        vm.startBroadcast();
        FundMe(payable(recentlyAddress)).fund{value: SEND_VALUE}();
        vm.stopBroadcast();
        console.log("Funded FundMe with %s", SEND_VALUE);
    }

    function run() public {
        address recentlyAddress = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        fundFundMe(recentlyAddress);
    }
}

contract WithdrawFundMe is Script {
    function withdrawFundMe(address recentlyAddress) public {
        vm.startBroadcast();
        FundMe(payable(recentlyAddress)).withdraw();
        vm.stopBroadcast();
        console.log("Withdraw FundMe ");
    }

    function run() public {
        address recentlyAddress = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        withdrawFundMe(recentlyAddress);
    }
}

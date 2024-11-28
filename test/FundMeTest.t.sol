// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    function setUp() external {
        fundMe = new DeployFundMe().run();
    }

    function testUsdIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e14);
    }

    function testOwnerIsMsgSender() public view {
        assertEq(fundMe.i_owner(), msg.sender);
    }

    function testGetVersion() public view {
        console.log(fundMe.getVersion());
        assert(fundMe.getVersion()>=0);
    }
}

// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";
import {FundMe} from "../../src/FundMe.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {Test, console} from "forge-std/Test.sol";

contract InteractionTest is Test {
    FundMe fundMe;

    address USER_ADDRESS = makeAddr("USER");
    uint256 constant INPUT_FUND_AMOUNT = 0.001 ether;
    uint256 constant START_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() public {
        fundMe = new DeployFundMe().run();
        vm.deal(USER_ADDRESS, START_BALANCE);
    }

    function testUserCanFundInteractions() public {
        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.fundFundMe(address(fundMe));

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));

        assertEq(address(fundMe).balance, 0);
    }
}

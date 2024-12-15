// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    address USER_ADDRESS = makeAddr("USER");
    uint256 constant INPUT_FUND_AMOUNT = 0.001 ether;
    uint256 constant START_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        fundMe = new DeployFundMe().run();
        vm.deal(USER_ADDRESS, START_BALANCE);
    }

    function testUsdIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e14);
    }

    function testOwnerIsMsgSender() public view {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testGetVersion() public view {
        console.log(fundMe.getVersion());
        assert(fundMe.getVersion() >= 0);
    }

    function testFundFailsWithoutEnoughETH() public {
        vm.expectRevert();
        fundMe.fund();
    }

    function testFundUpdateFundedDataStructure() public M_changeTXSender(USER_ADDRESS) {
        fundMe.fund{value: INPUT_FUND_AMOUNT}();
        uint256 storedFundAmount = fundMe.getAddressToAmountFunded(USER_ADDRESS);

        assertEq(storedFundAmount, INPUT_FUND_AMOUNT);
    }

    function testAddFunderAndCheck() public M_changeTXSender(USER_ADDRESS) M_funded {
        fundMe.fund{value: INPUT_FUND_AMOUNT}();
        address funder = fundMe.getFunderAddress(0);
        console.log(address(fundMe));
        console.log(msg.sender);
        console.log(fundMe.getOwner());
        assertEq(funder, USER_ADDRESS);
    }

    function testOnlyOwnerWithdraw() public M_changeTXSender(USER_ADDRESS) M_funded {
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdrawWithSingleFunder() public M_changeTXSender(USER_ADDRESS) M_funded {
        uint256 startFunderBalance = address(fundMe).balance;
        uint256 startOwnerBalance = fundMe.getOwner().balance;

        vm.stopPrank();
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        uint256 endFunderBalance = address(fundMe).balance;
        uint256 endOwnerBalance = fundMe.getOwner().balance;

        assertEq(endFunderBalance, 0);
        assertEq(startFunderBalance + startOwnerBalance, endOwnerBalance);
    }

    function testWithdrawWithMultipleFunder() public {
        uint160 numberOfFunders = 10;
        uint160 startIndexOfFunders = 0;
        for (uint160 i = startIndexOfFunders; i < numberOfFunders; i++) {
            hoax(address(i), INPUT_FUND_AMOUNT);
            fundMe.fund{value: INPUT_FUND_AMOUNT}();
        }
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFunderBalance = address(fundMe).balance;

        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFunderBalance = address(fundMe).balance;
        assertEq(endingFunderBalance, 0);
        assertEq(startingOwnerBalance + startingFunderBalance, endingOwnerBalance);
    }

    function testWithdrawWithMultipleFunderCheaperGas() public {
        uint160 numberOfFunders = 10;
        uint160 startIndexOfFunders = 0;
        for (uint160 i = startIndexOfFunders; i < numberOfFunders; i++) {
            hoax(address(i), INPUT_FUND_AMOUNT);
            fundMe.fund{value: INPUT_FUND_AMOUNT}();
        }
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFunderBalance = address(fundMe).balance;

        vm.prank(fundMe.getOwner());
        fundMe.cheaperWithdraw();

        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFunderBalance = address(fundMe).balance;
        assertEq(endingFunderBalance, 0);
        assertEq(startingOwnerBalance + startingFunderBalance, endingOwnerBalance);
    }

    /*
    Modifiers
    */
    modifier M_changeTXSender(address targetAddress) {
        vm.startPrank(targetAddress);
        _;
        vm.stopPrank();
    }

    modifier M_funded() {
        fundMe.fund{value: INPUT_FUND_AMOUNT}();
        _;
    }
}

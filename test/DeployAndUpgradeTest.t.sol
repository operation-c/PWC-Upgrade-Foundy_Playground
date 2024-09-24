// SPDX-License-Identifier: MIT 

pragma solidity ^0.8.18;

import { BoxV1 } from "../src/BoxV1.sol";
import { BoxV2 } from "../src/BoxV2.sol";
import { Test, console } from "forge-std/Test.sol";
import { StdCheats } from "forge-std/StdCheats.sol";
import { DeployBox } from "../script/DeployBox.s.sol";
import { UpgradeBox } from "../script/UpgradeBox.s.sol";

contract DeployAndUpgradeTest is StdCheats, Test {
    DeployBox public deployBox;
    UpgradeBox public upgradeBox;

    address public OWNER = address(1);

    function setUp() public {
        deployBox = new DeployBox();
        upgradeBox = new UpgradeBox();
    }

    // test if deployment works as intended 
    function testBoxWorks() public {
        address proxyAddress = deployBox.deployBox();
        uint256 expectedValue = 1;
     
        assertEq(expectedValue, BoxV1(proxyAddress).version());
    }

    function testDeploymentIsV1() public {
        uint256 expectedValue = 7;
        address proxyAddress = deployBox.deployBox();
    
        vm.expectRevert();
        BoxV2(proxyAddress).setValue(expectedValue);
    }

    function testUpgradesWork() public {
        address proxyAddress = deployBox.deployBox();

        BoxV2 box2 = new BoxV2();

        vm.prank(BoxV1(proxyAddress).owner());
        BoxV1(proxyAddress).transferOwnership(msg.sender);

        address proxy = upgradeBox.upgradeBox(proxyAddress, address(box2));

        uint256 expectedValue = 2;
        // with new ownership comes new version 
        // expected ownership should now be v2
        assertEq(expectedValue, BoxV2(proxy).version());
    
        // updating boxV2 to the proper version since BoxV1 relinquished ownership
        BoxV2(proxy).setValue(expectedValue);
        assertEq(expectedValue, BoxV2(proxy).getValue());
        console.log("BoxV2 value:", BoxV2(proxy).getValue());
    }


}
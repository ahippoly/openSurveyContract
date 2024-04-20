// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {SurveyContract} from "../src/SurveyContract3.sol";
import "ds-test/test.sol";

contract SurveyContractTest is DSTest {
    // Import the main contract

    // Create an instance of the SurveyContract
    SurveyContract surveyContract;

    function setUp() public {
        // Deploy a new instance of SurveyContract
        surveyContract = new SurveyContract(0xce36ae7bbc3221fdba8b40923b7efd32);
    }

    function test_PublishSurvey() public {
        // Call the publishSurvey function with test data

        SurveyContract.ZkSource[] memory zkSources = new SurveyContract.ZkSource[](2);
        bytes16[] memory questionZkSources = new bytes16[](2);

        zkSources[0] = SurveyContract.ZkSource({minimumRequired: 1, groupId: bytes16(0x12345678901234567890123456789012)});
        zkSources[1] = SurveyContract.ZkSource({minimumRequired: 2, groupId: bytes16(0x12345678901234567890123456789012)});

        questionZkSources[0] = bytes16(0x12345678901234567890123456789012);
        questionZkSources[1] = bytes16(0x12345678901234567890123456789012);

        string memory fileCID = "bafybeihrlflerpb6cdt6vgwdty3jripx4dlsfy5eyube5ak7voluj3cc34";


        surveyContract.publishSurvey(
            "Sample Survey",
            fileCID,
            2,
            100,
            block.timestamp + 3600,
            zkSources,
            questionZkSources
        );

        // You can write assertions here to check the state or events emitted.
        // For example, you can check the survey count:
        assertEq(surveyContract.surveyCount(), 1);

        // You can also check the survey details:
        SurveyContract.Survey memory survey = surveyContract.getSurvey(fileCID);
        assertEq(survey.rewardByAnswer, 100);
        assertEq(survey.remainingRewardToken, 0);
        assertEq(survey.endTimestamp, block.timestamp + 3600);
        assertEq(survey.numberOfQuestions, 2);
        // assertEq(survey.fileCID, fileCID);
        assertEq(survey.zkSourceStartIndex, 0);
        assertEq(survey.zkSourceNumber, 2);
        assertEq(survey.questionZkSourceStartIndex, 0);
        assertEq(survey.questionZkSourceNumber, 2);
    }

 

    // Add more test cases as needed
}
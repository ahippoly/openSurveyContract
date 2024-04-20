// // FILE: SurveyContract.test.sol

// // SPDX-License-Identifier: MIT

// pragma solidity ^0.8.13;

// import "ds-test/test.sol";
// import {SurveyContract} from "../src/SurveyContract2.sol";

// contract SurveyContractTest is DSTest {
//     SurveyContract surveyContract;

//     function setUp() public {
//         surveyContract = new SurveyContract();
//     }

//     function testPublishSurvey() public {
//         string memory name = "Survey 1";

//         SurveyContract.QuestionMultiple[] memory questionMultiples = new SurveyContract.QuestionMultiple[](2);
//         questionMultiples[0] = SurveyContract.QuestionMultiple({possibleAnswers: 2});
//         questionMultiples[1] = SurveyContract.QuestionMultiple({possibleAnswers: 3});

//         SurveyContract.QuestionNumber[] memory questionsNumber = new SurveyContract.QuestionNumber[](2);
//         questionsNumber[0] = SurveyContract.QuestionNumber({minimumValue: 0, maximumValue: 10});
//         questionsNumber[1] = SurveyContract.QuestionNumber({minimumValue: 20, maximumValue: 30});

//         SurveyContract.QuestionZkSource[] memory questionZkSources = new SurveyContract.QuestionZkSource[](2);
//         questionZkSources[0] = SurveyContract.QuestionZkSource({groupId: bytes16(0x12345678901234567890123456789012)});
//         questionZkSources[1] = SurveyContract.QuestionZkSource({groupId: bytes16(0x12345678901234567890123456789012)});

//         uint256 rewardByAnswer = 100;
//         uint256 endTimestamp = block.timestamp + 3600;

//         surveyContract.publishSurvey(name, questionMultiples, questionsNumber, questionZkSources, rewardByAnswer, endTimestamp);

//         SurveyContract.Survey memory survey = surveyContract.getSurvey(0);

//         assertEq(survey.rewardByAnswer, rewardByAnswer);
//         assertEq(survey.remainingRewardToken, 0);
//         assertEq(survey.endTimestamp, endTimestamp);
//         assertEq(survey.zkSourceCount, 2);
//         assertEq(survey.questionNumberCount, 2);
//         assertEq(survey.questionZkSourceCount, 2);
//         assertEq(survey.questionMultipleCount, 2);
//     }

//     function testAddQuestionMultiple() public {
//         SurveyContract.QuestionMultiple memory question = SurveyContract.QuestionMultiple({possibleAnswers: 2});

//         surveyContract.addQuestionMultiple(0, question);

//         SurveyContract.Survey memory survey = surveyContract.surveys(0);

//         assertEq(survey.questionMultiples.length, 1);
//         assertEq(survey.questionMultiples[0].possibleAnswers, 2);
//     }

//     function testAddQuestionNumber() public {
//         SurveyContract.QuestionNumber memory question = SurveyContract.QuestionNumber({minimumValue: 0, maximumValue: 10});

//         surveyContract.addQuestionNumber(0, question);

//         SurveyContract.Survey memory survey = surveyContract.surveys(0);

//         assertEq(survey.questionNumbers.length, 1);
//         assertEq(survey.questionNumbers[0].minimumValue, 0);
//         assertEq(survey.questionNumbers[0].maximumValue, 10);
//     }

//     function testAddQuestionZkSource() public {
//         SurveyContract.QuestionZkSource memory question = SurveyContract.QuestionZkSource({groupId: bytes16(0x1234567890123456)});

//         surveyContract.addQuestionZkSource(0, question);

//         SurveyContract.Survey memory survey = surveyContract.surveys(0);

//         assertEq(survey.questionZkSources.length, 1);
//         assertEq(survey.questionZkSources[0].groupId, bytes16(0x1234567890123456));
//     }

//     function testGetZkSourceCount() public {
//         uint256 count = surveyContract.getZkSourceCount(0);

//         assertEq(count, 0);
//     }

//     function testGetQuestionNumberCount() public {
//         uint256 count = surveyContract.getQuestionNumberCount(0);

//         assertEq(count, 0);
//     }

//     function testGetQuestionZkSourceCount() public {
//         uint256 count = surveyContract.getQuestionZkSourceCount(0);

//         assertEq(count, 0);
//     }

//     function testGetQuestionMultipleCount() public {
//         uint256 count = surveyContract.getQuestionMultipleCount(0);

//         assertEq(count, 0);
//     }
// }
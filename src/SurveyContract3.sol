// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "sismo-connect-solidity/SismoConnectLib.sol"; 

contract SurveyContract is SismoConnect {
    struct ZkSource {
        uint256 minimumRequired;
        bytes16 groupId;
    }

    struct Survey {
        uint256 rewardByAnswer;
        uint256 remainingRewardToken;
        uint256 endTimestamp;
        uint32 numberOfQuestions;

        uint256 zkSourceStartIndex;
        uint256 zkSourceNumber;

        uint256 questionZkSourceStartIndex;
        uint256 questionZkSourceNumber;
    }

    mapping(uint256 => ZkSource) zkSources;
    uint256 zkSourceCount;

    mapping(uint256 => bytes16) questionZkSources;
    uint256 questionZkSourceCount;

    mapping(string => Survey) public surveys;
    uint256 public surveyCount;

    // It is answer by survey by VaultId
    mapping(string => mapping(uint256 => bool)) public anwers;

    event SurveyPublished(
        string name,        
        string fileCID,
        uint32 numberOfQuestions,
        uint256 rewardByAnswer,
        uint256 endTimestamp,
        ZkSource[] zkSources,
        bytes16[] questionZkSource
    );

    event SurveyAnswered(string fileCID, uint256[] answers, uint256[] zkAnswers );

    constructor(bytes16 appId) SismoConnect(buildConfig(appId, true)) {}

    function answerSurvey(
        string memory fileCID,
        bytes memory sismoConnectResponse,
        uint256[] memory answers
    ) public {
        Survey storage survey = surveys[fileCID];

        require(
            survey.endTimestamp > block.timestamp,
            "Survey is not available anymore"
        );

        require(
            survey.remainingRewardToken >= survey.rewardByAnswer,
            "Survey has no more reward token"
        );

        require(
            address(this).balance >= survey.rewardByAnswer,
            "Insufficient contract balance"
        );

        require(
            answers.length == survey.numberOfQuestions,
            "Invalid number of answers"
        );

        ClaimRequest[] memory claims = new ClaimRequest[](
            survey.zkSourceNumber + survey.questionZkSourceNumber
        );

        uint256 claimIndex = 0;

        for (
            uint256 i = survey.zkSourceStartIndex;
            i < survey.zkSourceStartIndex + survey.zkSourceNumber;
            i++
        ) {
            claims[claimIndex++] = buildClaim({
                groupId: zkSources[i].groupId, 
                isOptional: false, 
                value: zkSources[i].minimumRequired,
                isSelectableByUser: false
            });
        }

        for (
            uint256 i = survey.questionZkSourceStartIndex;
            i <
            survey.questionZkSourceStartIndex + survey.questionZkSourceNumber;
            i++
        ) {
            claims[claimIndex++] = buildClaim({
                groupId: questionZkSources[i],
                isOptional: false,
                value: 0, //hope to not have error
                isSelectableByUser: true
            });
        }

        SismoConnectVerifiedResult memory result = verify({
            responseBytes: sismoConnectResponse,
            claims: claims
        });

        uint256 vaultId = SismoConnectHelper.getUserId(
            result,
            AuthType.VAULT
        );

        //require answer to be false
        require(
            !anwers[fileCID][vaultId],
            "You have already answered this survey"
        );

        anwers[fileCID][vaultId] = true;

        //pay token reward from contract to user
        payable(msg.sender).transfer(survey.rewardByAnswer); 
        survey.remainingRewardToken -= survey.rewardByAnswer;

        //get zk answers from SismoConnectVerifiedResult
        uint256[] memory zkAnswers = new uint256[](survey.questionZkSourceNumber);
        uint256 zkAnswerIndex = 0;
        for (
            uint256 i = survey.zkSourceNumber;
            i <
            survey.zkSourceNumber + survey.questionZkSourceNumber;
            i++
        ) {
            zkAnswers[zkAnswerIndex++] = result.claims[i].value;
        }

        emit SurveyAnswered(fileCID, answers, zkAnswers);
    }

    function refillSurvey(string memory fileCID) public payable {
        Survey storage survey = surveys[fileCID];

        require(
            survey.endTimestamp > block.timestamp,
            "Survey is not available anymore"
        );

        survey.remainingRewardToken += msg.value;
    }

    function publishSurvey(
        string memory _name,
        string memory fileCID,
        uint32 _numberOfQuestions,
        uint256 _rewardByAnswer,
        uint256 _endTimestamp,
        ZkSource[] memory _zkSources,
        bytes16[] memory _questionZkSource
    ) public payable {
        require(
            _questionZkSource.length + _numberOfQuestions > 0,
            "Questions list cannot be empty"
        );

        //check if fileCID is already used
        require(
            surveys[fileCID].questionZkSourceNumber + surveys[fileCID].numberOfQuestions == 0 ,
            "Survey with this fileCID already exists"
        );

        Survey storage newSurvey = surveys[fileCID];
        
        newSurvey.rewardByAnswer = _rewardByAnswer;
        newSurvey.remainingRewardToken = msg.value;
        newSurvey.endTimestamp = _endTimestamp;
        newSurvey.numberOfQuestions = _numberOfQuestions;

        newSurvey.zkSourceStartIndex = zkSourceCount;
        newSurvey.zkSourceNumber = _zkSources.length;

        newSurvey.questionZkSourceStartIndex = questionZkSourceCount;
        newSurvey.questionZkSourceNumber = _questionZkSource.length;

        // Add questions to the survey
        for (uint256 i = 0; i < _zkSources.length; i++) {
            zkSources[zkSourceCount++] = _zkSources[i];
        }

        for (uint256 i = 0; i < _questionZkSource.length; i++) {
            questionZkSources[questionZkSourceCount++] = _questionZkSource[i];
        }

        emit SurveyPublished(
            _name,
            fileCID,
            _numberOfQuestions,
            _rewardByAnswer,
            _endTimestamp,
            _zkSources,
            _questionZkSource
        );

        surveyCount++;
    }

    function getSurvey(string memory fileCID) public view returns (Survey memory) {
        return surveys[fileCID];
    }
}

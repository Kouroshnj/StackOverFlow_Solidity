// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract project {
    IERC20 immutable token;

    string[] public questions; // array of all questions
    uint256 public id;
    uint256 public idAnswer;
    mapping(address => uint256[]) Ids; // All ids that are created by an address
    mapping(uint256 => Question) public IdQuestion; // return Question with it's id
    mapping(uint256 => address) creator; // address creator of question
    mapping(address => string[]) AddressQuestions; // return all questions that are created by an address
    mapping(address => Answer[]) public AddressAnswers; // get the address, return answer, id, rate
    mapping(address => uint256[]) AddressAnswerId; // get an address, return all ids that are answered
    mapping(uint256 => string[]) IdAllAnswers; // all answers to an id
    mapping(uint256 => address[]) public allAddressesToId; // all addresses that answered to an id
    mapping(uint256 => Answer2) public Aid; // get answerId, returns Struct Answer2
    mapping(uint256 => uint256[]) idToid; // get questionId, returns all answerIDs to it

    event _setQuestion(address sender, string question, uint256 amount);
    event allQuestions(string[] questions);

    constructor(address _token) {
        token = IERC20(_token);
    }

    struct Question {
        string question;
        address setter;
        bool IsLocked;
    }

    struct Answer {
        string answers;
        uint256 id;
        uint256 rate;
    }

    struct Answer2 {
        uint256 questionID;
        string answer;
        address setter;
        address answerer;
        bool IsTrue;
    }

    modifier SetTrueAgain(uint256 _questionID) {
        require(!IdQuestion[_questionID].IsLocked, "can not set true again");
        _;
    }

    modifier onlyOwner(uint256 _answerID, uint256 _questionID) {
        require(msg.sender == Aid[_answerID].setter, "ERROR");
        require(
            IdQuestion[_questionID].setter == Aid[_answerID].setter,
            "Not Owner"
        );
        _;
    }

    // Set the Question
    function setQuestion(string memory _question) public {
        token.transferFrom(msg.sender, address(this), 50e18);
        questions.push(_question);
        id++;
        Ids[msg.sender].push(id);
        creator[id] = msg.sender;
        AddressQuestions[msg.sender].push(_question);
        IdQuestion[id] = (Question(_question, msg.sender, false));
    }

    // to get all questions.
    function getQuestion() public view returns (string[] memory) {
        uint256 length = questions.length;
        string[] memory reversedArray = new string[](length);
        uint256 j = 0;
        for (uint256 i = length; i >= 1; i--) {
            reversedArray[j] = questions[i - 1];
            j++;
        }
        return reversedArray;
    }

    function AnswerTheQuestion(
        string memory _answer,
        uint256 _id,
        uint256 _rate
    ) public {
        bytes memory check = bytes(_answer);
        require(check.length != 0, "You must write something!!!");
        require(_rate <= 10, "you must rate between 0 to 10!!!");
        idAnswer++;
        if (_id >= id + 1 || _id == 0) {
            revert("this question does not exist");
        }
        Aid[idAnswer] = (
            Answer2(_id, _answer, IdQuestion[id].setter, msg.sender, false)
        );
        idToid[_id].push(idAnswer);
        AddressAnswers[msg.sender].push(Answer(_answer, _id, _rate));
        AddressAnswerId[msg.sender].push(_id);
        IdAllAnswers[_id].push(_answer);
        allAddressesToId[_id].push(msg.sender);
    }

    function setTrueAnswer(uint256 _answerID, uint256 _questionID)
        public
        SetTrueAgain(_questionID)
        onlyOwner(_answerID, _questionID)
    {
        require(
            _answerID <= idAnswer && _answerID != 0,
            "Not Allowed To set True"
        );
        // require(msg.sender == Aid[_answerID].setter, "ERROR");
        // require(
        //     IdQuestion[_questionID].setter == Aid[_answerID].setter,
        //     "Not Owner"
        // );
        // if (IdQuestion[_questionID].IsLocked == true) {
        //     revert("can not set true again");
        // }
        Aid[_answerID].IsTrue = true;
        IdQuestion[_questionID].IsLocked = true;
        if (Aid[_answerID].IsTrue != false) {
            token.transfer(Aid[_answerID].answerer, 10e18);
        }
    }

    function SeeAllidAnswers(uint256 _id)
        public
        view
        returns (string[] memory)
    {
        return IdAllAnswers[_id];
    }

    function idsThatAnsweredOneQuestion(uint256 _id)
        public
        view
        returns (uint256[] memory)
    {
        return idToid[_id];
    }

    function QuestionsByAddress(address _creator)
        public
        view
        returns (string[] memory)
    {
        return AddressQuestions[_creator];
    }

    function AddressanswerdID(address _answerer)
        public
        view
        returns (uint256[] memory)
    {
        return AddressAnswerId[_answerer];
    }

    function QuestionCreatedByAddress(address _creator)
        public
        view
        returns (uint256[] memory)
    {
        return Ids[_creator];
    }
}

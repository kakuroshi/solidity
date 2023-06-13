// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0;

contract voice {
    address admin = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;

    struct student {
        string FIO;
        uint age;
        string role;
        bool vote;
        string group;
    }

    struct vote {
        string group;
        address[] condidates;
        uint startTime;
        uint amountInSeconds;
        bool active;
        uint[] condVote;
    }

    mapping (address => student) _students;
    vote[] votes;
    address[] classPresidents;


    constructor() {
        _students[0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2] = (student("Kostikova D. O.", 16, "Student", false, "IOP"));
        _students[0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db] = (student("Kasatsky K. Y.", 18, "Student", false, "ISIP"));
        _students[0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB] = (student("Sorokina A. G.", 17, "Student", false, "ISIP"));
        _students[0x617F2E2fD72FD9D5503197092aC168c91465E7f2] = (student("Isaev A. V.", 17, "Student", false, "IOP"));
    }

    function addStd (address _student, string memory _FIO, uint _age, string memory _role, string memory _group) public {
        require(msg.sender == admin, "Not enough rights");
        require(_students[_student].age == 0, "Student already exists");

        _students[_student] = (student(_FIO, _age, _role, false, _group));
    }

    function start (string memory _group, address _newStar, uint _endTime) public {
        require(msg.sender == admin, "Not enough rights");
        require(_students[_newStar].age != 0, "Student does not exist");
        require(keccak256(abi.encodePacked(_students[_newStar].group)) == keccak256(abi.encodePacked(_group)), "The student is in another group");

        address[] memory allCondidates = new address[](1);
        uint[] memory _condVotesMas = new uint[](1);

        allCondidates[0] = _newStar;
        _condVotesMas[0] = 0;

        votes.push(vote(_group, allCondidates, block.timestamp, _endTime, true, _condVotesMas));
    }

    function addCond (address _newCond, uint _votingNum) public {
        require(msg.sender == admin, "Not enough rights");
        require(keccak256(abi.encodePacked(_students[_newCond].group)) == keccak256(abi.encodePacked(votes[_votingNum].group)), "The student is in another group");

        votes[_votingNum].condidates.push(_newCond);
        votes[_votingNum].condVote.push(0);
    }

    function stdVote (uint _votingNum, address _newSt) public {
        require(_students[msg.sender].vote == false);
        require(votes[_votingNum].active);
        require(keccak256(abi.encodePacked(_students[msg.sender].group)) ==  keccak256(abi.encodePacked(votes[_votingNum].group)));
        require(votes[_votingNum].amountInSeconds + votes[_votingNum].startTime > block.timestamp);
        
        for (uint i = 0; i < votes[_votingNum].condidates.length; i++) {
            if (_newSt == votes[_votingNum].condidates[i]) {
                votes[_votingNum].condVote[i] += 1;
            }
        }

        _students[msg.sender].vote = true;
    }

    function getNewStarosta(uint _voteNum) public {
        require(msg.sender == admin, "Not enough rights");
        require(votes[_voteNum].amountInSeconds + votes[_voteNum].startTime > block.timestamp, "Voting is inactive");

        address newStarosta = votes[_voteNum].condidates[0];
        uint numOfVotes = votes[_voteNum].condVote[0];

        for  (uint i = 0; i < votes[_voteNum].condidates.length; i++) {
            if (votes[_voteNum].condVote[i] > numOfVotes) {
                newStarosta = votes[_voteNum].condidates[i];
                numOfVotes = votes[_voteNum].condVote[i];
            }
        }

        _students[newStarosta].role = "Starosta";

        for (uint i = 0; i < classPresidents.length; i++) {
            if (keccak256(abi.encodePacked(_students[classPresidents[i]].group)) == keccak256(abi.encodePacked( _students[newStarosta].group))) {
                _students[classPresidents[i]].role = "Student";
                classPresidents[i] = newStarosta;
            } else {
                classPresidents.push(newStarosta);
            }
        }

        votes[_voteNum].active = false;
    }

    function getRes(uint _voteNum) public view returns (uint[] memory) {
        return votes[_voteNum].condVote;
    }

    function res() public view returns (vote[] memory) {
        return votes;
    }
}

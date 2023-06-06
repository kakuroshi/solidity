// SPDX-License-Identifier: MIT 
pragma solidity >= 0.7.0; 
 
contract Painting{ 
    struct Car { 
        string number; 
        string color; 
        string brand; 
        string model; 
        uint year; 
    } 
 
    struct Order { 
        uint id_order; 
        string number; 
        bool beingPainting; 
        uint paintingCost; 
        bool agreeToPaint; 
        string desiredColor; 
    } 
 
    address master = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2; 
 
    mapping (address => Car[]) _cars; 
    Order[] public _orders; 
 
    constructor () { 
        _cars[0x5B38Da6a701c568545dCfcB03FcB875f56beddC4].push(Car("F637AR", "grey", "LADA", "2107", 1990)); 
        // orders.push(0, "F637AR", false, 0, false, ""); 
 
        _cars[0x5B38Da6a701c568545dCfcB03FcB875f56beddC4].push(Car("M527MR", "yellow", "LADA", "KALINA", 2010)); 
        // orders.push(0, "M527MR", false, 0, false, ""); 
    } 
 
    function addCar(address _client, string memory _number, string memory _color, string memory _brand, string memory _model, uint year) public { 
        require(msg.sender == master, "Insufficient rights to register the machine."); 
        _cars[_client].push(Car(_number, _color, _brand, _model, year)); 
    } 
 
    function toPaint (string memory _number, string memory _color) public { 
        for (uint i = 0; i < _cars[msg.sender].length; i++) { 
            if (keccak256(abi.encodePacked((_cars[msg.sender][i].number))) == keccak256(abi.encodePacked((_number)))) { 
                 _orders.push(Order(_orders.length, _number, true, 0, false, _color)); 
            } 
        } 
        // _cars[msg.sender][_id_car].beingPainting = true; 
        // _cars[msg.sender][_id_car].desiredColor = _color; 
    } 
 
    function priceEstimate (uint _id) public { 
        require(msg.sender == master, "You are not a master"); 
        require(_orders[_id].beingPainting = true, "The car is not being painted."); 
 
        _orders[_id].paintingCost = 10; 
    } 
 
    function firstAgree (uint _id, bool _agree) public payable { 
        require(_orders[_id].paintingCost != 0, "The car has not been rated."); 
 
        if (_agree) { 
            require(msg.value == (_orders[_id].paintingCost) * 10 **18, "Insufficient funds"); 
 
            _orders[_id].agreeToPaint = true; 
        } else if (_agree == false) { 
            _orders[_id].paintingCost = 0; 
            _orders[_id].beingPainting = false; 
        } 
    } 
 
    function painting (address _client, uint _id) public { 
        require(msg.sender == master, "You are not a master"); 
        require(_orders[_id].agreeToPaint, "The client does not agree to painting"); 
 
        for (uint i = 0; i < _cars[_client].length; i++) { 
            if (keccak256(abi.encodePacked((_cars[_client][i].number))) == keccak256(abi.encodePacked((_orders[_id].number)))) { 
                _cars[_client][i].color = _orders[_id].desiredColor; 
                _orders[_id].beingPainting = false; 
            } 
        } 
    } 
 
    function finalAgree (uint _id, bool _agree) public payable { 
        require(_orders[_id].paintingCost != 0, "The car has not been rated."); 
        require(_orders[_id].beingPainting == false, "car for painting"); 
 
        if (_agree) { 
            payable(master).transfer(_orders[_id].paintingCost * 10 **18); 
 
            _orders[_id].paintingCost = 0; 
           _orders[_id].agreeToPaint = false; 
        } else if (_agree == false) { 
            payable(msg.sender).transfer(_orders[_id].paintingCost * 10 **18); 
 
        _orders[_id].paintingCost = 0; 
        _orders[_id].agreeToPaint = false; 
        } 
    } 
 
    function returnCar (address _client) public view returns (Car[] memory) { 
        return _cars[_client]; 
    } 
}

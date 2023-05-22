// SPDX-License-Identifier: MIT
pragma solidity >= 0.7.0;

contract Painting{
    struct Car {
        uint id;
        string color;
        string brand;
        string model;
        uint year;
        bool beingPainting;
        uint paintingCost;
        bool agreeToPaint;
        string desiredColor;
    }

    address master = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;

    mapping (address => Car[]) _cars;

    constructor () {
        _cars[0x5B38Da6a701c568545dCfcB03FcB875f56beddC4].push(Car(0, "grey", "LADA", "2107", 1990, false, 0, false, ""));
        _cars[0x5B38Da6a701c568545dCfcB03FcB875f56beddC4].push(Car(1, "yellow", "LADA", "KALINA", 2010, false, 0, false, ""));
    }

    function toPaint (address _client, uint _id_car, string memory _color) public {
        require(_client == msg.sender);
        _cars[_client][_id_car].beingPainting = true;
        _cars[_client][_id_car].desiredColor = _color;
    }

    function priceEstimate (address _client, uint _id_car) public {
        require(_cars[_client][_id_car].beingPainting = true);
        require(msg.sender == master);

        _cars[_client][_id_car].paintingCost = 10;
    }

    function firstAgree (address _client, uint _id_car, bool _agree) public payable {
        require(msg.sender == _client);
        require(_cars[_client][_id_car].paintingCost != 0);

        if (_agree) {
            require(msg.value == (_cars[_client][_id_car].paintingCost) * 10 **18);

            _cars[_client][_id_car].agreeToPaint = true;
        } else if (_agree == false) {
            _cars[_client][_id_car].paintingCost = 0;
            _cars[_client][_id_car].beingPainting = false;
        }
    }

    function painting (address _client, uint _id_car) public {
        require(msg.sender == master);
        require(_cars[_client][_id_car].agreeToPaint);
        
        _cars[_client][_id_car].color = _cars[_client][_id_car].desiredColor;
        _cars[_client][_id_car].beingPainting = false;
    }

    function finaAgree (address _client, uint _id_car, bool _agree) public payable {
        require(msg.sender == _client);
        require(_cars[_client][_id_car].paintingCost != 0);
        require( _cars[_client][_id_car].beingPainting == false);

        if (_agree) {
            payable(master).transfer(_cars[_client][_id_car].paintingCost * 10 **18);

            _cars[_client][_id_car].paintingCost = 0;
            _cars[_client][_id_car].agreeToPaint = false;
        } else if (_agree == false) {
            payable(_client).transfer(_cars[_client][_id_car].paintingCost * 10 **18);

        _cars[_client][_id_car].paintingCost = 0;
        _cars[_client][_id_car].agreeToPaint = false;
        }
    }

    function returnCar (address _client) public view returns (Car[] memory) {
        return _cars[_client];
    }
}

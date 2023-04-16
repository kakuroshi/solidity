// SPDX-License-Identifier: MIT 
pragma solidity >=0.7.0; 
 
// Задание 1
// contract FlatQuest { 
//     struct Flat { 
//         uint estate_id; 
//         address owner; 
//         string info; 
//         uint square; 
//         uint useful_square; 
//     } 
 
//     address admin = 0x03C6FcED478cBbC9a4FAB34eF9f40767739D1Ff7; 
 
//     Flat[] public flats; 
 
//     constructor() { 
//         flats.push(Flat(0, 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2, "Moskovskaya 3", 120, 100)); 
//         flats.push(Flat(0, 0xdD870fA1b7C4700F2BD7f44238821C26f7392148, "Pobedi 1", 140, 130)); 
//     } 
 
//     function AddFlat (uint _estate_id, address _owner, string memory _info, uint _square, uint _useful_square) public { 
//         require(msg.sender == admin, "Not admin"); 
//         flats.push(Flat(_estate_id, _owner, _info, _square, _useful_square)); 
//     } 
 
//         function count() public view returns (uint) { 
//         return flats.length; 
//     } 
 
//     function viewFlats () public view returns (Flat[] memory) { 
//         return flats; 
//     } 
// } 
 
 // Задание 2
contract Estate { 
    struct RealEstate { 
        uint id;
        address owner; 
        uint square; 
        uint lifetime; 
    } 
 
    struct Sell { 
        uint id;
        bool ForSale;
        uint price;
        uint SaleTerm;
        address Customer;
    } 

    address admin = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;  

    RealEstate[] public estates; 
    Sell[] public sells; 

    constructor () { 
        estates.push(RealEstate(0, 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4, 50, 7));
        sells.push(Sell(0, false, 0, 0, address(0)));
    } 

    function registerEstate (uint _id, address _owner, uint _square, uint _lifetime) public { 
        require(msg.sender == admin, "Insufficient rights to register property"); 
        estates.push(RealEstate(_id, _owner, _square, _lifetime));
        sells.push(Sell(_id, false, 0, 0, address(0)));
    } 

    function saleOfRealEstate(uint _id, uint _price, uint _SaleTerm) public { 
        require(msg.sender == estates[_id].owner, "You are not the owner");
        require(sells[_id].ForSale != true, "Estate is already for sale");

        sells[_id].ForSale = true;
        sells[_id].price = _price;
        sells[_id].SaleTerm = _SaleTerm;
        sells[_id].Customer = address(0);
    }

    function CancelSell(uint _id) public payable {
        require(sells[_id].ForSale == true);
        require(msg.sender == estates[_id].owner);
        if (sells[_id].Customer != address(0)) {
            payable(sells[_id].Customer).transfer(sells[_id].price*(10**18));
        }

        sells[_id].ForSale = false;
        sells[_id].price = 0;
        sells[_id].SaleTerm = 0;
        sells[_id].Customer = address(0);
    }

    function perevod (uint _id) public payable { 
        require(msg.value == sells[_id].price * (10**18));
        sells[_id].Customer = msg.sender;
    } 

    function confirm (uint _id) public payable{
        require(msg.sender == estates[_id].owner);
        require(sells[_id].ForSale == true);
        require(sells[_id].Customer != address(0));

        payable(estates[_id].owner).transfer(sells[_id].price * (10**18));
        
        estates[_id].owner = sells[_id].Customer;

        sells[_id].ForSale = false;
        sells[_id].price = 0;
        sells[_id].SaleTerm = 0;
        sells[_id].Customer = address(0);
    }

    function checkEstates() public view returns (RealEstate[] memory) {
        return estates;
    }

    function checkSells() public view returns (Sell[] memory) {
        return sells;
    }
}

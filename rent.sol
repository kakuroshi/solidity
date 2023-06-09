// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0;

contract Estate { 
    struct RealEstate { 
        uint id;
        address owner; 
        uint square; 
        uint lifetime; 
    } 
 
    struct Sell { 
        bool ForSale;
        uint price;
        uint SaleTerm;
        address Customer;
    } 

    address public admin = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;  

    mapping(uint => RealEstate) public estates; 
    mapping(uint => Sell) public sells; 
    uint public estateCount = 0;

    constructor () { 
        addEstate(0x5B38Da6a701c568545dCfcB03FcB875f56beddC4, 50, 7);
    } 

    function addEstate(address _owner, uint _square, uint _lifetime) public { 
        require(msg.sender == admin, "Insufficient rights to register property"); 
        estateCount++;
        estates[estateCount] = RealEstate(estateCount, _owner, _square, _lifetime);
        sells[estateCount] = Sell(false, 0, 0, address(0));
    } 

    function saleOfRealEstate(uint _id, uint _price, uint _SaleTerm) public { 
        require(msg.sender == estates[_id].owner, "You are not the owner");
        require(sells[_id].ForSale != true, "Estate is already for sale");

        sells[_id].ForSale = true;
        sells[_id].price = _price;
        sells[_id].SaleTerm = _SaleTerm;
        sells[_id].Customer = address(0);
    }

    function cancelSell(uint _id) public payable {
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

    function buyEstate(uint _id) public payable { 
        require(msg.value == sells[_id].price * (10**18));
        sells[_id].Customer = msg.sender;
    } 

    function confirmSale(uint _id) public payable{
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
    

    function getEstates() public view returns (RealEstate[] memory) {
        RealEstate[] memory result = new RealEstate[](estateCount);
        for (uint i = 1; i <= estateCount; i++) {
            result[i - 1] = estates[i];
        }
        return result;
    }

    function getSells() public view returns (Sell[] memory) {
        Sell[] memory result = new Sell[](estateCount);
        for (uint i = 1; i <= estateCount; i++) {
            result[i - 1] = sells[i];
        }
        return result;
    }
}

contract RentalEstate is Estate {
    
    struct Rent {
        bool ForRent;
        uint price;
        uint RentTerm;
        address Tenant;
        uint timestamp;
    }
    
    mapping(uint => Rent) public rents; 
    
    function rentOutRealEstate(uint _id, uint _price, uint _RentTerm) public { 
        require(msg.sender == estates[_id].owner, "You are not the owner");
        require(rents[_id].ForRent != true, "Estate is already for rent");

        rents[_id].ForRent = true;
        rents[_id].price = _price;
        rents[_id].RentTerm = _RentTerm;
        rents[_id].Tenant = address(0);
        rents[_id].timestamp = block.timestamp;
    }
    
    function cancelRent(uint _id) public payable {
        require(rents[_id].ForRent == true);
        require(msg.sender == estates[_id].owner);
        if (rents[_id].Tenant != address(0)) {
            payable(rents[_id].Tenant).transfer(rents[_id].price*(10**18));
        }

        rents[_id].ForRent = false;
        rents[_id].price = 0;
        rents[_id].RentTerm = 0;
        rents[_id].Tenant = address(0);
        rents[_id].timestamp = 0;
    }
    
    function rentEstate(uint _id) public payable { 
        require(msg.value == rents[_id].price * (10**18));
        rents[_id].Tenant = msg.sender;
        rents[_id].timestamp = block.timestamp;
    } 
    
    function confirmRent(uint _id) public payable{
        require(msg.sender == estates[_id].owner);
        require(rents[_id].ForRent == true);
        require(rents[_id].Tenant != address(0));

        payable(estates[_id].owner).transfer(rents[_id].price * (10**18));
        
        rents[_id].ForRent = false;
        rents[_id].price = 0;
        rents[_id].RentTerm = 0;
        rents[_id].Tenant = address(0);
        rents[_id].timestamp = 0;
    }
    
    function getRents() public view returns (Rent[] memory) {
        Rent[] memory result = new Rent[](estateCount);
        for (uint i = 1; i <= estateCount; i++) {
            result[i - 1] = rents[i];
        }
        return result;
    }
}

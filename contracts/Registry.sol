//SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.0;


// Import Ownable from the OpenZeppelin Contracts library
// import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
// import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./RegisterFactory.sol";
import "hardhat/console.sol";

// contract RegisterFactory {
//     Registry[] public registrys;

//     function createRegister(address payable creator) public {
//         Registry registry = new Registry(creator);
//         registrys.push(registry);
//     }
// }



contract Registry {

    using Counters for Counters.Counter;

    Counters.Counter private propCounter;
    address payable public owner;
    bytes32[] public s_persons;
    Locale[] public locales;
    Property[] public s_properties;
    bytes32[] public s_propHashes;
    bytes32 public s_personHash;
    bytes32 public s_lockedHash;
    

    

     

    struct Person{
        string name;
        string country;
        string idProof;
        bytes32 hash_;
        
    }

    struct Property{

        uint lat;
        uint lng;
        uint totalArea;
    }

    mapping(address => bytes32) public s_AddrToPersonHash;
    
    mapping(string => bytes32) public s_idToLockedHash;

    mapping(address => uint256) public s_addrToPropCount;
    mapping(address => string) public s_addrToIdProof;
    mapping(address => mapping(uint256 => string)) public s_addressToID;

    mapping(address =>  uint256) public s_propertyPerAccount;
    mapping(address => mapping(uint256 => Property)) public s_addrToaSingleProperty;
    mapping(address => mapping(uint256 => bytes32)) public s_addrToCountToPropHash;

    // mapping(address => Person) public addrToPerson;
    mapping(address => Property) public addrToProperty;
    mapping(address => bytes32) public s_AddrToPropHash;
    mapping(bytes32 => bool) public s_PropExist;
    mapping(address => mapping(bytes32 => bool)) public s_isPropExist;
    mapping(bytes32 => bool) public s_exitsPersonHash;
    mapping(address => Locale) public addrToLocale;

        struct Locale {

        uint256 lat;
        uint256 lng;
    }

    enum Status{
        OFF,
        
        ON
    }

    Status public status;


    constructor(address payable owner_) {
          owner = owner_;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        
        _;
    }

    
     
    

    function newPerson( string memory name_, string memory country_, string memory idProof_) public onlyOwner{
        require(bytes(name_).length !=0 && bytes(country_).length !=0 && bytes(idProof_).length !=0, "input required");
        require( status == Status.OFF, "compelete pending...");
        
         
        

         
         
        // persons.push(Person(name_, coutry_, idProof_));
        Person memory person;
        person.name = name_;
        person.country = country_;
        person.idProof = idProof_;
      
    //    require(person.name_ && person.country_, "There is empty string passed as parameter.");


        

       // hashing the personal data...

        s_personHash = keccak256(abi.encode(person));

        require(!s_exitsPersonHash[s_personHash] , "duplicate person info");
        s_exitsPersonHash[s_personHash] = true;

        // adding the hashed data to  an array..

        s_persons.push(s_personHash);
        // extracting prop coun..from  addr to prop count mapping
        
        uint256 propCount = s_addrToPropCount[msg.sender];

        // setting addr to prop count to id proof mapping...

         s_addressToID[msg.sender][propCount] = idProof_;

         // mapping from addr to idProof...

         s_addrToIdProof[msg.sender] = idProof_;
         
         //mapping from address to person detail hashll
        s_AddrToPersonHash[msg.sender] = s_personHash;

        status = Status.ON;

         
    }

    function newProperty(uint lat_, uint lng_, uint totalArea_) public  {
        require(lat_ !=0 && lng_ !=0 && totalArea_ !=0);
        require( status == Status.ON, "start with person infor....");
        
       
        
        // status = Status.pending;

        Property memory property;
        property.lat = lat_;
        property.lng = lng_;
        property.totalArea = totalArea_;

        s_properties.push(property);
        

        bytes32 s_propHash =  keccak256(abi.encode(property));
        // ensuring not duplicate property...
        require(!s_PropExist[s_propHash], "prorperty exists." );

        // now adding property....
        s_propHashes.push(s_propHash);

       

        // now setting the property exists true....
        s_PropExist[s_propHash] = true;

        

        s_AddrToPropHash[msg.sender] = s_propHash;

         
        s_addrToPropCount[msg.sender] =  propCounter.current();

        uint256 propCount = s_addrToPropCount[msg.sender];
        s_addrToCountToPropHash[msg.sender] [propCount] = s_propHash;

        s_addrToaSingleProperty[msg.sender] [propCount]= property;
         
        propCounter.increment();

        // calling register function....final step...

        register();

        status = Status.OFF;


       // setting stauts to complete...

    }

        function setLocale(uint256 lat_, uint256 lng_) public onlyOwner {
            require(lat_ !=0 && lng_ !=0, "input required");
        // Locale memory locale;
        // locale.lat = lat;
        // locale.lng = lng;
        // locales.push(locale);
        addrToLocale[owner] = Locale(lat_, lng_);
        locales.push(Locale(lat_, lng_));
        

    }

    function register() private onlyOwner {
          connect();

          string memory idProof_ = s_addrToIdProof[msg.sender];
          s_idToLockedHash[idProof_] = s_lockedHash;

          
    }

    function connect() private  returns(bytes32) {
        bytes32 s_propHash_ = s_AddrToPropHash[msg.sender];
        // s_AddrToPropHash[msg.sender] = s_propHash;
        bytes32  s_personHash_ = s_AddrToPersonHash[msg.sender];

         

       s_lockedHash = keccak256(abi.encode(s_propHash_, s_personHash_));
    
        return s_lockedHash;

    }





    function verifyOwner(string memory idProof_) public view returns(bool ) {
        require(s_lockedHash != bytes32(0x0000000000000000000000000000000000000000000000000000000000000000), "data not uploaded yet");
        

        if(s_idToLockedHash[idProof_] == s_lockedHash) {
            return true;
        } else {
            return false;
        }

        
    }
}
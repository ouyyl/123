pragma solidity ^0.5.0;

contract Election{
    string public constant name = "DAPP";
    string public constant symbol = "DNF767";
    uint256 public _capacity = 0;
    address private _founder;
    mapping (address => uint8) public _authorization;  
    mapping (uint256 => string) public _cargoesName;   
    mapping (uint256 => string) public _cargoesplace;  
 
    
    
    mapping (uint256 => string) public _processdata;    
    mapping (uint256 => string) public _batchnumber;   
    

    mapping (address => mapping (uint256 => uint256)) public _cargoes;  
    mapping (address => uint256) public _cargoesCount;
    mapping (address => mapping (uint256 => uint256)) public _holdCargoes; 

    mapping (uint256 => uint256) public _holdCargoIndex; 
    mapping (address => uint256) public _holdCargoesCount;
    mapping (uint256 => mapping (uint256 => Log)) public _logs;
    mapping (uint256 => uint256) public _transferTimes;

    
    event NewCargo(address indexed _creater, uint256 _cargoID);
    event Transfer(uint256 indexed _cargoID, address indexed _from, address _to);
    
    struct Log {
        uint256 time;
        address holder;
    }
    
   mapping (uint => productnew) public productnews;
   

    struct productnew{
         uint id;
         
         uint num;
         uint createTime;
         address  nowhold;
         address  createMan;
         string cargoName；
         string  cargoraw;
       

       
         string  data;
         string  number;
         


         uint tranTIME;
         address  befhold;
          
    }
    
    constructor () public {
        _founder = msg.sender;
        _authorization[msg.sender] = 3;
    }

  
    function capacity () public view returns (uint256) { return _capacity; }

    function capacityOf (address _owner) public view returns (uint256) { return _cargoesCount[_owner]; }
    
    function cargoNameOf (uint256 _cargoID) public view returns (string memory) { return _cargoesName[_cargoID]; }
    function cargorawOf (uint256 _cargoID) public view returns (string memory ) { return _cargoesplace[_cargoID]; }

    
    function dataOf (uint256 _cargoID) public view returns (string memory) { return _processdata[_cargoID]; }
    function numberOf (uint256 _cargoID) public view returns (string memory) { return _batchnumber[_cargoID]; }
   



  
    function permissionOf (address _user) public view returns (uint8) { return _authorization[_user]; }
    
    function transferTimesOf (uint256 _cargoID) public view returns (uint256) {
        return _transferTimes[_cargoID];
    }

   
    function holderOf (uint256 _cargoID) public view returns (address) {
        return _logs[_cargoID][_transferTimes[_cargoID]].holder;
    }


    function tracesOf (uint256 _cargoID) public view returns ( address[] memory holders) {
        uint256 transferTime = _transferTimes[_cargoID];
        holders = new address[](transferTime + 1);
        uint256[] memory times;
        times = new uint256[](transferTime + 1);
        for (uint256 i = 0; i <= transferTime; i++) {
            Log memory log = _logs[_cargoID][i];
            holders[i] = log.holder;
            times[i] = log.time;
        }
        return holders;
    }

  
    function allCreated () public view returns (uint256[] memory cargoes) {
         address _creater= msg.sender;
        uint256 count = _cargoesCount[_creater];
        cargoes = new uint256[](count);
        for (uint256 i = 0; i < count; i++) {
            cargoes[i] = _cargoes[_creater][i];
        }
    }



    function createNewCargo (string memory _cargoName,string memory _cargoraw,string memory _processdatas,string memory batchnum) public returns (uint256 cargoID) {
        uint8 authorization = _authorization[msg.sender];
        require(authorization > 1, "unthorizted");
        uint256 count = _cargoesCount[msg.sender];
     
      
        cargoID = uint(keccak256(abi.encodePacked(msg.sender, count, _capacity)))%10000000000;
   
         _cargoes[msg.sender][count] = cargoID;
     
        _cargoesName[cargoID] = _cargoName;
        _cargoesplace[cargoID] = _cargoraw;
   

      
        _processdata[cargoID] = _processdatas;
        _batchnumber[cargoID] = batchnum;
       
  
        _logs[cargoID][0] = Log({
            time: block.timestamp,
            holder: msg.sender
        });
        _addToHolder(msg.sender, cargoID);
        emit NewCargo(msg.sender, cargoID);
        _cargoesCount[msg.sender]++;

       _capacity++;
      
       productnews[_capacity] = productnew( _capacity,cargoID, now, msg.sender, msg.sender,_cargoName,_cargoraw,_processdatas,batchnum,now, msg.sender);      
    }


    
    function allHolding (address _owner) public view returns (uint256[] memory cargoes) {
        uint256 count = _holdCargoesCount[_owner];
        cargoes = new uint256[](count);
        for (uint256 i = 0; i < count; i++) {
            cargoes[i] = _holdCargoes[_owner][i + 1];
        }
    }

   

    function setPermission (address _address, uint8 _state) public {
          
           uint8 authorization = _authorization[msg.sender];
           require(authorization > 2, "unauthorizated");
            _authorization[_address] = _state;
     }



 
    function transfer (uint256 _cargoID, address _to) public returns (bool success) {
        uint8 authorization = _authorization[msg.sender];
        require(authorization > 0, "illeagal！");
        uint256 transferTime = _transferTimes[_cargoID];
        address holder = _logs[_cargoID][transferTime].holder;
        
        require(holder != address(0), "address is unused！");
     
        require(holder == msg.sender, "no！");
        
        require(holder != _to, "no！");
       
        require(_to != address(0), "no！");

  
        _transferTimes[_cargoID]++;
        _logs[_cargoID][transferTime + 1] = Log({
            time: block.timestamp,
            holder: _to
        });
  
        _removeFromHolder(msg.sender, _cargoID);
        _addToHolder(_to, _cargoID);
`transactionReceipt`
        emit Transfer(_cargoID, holder, _to);

   
        uint littleID=0;
        for(uint i=0;i<=_capacity;i++){
            productnew storage productTemp = productnews[i];
            if(productTemp.num== _cargoID){
                 littleID=i;
            }
        }
        require(littleID!=0);
         productnew storage productnewa = productnews[littleID];
         productnewa.befhold= productnewa.nowhold ;
         
         productnewa.nowhold=_to;
         productnewa.tranTIME=now;
        
        
        return true;
    }



    function _removeFromHolder (address _oriHolder, uint256 _cargoID) private {
        uint256 count = _holdCargoesCount[_oriHolder];
        uint256 index = _holdCargoIndex[_cargoID];
        _holdCargoes[_oriHolder][index] = _holdCargoes[_oriHolder][count];
        _holdCargoesCount[_oriHolder]--;
    }




    function _addToHolder (address _newHolder, uint256 _cargoID) private {
        uint256 count = _holdCargoesCount[_newHolder];
        _holdCargoIndex[_cargoID] = count + 1;
        _holdCargoes[_newHolder][count + 1] = _cargoID;
        _holdCargoesCount[_newHolder]++;
    }


}

pragma solidity ^0.4.19;

import "./Owner.sol";

contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract AdContract {
    // This is an abstract contract for local test
    function AdContract() {
        
    }
}

contract AdMain is Ownable {
    using SafeMath for uint256;
    
    mapping (address => bool) public users;
    mapping (address => address) public adContracts;
    mapping (address => uint256) public balances;
    
    ERC20Basic public token;
    
    function AdMain() {
        token = ERC20Basic(address(0x27992a037756b7f1b5d024527b37df5fcd1258ef));
    }
    
    function setUser(address who) onlyOwner external {
        users[who] = true;
    }
    
    function resetUser(address who) onlyOwner external {
        users[who] = false;
    }
    
// 这个函数是合约调用的，前端无需处理    
    function clickAd(address media, address user, uint256 mediaValue, uint256 userValue) external returns (uint8) {
        address fromContract = msg.sender;
        
        if (adContracts[msg.sender]==address(0x0)) {
            return 1;
        }
        
        if (mediaValue.add(userValue) >= balances[fromContract]) {
            return 2; 
        }
        
        if (!users[user]) {
            return 3;
        }
        
        // Transfer if false, return 4
        // if true, return 0
    }
    
    function newContract() external {
        address adContract = new AdContract();
        // dosomething
    }
    
    function deposit(address beneficiary, uint256 value) external {
	
	//如果失败,会revert        
    }
    
    function withdraw(address beneficiary, uint256 value) external {
        
	//如果失败,会revert        
    }
    
}

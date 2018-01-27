pragma solidity ^0.4.18;

import "./Owner.sol";

contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;

  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  modifier whenPaused {
    require(paused);
    _;
  }

  function pause() onlyOwner whenNotPaused returns (bool) {
    paused = true;
    Pause();
    return true;
  }

  function unpause() onlyOwner whenPaused returns (bool) {
    paused = false;
    Unpause();
    return true;
  }
}

contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract AdMainBasic {
    function clickAd(address media, address user, uint256 mediaValue, uint256 userValue) external returns (uint8);
    function withdraw(address beneficiary) external;
    function newContract(address owner) external;
    function isPaused() public returns (bool);
}

contract AdContract is Ownable {
    struct PriceObject {
        uint256 media_price;
        uint256 user_price;
    }
    mapping (address => bool) public users;
    mapping (address => PriceObject) public mediaBenefit;

    string public imageURL;
    string public linkURL;

    AdMainBasic public admain;

    function AdContract(address addr, string image, string link) public {
        admain = AdMainBasic(addr);
        require(!admain.isPaused());
        imageURL = image;
        linkURL = link;
        admain.newContract(msg.sender);
    }

    function getURL() view public returns (string, string) {
        return (imageURL, linkURL);
    }

    function adClick(address media) external returns (bool success){
        require(!admain.isPaused());
        address user = msg.sender;
        if (users[user] == false) {
            //new user
            uint256 media_price = mediaBenefit[media].media_price;
            uint256 user_price = mediaBenefit[media].user_price;
            uint256 state = admain.clickAd(media, user, media_price, user_price);
            if (state == 0) {
                users[user] = true;
                return true;
            } else {
                return false;
            }
        }else{
            //old user
            return false;
        }
    }
    function setPrice(address media, uint256 media_price, uint256 user_price) onlyOwner public {
        require(!admain.isPaused());
        mediaBenefit[media].media_price = media_price;
        mediaBenefit[media].user_price = user_price;
    }

    function withdrawAd() onlyOwner public {
        withdrawAd(msg.sender);
    }

    function withdrawAd(address addr) onlyOwner public {
        admain.withdraw(addr);
    }

}

contract AdMain is Pausable {

    event Click(address indexed media, address indexed user, uint256 mediaValue, uint256 userValue);

    event Transfer(address indexed from, address indexed media, address indexed user, uint256 mediaValue, uint256 userValue);

    event Withdraw(address indexed beneficiary, uint256 value);

    event Deposit(address indexed beneficiary, uint256 value);

    event NewContract(address indexed, address indexed);

    event ContractUpgrade(address newContract);

    event TokenUpgrade(address newToken);

    using SafeMath for uint256;

    mapping (address => bool) public users;
    mapping (address => address) public adContracts;
    mapping (address => uint256) public balances;
    address public newContractAddress;
    address public newTokenAddress;

    ERC20Basic public token;

    function AdMain() public {
        paused = true;
        token = ERC20Basic(address(0xf23805cace264d244d61d034c474b2c456be8c65));
    }

    function setNewERC20(address _erc20addr) external onlyOwner whenPaused {
        newTokenAddress = _erc20addr;
        token = ERC20Basic(newTokenAddress);
        TokenUpgrade(newTokenAddress);
    }

    function setNewAddress(address _v2Address) external onlyOwner whenPaused {
        newContractAddress = _v2Address;
        ContractUpgrade(_v2Address);
    }

    function setUser(address who) onlyOwner external {
        users[who] = true;
    }

    function resetUser(address who) onlyOwner external {
        users[who] = false;
    }

    function transfer(address from, address media, address user, uint256 mediaValue, uint256 userValue) internal returns (uint8){
        bool success = token.transfer(user, userValue);
        if (!success) {
            return 4;
        }

        balances[from] = balances[from].sub(userValue);
        balances[from] = balances[from].sub(mediaValue);
        balances[media] = balances[media].add(mediaValue);

        Transfer(from, media, user, mediaValue, userValue);
        return 0;
    }


    /**
     * 仅供合约之间调用，前端无需处理
     * 返回值含义：
     * 0, success
     * 1, invalid ad contract
     * 2, contract doesn't have enough token
     * 3, invalid user
     * 4, fail to send tokens to user (critical problem!!!)
     * */

    event Status(address indexed, uint8);
    function clickAd(address media, address user, uint256 mediaValue, uint256 userValue) whenNotPaused external returns (uint8) {
        address fromContract = msg.sender;

        if (adContracts[fromContract] == address(0x0)) {
            Status(fromContract, 1);
            return 1;
        }

        if (mediaValue.add(userValue) >= balances[fromContract]) {
            Status(fromContract, 2);
            return 2;
        }

        if (!users[user]) {
            Status(fromContract, 3);
            return 3;
        }
        //Click(media, user, mediaValue, userValue);

        uint8 result = transfer(fromContract, media, user, mediaValue, userValue);
        Status(fromContract, result);

        return result;
    }

    function newContract(address owner) whenNotPaused external {
        adContracts[msg.sender] = owner;

        NewContract(msg.sender, owner);
    }

    function deposit(address beneficiary, uint256 value) whenNotPaused external {
        bool success = token.transferFrom(msg.sender, address(this), value);
        require(success);

        balances[beneficiary] = balances[beneficiary].add(value);
        Deposit(beneficiary, value);
    }

    function withdraw() whenNotPaused public {
        withdraw(msg.sender);
    }

    function withdraw(address beneficiary) whenNotPaused public {
        uint256 value = balances[msg.sender];
        bool success = token.transfer(beneficiary, value);
        balances[msg.sender] = 0;

        require(success);
        Withdraw(beneficiary, value);
    }

    function unpause() public onlyOwner whenPaused returns (bool) {
      require(newContractAddress == address(0));
      require(newTokenAddress == address(0));
      super.unpause();
    }

    function isPaused() public returns (bool) {
        return paused;
    }
}

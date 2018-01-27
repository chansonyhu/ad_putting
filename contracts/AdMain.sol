pragma solidity ^0.4.18;

import "./Owner.sol";

contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  function transferFrom(address from, address to, uint256 value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract AdMainBasic {
    function clickAd(address media, address user, uint256 mediaValue, uint256 userValue) external returns (uint8);
    function withdraw(address beneficiary, uint256 value) external;
}

contract AdContract is Ownable {
    struct PriceObject {
        uint256 media_price;
        uint256 user_price;
    }
    mapping (address => bool) public users;
    mapping (address => PriceObject) public mediaBenefit;

    AdMainBasic public admain;

    function AdContract (address addr) {
        admain = AdMainBasic(addr);
    }

    function AdClick(address media) external returns (bool success) {
        address user = msg.sender;
        if (users[user] == false) {
            //new user
            users[user] = true;
            uint256 media_price = mediaBenefit[media].media_price;
            uint256 user_price = mediaBenefit[media].user_price;
            uint256 state = admain.clickAd(media, user, media_price, user_price);
            if (state == 1) {
                return true;
            } else {
                return false;
            }
        }else{
            //old user
            return false;
        }
    }
    function setPrice(address media, uint256 media_price, uint256 user_price) onlyOwner {
        mediaBenefit[media].media_price = media_price;
        mediaBenefit[media].user_price = user_price;
    }
    function withDraw(uint256 value) onlyOwner {
        admain.withdraw(msg.sender, value);
    }

    function withDraw(address addr, uint256 value) onlyOwner {
        admain.withdraw(addr, value);
    }

}

contract AdMain is Ownable {
    using SafeMath for uint256;

    mapping (address => bool) public users;
    mapping (address => address) public adContracts;
    mapping (address => uint256) public balances;

    ERC20Basic public token;

    function AdMain() public {
        token = ERC20Basic(address(0x27992a037756b7f1b5d024527b37df5fcd1258ef));
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
    function clickAd(address media, address user, uint256 mediaValue, uint256 userValue) external returns (uint8) {
        address fromContract = msg.sender;

        if (adContracts[msg.sender] == address(0x0)) {
            return 1;
        }

        if (mediaValue.add(userValue) >= balances[fromContract]) {
            return 2;
        }

        if (!users[user]) {
            return 3;
        }

        return transfer(fromContract, media, user, mediaValue, userValue);
    }

    function newContract() external {
        address adContract = new AdContract(address(this));
        adContracts[adContract] = msg.sender;
    }

    function deposit(address beneficiary, uint256 value) external {
        bool success = token.transferFrom(msg.sender, address(this), value);
        require(success);

        balances[beneficiary] = balances[beneficiary].add(value);
    }

    function withdraw(address beneficiary, uint256 value) external {
        require(balances[msg.sender] >= value);
        balances[msg.sender] = balances[msg.sender].sub(value);
        bool success = token.transfer(beneficiary, value);
        require(success);
    }

}

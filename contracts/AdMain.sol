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
    function withdraw(address beneficiary) external;
    function newContract(address owner) external;
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
        imageURL = image;
        linkURL = link;
        admain.newContract(msg.sender);
    }

    function getURL() view public returns (string, string) {
        return (imageURL, linkURL);
    }

    function adClick(address media) external returns (bool success){
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

contract AdMain is Ownable {

    event Click(address indexed media, address indexed user, uint256 mediaValue, uint256 userValue);

    event Transfer(address indexed from, address indexed media, address indexed user, uint256 mediaValue, uint256 userValue);

    event Withdraw(address indexed beneficiary, uint256 value);

    event Deposit(address indexed beneficiary, uint256 value);

    event NewContract(address indexed, address indexed);

    using SafeMath for uint256;

    mapping (address => bool) public users;
    mapping (address => address) public adContracts;
    mapping (address => uint256) public balances;

    ERC20Basic public token;

    function AdMain() public {
        token = ERC20Basic(address(0xf23805cace264d244d61d034c474b2c456be8c65));
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
        Click(media, user, mediaValue, userValue);
        return transfer(fromContract, media, user, mediaValue, userValue);
    }

    function newContract(address owner) external {
        adContracts[msg.sender] = owner;

        NewContract(msg.sender, owner);
    }

    function deposit(address beneficiary, uint256 value) external {
        bool success = token.transferFrom(msg.sender, address(this), value);
        require(success);

        balances[beneficiary] = balances[beneficiary].add(value);
        Deposit(beneficiary, value);
    }

    function withdraw() public {
        withdraw(msg.sender);
    }

    function withdraw(address beneficiary) public {
        uint256 value = balances[msg.sender];
        bool success = token.transfer(beneficiary, value);
        balances[msg.sender] = 0;

        require(success);
        Withdraw(beneficiary, value);
    }
}

pragma solidity ^0.4.18;
import './Owner.sol';
contract AdMain{
    function clickAd(address media, address user, uint256 mediaValue, uint256 userValue) external returns (uint8);
    function withdraw(address beneficiary, uint256 value) external;
}

contract AdContract is Ownable{
    struct priceObject{
        uint256 media_price;
        uint256 user_price;
    }
    mapping (address => bool) public users;
    mapping (address => priceObject) public mediaBenefit;

    AdMain public admain;

    function AdContract(address addr){
        admain = AdMain(addr);
    }

    function AdClick(address media) external returns (bool success) {
        address user = msg.sender;
        if(users[user] == false){
            //new user
            users[user] = true;
            uint256 media_price = mediaBenefit[media].media_price;
            uint256 user_price = mediaBenefit[media].user_price;
            uint256 state = admain.clickAd(media, user, media_price, user_price);
            if(state == 1){
                return true;
            }else{
                return false;
            }
        }else{
            //old user
            return false;
        }
    }
    function setPrice(address media, uint256 media_price, uint256 user_price)onlyOwner{
        mediaBenefit[media].media_price = media_price;
        mediaBenefit[media].user_price = user_price;
    }
    function withDraw(uint256 value)onlyOwner{
        admain.withdraw(msg.sender, value);
    }

    function withDraw(address addr, uint256 value)onlyOwner{
        admain.withdraw(addr, value);
    }

}

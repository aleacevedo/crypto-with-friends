pragma solidity ^0.7.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract FriendFactory is Ownable {
    using SafeMath for uint256;
    using Address for address;

    event NewFriend(uint256 friendId);

    struct Friend {
        uint256 yBalance;
        uint256 available;
        bool disable;
    }

    Friend[] public friends;

    mapping(address => Friend) ownerToFriend;

    uint256 public totalAvailable;
    uint256 public totalYBalance;

    function _createFriend() internal {
        uint256 id = friends.push(Friend(0, 0, false)) - 1;
        ownerToFriend[msg.sender] = Friend(0, 0, false);
        emit NewFriend(id);
    }

    function _getFriendOf(address _owner) private returns (Friend) {
        return friends[ownerToFriend[_owner]];
    }

    function _friend() internal returns (Friend) {
        return _getFriendOf(msg.sender);
    }
}

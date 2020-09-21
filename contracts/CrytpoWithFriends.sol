pragma solidity ^0.7.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./FriendFactory.sol";

interface Vault is IERC20 {
    function getPricePerFullShare() public view returns (uint256);

    function deposit(uint256 _amount) public;

    function withdraw(uint256 _shares) public;
}

contract CrytpoWithFriends is FriendFactory {
    using Address for address;
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 public token;
    Vault public vault;

    address public constant dai = address(
        0x6B175474E89094C44Da98b954EedeAC495271d0F
    );
    address public constant yVault = address(
        0xACd43E627e64355f1861cEC6d3a6688B31a6F952
    );

    uint256 minInvest = 1000;

    constructor() public {
        token = IERC(dai);
        vault = Vault(yVault);
    }

    function deposit(uint256 _amount) external {
        if (!_friend()) {
            _createFrined();
        }
        token.safeTransferFrom(msg.sender, address(this), _amount);
        _friend().available = _friend().available.add(_ammount);
        totalAvailable = totalAvailable.add(_ammount);
    }

    function invest() external onlyOwner {
        require(totalAvailable > minInvest, "minInvset");
        token.approve(yVault, totalAvailable);
        vault.deposit(totalAvailable);
        _invested(vault.balanceOf(address(this)));
    }

    function _invested(uint256 _share) private {
        totalYBalance = totalYBalance.add(share);
        for (uint256 index; index < friends.length; index++) {
            uint256 _percentage = friends[index].available.div(totalAvailable);
            friends[index].yBalance = friends[index].yBalance.add(
                _percentage.mul(_share)
            );
            friends[index].available = 0;
        }
        totalAvailable = 0;
    }

    function withdraw(uint256 _amount) external {
        uint256 _yBalance = _friend().balance;
        uint256 _available = _friend().available;
        uint265 _yPrice = vault.getPricePerFullShare();
        require(
            _available.add(_ybalance.mul(_yPrice)) >= _amount,
            "friend with not enought money"
        );
        if (_amount > available) {
            vault.withdraw(_amount.sub(_available).div(_yPrice));
        }
        token.safeTransferFrom(address(this), msg.sender, _amount);
    }

    function withdrawAll() external onlyOwner {
        uint256 _pricePerShare = vault.getPricePerFullShare();
        vault.withdraw(totalYBalance);
        for (uint256 index; index < friends.length; index++) {
            uint256 _friendAvailable = friends[index].available.add(
                friend[index].yBalance.mul(_pricePerShare)
            );
            token.safeTransferFrom(address(this), _friendAvailable);
            friends[index].available = 0;
            friends[index].yBalance = 0;
        }
        totalAvailable = 0;
        totalYBalance = 0;
    }
}

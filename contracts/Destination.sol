// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "./lzApp/NonblockingLzApp.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/IStargateRouter.sol";
import "../node_modules/@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";


contract Destination is NonblockingLzApp {
    using SafeMath for uint256;

    event Deposit(address indexed user, uint256 amount);
    event Claim(
        address indexed user,
        uint256 offeringAmount,
        uint256 excessAmount
    );


    // Info of each user.
    struct UserInfo {
        uint256 amount; // How many tokens the user has provided.
        bool claimed; // default false
    }

    IStargateRouter public stargateRouter;
    // The raising token
    IERC20 public usdc;
    // The offering token
    IERC20 public offeringToken;
    // The timestamp the IDO starts
    uint256 public startTime;
    // The timestamp when IDO ends
    uint256 public endTime;
    // total amount of raising tokens need to be raised
    uint256 public raisingAmount;
    // total amount of offeringToken that will offer
    uint256 public offeringAmount;
    // total amount of raising tokens that have already raised
    uint256 public totalAmount;
    // address => amount
    mapping(address => UserInfo) public userInfo;
    // participators
    address[] public addressList;
    
    // min amount every account
    uint256 public minAmount;

    constructor(
        address _lzEndpoint,
        address _stargateRouter
    ) NonblockingLzApp(_lzEndpoint) {
        stargateRouter = IStargateRouter(_stargateRouter);
    }

    function initialize(
        IERC20 _token,
        IERC20 _offeringToken,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _offeringAmount,
        uint256 _raisingAmount,
        uint256 _minAmount
    ) public onlyOwner {
        usdc = _token;
        offeringToken = _offeringToken;
        startTime = _startTime;
        endTime = _endTime;
        offeringAmount = _offeringAmount;
        raisingAmount = _raisingAmount;
        totalAmount = 0;
        minAmount = _minAmount;
    }

    function setMinAmount(uint256 _minAmount) public onlyOwner {
        minAmount = _minAmount;
    }

    function setOfferingAmount(uint256 _offerAmount) public onlyOwner {
        require(block.timestamp < startTime, "no");
        offeringAmount = _offerAmount;
    }

    function setRaisingAmount(uint256 _raisingAmount) public onlyOwner {
        require(block.timestamp < startTime, "no");
        raisingAmount = _raisingAmount;
    }

    function deposit(uint256 _amount) public {
        require(
            block.timestamp > startTime && block.timestamp < endTime,
            "not ido time"
        );
        require(_amount > 0, "need _amount > 0");
        require(_amount >= minAmount, "_amount < minAmoun");

        usdc.transferFrom(address(msg.sender), address(this), _amount);
        if (userInfo[msg.sender].amount == 0) {
            addressList.push(address(msg.sender));
        }
        userInfo[msg.sender].amount = userInfo[msg.sender].amount.add(_amount);
        totalAmount = totalAmount.add(_amount);

        emit Deposit(msg.sender, _amount);
    }

    function omniDeposit(uint256 _amount, address _depositor) public {
        require(
            block.timestamp > startTime && block.timestamp < endTime,
            "not ido time"
        );
        require(_amount > 0, "need _amount > 0");
        require(_amount >= minAmount, "_amount < minAmoun");

        if (userInfo[_depositor].amount == 0) {
            addressList.push(address(_depositor));
        }
        userInfo[_depositor].amount = userInfo[_depositor].amount.add(_amount);
        totalAmount = totalAmount.add(_amount);

        emit Deposit(_depositor, _amount);
    }

    function claim(address _user) public {
        require(block.timestamp > endTime, "not claim time");
        require(userInfo[_user].amount > 0, "have you participated?");
        require(!userInfo[_user].claimed, "nothing to claim");
        userInfo[_user].claimed = true;
        uint256 offeringTokenAmount = getOfferingAmount(_user);
        uint256 refundingTokenAmount = getRefundingAmount(_user);
        if (offeringTokenAmount > 0) {
            offeringToken.transfer(
                address(_user),
                offeringTokenAmount
            );
        }
        if (refundingTokenAmount > 0) {
            usdc.transfer(address(_user), refundingTokenAmount);
        }

        emit Claim(_user, offeringTokenAmount, refundingTokenAmount);
    }

    function hasClaimed(address _user) external view returns (bool) {
        return userInfo[_user].claimed;
    }


    // allocation 100000 - 0.1(10%), 1 - 0.000001(0.0001%), 1000000 - 1(100%)
    function getUserAllocation(address _user) public view returns (uint256) {
        return userInfo[_user].amount.mul(1e12).div(totalAmount).div(1e6);
    }

    // get the amount of IDO token you will get
    function getOfferingAmount(address _user) public view returns (uint256) {
        if (totalAmount > raisingAmount) {
            uint256 allocation = getUserAllocation(_user);
            return offeringAmount.mul(allocation).div(1e6);
        } else {
            return
                userInfo[_user].amount.mul(offeringAmount).div(raisingAmount);
        }
    }

    // get the amount of lp token you will be refunded
    function getRefundingAmount(address _user) public view returns (uint256) {
        if (totalAmount <= raisingAmount) {
            return 0;
        }
        uint256 allocation = getUserAllocation(_user);
        uint256 payAmount = raisingAmount.mul(allocation).div(1e6);
        return userInfo[_user].amount.sub(payAmount);
    }

    function getAddressListLength() external view returns (uint256) {
        return addressList.length;
    }

    function finalWithdraw(uint256 _lpAmount, uint256 _offerAmount)
        public
        onlyOwner
    {
        require(
            _lpAmount <= usdc.balanceOf(address(this)),
            "not enough token 0"
        );
        require(
            _offerAmount <= offeringToken.balanceOf(address(this)),
            "not enough token 1"
        );
        if (_offerAmount > 0) {
            offeringToken.transfer(address(msg.sender), _offerAmount);
        }
        if (_lpAmount > 0) {
            usdc.transfer(address(msg.sender), _lpAmount);
        }
    }

    function _nonblockingLzReceive(
        uint16 _srcChainId, 
        bytes memory _srcAddress, 
        uint64 _nonce, 
        bytes memory _payload
    ) internal override {
        (address _depositor) = abi.decode(_payload, (address));
        claim(_depositor);
    }

    function sgReceive(
        uint16 _chainId, 
        bytes memory _srcAddress, 
        uint _nonce, 
        address _token, 
        uint amountLD, 
        bytes memory _payload
    ) external {
        require(msg.sender == address(stargateRouter), "Unauthorized");
        require(_token == address(usdc), "not raise token");
        
        (address _depositor) = abi.decode(_payload, (address));

        omniDeposit(amountLD, _depositor);
    }
}
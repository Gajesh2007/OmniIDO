// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "./lzApp/NonblockingLzApp.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/IStargateRouter.sol";
import "../node_modules/@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";


contract Source is NonblockingLzApp {
    using SafeMath for uint256;

    uint256 constant MAX_INT = 115792089237316195423570985008687907853269984665640564039457584007913129639935;
    // Info of each user.
    struct UserInfo {
        uint256 amount; // How many tokens the user has provided.
        bool claimed; // default false
    }

    IStargateRouter public stargateRouter;
    // Address of Destination contract where all the money will be sent
    address public destination;
    // The raising token
    IERC20 public usdc;
    // The timestamp the IDO starts
    uint256 public startTime;
    // The timestamp when IDO ends
    uint256 public endTime;
    // Chain id of Destination Chain
    uint16 dstChainId;
    // Chain id of Source Chain
    uint256 srcPoolId;
    // Pool id of the Destination Chain
    uint256 dstPoolId;
    // min amount to deposit
    uint256 public minAmount;

    constructor(
        address _lzEndpoint,
        address _stargateRouter,
        uint16 _dstChainId,
        uint256 _srcPoolId,
        uint256 _dstPoolId,
        IERC20 _usdc,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _minAmount
    ) NonblockingLzApp(_lzEndpoint) {
        stargateRouter = IStargateRouter(_stargateRouter);
        dstChainId = _dstChainId;
        srcPoolId = _srcPoolId;
        dstPoolId = _dstPoolId;
        usdc = _usdc;
        startTime = _startTime;
        endTime = _endTime;
        minAmount = _minAmount;
    }

    function setMinAmount(uint256 _minAmount) public onlyOwner {
        minAmount = _minAmount;
    }

    function deposit(uint256 _amount) public payable {
        require(
            block.timestamp > startTime && block.timestamp < endTime,
            "not ido time"
        );
        require(_amount > 0, "need _amount > 0");
        require(_amount >= minAmount, "_amount < minAmoun");
        require(msg.value > 0, "stargate requires fee to pay crosschain message");

        usdc.transferFrom(address(msg.sender), address(this), _amount);
        
        bytes memory data = abi.encode(msg.sender);

        usdc.approve(address(stargateRouter), MAX_INT);

        // Stargate's Router.swap() function sends the tokens to the destination chain.
        stargateRouter.swap{value:msg.value}(
            dstChainId,                                     // the destination chain id
            srcPoolId,                                      // the source Stargate poolId
            dstPoolId,                                      // the destination Stargate poolId
            payable(msg.sender),                            // refund adddress. if msg.sender pays too much gas, return extra eth
            _amount,                                        // total tokens to send to destination chain
            0,                                              // min amount allowed out
            IStargateRouter.lzTxObj(200000, 0, "0x"),       // default lzTxObj
            abi.encodePacked(destination),                   // destination address 
            data                                            // bytes payload
        );
    }

    function claim(address _user) public payable {
        require(block.timestamp > endTime, "not claim time");
        require(msg.value > 0, "lz requires fee to pay crosschain message");

        bytes memory data = abi.encode(_user);

        _lzSend(
            dstChainId, 
            data, 
            payable(_user), 
            address(0x0), 
            bytes(""),
            msg.value
        );
    }

    function _nonblockingLzReceive(
        uint16 _srcChainId, 
        bytes memory _srcAddress, 
        uint64 _nonce, 
        bytes memory _payload
    ) internal override {

    }
}
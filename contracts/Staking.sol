// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import "../node_modules/@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../node_modules/@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Staking {

    /*  
        ==============================================
        === STATE VARIABLES, EVENTS & CONTSTRUCTOR ===
        ==============================================
    */

    bool internal locked; // reentrancy lock

    // Libraries
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    address public owner;

    // Timestamps
    uint256 public initialTimestamp;
    bool public timestampSet;
    uint256 public timePeriod;

    // Balances
    // mapping(address => uint256) public alreadyWithdrawn;
    mapping(address => uint256) public balances;
    // uint256 public contractBalance;

    // Stakable token
    IERC20 public erc20Contract;

    // Events
    event TokensStaked(address from, uint256 amount);
    event TokensUnstaked(address to, uint256 amount);

    // Constructor
    constructor(IERC20 _erc20_contract_address) {
        owner = msg.sender;
        timestampSet = false;
        require(address(_erc20_contract_address) != address(0), "Can't be zero address");
        erc20Contract = _erc20_contract_address;
        locked = false;
    }

    /*  
        =============================================
        ================= FUNCTIONS =================
        =============================================
    */

    // Minimum staking period (set by owner)
    function setTimestamp(uint256 _timePeriodInSeconds) public onlyOwner timestampNotSet {
        timestampSet = true;
        initialTimestamp = block.timestamp;
        timePeriod = initialTimestamp.add(_timePeriodInSeconds);
    }
    
    // Stake tokens
    function stakeTokens(IERC20 token, uint256 amount) public timestampIsSet noReentrant {
        require(token == erc20Contract, "Only the ERC20 token contract approved by the owner can be staked");
        require(amount <= token.balanceOf(msg.sender), "You do not have enought tokens to stake, try a lower amount");
        token.safeTransferFrom(msg.sender, address(this), amount);
        balances[msg.sender] = balances[msg.sender].add(amount);
        emit TokensStaked(msg.sender, amount);
    }

    function unstakeTokens(IERC20 token, uint256 amount) public timestampIsSet noReentrant {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        require(token == erc20Contract, "Incorrect token parameter passed in, it must be the same as the staked tokens");
        if(block.timestamp >= timePeriod) {
            // alreadyWithdrawn[msg.sender] = alreadyWithdrawn[msg.sender].add(amount);
            balances[msg.sender] = balances[msg.sender].sub(amount);
            token.safeTransfer(msg.sender, amount);
            emit TokensUnstaked(msg.sender, amount);
        } else {
            revert("Tokens can't be unstaked until the timePeriod has passed");
        }
    }

    // function transferAccidentallyLockedTokens(IERC20 token, uint256 amount) public onlyOwner noReentrant {
    //     require(address(token) != address(0), "Token address can't be zero");
    //     require(token != erc20Contract, "Can't be the official staking token of this contract");
    //     token.safeTransfer(owner, amount);
    // }

    /*  
        =============================================
        ================= MODIFIERS =================
        =============================================
    */ 

    modifier noReentrant() {
        require(!locked, "Reentrancy not allowed");
        locked = true;
        _;
        locked = false;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Can only be accessed by the owner");
        _;
    }

    modifier timestampNotSet() {
        require(timestampSet == false, "Timestamp already set");
        _;
    }

    modifier timestampIsSet() {
        require(timestampSet == true, "Set the timestamp first");
        _;
    }

}
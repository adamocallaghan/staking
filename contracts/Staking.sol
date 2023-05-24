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
    mapping(address => uint256) public alreadyWithdrawn;
    mapping(address => uint256) public balances;
    uint256 public contractBalance;

    // Stakable token
    IERC20 public erc20Contract;

    // Events
    event tokensStaked(address from, uint256 amount);
    event tokensUnstaked(address to, uint256 amount);

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
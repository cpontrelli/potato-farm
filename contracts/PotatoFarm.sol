// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./PotatoToken.sol";

contract TokenFarm {

    mapping(address => uint256) public stakingBalance;
    mapping(address => bool) public isStaking;
    mapping(address => uint256) public startTime;
    mapping(address => uint256) public potatoBalance;

    PotatoToken public potatoToken;
    uint256 ratio;

    constructor(PotatoToken _potatoToken, uint256 _ratio) {
            potatoToken = _potatoToken;
            ratio = _ratio;
        }

    function stake() external payable {
        require(msg.value > 0, "You cannot stake zero tokens");
            
        if(isStaking[msg.sender] == true){
            uint256 toTransfer = calculateYieldTotal(msg.sender);
            potatoBalance[msg.sender] += toTransfer;
        }

        stakingBalance[msg.sender] += msg.value;
        startTime[msg.sender] = block.timestamp;
        isStaking[msg.sender] = true;
    }

    function unstake(uint256 amount) external {
        require(
            isStaking[msg.sender] = true &&
            stakingBalance[msg.sender] >= amount, 
            "Nothing to unstake"
        );
        uint256 yieldTransfer = calculateYieldTotal(msg.sender);
        startTime[msg.sender] = block.timestamp;
        uint256 balanceTransfer = amount;
        amount = 0;
        stakingBalance[msg.sender] -= balanceTransfer;
        payable(msg.sender).transfer(balanceTransfer);
        potatoBalance[msg.sender] += yieldTransfer;
        if(stakingBalance[msg.sender] == 0){
            isStaking[msg.sender] = false;
        }
    }

    function withdrawYield() public {
        uint256 toTransfer = calculateYieldTotal(msg.sender);

        require(
            toTransfer > 0 ||
            potatoBalance[msg.sender] > 0,
            "Nothing to withdraw"
            );
            
        if(potatoBalance[msg.sender] != 0){
            uint256 oldBalance = potatoBalance[msg.sender];
            potatoBalance[msg.sender] = 0;
            toTransfer += oldBalance;
        }

        startTime[msg.sender] = block.timestamp;
        potatoToken.mint(msg.sender, toTransfer);
    }

    function calculateYieldTime(address user) public view returns(uint256){
        uint256 end = block.timestamp;
        uint256 totalTime = end - startTime[user];
        return totalTime;
    }

    function calculateYieldTotal(address user) public view returns(uint256) {
        uint256 time = calculateYieldTime(user) * 10**18;
        uint256 rate = 86400 * ratio;
        uint256 timeRate = time / rate;
        uint256 rawYield = (stakingBalance[user] * timeRate) / 10**18;
        return rawYield;
    }
}
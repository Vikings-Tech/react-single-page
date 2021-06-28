// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "@chainlink/contracts/src/v0.6/VRFConsumerBase.sol";



contract RandomGame is VRFConsumerBase  {
    
    bytes32 internal keyHash;
    uint256 internal fee;
    
    address private _owner;

    uint256 private endTime;
    
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event RandomnessFulfilled(address indexed player,randomData playerData,bytes32 requestId);
    event PayoutFulfilled(address indexed player,uint256 payoutAmount);
    mapping(address=>randomData[]) randomResult;
    
    
    struct randomData{
        bytes32 requestId;
        uint256 randomness;
        uint256 payoutAmount;
    }
    
    uint256 lockedAmount;
    

    /**
     * Constructor inherits VRFConsumerBase
     * 
     * Network: Mumbai Testnet
     * Chainlink VRF Coordinator address: 0x8C7382F9D8f56b33781fE506E897a4F1e2d17255
     * LINK token address:                0x326C977E6efc84E512bB9C30f76E30c160eD06FB
     * Key Hash: 0x6e75b569a01ef56d18cab6a8e71e6600d6ce853834d4a5748b720d06f878b3a4
     */
    constructor() 
        VRFConsumerBase(
            0x8C7382F9D8f56b33781fE506E897a4F1e2d17255, // VRF Coordinator
            0x326C977E6efc84E512bB9C30f76E30c160eD06FB  // LINK Token
        ) public
    {
        endTime = 15 * 1 days;
        keyHash = 0x6e75b569a01ef56d18cab6a8e71e6600d6ce853834d4a5748b720d06f878b3a4;
        fee = 0.0001 * 10 ** 18; // 0.0001 LINK (varies by network)
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
        
    }
    
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
    
    function getRandomNumber() public returns (bytes32 requestId)  {
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK - fill contract with faucet");
        bytes32 reqId = requestRandomness(keyHash, fee); 
        return reqId;
    }

    /**
     * Callback function used by VRF Coordinator
     */
     
    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override{
        randomData memory data;
        data.randomness = randomness%1329;
        data.requestId = requestId;
        //If lucky we want to lock the amount they are supposed to receive
        if(data.randomness == 7)
        {data.payoutAmount = address(this).balance - lockedAmount;
            lockedAmount = address(this).balance;
        }
        else{
            data.payoutAmount = 0;}
        randomResult[msg.sender].push(data);
        emit RandomnessFulfilled(msg.sender,data,requestId);
        
    }
    
    function gamble() public payable{
        require(msg.value == 0.05 ether,"Game : Value doesn't match requested amount" );
        getRandomNumber();
    }
    
    function payout() public {
        require(randomResult[msg.sender].length != 0,"No New Result available");
        uint256 length = randomResult[msg.sender].length;
        if(randomResult[msg.sender][length-1].payoutAmount == 0){
            emit PayoutFulfilled(msg.sender,randomResult[msg.sender][length-1].payoutAmount);
            randomResult[msg.sender].pop();
            return;
        }
        uint256 payoutAmount = randomResult[msg.sender][length-1].payoutAmount;
        randomResult[msg.sender][length-1].payoutAmount = 0;
        lockedAmount -= payoutAmount;
        payable(msg.sender).transfer(payoutAmount);
        
        emit PayoutFulfilled(msg.sender,payoutAmount);
        randomResult[msg.sender].pop();
    
    }
    
    function getPendingResults() external view returns(randomData[] memory){
        return randomResult[msg.sender];
    }
    

    function endContract() external onlyOwner{
        require(now>=endTime,"Its not that time yet !");
        uint256 tokenBalance = LINK.balanceOf(address(this));
        
        if(tokenBalance>0){
            LINK.transfer(_owner,tokenBalance);
        }
        selfdestruct(payable(_owner));
    }
    
    
    
    
    
}
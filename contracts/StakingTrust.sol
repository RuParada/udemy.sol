pragma solidity ^0.4.22;


library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

contract ERC20 {
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract Staking  {
    using SafeMath for uint;
    
    uint BIGNUMBER = 10**18;
    uint DECIMAL = 10**3;

    struct stakingInfo {
        uint amount;
        bool requested;
        uint releaseDate;
    }
    
    
    //allowed token addresses
    mapping (address => bool) public allowedTokens;
    

    mapping (address => mapping(address => stakingInfo)) public StakeMap; //tokenAddr to user to stake amount
    mapping (address => mapping(address => uint)) public userCummRewardPerStake; //tokenAddr to user to remaining claimable amount per stake
    mapping (address => uint) public tokenCummRewardPerStake; //tokenAddr to cummulative per token reward since the beginning or time
    mapping (address => uint) public tokenTotalStaked; //tokenAddr to total token claimed 
    
    mapping (address => address) public Mediator;
    
    
    modifier isValidToken(address _tokenAddr){
        require(allowedTokens[_tokenAddr]);
        _;
    }
    modifier isMediator(address _tokenAddr){
        require(Mediator[_tokenAddr] == msg.sender);
        _;
    }

    address public StakeTokenAddr;
    
    
    constructor(address _tokenAddr) public{
        StakeTokenAddr= _tokenAddr;
    }
    
    
    /**
    * @dev add approved token address to the mapping 
    */
    
    function addToken( address _tokenAddr) onlyOwner external {
        allowedTokens[_tokenAddr] = true;
    }
    
    /**
    * @dev remove approved token address from the mapping 
    */
    function removeToken( address _tokenAddr) onlyOwner external {
        allowedTokens[_tokenAddr] = false;
    }

    /**
    * @dev stake a specific amount to a token
    * @param _amount the amount to be staked
    * @param _tokenAddr the token the user wish to stake on
    * for demo purposes, not requiring user to actually send in tokens right now
    */
    
    function stake(uint _amount, address _tokenAddr) isValidToken(_tokenAddr) external returns (bool){
        require(_amount != 0);
        //require(ERC20(StakeTokenAddr).transferFrom(msg.sender,this,_amount));
        
        if (StakeMap[_tokenAddr][msg.sender].amount ==0){
            StakeMap[_tokenAddr][msg.sender].amount = _amount;
            userCummRewardPerStake[_tokenAddr][msg.sender] = tokenCummRewardPerStake[_tokenAddr];
        }else{
            claim(_tokenAddr, msg.sender);
            StakeMap[_tokenAddr][msg.sender].amount = StakeMap[_tokenAddr][msg.sender].amount.add( _amount);
        }
        tokenTotalStaked[_tokenAddr] = tokenTotalStaked[_tokenAddr].add(_amount);
        return true;
    }
    
    
    /**
     * demo version
    * @dev pay out dividends to stakers, update how much per token each staker can claim
    * @param _reward the aggregate amount to be send to all stakers
    * @param _tokenAddr the token that this dividend gets paied out in
    */
    function distribute(uint _reward,address _tokenAddr) isValidToken(_tokenAddr) external returns (bool){
        require(tokenTotalStaked[_tokenAddr] != 0);
        uint reward = _reward.mul(BIGNUMBER); //simulate floating point operations
        uint rewardAddedPerToken = reward/tokenTotalStaked[_tokenAddr];
        tokenCummRewardPerStake[_tokenAddr] = tokenCummRewardPerStake[_tokenAddr].add(rewardAddedPerToken);
        return true;
    }
    
    
    
    
    // /**
    // * production version
    // * @dev pay out dividends to stakers, update how much per token each staker can claim
    // * @param _reward the aggregate amount to be send to all stakers
    // */
    
    // function distribute(uint _reward) isValidToken(msg.sender) external returns (bool){
    //     require(tokenTotalStaked[msg.sender] != 0);
    //     uint reward = _reward.mul(BIGNUMBER);
    //     tokenCummRewardPerStake[msg.sender] += reward/tokenTotalStaked[msg.sender];
    //     return true;
    // } 
    
    
    event claimed(uint amount);
    /**
    * @dev claim dividends for a particular token that user has stake in
    * @param _tokenAddr the token that the claim is made on
    * @param _receiver the address which the claim is paid to
    */
    function claim(address _tokenAddr, address _receiver) isValidToken(_tokenAddr)  public returns (uint) {
        uint stakedAmount = StakeMap[_tokenAddr][msg.sender].amount;
        //the amount per token for this user for this claim
        uint amountOwedPerToken = tokenCummRewardPerStake[_tokenAddr].sub(userCummRewardPerStake[_tokenAddr][msg.sender]);
        uint claimableAmount = stakedAmount.mul(amountOwedPerToken); //total amoun that can be claimed by this user
        claimableAmount = claimableAmount.mul(DECIMAL); //simulate floating point operations
        claimableAmount = claimableAmount.div(BIGNUMBER); //simulate floating point operations
        userCummRewardPerStake[_tokenAddr][msg.sender]=tokenCummRewardPerStake[_tokenAddr];
        // if (_receiver == address(0)){
        //     require(ERC20(_tokenAddr).transfer(msg.sender,claimableAmount));
        // }else{
        //     require(ERC20(_tokenAddr).transfer(_receiver,claimableAmount));
        // }
        emit claimed(claimableAmount);
        return claimableAmount;

    }
    
    
    /**
    * @dev request to withdraw stake from a particular token, must wait 4 weeks
    */
    function initWithdraw(address _tokenAddr) isValidToken(_tokenAddr)  external returns (bool){
        require(StakeMap[_tokenAddr][msg.sender].amount >0 );
        require(! StakeMap[_tokenAddr][msg.sender].requested );
        StakeMap[_tokenAddr][msg.sender].releaseDate = now + 4 weeks;
        return true;

    }
    
    
    /**
    * @dev finalize withdraw of stake
    */
    function finalizeWithdraw(uint _amount, address _tokenAddr) isValidToken(_tokenAddr)  external returns(bool){
        require(StakeMap[_tokenAddr][msg.sender].amount >0 );
        require(StakeMap[_tokenAddr][msg.sender].requested );
        require(now > StakeMap[_tokenAddr][msg.sender].releaseDate );
        claim(_tokenAddr, msg.sender);
        require(ERC20(_tokenAddr).transfer(msg.sender,_amount));
        tokenTotalStaked[_tokenAddr] = tokenTotalStaked[_tokenAddr].sub(_amount);
        StakeMap[_tokenAddr][msg.sender].requested = false;
        return true;
    }
    
    function releaseStake(address _tokenAddr, address[] _stakers, uint[] _amounts,address _dest) isMediator(_tokenAddr) isValidToken(_tokenAddr) constant external returns (bool){
        require(_stakers.length == _amounts.length);
        for (uint i =0; i< _stakers.length; i++){
            require(ERC20(_tokenAddr).transfer(_dest,_amounts[i]));
            StakeMap[_tokenAddr][_stakers[i]].amount -= _amounts[i];
        }
        return true;
        
    }
}
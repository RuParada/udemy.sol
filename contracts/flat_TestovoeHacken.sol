
/** 
 *  SourceUnit: /Users/ruslan/token/udemy.sol/contracts/TestovoeHacken.sol
*/

////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
pragma solidity ^0.8.0;

////import "@openzeppelin/contracts/access/Ownable.sol";
////import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
////import "@openzeppelin/contracts/security/Pausable.sol";
////import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
////import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
////import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract AutoCompoundFarm is ReentrancyGuard, Pausable, Ownable {

    using SafeMath for uint;
    using SafeERC20 for IERC20;
    
    struct UserInfo {
        uint amount;
        uint divisor;
        uint pastPending;
    }

    IERC20 public immutable krw;
    bool public multiplierIsMaxed;
    uint public dailyBlocks;
    uint public totalStaked;
    uint public totalPending;
    uint public multiplier;
    uint16 public fee;
    uint public targetDailyCompoundRate;
    uint public maxRewardsPerBlock;
    uint public rewardsPerBlock;
    uint public lastRewardBlock;
    uint public finalBlock;
    address public vault;
    mapping(address => UserInfo) public stakes;

    event Deposit(address indexed user, uint amount);
    event Withdraw(address indexed user, uint amount);
    event Claim(address indexed user, uint amount);
    event EmergencyWithdraw(address indexed user, uint amount);
    
    /**
     * @dev initialise the autocompounding farm. Fee defaults to zero
     * @param _krw contract address for krown
     * @param _vault address to send fees to
     * @param _maxRewardsPerBlock the maximum amount of krown rewards to be distributed per block
     * @param _targetDailyCompoundRate the daily compounding rate used to determine the amount of krown rewards per block
     */
    constructor(
        address _krw, 
        address _vault, 
        uint _maxRewardsPerBlock, 
        uint _targetDailyCompoundRate
    ) {

        krw = IERC20(_krw);
        multiplierIsMaxed = false;
        dailyBlocks = 1e18 * 20 * 60 * 24; // Based on 3 second per block on BSC
        totalStaked = 0;
        totalPending = 0;
        multiplier = 1e18;
        fee = 0;
        targetDailyCompoundRate = _targetDailyCompoundRate;
        maxRewardsPerBlock = _maxRewardsPerBlock;
        rewardsPerBlock = 0;
        lastRewardBlock = block.number;
        finalBlock = type(uint).max;
        vault = _vault;
        
    }

    /// @dev retrieves the amount deposited by the user
    function getDeposit(address account) external view returns(uint) {
        return stakes[account].amount;
    }

    /// @dev calculates and returns the APY
    function getAPY() external view returns(uint) {
        return totalStaked == 0 ? 0 : (rewardsPerBlock * dailyBlocks * 365) / (totalStaked + totalPending);
    }

    /// @dev updates the daily blocks variable
    /// @param _dailyBlocks the expected number of blocks to be mined per day
    function changeDailyBlocks(uint _dailyBlocks) external onlyOwner {
        dailyBlocks = _dailyBlocks;
    }

    /// @dev updates the final block variable
    /// @param _finalBlock the block number after which reward distribution will halt
    function changeFinalBlock(uint _finalBlock) external onlyOwner {
        finalBlock = _finalBlock;
    }

    /// @dev updates the fee variable
    /// @param _fee the % fee for depositing e.g. 100 = 1%
    function changeFee(uint16 _fee) public onlyOwner {
        require(_fee <= 10000, "Invalid fee");
        fee = _fee;
    }

    /// @dev updates the maximum rewards per block variable
    /// @param _maxRewardsPerBlock the maximum amount of the token to be distributed per block
    function changeMaxRewardsPerBlock(uint _maxRewardsPerBlock) external onlyOwner {
        maxRewardsPerBlock = _maxRewardsPerBlock;
    }

    /// @dev updates the daily compound rate target variable
    /// @param _targetDailyCompoundRate the daily compounding rate used to determine the amount of krown rewards per block
    function changeTargetDailyCompoundRate(uint _targetDailyCompoundRate) external onlyOwner {
        require(_targetDailyCompoundRate > 1e18, "Target compound rate must be greater than 1 ether");
        targetDailyCompoundRate = _targetDailyCompoundRate;
    }

    /// @dev updates the vault address variable
    /// @param _vault address to send fees to
    function changeVault(address _vault) external onlyOwner {
        vault = _vault;
    }

    /// @dev deposits tokens into the farm
    /// @param amount the amount of tokens to deposit
    function deposit(uint amount) external whenNotPaused nonReentrant {
        require(amount >= 1e18, "Must deposit at least 1 KRW");

        update(); // distribute rewards
        krw.safeTransferFrom(msg.sender, address(this), amount);

        // subtract fee
        if (fee != 0) {
            uint feeAmount = (amount * fee) / 10000;
            krw.safeTransfer(address(vault), feeAmount);
            amount -= feeAmount;
        }

        // update user stake information
        UserInfo storage user = stakes[msg.sender];
        user.pastPending = getPending(msg.sender);
        user.divisor = multiplier;
        user.amount += amount;
        totalStaked += amount;

        emit Deposit(msg.sender, amount);
    }    
    
    /// @dev withdraw tokens from the farm
    /// @param amount the amount of tokens to withdraw
    function withdraw(uint amount) public nonReentrant  {
        require(amount > 0, 'Amount must be larger than 0.');
        require(stakes[msg.sender].amount >= amount, 'Amount cannot exceed balance.');
        
        update(); // distribute rewards

        // send rewards to user
        uint pendingAmount = getPending(msg.sender);
        totalPending -= pendingAmount;
        krw.safeTransfer(msg.sender, pendingAmount);
        
        // remove amount from user stake
        UserInfo storage user = stakes[msg.sender];
        totalStaked -= amount;
        user.amount -= amount;
        user.pastPending = 0;
        user.divisor = user.amount == 0 ? 0 : multiplier;

        // send amount to user
        krw.safeTransfer(msg.sender, amount);
        
        emit Withdraw(msg.sender, amount);
        
    }

    /// @dev withdraw all tokens from the farm
    function withdrawAll() external {
        withdraw(stakes[msg.sender].amount);
    }

    /// @dev withdraw all tokens from the farm, ignoring rewards
    function emergencyWithdraw() external nonReentrant {
        UserInfo storage user = stakes[msg.sender];

        // remove user stake and clear rewards
        uint pendingAmount = getPending(msg.sender);
        totalStaked -= user.amount;
        totalPending -= pendingAmount;
        user.amount = 0;
        user.pastPending = 0;
        user.divisor = 0;

        // send tokens to user
        krw.safeTransfer(msg.sender, user.amount);

        emit EmergencyWithdraw(msg.sender, user.amount);
    }

    /// @dev claim rewards from the farm
    function claim() external nonReentrant {

        update(); // distribute rewards

        // clear rewards from user information
        UserInfo storage user = stakes[msg.sender];
        uint pendingAmount = getPending( msg.sender);
        totalPending -= pendingAmount;
        user.divisor = multiplier;
        user.pastPending = 0;

        // send rewards to user
        krw.safeTransfer(msg.sender, pendingAmount);

        emit Claim(msg.sender, pendingAmount); 
    }

    /// @dev updates the amount of rewards per block
    function updateRewardsPerBlock() internal {
        uint total = totalStaked + totalPending;
        rewardsPerBlock = ((targetDailyCompoundRate - 1e18) * total) / dailyBlocks;
        rewardsPerBlock = rewardsPerBlock < maxRewardsPerBlock ? rewardsPerBlock : maxRewardsPerBlock;
    }
    
    /// @dev distributes the rewards since update was last called
    function update() public whenNotPaused {
        if (totalStaked != 0) {

            updateRewardsPerBlock();
            uint blocksSinceLastReward = block.number < finalBlock ? (block.number - lastRewardBlock) : 0;
            uint rewardsToDeliver = rewardsPerBlock * blocksSinceLastReward;
            uint total = totalStaked + totalPending;
            uint totalAfterRewards = total + rewardsToDeliver;
            
            // If the multiplier is going to overflow, then end the reward distribution
            // by setting the final block equal to the block number when rewards were last distributed.
            // Then return, so that no rewards are distributed. Using this mechanism, people will be
            // able to withdraw their stake and claim their rewards without any issues.
            if (type(uint).max / totalAfterRewards < multiplier) {
                multiplierIsMaxed = true;
                finalBlock = lastRewardBlock;
                return;
            }

            multiplier = (multiplier * totalAfterRewards) / total;
            totalPending += rewardsToDeliver;
        }
        lastRewardBlock = block.number;
    }
    
    /// @dev calculates the rewards
    /// @param account the account to calculate the rewards for
    /// @return the rewards for the account
    function getPending(address account) public view returns(uint) {
        UserInfo memory user = stakes[account];
        uint totalAmount = user.amount + user.pastPending;
        return user.divisor == 0 ? 0 : (totalAmount * multiplier) / user.divisor - user.amount;
    }

    /// @dev pauses the farm
    function pause() external onlyOwner {
        _pause();
        lastRewardBlock = block.number;
    }
    
    /// @dev resumes the farm
    function unpause() external onlyOwner {
        _unpause();
        lastRewardBlock = block.number;
    }

}

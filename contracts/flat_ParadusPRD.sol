
/** 
 *  SourceUnit: /Users/ruslan/token/udemy.sol/contracts/ParadusPRD.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT

pragma solidity ^0.8.0;

interface IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint);

    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address _to, uint _value) external returns (bool);
}

/** 
 *  SourceUnit: /Users/ruslan/token/udemy.sol/contracts/ParadusPRD.sol
*/

// ----------------------------------------------------------------------------
// PRD token main contract release in (01.04.2022)
//
// Symbol       : PRD
// Name         : Paradus
// Total supply : 1.000.000.000 (burnable)
// Decimals     : 18
// ----------------------------------------------------------------------------
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
// ----------------------------------------------------------------------------
pragma solidity =0.8.0;

////import "./Ownable.sol";
////import "./IERC20.sol";

contract Pausable is Ownable {
    event Pause();
    event Unpause();

    bool public paused = false;


    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    modifier whenPaused() {
        require(paused);
        _;
    }

    function pause() onlyOwner whenNotPaused public {
        paused = true;
        Pause();
    }

    function unpause() onlyOwner whenPaused public {
        paused = false;
        Unpause();
    }
}

contract PRD is IERC20, Ownable, Pausable {
    mapping (address => mapping (address => uint)) private _allowances;
    
    mapping (address => uint) private _unfrozenBalances;

    mapping (address => uint) private _vestingNonces;
    mapping (address => mapping (uint => uint)) private _vestingAmounts;
    mapping (address => mapping (uint => uint)) private _unvestedAmounts;
    mapping (address => mapping (uint => uint)) private _vestingTypes; //0 - multivest, 1 - single vest, > 2 give by vester id
    mapping (address => mapping (uint => uint)) private _vestingReleaseStartDates;

    uint private _totalSupply = 1_000_000_000e18;
    string private constant _name = "Paradus";
    string private constant _symbol = "PRD";
    uint8 private constant _decimals = 18;

    uint private constant vestingFirstPeriod = 60 days;
    uint private constant vestingSecondPeriod = 152 days;

    uint public giveAmount;
    mapping (address => bool) public vesters;

    bytes32 public immutable DOMAIN_SEPARATOR;
    bytes32 public constant PERMIT_TYPEHASH = keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    mapping (address => uint) public nonces;

    event Unvest(address indexed user, uint amount);

    constructor () {
        _unfrozenBalances[owner] = _totalSupply;
        emit Transfer(address(0), owner, _totalSupply); 

        uint chainId = block.chainid;

        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256('EIP712Domain(string name,uint256 chainId,address verifyingContract)'),
                keccak256(bytes(_name)),
                chainId,
                address(this)
            )
        );
        giveAmount = _totalSupply / 10;
    }

    receive() payable external {
        revert();
    }

    function approve(address spender, uint amount) external override whenNotPaused returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transfer(address recipient, uint amount) external override whenNotPaused returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint amount) external override whenNotPaused returns (bool) {
        _transfer(sender, recipient, amount);
        
        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(currentAllowance >= amount, "PRD::transferFrom: transfer amount exceeds allowance");
        _approve(sender, msg.sender, currentAllowance - amount);

        return true;
    }

    function permit(address owner, address spender, uint amount, uint deadline, uint8 v, bytes32 r, bytes32 s) external whenNotPaused {
        bytes32 structHash = keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, amount, nonces[owner]++, deadline));
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, structHash));
        address signatory = ecrecover(digest, v, r, s);
        require(signatory != address(0), "PRD::permit: invalid signature");
        require(signatory == owner, "PRD::permit: unauthorized");
        require(block.timestamp <= deadline, "PRD::permit: signature expired");

        _allowances[owner][spender] = amount;

        emit Approval(owner, spender, amount);
    }

    function increaseAllowance(address spender, uint addedValue) external returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint subtractedValue) external returns (bool) {
        uint256 currentAllowance = _allowances[msg.sender][spender];
        require(currentAllowance >= subtractedValue, "PRD::decreaseAllowance: decreased allowance below zero");
        _approve(msg.sender, spender, currentAllowance - subtractedValue);

        return true;
    }

    function unvest() external whenNotPaused returns (uint unvested) {
        require (_vestingNonces[msg.sender] > 0, "PRD::unvest:No vested amount");
        for (uint i = 1; i <= _vestingNonces[msg.sender]; i++) {
            if (_vestingAmounts[msg.sender][i] == _unvestedAmounts[msg.sender][i]) continue;
            if (_vestingReleaseStartDates[msg.sender][i] > block.timestamp) break;
            uint toUnvest = (block.timestamp - _vestingReleaseStartDates[msg.sender][i]) * _vestingAmounts[msg.sender][i] / vestingSecondPeriod;
            if (toUnvest > _vestingAmounts[msg.sender][i]) {
                toUnvest = _vestingAmounts[msg.sender][i];
            } 
            uint totalUnvestedForNonce = toUnvest;
            toUnvest -= _unvestedAmounts[msg.sender][i];
            unvested += toUnvest;
            _unvestedAmounts[msg.sender][i] = totalUnvestedForNonce;
        }
        _unfrozenBalances[msg.sender] += unvested;
        emit Unvest(msg.sender, unvested);
    }

    function give(address user, uint amount, uint vesterId) external {
        require (giveAmount > amount, "PRD::give: give finished");
        require (vesters[msg.sender], "PRD::give: not vester");
        giveAmount -= amount;
        _vest(user, amount, vesterId);
     }

    function vest(address user, uint amount) external {
        require (vesters[msg.sender], "PRD::vest: not vester");
        _vest(user, amount, 1);
    }

    function burnTokens(uint amount) external onlyOwner returns (bool success) {
        require(amount <= _unfrozenBalances[owner], "PRD::burnTokens: exceeds available amount");

        uint256 ownerBalance = _unfrozenBalances[owner];
        require(ownerBalance >= amount, "PRD::burnTokens: burn amount exceeds owner balance");

        _unfrozenBalances[owner] = ownerBalance - amount;
        _totalSupply -= amount;
        emit Transfer(owner, address(0), amount);
        return true;
    }



    function allowance(address owner, address spender) external view override returns (uint) {
        return _allowances[owner][spender];
    }

    function decimals() external pure returns (uint8) {
        return _decimals;
    }

    function name() external pure returns (string memory) {
        return _name;
    }

    function symbol() external pure returns (string memory) {
        return _symbol;
    }

    function totalSupply() external view override returns (uint) {
        return _totalSupply;
    }

    function balanceOf(address account) external view override returns (uint) {
        uint amount = _unfrozenBalances[account];
        if (_vestingNonces[account] == 0) return amount;
        for (uint i = 1; i <= _vestingNonces[account]; i++) {
            amount = amount + _vestingAmounts[account][i] - _unvestedAmounts[account][i];
        }
        return amount;
    }

    function availableForUnvesting(address user) external view returns (uint unvestAmount) {
        if (_vestingNonces[user] == 0) return 0;
        for (uint i = 1; i <= _vestingNonces[user]; i++) {
            if (_vestingAmounts[user][i] == _unvestedAmounts[user][i]) continue;
            if (_vestingReleaseStartDates[user][i] > block.timestamp) break;
            uint toUnvest = (block.timestamp - _vestingReleaseStartDates[user][i]) * _vestingAmounts[user][i] / vestingSecondPeriod;
            if (toUnvest > _vestingAmounts[user][i]) {
                toUnvest = _vestingAmounts[user][i];
            } 
            toUnvest -= _unvestedAmounts[user][i];
            unvestAmount += toUnvest;
        }
    }

    function availableForTransfer(address account) external view returns (uint) {
        return _unfrozenBalances[account];
    }

    function vestingInfo(address user, uint nonce) external view returns (uint vestingAmount, uint unvestedAmount, uint vestingReleaseStartDate, uint vestType) {
        vestingAmount = _vestingAmounts[user][nonce];
        unvestedAmount = _unvestedAmounts[user][nonce];
        vestingReleaseStartDate = _vestingReleaseStartDates[user][nonce];
        vestType = _vestingTypes[user][nonce];
    }

    function vestingNonces(address user) external view returns (uint lastNonce) {
        return _vestingNonces[user];
    }



    function _approve(address owner, address spender, uint amount) private {
        require(owner != address(0), "PRD::_approve: approve from the zero address");
        require(spender != address(0), "PRD::_approve: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address sender, address recipient, uint amount) private {
        require(sender != address(0), "PRD::_transfer: transfer from the zero address");
        require(recipient != address(0), "PRD::_transfer: transfer to the zero address");

        uint256 senderAvailableBalance = _unfrozenBalances[sender];
        require(senderAvailableBalance >= amount, "PRD::_transfer: amount exceeds available for transfer balance");
        _unfrozenBalances[sender] = senderAvailableBalance - amount;
        _unfrozenBalances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _vest(address user, uint amount, uint vestType) private {
        require(user != address(0), "PRD::_vest: vest to the zero address");
        uint nonce = ++_vestingNonces[user];
        _vestingAmounts[user][nonce] = amount;
        _vestingReleaseStartDates[user][nonce] = block.timestamp + vestingFirstPeriod;
        _unfrozenBalances[owner] -= amount;
        _vestingTypes[user][nonce] = vestType;
        emit Transfer(owner, user, amount);
    }




    function multisend(address[] memory to, uint[] memory values) external onlyOwner returns (uint) {
        require(to.length == values.length);
        require(to.length < 100);
        uint sum;
        for (uint j; j < values.length; j++) {
            sum += values[j];
        }
        _unfrozenBalances[owner] -= sum;
        for (uint i; i < to.length; i++) {
            _unfrozenBalances[to[i]] += values[i];
            emit Transfer(owner, to[i], values[i]);
        }
        return(to.length);
    }

    function multivest(address[] memory to, uint[] memory values) external onlyOwner returns (uint) { 
        require(to.length == values.length);
        require(to.length < 100);
        uint sum;
        for (uint j; j < values.length; j++) {
            sum += values[j];
        }
        _unfrozenBalances[owner] -= sum;
        for (uint i; i < to.length; i++) {
            uint nonce = ++_vestingNonces[to[i]];
            _vestingAmounts[to[i]][nonce] = values[i];
            _vestingReleaseStartDates[to[i]][nonce] = block.timestamp + vestingFirstPeriod;
            _vestingTypes[to[i]][nonce] = 0;
            emit Transfer(owner, to[i], values[i]);
        }
        return(to.length);
    }

    function updateVesters(address vester, bool isActive) external onlyOwner { 
        vesters[vester] = isActive;
    }

    function updateGiveAmount(uint amount) external onlyOwner { 
        require (_unfrozenBalances[owner] > amount, "PRD::updateGiveAmount: exceed owner balance");
        giveAmount = amount;
    }
    
    function transferAnyERC20Token(address tokenAddress, uint tokens) external onlyOwner returns (bool success) {
        return IERC20(tokenAddress).transfer(owner, tokens);
    }

    function acceptOwnership() public override {
        uint amount = _unfrozenBalances[owner];
        _unfrozenBalances[newOwner] = amount;
        _unfrozenBalances[owner] = 0;
        emit Transfer(owner, newOwner, amount);
        super.acceptOwnership();
    }
}

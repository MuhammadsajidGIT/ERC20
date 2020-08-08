pragma solidity ^0.6.1;

import './IERC20.sol';
import './SafeMath.sol';

contract ERC20 is IERC20{
    using SafeMath for uint256;
    //mapping to hold balances against EOA accounts
    mapping (address => uint256) private _balances;

    //mapping to hold approved allowance of token to certain address
    //       Owner               Spender    allowance
    mapping (address => mapping (address => uint256)) private _allowances;

    //the amount of tokens in existence
    uint256 private _totalSupply;

    //owner
    address public owner;
    
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 internal lockTransaction;

    
    constructor () public {
        name = "Pioneer Token";
        symbol = "PI token";
        decimals = 4;
        owner = msg.sender;
        
        //1 million tokens to be generated
        //1 * (10**18)  = 1;
        
        _totalSupply = 1000000 * (10 ** uint256(decimals));
        
        //transfer total supply to owner
        _balances[owner] = _totalSupply;
        
        //fire an event on transfer of tokens
        emit Transfer(address(this),owner,_totalSupply);
     }
     
     function totalSupply() public view override returns (uint256) { 
         return _totalSupply;
    } 
    
     function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }
    
      function transfer(address recipient, uint256 amount) public  override returns (bool) {
        address sender = msg.sender;
        require(sender != address(0), "Transfer from the zero address");
        require(recipient != address(0), "Transfer to the zero address");
        require(_balances[sender] > amount,"Transfer amount exceeds balance");

        //decrease the balance of token sender account
        _balances[sender] = _balances[sender].sub(amount);
        
        //increase the balance of token recipient account
        _balances[recipient] = _balances[recipient].add(amount);

        emit Transfer(sender, recipient, amount);
        return true;
    }
    
    function allowance(address tokenOwner, address spender) public view  override returns (uint256) {
        return _allowances[tokenOwner][spender];
    }
    
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address tokenOwner = msg.sender;
        require(tokenOwner != address(0), "Approve from the zero address");
        require(spender != address(0), "Approve to the zero address");
        
        _allowances[tokenOwner][spender] = amount;
        
        emit Approval(tokenOwner, spender, amount);
        return true;
    }
    
    function transferFrom(address tokenOwner, address recipient, uint256 amount) public virtual override returns (bool) {
        address spender = msg.sender;
        uint256 _allowance = _allowances[tokenOwner][spender];
        require(_allowance > amount, "Transfer amount exceeds allowance");
        
        //deducting allowance
        _allowance = _allowance.sub(amount);
        
        //--- start transfer execution -- 
        
        //owner decrease balance
        _balances[tokenOwner] =_balances[tokenOwner].sub(amount); 
        
        //transfer token to recipient;
        _balances[recipient] = _balances[recipient].add(amount);
        
        emit Transfer(tokenOwner, recipient, amount);
        //-- end transfer execution--
        
        //decrease the approval amount;
        _allowances[tokenOwner][spender] = _allowance;
        
        emit Approval(tokenOwner, spender, amount);
        
        return true;
    }
    
    function mint(uint256 amount) public onlyOwner returns(uint256){
        require(amount > 0,"Invalid Amount. Minted amount should be greater than 0");
        _balances[owner] = _balances[owner].add(amount);
        
    }
       function lock_trans(uint256 time) onlyOwner public{
        require(time > 0 && time > now ,"invailed Time");
        lockTransaction = time;
        
    }
    
     modifier onlyOwner(){
        require(msg.sender == owner,"Only owner can execute this feature");
        _;
    }
    
    }
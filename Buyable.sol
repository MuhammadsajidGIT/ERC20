pragma solidity ^0.6.1;

import './IERC20.sol';
import './SafeMath.sol';
//import 'Address.sol';

contract ERC20 is IERC20{
    using SafeMath for uint256;
    //mapping to hold balances against EOA accounts
    mapping (address => uint256) private _balances;

    //mapping to hold approved allowance of token to certain address
    //       Owner               Spender    allowance
    mapping (address => mapping (address => uint256)) private _allowances;
    
    mapping(address => uint256) time;


    //the amount of tokens in existence
    uint256 private _totalSupply;

    //owner
    address public owner;
    
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 internal price;
    address internal delegatedAddres;
    
    constructor () public {
        name = "Pioneer Token";
        symbol = "PI token";
        decimals = 0;
        owner = msg.sender;
        
        //1 million tokens to be generated
        //1 * (10**18)  = 1;
        
        _totalSupply = 1000000 * (10 ** uint256(decimals));
        
        //transfer total supply to owner
        _balances[owner] = _totalSupply;
        
        price = 1 wei;
        
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
    
    receive() external payable{
        buy_token();
    }
    
    
    function buy_token()  public payable returns(bool) {
        require(msg.value > 0 ether, "invailed amount");
      //  require(msg.value > price, "Less price");
        require(tx.origin == msg.sender,"should be external owned account");
        uint256 wei_unit = (1 ether)/price; 
        uint256 FinalPrice = msg.value * wei_unit;
        _balances[msg.sender] += FinalPrice;
        time[msg.sender] = now.add(30 days); 
        return true;
    }

   
    
    function checkBalance() public view returns(uint){
        return address(this).balance;
    }
    
  function delegate_address_for_price(address _address) onlyOwner public returns(bool){
        delegatedAddres = _address;
        return true;
    }
    
    
    function UpDatePrice( uint _price  ) public returns(bool){
        require(msg.sender == owner || msg.sender == delegatedAddres, "Only Owner and Special Account are allowed to update the price"  );
        price = _price;
        return true;
    }
    
    function Change_OwnerShip(address NewOwner) public returns(bool){
        owner = NewOwner;
        return true;
    }
    
    function Return_Token(uint Token_Amount) public  returns(bool) {
        address payable sender = msg.sender;
        require(Token_Amount <= _balances[msg.sender],"invailed amount");
        require(time[msg.sender] >= now , "cannot return when time is over");
        
        uint256 temp_price = (Token_Amount.mul(price)).div(1 ether);
        require(temp_price <= address(this).balance,"account doesnot have enough fund for returning you ammount");
        _balances[owner] = _balances[owner].add(temp_price);
        _balances[msg.sender] = _balances[msg.sender].sub(temp_price);
        sender.transfer(temp_price);
        
    }
    
   
    
     modifier onlyOwner(){
        require(msg.sender == owner,"Only owner can execute this feature");
        _;
    }
    
    }
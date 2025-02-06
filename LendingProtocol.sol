pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract LendingProtocol is ReentrancyGuard {
    IERC20 public token;
    mapping(address => uint256) public deposits;
    mapping(address => uint256) public loans;

    uint256 public interestRate = 5;

    constructor(address _tokenAddress) {
        token = IERC20(_tokenAddress);
    }

    function deposit(uint256 amount) public {
        require(amount > 0, "Amount must be greater than zero");
        token.transferFrom(msg.sender, address(this), amount);
        deposits[msg.sender] += amount;
    }

    function borrow(uint256 amount) public nonReentrant {
        require(amount <= deposits[msg.sender] / 2, "Cannot borrow more than 50% of deposit");
        loans[msg.sender] += amount;
        token.transfer(msg.sender, amount);
    }

    function repay(uint256 amount) public nonReentrant {
        require(amount <= loans[msg.sender], "Cannot repay more than borrowed");
        token.transferFrom(msg.sender, address(this), amount);
        loans[msg.sender] -= amount;
    }

    function withdraw(uint256 amount) public nonReentrant {
        require(amount <= deposits[msg.sender], "Cannot withdraw more than deposited");
        require(loans[msg.sender] == 0, "Repay loans before withdrawal");
        deposits[msg.sender] -= amount;
        token.transfer(msg.sender, amount);
    }
}

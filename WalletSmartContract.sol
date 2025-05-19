// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract WalletTransfer {
    
    // Event to log the transfer details
    event Transfer(address indexed from, address indexed to, uint256 amount);

    // Function to receive Ether. msg.value contains the amount of Ether sent.
    receive() external payable {}

    // Function to check the balance of the contract
    function checkBalance() external view returns (uint256) {
        return address(this).balance;
    }

    // Function to transfer Ether from the contract to another wallet
    function transferEther(address payable _recipient, uint256 _amount) external {
        // Ensure the contract has enough Ether
        require(address(this).balance >= _amount, "Insufficient balance");

        // Emit the Transfer event for transparency
        emit Transfer(msg.sender, _recipient, _amount);

        // Perform the transfer
        (bool success, ) = _recipient.call{value: _amount}("");  // Send Ether using call
        require(success, "Transfer failed");
    }

    // Function to withdraw Ether from the contract to the sender's wallet
    function withdrawEther(uint256 _amount) external {
        // Ensure the contract has enough Ether
        require(address(this).balance >= _amount, "Insufficient balance");

        // Perform the withdrawal to the caller (msg.sender)
        (bool success, ) = msg.sender.call{value: _amount}("");
        require(success, "Withdrawal failed");
    }


}

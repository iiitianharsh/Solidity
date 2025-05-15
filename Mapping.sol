// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title MappingExamples
 * @dev This contract demonstrates the use of mappings, including single and nested mappings, in Solidity.
 */
contract MappingExamples {
    // Example 1: Simple mapping
    // Maps an address to a uint value, useful for balances, scores, etc.
    mapping(address => uint256) public balances;

    // Example 2: Nested mapping
    // Maps an address to another mapping of address to bool, useful for permissions or relationships.
    mapping(address => mapping(address => bool)) public isFriend;

    // Example 3: Mapping to a struct
    struct UserProfile {
        string name;
        uint256 age;
        bool isActive;
    }
    mapping(address => UserProfile) public userProfiles;

    // Add a value to the balances mapping -> adding
    function setBalance(address user, uint256 amount) public {
        balances[user] = amount; // Sets the balance for the user
    }

    // Retrieve a user's balance
    function getBalance(address user) public view returns (uint256) {
        return balances[user];
    }

    // Add a friend relationship in the nested mapping
    function addFriend(address user, address friend) public {
        isFriend[user][friend] = true; // Marks 'friend' as a friend of 'user'
    }

    // Check if two addresses are friends
    function checkFriendship(address user, address friend) public view returns (bool) {
        return isFriend[user][friend];
    }

    // Create or update a user profile
    function setUserProfile(address user, string memory name, uint256 age, bool isActive) public {
        userProfiles[user] = UserProfile(name, age, isActive); // Assigns the struct to the mapping
    }

    // Get a user's profile
    function getUserProfile(address user) public view returns (string memory, uint256, bool) {
        UserProfile memory profile = userProfiles[user];
        return (profile.name, profile.age, profile.isActive);
    }

    // Example 4: Deleting a mapping value
    function deleteBalance(address user) public {
        delete balances[user]; // Resets the value in the mapping to its default (0 for uint256)
    }

    function removeFriend(address user, address friend) public {
        delete isFriend[user][friend]; // Removes the friend relationship
    }

    // Example 5: Using mappings for counters
    // Tracks the number of transactions a user has made
    mapping(address => uint256) public transactionCount;
    mapping(address => uint104) private intGiven;
    
    function incrementTransactionCount(address user) public {
        transactionCount[user] += 1; // Increment the transaction count for the user
    }

    function getTransactionCount(address user) public view returns (uint256) {
        return transactionCount[user];
    }
        mapping(address => uint104) private intGiven;

    // Example 6: Complex usage - Nested mappings with additional logic
    // Tracks votes for candidates in different elections
    mapping(uint256 => mapping(address => uint256)) public votes; // electionId => (candidate => votes)

    function vote(uint256 electionId, address candidate) public {
        votes[electionId][candidate] += 1; // Increment the vote count for the candidate in the election
    }

    function getVotes(uint256 electionId, address candidate) public view returns (uint256) {
        return votes[electionId][candidate];
    }
}

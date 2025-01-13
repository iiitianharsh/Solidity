// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Crowdfunding {
    struct Campaign {
        address owner;           // Campaign creator
        uint256 goal;            // Funding goal in wei
        uint256 deadline;        // Deadline (timestamp)
        uint256 totalFunds;      // Total funds raised
        bool fundsWithdrawn;     // Whether the owner withdrew funds
    }

    mapping(uint256 => Campaign) public campaigns;      // Campaign ID to Campaign details
    mapping(uint256 => mapping(address => uint256)) public contributions; // Campaign ID -> Contributor -> Amount
    uint256 public campaignCount = 0;                  // Counter for campaign IDs

    /// @notice Event emitted when a new campaign is created
    event CampaignCreated(uint256 indexed campaignId, address indexed owner, uint256 goal, uint256 deadline);

    /// @notice Event emitted when a contribution is made
    event ContributionMade(uint256 indexed campaignId, address indexed contributor, uint256 amount);

    /// @notice Event emitted when a contributor gets a refund
    event RefundIssued(uint256 indexed campaignId, address indexed contributor, uint256 amount);

    /// @notice Event emitted when the owner withdraws funds
    event FundsWithdrawn(uint256 indexed campaignId, address indexed owner, uint256 amount);

    /// @notice Creates a new crowdfunding campaign
    /// @param goal The funding goal in wei
    /// @param duration The duration of the campaign in seconds
    function createCampaign(uint256 goal, uint256 duration) external {
        require(goal > 0, "Goal must be greater than zero");
        require(duration > 0, "Duration must be greater than zero");

        uint256 campaignId = campaignCount++;
        campaigns[campaignId] = Campaign({
            owner: msg.sender,
            goal: goal,
            deadline: block.timestamp + duration,
            totalFunds: 0,
            fundsWithdrawn: false
        });

        emit CampaignCreated(campaignId, msg.sender, goal, block.timestamp + duration);
    }

    /// @notice Contribute to a specific campaign
    /// @param campaignId The ID of the campaign
    function contribute(uint256 campaignId) external payable {
        Campaign storage campaign = campaigns[campaignId];
        require(block.timestamp < campaign.deadline, "Campaign has ended");
        require(msg.value > 0, "Contribution must be greater than zero");

        campaign.totalFunds += msg.value;
        contributions[campaignId][msg.sender] += msg.value;

        emit ContributionMade(campaignId, msg.sender, msg.value);
    }

    /// @notice Request a refund for a specific campaign
    /// @param campaignId The ID of the campaign
    function requestRefund(uint256 campaignId) external {
        Campaign storage campaign = campaigns[campaignId];
        require(block.timestamp >= campaign.deadline, "Campaign is still ongoing");
        require(campaign.totalFunds < campaign.goal, "Funding goal was reached");

        uint256 contributedAmount = contributions[campaignId][msg.sender];
        require(contributedAmount > 0, "No contributions found");

        contributions[campaignId][msg.sender] = 0;
        (bool success, ) = msg.sender.call{value: contributedAmount}("");
        require(success, "Refund failed");

        emit RefundIssued(campaignId, msg.sender, contributedAmount);
    }

    /// @notice Withdraw funds by the campaign owner
    /// @param campaignId The ID of the campaign
    function withdrawFunds(uint256 campaignId) external {
        Campaign storage campaign = campaigns[campaignId];
        require(msg.sender == campaign.owner, "Only the campaign owner can withdraw funds");
        require(block.timestamp >= campaign.deadline, "Campaign is still ongoing");
        require(campaign.totalFunds >= campaign.goal, "Funding goal not reached");
        require(!campaign.fundsWithdrawn, "Funds already withdrawn");

        uint256 amount = campaign.totalFunds;
        campaign.fundsWithdrawn = true;
        (bool success, ) = campaign.owner.call{value: amount}("");
        require(success, "Withdrawal failed");

        emit FundsWithdrawn(campaignId, campaign.owner, amount);
    }

    /// @notice Get details of a specific campaign
    /// @param campaignId The ID of the campaign
    function getCampaignDetails(uint256 campaignId)
        external
        view
        returns (address, uint256, uint256, uint256, bool)
    {
        Campaign storage campaign = campaigns[campaignId];
        return (
            campaign.owner,
            campaign.goal,
            campaign.deadline,
            campaign.totalFunds,
            campaign.fundsWithdrawn
        );
    }
}

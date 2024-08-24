// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Crowdfunding {

    // Struct to represent each campaign
    struct Campaign {
        string title; //name of the campaign
        string description; //description of the campaign.
        address payable benefactor; //address of the person or organization that will receive the funds
        uint goal; //fundraising goal (in wei).
        uint deadline; //timestamp when the campaign ends.
        uint amountRaised; //total amount of funds raised so far.
        bool ended; //tell us if a campaign has ended
    }

    mapping(uint256 => Campaign) public campaigns;
    uint256 public campaignCount; //to keep track of the campaigns. Would help us give IDs also
    address public owner;

    //Events to track activities within the contract. Would be triggered with emit calls
    event CampaignCreated(uint256 campaignId, string title, address benefactor, uint256 goal, uint256 deadline);
    event DonationReceived(uint256 campaignId, address donor, uint256 amount);
    event CampaignEnded(uint256 campaignId, uint256 amountRaised, bool successful);

    constructor() {
        owner = msg.sender; 
    }

    //This modifier allows us to ensure only the owner calls a particular function
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can call this function");
        _;
    }

    //function to create a campaign
    function createCampaign(
        string memory _title,
        string memory _description,
        address payable _benefactor,
        uint256 _goal,
        uint256 _duration )
        
        public 

        {
        require(_goal > 0, "Goal must be greater than zero");
        require(_duration > 0, "Duration must be greater than zero");

        campaignCount++; //this increments the campaign count
        uint256 deadline = block.timestamp + _duration; //deadline is current time + the duration set

        campaigns[campaignCount] = Campaign({
            title: _title,
            description: _description,
            benefactor: _benefactor,
            goal: _goal,
            deadline: deadline,
            amountRaised: 0,
            ended: false
        }); //these fields are required from the campaign struct and ended will be false because the campaign hasn't ended yet

        emit CampaignCreated(campaignCount, _title, _benefactor, _goal, deadline); //these fields are required from the event to create a campaign
    }

    //function called when a user wants to make a donation
    function donate(uint256 _campaignId) public payable {
        Campaign storage campaign = campaigns[_campaignId]; //we fetch the campaign (using the ID (from campaigncount)) the user wants to donate into
        require(block.timestamp < campaign.deadline, "Campaign has ended"); //incase the campaign has already ended
        require(msg.value > 0, "Donation amount must be greater than zero"); //donation amount must be higher than one

        campaign.amountRaised += msg.value; //add the donated amount to the total amount donated

        emit DonationReceived(_campaignId, msg.sender, msg.value); //trigger the event for receiving donation

        //if the current time has reached the deadline set, then call the endCampaign function
        if (block.timestamp >= campaign.deadline) {
            endCampaign(_campaignId);
        }
    }

    //function to end a campaign when the deadline has reached
    function endCampaign(uint256 _campaignId) public {
        Campaign storage campaign = campaigns[_campaignId]; //find the campaign with it's ID
        require(!campaign.ended, "Campaign has already ended"); //do not end if the campaign has not ended
        require(block.timestamp >= campaign.deadline, "Campaign deadline has not been reached"); //do not end if the dealine has not reached

        campaign.ended = true; //change the value to true for the campaign if it has ended
        bool successful = campaign.amountRaised >= campaign.goal; //this returns true IF the amount raised is equal or greater than the goal set. Will be useful in the frontend implementation to colour code successful campaigns

        //when a campaign has ended, the amount raised thus far should be transfered to the benefactor
        if (campaign.amountRaised > 0) {
            campaign.benefactor.transfer(campaign.amountRaised);
        }

        emit CampaignEnded(_campaignId, campaign.amountRaised, successful); //trigger the event for campaign ended
    }

    //this function allows only the owner of the contract to withdraw the funds in a campaign
    function withdrawFunds() public onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");
        payable(owner).transfer(balance); //this transfers the fund to the owner
    }

    // Prevent accidental Ether transfers to the contract
    receive() external payable {
        revert("Direct transfers not allowed. Use the donate function.");
    }
}
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.12;

contract Rice {

    // Required participation fee

    uint64 public participationFee = 5 * 10**18;
    uint64 public rngFee = 0.05 * 10**18;


    // Init campaign

    uint public currentCampaign = 0;
    mapping(uint => uint) public campaignIndexes;
    uint public campaignIndexesLength = 0;


    // Submissions

    // Submission structure
    struct Submission {
        bytes32 mask;
        bool    revealed;
        bool    rewarded;
        uint8   flag;
    }

    // Map containing maps of submissions from participants for each campaign.
    mapping (uint => mapping(address => Submission)) public submissions;
    // Map containing total rewards for each campaign.
    mapping (uint => uint) public rewards;

    event Submit(uint campaignIndex, address participant);

    // Submit a hash (also called "masked value") (phase 1)
    function submit(bytes32 maskedValue) external payable {
        if (campaignIndexes[campaignIndexesLength] != block.number) {
            campaignIndexesLength += 1;
            campaignIndexes[campaignIndexesLength] = block.number;
        }

        // Only accept submission if participant locks 5 ETH (5*10**18 wei)
        require(msg.value >= participationFee, "Not enough money to participate.");

        require(submissions[block.number][msg.sender].flag == 0, "Already submitted to campaign!");

        submissions[block.number][msg.sender] = Submission(maskedValue, false, false, 1);
        rewards[block.number] += participationFee;

        emit Submit(block.number, msg.sender);
    }


    // Reveals and generates random number

    // Map containing numbers of participants that reveal values for each campaign.
    mapping (uint => uint) public revealers;
    // Map containing generated number from each campaign.
    mapping (uint => uint) private randomNumber;

    event Reveal(uint campaignIndex, address participant);

    // Reveal value from masked value (phase 2)
    function reveal(uint subIndex, uint realValue, bytes32 dummyValue) external {
        require(submissions[subIndex][msg.sender].flag == 1, "Submission does not exist.");  // Checks if submissions[subIndex][msg.sender] exists.

        require(
            block.number - subIndex <= 6 &&
            !submissions[subIndex][msg.sender].revealed &&
            keccak256(abi.encode(realValue, dummyValue)) == submissions[subIndex][msg.sender].mask
            // Proceed if submitted mask matches with revealed values.
        ); 

        submissions[subIndex][msg.sender].revealed = true;

        randomNumber[subIndex] ^= realValue;

        // Return locked funds
        payable(msg.sender).transfer(participationFee);
        // Because locked funs are returned, the fund is no longer used to reward other participants.
        rewards[subIndex] -= participationFee;
        // Increments the amount of revealers for the campaign.
        revealers[subIndex] += 1;

        emit Reveal(subIndex, msg.sender);
    }

    event GenerateNumber(uint number, address caller);

    // Function to generate the random number
    function generateNumber() external payable returns (uint) {
        // Update current campaign if needed (finish phase 2).
        if (block.number - campaignIndexes[currentCampaign] > 7) {
            while (block.number - campaignIndexes[currentCampaign] > 7) {
                currentCampaign += 1;
            }

            if (currentCampaign != 0) { currentCampaign -= 1; }
        }

        require(msg.value >= rngFee, "Not enough money to call contract."); // Caller must send rngFee to generate random number.

        rewards[campaignIndexes[currentCampaign]] += msg.value;

        emit GenerateNumber(randomNumber[campaignIndexes[currentCampaign]], msg.sender);

        return randomNumber[campaignIndexes[currentCampaign]];
    }

    event GetNumber(uint number, address caller);

    // Function to get the generated random number at specific campaign index
    function getNumber(uint campaignBlockNumber) external payable returns (uint) {
        require(msg.value >= rngFee, "Not enough money to call contract."); // Caller must send rngFee to generate random number.

        rewards[campaignBlockNumber] += msg.value;

        emit GetNumber(randomNumber[campaignBlockNumber], msg.sender);

        return randomNumber[campaignBlockNumber];
    }


    // Rewards

    event CollectReward(uint reward, address participant);

    // Function to collect rewards
    function collectReward(uint subIndex) external {
        require(
            submissions[subIndex][msg.sender].revealed && // Check if submission is already revealed before.
            !submissions[subIndex][msg.sender].rewarded, // Check if submission is already rewarded before.
            "Submission is either not revealed, non-existent or participant has already been rewarded."
        );

        uint reward = rewards[subIndex] / revealers[subIndex];

        submissions[subIndex][msg.sender].rewarded = true;

        payable(msg.sender).transfer(reward);

        emit CollectReward(reward, msg.sender);
    }

    function calculateReward(uint subIndex) public view returns (uint) {
        if (!submissions[subIndex][msg.sender].revealed || submissions[subIndex][msg.sender].rewarded) {
            return 0;
        }

        uint reward = rewards[subIndex] / revealers[subIndex];

        return reward;
    }


    // Governance 

    // UGT token address
    address private tokenAddress;

    // Voting
    mapping(uint256 => uint256) public votes;
    mapping(address => uint256) public deposits;


    event VoteOnCallerFee (uint256 fee, uint256 amount, address participant);

    function voteOnCallerFee(uint64 fee, uint256 amount) external {
        // Call allowance method from token.
        (bool success, bytes memory result) = tokenAddress.call(
            abi.encodeWithSignature(
                "allowance(address,address)", 
                msg.sender, 
                address(this)
            )
        );

        require(success); // Process must be successful to continue.

        (uint256 allowed) = abi.decode(result, (uint256)); // Get allowed amount to transfer.

        require(allowed >= amount); // Allowance for deposit is needed.

        (bool _success, ) = tokenAddress.call(
            abi.encodeWithSignature(
                "transferFrom(address,address,uint256)",
                msg.sender,
                address(this), 
                amount
            )
        ); // Lock UGTs.

        require(_success); // Process must be successful to continue.

        // Call totalSupply from token.
        (bool __success, bytes memory __result) = tokenAddress.call(abi.encodeWithSignature("totalSupply()"));

        require(__success); // Process must be successful to continue.

        (uint256 totalSupply) = abi.decode(__result, (uint256)); // Get total supply.

        votes[fee] += amount; // Update the amount of votes on a fee.
        deposits[msg.sender] += amount; // Update the deposit amount.

        // If the amount of votes surpass 2/3 of the total supply, then fee is updated.
        if (votes[fee] >= totalSupply * 2 / 3) { rngFee = fee; }

        emit VoteOnCallerFee(fee, amount, msg.sender);
    }

    event WithdrawOnCallerFee(uint256 fee, address participant);

    function withdrawOnCallerFee(uint256 fee) external {
        (bool _success, ) = tokenAddress.call(
            abi.encodeWithSignature(
                "transfer(address,uint256)", 
                msg.sender, 
                deposits[msg.sender]
            )
        ); // Return locked UGTs.

        require(_success);
        
        votes[fee] -= deposits[msg.sender]; // Update the amount of votes on a fee.

        deposits[msg.sender] = 0; // Clear deposit

        emit WithdrawOnCallerFee(fee, msg.sender);
    }


    constructor(address _tokenAddress) {
        tokenAddress = _tokenAddress;
    }
}

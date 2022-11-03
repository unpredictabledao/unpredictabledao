// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.12;

contract TestUser {
    address rngAddress; // Unpredictable DAO's random number generator contract address.

    constructor(address _rngAddress) {
        rngAddress = _rngAddress; // Initiate with contract address
    }

    // Function to return the generated random number.
    function generateNumber() public payable returns (uint) {
        (bool success, bytes memory result) = rngAddress.call(abi.encodeWithSignature("rngFee()")); // Get fee from UnDAO's RNG contract.

        require(success, "Failed when trying to get fee."); // Error handler.

        (uint rngFee) = abi.decode(result, (uint256)); // Get the actual fee value from encoded result.

        require(msg.value >= rngFee, "Not enough money to call contract."); // User must provide enough money to pay for number generation fee.

        // Call the random number generator function from the contract.
        (bool _success, bytes memory _result) = rngAddress.call{value: rngFee}(abi.encodeWithSignature("generateNumber()"));

        require(_success, "Failed when calling RNG."); // Error handler.

        (uint generatedNumber) = abi.decode(_result, (uint256)); // Decode generated number from the result.

        return generatedNumber; // Return our newly generated number! Yay!
    }
}



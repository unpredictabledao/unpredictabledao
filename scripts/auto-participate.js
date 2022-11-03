const { ethers } = require("hardhat");
const hre = require("hardhat");

const { RiceABI, riceAddress } = require("./config");

async function main() {
    const [ signer ] = await ethers.getSigners();

    const rice = new ethers.Contract(riceAddress, RiceABI, signer);

    // Values to enter submissions.
    let realValue, dummyValue, maskedValue;

    realValue = Math.floor(Math.random() * 2147483648);
    
    dummyValue = ethers.utils.keccak256(
        ethers.utils.toUtf8Bytes(
            Math.floor(Math.random() * 10000).toString()
        )
    );

    maskedValue = ethers.utils.solidityKeccak256(
        ["uint", "bytes32"],
        [realValue, dummyValue]
    );

    rice.on("Submit", async (campaignIndex, participant) => {
        if (participant === await signer.getAddress()) {
            alert(`Submitted to campaign #${campaignIndex}, funds locked.`);

            // Reveal right after submission
            await rice.reveal(campaignIndex, realValue, dummyValue);
        }
    });

    rice.on("Reveal", async (campaignIndex, participant) => {
        if (participant === await signer.getAddress()) {
            alert(`Revealed values for campaign #${campaignIndex}, funds received.`);

            realValue = Math.floor(Math.random() * 2147483648);
    
            dummyValue = ethers.utils.keccak256(
                ethers.utils.toUtf8Bytes(
                    Math.floor(Math.random() * 10000).toString()
                )
            );

            maskedValue = ethers.utils.solidityKeccak256(
                ["uint", "bytes32"],
                [realValue, dummyValue]
            );

            await rice.submit(maskedValue, { value: ethers.utils.parseEther("5.0") });
        }
    });
}

main();

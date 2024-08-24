async function main() {
    const [deployer] = await ethers.getSigners();

    console.log(
        "Deploying contracts with the account:",
        deployer.address
    );

    const CrowdFunding = await ethers.getContractFactory("Crowdfunding");
    const crowdfund = await CrowdFunding.deploy();
    console.log("Contract Deployed to Address:", crowdfund.address);
}
main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });

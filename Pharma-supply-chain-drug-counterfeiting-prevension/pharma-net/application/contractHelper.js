const fs = require('fs');
const yaml = require('js-yaml');
const { FileSystemWallet, Gateway } = require('fabric-network');
let gateway;
const orgGroupNames = new Set(['manufacturer', 'distributor', 'retailer', 'transporter', 'consumer']);

async function getContractInstance(orgGroupName) {
	orgGroupName=orgGroupName.toLowerCase();
	if (!orgGroupNames.has(orgGroupName)){
		return ("Error: Invalid Group name: " + orgGroupName + ", valid group names are: manufacturer,distributor,retailer,transporter,consumer")
	}

	// A gateway defines which peer is used to access Fabric network
	// It uses a common connection profile (CCP) to connect to a Fabric Peer
	// A CCP is defined manually in file connection-profile-${orgnizationName}.yaml
	gateway = new Gateway();
	
	// A wallet is where the credentials to be used for this transaction exist
	// Credentials for admin user of 'manufacturer', 'distributor', 'retailer', 'transporter', 'consumer' was initially added to this wallet.
	const wallet = new FileSystemWallet('./identity/' + orgGroupName);
	
	// What is the username of this Client user accessing the network?
	const fabricUserName = orgGroupName.toUpperCase()+'_ADMIN';
	
	// Load connection profile; will be used to locate a gateway; The CCP is converted from YAML to JSON.
	let connectionProfile = yaml.safeLoad(fs.readFileSync('./connection-profile-'+orgGroupName.toLowerCase()+'.yaml', 'utf8'));
	
	// Set connection options; identity and wallet
	let connectionOptions = {
		wallet: wallet,
		identity: fabricUserName,
		discovery: { enabled: false, asLocalhost: true }
	};
	
	// Connect to gateway using specified parameters
	console.log('Connecting to Fabric Gateway');
	await gateway.connect(connectionProfile, connectionOptions);
	
	// Access pharmachannel channel
	console.log('Connecting to channel - pharmachannel');
	const channel = await gateway.getNetwork('pharmachannel');
	
	// Get instance of deployed pharmanet contract
	console.log('Connecting to pharmanet Smart Contract');
	return channel.getContract('pharmanet', 'org.pharma-network.pharmanet');
}

function disconnect() {
	console.log('Disconnecting from Fabric Gateway');
	gateway.disconnect();
}

module.exports.getContractInstance = getContractInstance;
module.exports.disconnect = disconnect;

/*
getContractInstance('consumer').then((contract)=>{
	console.log('received: ' + contract );
});
*/
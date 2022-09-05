'use strict';

const fs = require('fs');
const { FileSystemWallet, X509WalletMixin } = require('fabric-network');
const orgGroupNames = new Set(['manufacturer', 'distributor', 'retailer', 'transporter', 'consumer']);
async function main(orgGroupName, certificatePath="", privateKeyPath="") {
	orgGroupName = orgGroupName.toLowerCase();
	if (!orgGroupNames.has(orgGroupName)){
		return ("Error: Invalid Group name: " + orgGroupName + ", valid group names are: manufacturer,distributor,retailer,transporter,consumer")
	}
	const wallet = new FileSystemWallet('./identity/' + orgGroupName);
	if(certificatePath===""){
		certificatePath = '../network/crypto-config/peerOrganizations/'+orgGroupName+'.pharma-network.com/users/Admin@'+orgGroupName+'.pharma-network.com/msp/signcerts/Admin@'+orgGroupName+'.pharma-network.com-cert.pem';
	}
	if(privateKeyPath===""){
		let privateKeyPathFolder = '../network/crypto-config/peerOrganizations/'+orgGroupName+'.pharma-network.com/users/Admin@'+orgGroupName+'.pharma-network.com/msp/keystore';
		let files = fs.readdirSync(privateKeyPathFolder);

		files.forEach(function (file) {
			if(file.endsWith('_sk')){
				privateKeyPath = privateKeyPathFolder+'/'+file;
			}
		});
	}
	
	console.log("certificatePath for - " + orgGroupName + ": " + certificatePath);
	console.log("privateKeyPath for - " + orgGroupName + ": " + privateKeyPath);
	
	try {
		const certificate = fs.readFileSync(certificatePath).toString();
		const privatekey = fs.readFileSync(privateKeyPath).toString();
		const identityLabel = orgGroupName.toUpperCase()+'_ADMIN';
		const identity = X509WalletMixin.createIdentity(orgGroupName.toLowerCase()+'MSP', certificate, privatekey);

		await wallet.import(identityLabel, identity);
		
		console.log('User identity added to wallet for: ' + orgGroupName);

	} catch (error) {
		console.log(`Error adding to wallet. ${error}`);
		console.log(error.stack);
		throw new Error(error);
	}
}

main('manufacturer').then(() => {
  //console.log('done');
});

main('distributor').then(() => {
  //console.log('done');
});

main('retailer').then(() => {
  //console.log('done');
});

main('transporter').then(() => {
  //console.log('done');
});

main('consumer').then(() => {
  //console.log('done');
});

module.exports.execute = main;

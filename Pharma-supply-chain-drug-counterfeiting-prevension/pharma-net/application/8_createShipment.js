'use strict';

/**
 * This is a Node.JS module to register a drug on the pankaj-pharma-network.
 */

const {getContractInstance, disconnect} = require('./contractHelper')

async function main(orgGroupName, buyerCRN, drugName, listOfAssets, transporterCRN) {
	try {
		listOfAssets = JSON.stringify(listOfAssets);
		const pharmanetContract = await getContractInstance(orgGroupName);
		console.log('adding shipment to network');
		const response = await pharmanetContract.submitTransaction('createShipment', buyerCRN, drugName, listOfAssets, transporterCRN);
		console.log('Processing createShipment Transaction');
		console.log('response: ' + response);
//		let shipment = JSON.parse(response.toString());
		let shipment = response.toString();
		console.log(shipment);
		console.log('createShipment Submit Transaction Complete!');
//		return JSON.stringify(shipment);
		return shipment;
	} catch (error) {
		console.log('Error: ' + error);
		throw new Error(error);
	} finally {
		disconnect();
	}
}

module.exports.execute = main;

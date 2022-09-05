'use strict';

/**
 * This is a Node.JS module to view a drug on the pankaj-pharma-network.
 */

const {getContractInstance, disconnect} = require('./contractHelper')

async function main(orgGroupName, buyerCRN, drugName) {
	try {
		const pharmanetContract = await getContractInstance(orgGroupName);
		console.log('retrieving shipment from network');
		const response = await pharmanetContract.evaluateTransaction('viewShipment', buyerCRN, drugName);
		console.log('Processing viewShipment Transaction');
		console.log('response: ' + response);
//		let shipment = JSON.parse(JSON.stringify(response.toString()));
		let shipment = response.toString();
		console.log(shipment);
		console.log('View shipment Evaluate Transaction Complete!');
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

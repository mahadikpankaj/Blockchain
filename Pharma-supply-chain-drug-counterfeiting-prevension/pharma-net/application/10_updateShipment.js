'use strict';

/**
 * This is a Node.JS module to register a drug on the pankaj-pharma-network.
 */

const {getContractInstance, disconnect} = require('./contractHelper')

async function main(orgGroupName, buyerCRN, drugName, transporterCRN) {
	try {
		const pharmanetContract = await getContractInstance(orgGroupName);
		console.log('updating shipment on network');
		const response = await pharmanetContract.submitTransaction('updateShipment', buyerCRN, drugName, transporterCRN);
		console.log('Processing updateShipment Transaction');
		console.log('response: ' + response);
//		let shipment = JSON.parse(response.toString());
		let shipment = response.toString();
		console.log(shipment);
		console.log('updateShipment Submit Transaction Complete!');
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

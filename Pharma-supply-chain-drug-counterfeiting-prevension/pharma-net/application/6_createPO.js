'use strict';

/**
 * This is a Node.JS module to register a drug on the pankaj-pharma-network.
 */

const {getContractInstance, disconnect} = require('./contractHelper')

async function main(orgGroupName, buyerCRN, sellerCRN, drugName, quantity) {
	try {
		const pharmanetContract = await getContractInstance(orgGroupName);
		console.log('adding PO to network');
		const response = await pharmanetContract.submitTransaction('createPO', buyerCRN, sellerCRN, drugName, quantity);
		console.log('Processing createPO Transaction');
		console.log('response: ' + response);
//		let purchaseOrder = JSON.parse(response.toString());
		let purchaseOrder = response.toString();
		console.log(purchaseOrder);
		console.log('createPO Submit Transaction Complete!');
//		return JSON.stringify(drug);
		return purchaseOrder;
	} catch (error) {
		console.log('Error: ' + error);
		throw new Error(error);
	} finally {
		disconnect();
	}
}

module.exports.execute = main;

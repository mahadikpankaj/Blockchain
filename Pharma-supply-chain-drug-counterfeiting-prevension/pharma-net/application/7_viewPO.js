'use strict';

/**
 * This is a Node.JS module to view a drug on the pankaj-pharma-network.
 */

const {getContractInstance, disconnect} = require('./contractHelper')

async function main(orgGroupName, buyerCRN, drugName) {
	try {
		const pharmanetContract = await getContractInstance(orgGroupName);
		console.log('retrieving PO from network');
		const response = await pharmanetContract.evaluateTransaction('viewPO', buyerCRN, drugName);
		console.log('Processing viewPO Transaction');
		console.log('response: ' + response);
//		let purchaseOrder = JSON.parse(JSON.stringify(response.toString()));
		let purchaseOrder = response.toString();
		console.log(purchaseOrder);
		console.log('View PO Evaluate Transaction Complete!');
//		return JSON.stringify(purchaseOrder);
		return purchaseOrder;
	} catch (error) {
		console.log('Error: ' + error);
		throw new Error(error);
	} finally {
		disconnect();
	}
}

module.exports.execute = main;

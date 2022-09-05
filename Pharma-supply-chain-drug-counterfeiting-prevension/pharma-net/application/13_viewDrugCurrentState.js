'use strict';

/**
 * This is a Node.JS module to view a drug on the pankaj-pharma-network.
 */

const {getContractInstance, disconnect} = require('./contractHelper')

async function main(orgGroupName, drugName, serialNo) {
	try {
		const pharmanetContract = await getContractInstance(orgGroupName);
		console.log('retrieving drug state from network');
		const response = await pharmanetContract.evaluateTransaction('viewDrugCurrentState', drugName, serialNo);
		console.log('Processing viewDrugCurrentState Transaction');
		console.log('response: ' + response);
//		let registeredCompany = JSON.parse(JSON.stringify(response.toString()));
		let drug = response.toString();
		console.log(drug);
		console.log('View Drug State Evaluate Transaction Complete!');
//		return JSON.stringify(registeredCompany);
		return drug;
	} catch (error) {
		console.log('Error: ' + error);
		throw new Error(error);
	} finally {
		disconnect();
	}
}

module.exports.execute = main;

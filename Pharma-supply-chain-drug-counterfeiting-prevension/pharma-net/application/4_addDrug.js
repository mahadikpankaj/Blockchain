'use strict';

/**
 * This is a Node.JS module to register a drug on the pankaj-pharma-network.
 */

const {getContractInstance, disconnect} = require('./contractHelper')

async function main(orgGroupName, drugName, serialNo, mfgDate, expDate, companyCRN) {
	try {
		const pharmanetContract = await getContractInstance(orgGroupName);
		console.log('adding drug to network');
		const response = await pharmanetContract.submitTransaction('addDrug', drugName, serialNo, mfgDate, expDate, companyCRN);
		console.log('Processing addDrug Transaction');
		console.log('response: ' + response);
//		let drug = JSON.parse(response.toString());
		let drug = response.toString();
		console.log(drug);
		console.log('addDrug Submit Transaction Complete!');
//		return JSON.stringify(drug);
		return drug;
	} catch (error) {
		console.log('Error: ' + error);
		throw new Error(error);
	} finally {
		disconnect();
	}
}

module.exports.execute = main;

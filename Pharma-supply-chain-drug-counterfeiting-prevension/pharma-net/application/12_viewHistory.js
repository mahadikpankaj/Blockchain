'use strict';

/**
 * This is a Node.JS module to view a drug on the pankaj-pharma-network.
 */

const {getContractInstance, disconnect} = require('./contractHelper')

async function main(orgGroupName, drugName, serialNo) {
	try {
		const pharmanetContract = await getContractInstance(orgGroupName);
		console.log('retrieving drug history from network');
		const response = await pharmanetContract.evaluateTransaction('viewHistory', drugName, serialNo);
		console.log('Processing viewHistory Transaction');
		console.log('response: ' + response);
//		let history = JSON.parse(JSON.stringify(response.toString()));
		let history = response.toString();
		console.log(history);
		console.log('View History Evaluate Transaction Complete!');
//		return JSON.stringify(history);
		return history;
	} catch (error) {
		console.log('Error: ' + error);
		throw new Error(error);
	} finally {
		disconnect();
	}
}

module.exports.execute = main;

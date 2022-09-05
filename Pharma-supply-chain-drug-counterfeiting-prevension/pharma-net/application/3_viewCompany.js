'use strict';

/**
 * This is a Node.JS module to view a company on the pankaj-pharma-network.
 */

const {getContractInstance, disconnect} = require('./contractHelper')

async function main(orgGroupName, companyCRN, companyName) {
	try {
		const pharmanetContract = await getContractInstance(orgGroupName);
		console.log('retrieving company from network');
		const response = await pharmanetContract.evaluateTransaction('viewCompany', companyCRN, companyName);
		console.log('Processing viewCompany Transaction');
		console.log('response: ' + response);
//		let registeredCompany = JSON.parse(JSON.stringify(response.toString()));
		let company = response.toString();
		console.log(company);
		console.log('View Company Evaluate Transaction Complete!');
//		return JSON.stringify(registeredCompany);
		return company;
	} catch (error) {
		console.log('Error: ' + error);
		throw new Error(error);
	} finally {
		disconnect();
	}
}

module.exports.execute = main;

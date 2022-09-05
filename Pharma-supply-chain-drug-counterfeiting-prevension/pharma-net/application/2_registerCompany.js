'use strict';

/**
 * This is a Node.JS module to register a company on the pankaj-pharma-network.
 */

const {getContractInstance, disconnect} = require('./contractHelper')

async function main(orgGroupName, companyCRN, companyName, location, organizationRole) {
	try {
		const pharmanetContract = await getContractInstance(orgGroupName);
		console.log('registering company to network');
		const response = await pharmanetContract.submitTransaction('registerCompany', companyCRN, companyName, location, organizationRole);
		console.log('Processing registerCompany Transaction');
		console.log('response: ' + response);
//		let registeredCompany = JSON.parse(JSON.stringify(response.toString()));
		let registeredCompany = response.toString();
		console.log(registeredCompany);
		console.log('Register Company Submit Transaction Complete!');
//		return JSON.stringify(registeredCompany);
		return registeredCompany;
	} catch (error) {
		console.log('Error: ' + error);
		throw new Error(error);
	} finally {
		disconnect();
	}
}

module.exports.execute = main;

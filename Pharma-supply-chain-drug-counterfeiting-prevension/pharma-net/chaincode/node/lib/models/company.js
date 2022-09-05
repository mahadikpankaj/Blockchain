'use strict';

// class representing User Entity
const State = require('../../ledger-api/state.js');
const utils=require('../utils/utility-functions.js');

class Company extends State {
	
	/**
	 * Constructor function
	 * @param companyObject
	 */
	constructor(companyObject) {
		super(Company.getClass(), [utils.formatKey(companyObject.companyCRN),  utils.formatKey(companyObject.companyName)], "companyID");
        Object.assign(this, companyObject);
	}
	
	/**
	 * Get class of this model
	 * @returns {string}
	 */
	static getClass() {
		return 'org.pharma-network.pharmanet.company';
	}
	
	/**
	 * Convert the buffer stream received from blockchain into an object of this model
	 * @param buffer {Buffer}
	 */
	 static fromBuffer(buffer) {
		return Company.deserialize(buffer);
	}
	
	/**
     * Deserialize a state data to commercial paper
     * @param {Buffer} data to form back into the object
     */
	 static deserialize(data) {
        return State.deserializeClass(data, Company);
    }


	/**
	 * Convert the object of this model to a buffer stream
	 * @returns {Buffer}
	 */
	toBuffer() {
		return Buffer.from(JSON.stringify(this));
	}

	/**
	 * Create a new instance of this model
	 * @returns {Company}
	 * @param  {string}
	 */
	static createInstance(companyCRN, companyName, location, organisationRole) {
		let companyObject = {
			companyCRN: companyCRN.toUpperCase(),
			companyName: companyName.toUpperCase(),
			location: location.toUpperCase(),
			organisationRole: organisationRole.toUpperCase()
		};

		organisationRole = organisationRole.toUpperCase();
		if(organisationRole.toUpperCase() === 'MANUFACTURER'){
			companyObject.hierarchyKey = '1';
		}
		else if(organisationRole.toUpperCase() === 'DISTRIBUTOR'){
			companyObject.hierarchyKey = '2';
		}
		if(organisationRole.toUpperCase() === 'RETAILER'){
			companyObject.hierarchyKey = '3';
		}
		return new Company(companyObject);
	}
	
}

module.exports = Company;
'use strict';

// Utility class for collections of ledger states --  a state list
const StateList = require('../../ledger-api/statelist.js');
const Company = require('../models/company.js');
const utils = require('../utils/utility-functions.js');

class CompanyList extends StateList{
	
	constructor(ctx) {
		super(ctx,  'org.pharma-network.pharmanet.company');
		this.use(Company);
	}
	
	
	async getCompany(companyCRN, companyName) {
		const companyKey = Company.makeKey([utils.formatKey(companyCRN), utils.formatKey(companyName)]);
		return this.getState(companyKey);
	}

	async getCompanyByCompositeKey(companyKey) {
		return this.getStateByCompositeKey(companyKey);
	}


	async getCompanyUsingCRN(companyCRN){
		companyCRN = companyCRN.toUpperCase();
		let queryObject = {};
		queryObject.selector = {};
		queryObject.selector.class = Company.getClass();
		queryObject.selector.companyCRN = companyCRN;
		let queryString = JSON.stringify(queryObject);
		let companiesList = await this.getCompanyList(queryString).catch(err => console.log(err));

		if (companiesList.length < 1) {
			return null;
		}
		
		return JSON.parse(companiesList[0]);
	}
	
	/**
	 * Adds a Company object to the blockchain
	 * @param companyObject {Company}
	 * @returns {Promise<void>}
	 */
	async addCompany(companyObject) {
		return this.addState(companyObject);
	}
	
	/**
	 * Updates a Company object on the blockchain
	 * @param CompanyObject {Company}
	 * @returns {Promise<void>}
	 */
	async updateCompany(companyObject) {
		return this.updateState(companyObject);
	}

	async getCompanyList(queryString) {
		return this.getStatesList(queryString);
	}

}

module.exports = CompanyList;
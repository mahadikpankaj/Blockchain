'use strict';

// Utility class for collections of ledger states --  a state list
const StateList = require('../../ledger-api/statelist.js');
const Drug = require('../models/drug.js');
const utils = require('../utils/utility-functions.js');

class DrugList extends StateList{
	
	constructor(ctx) {
		super(ctx,  'org.pharma-network.pharmanet.drug');
		this.use(Drug);
	}
	
	/**
	 * Returns the Drug object stored in blockchain identified by this key
	 * @param drugKey
	 * @returns {Promise<Drug>}
	 */
	 async getDrug(drugName, serialNo) {
		const drugKey = Drug.makeKey([utils.formatKey(drugName), utils.formatKey(serialNo)]);
		return this.getState(drugKey);
	}

	async getDrugByCompositeKey(drugKey) {
		return this.getStateByCompositeKey(drugKey);
	}

	async getDrugHistory(drugName, serialNo){
		const drugKey = Drug.makeKey([utils.formatKey(drugName), utils.formatKey(serialNo)]);
		return this.getStateHistory(drugKey);
	}

	/**
	 * Adds a Drug object to the blockchain
	 * @param drugObject {Drug}
	 * @returns {Promise<void>}
	 */
	async addDrug(drugObject) {
		return this.addState(drugObject);
	}
	
	/**
	 * Updates a Drug object on the blockchain
	 * @param DrugObject {Drug}
	 * @returns {Promise<void>}
	 */
	async updateDrug(drugObject) {
		return this.updateState(drugObject);
	}

	async getDrugList(queryString) {
		return this.getStatesList(queryString);
	}

}

module.exports = DrugList;
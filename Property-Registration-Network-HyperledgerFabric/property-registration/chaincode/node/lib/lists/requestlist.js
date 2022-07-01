'use strict';

// Utility class for collections of ledger states --  a state list
const StateList = require('../../ledger-api/statelist.js');

const Request = require('../models/request.js');

class RequestList extends StateList{
	
	constructor(ctx) {
		super(ctx,  'org.property-registration-network.regnet.lists.request');
		this.use(Request);
	}
	
	/**
	 * Returns the Request object stored in blockchain identified by this key
	 * @param requestKey
	 * @returns {Promise<Request>}
	 */
	 async getRequest(requestKey) {
		return this.getState(requestKey);
	}
	
	/**
	 * Deletes the Request from Blockchain
	 * @param requestKey 
	 * @returns {Promise<Request>}
	 */
	async deleteRequest(requestKey) {
		return this.deleteState(requestKey);
	}
	
	/**
	 * Adds a Request object to the blockchain
	 * @param requestObject {Request}
	 * @returns {Promise<void>}
	 */
	async addRequest(requestObject) {
		return this.addState(requestObject);
	}
	
	/**
	 * Updates a Request object on the blockchain
	 * @param requestObject {Request}
	 * @returns {Promise<void>}
	 */
	async updateRequest(requestObject) {
		return this.updateState(requestObject);
	}

	async getRequestsList(queryString) {
		return this.getStatesList(queryString);
	}

}

module.exports = RequestList;
'use strict';

// Utility class for collections of ledger states --  a state list
const StateList = require('../../ledger-api/statelist.js');

const Property = require('../models/property.js');

class PropertyList extends StateList{
	
	constructor(ctx) {
		super(ctx,  'org.property-registration-network.regnet.lists.property');
		this.use(Property);
	}
	
	/**
	 * Returns the Property object stored in blockchain identified by this key
	 * @param propertyKey
	 * @returns {Promise<Property>}
	 */
	async getProperty(propertyKey) {
		return this.getState(propertyKey);
	}
	
	/**
	 * Adds a Property object to the blockchain
	 * @param propertyObject {Property}
	 * @returns {Promise<void>}
	 */
	async addProperty(propertyObject) {
		return this.addState(propertyObject);
	}
	
	/**
	 * Updates a Property object on the blockchain
	 * @param propertyObject {Property}
	 * @returns {Promise<void>}
	 */
	async updateProperty(propertyObject) {
		return this.updateState(propertyObject);
	}

	/**
	 * 
	 * @param {*} queryString 
	 * @returns string array of Properties
	 */
	async getPropertysList(queryString) {
		return this.getStatesList(queryString);
	}

}

module.exports = PropertyList;
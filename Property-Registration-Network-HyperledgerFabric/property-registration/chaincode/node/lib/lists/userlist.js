'use strict';

// Utility class for collections of ledger states --  a state list
const StateList = require('../../ledger-api/statelist.js');

const User = require('../models/user.js');

class UserList extends StateList{
	
	constructor(ctx) {
		super(ctx,  'org.property-registration-network.regnet.lists.user');
		this.use(User);
	}
	
	/**
	 * Returns the User object stored in blockchain identified by this key
	 * @param userKey
	 * @returns {Promise<User>}
	 */
	async getUser(userKey) {
		return this.getState(userKey);
	}
	
	/**
	 * Adds a User object to the blockchain
	 * @param userObject {User}
	 * @returns {Promise<void>}
	 */
	async addUser(userObject) {
		return this.addState(userObject);
	}
	
	/**
	 * Updates a User object on the blockchain
	 * @param userObject {User}
	 * @returns {Promise<void>}
	 */
	async updateUser(userObject) {
		return this.updateState(userObject);
	}

	async getUsersList(queryString) {
		return this.getStatesList(queryString);
	}

}

module.exports = UserList;
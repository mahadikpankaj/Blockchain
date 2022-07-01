'use strict';

// class representing User Entity
const State = require('../../ledger-api/state.js');
const utils=require('../utils/utility-functions.js');

class User extends State {
	
	/**
	 * Constructor function
	 * @param userObject
	 */
	constructor(userObject) {
		super(User.getClass(), [utils.formatKey(userObject.name + '-' + userObject.aadharNumber)]);
        Object.assign(this, userObject);
	}
	
	/**
	 * Get class of this model
	 * @returns {string}
	 */
	static getClass() {
		return 'org.property-registration-network.regnet.models.user';
	}
	
	/**
	 * Convert the buffer stream received from blockchain into an object of this model
	 * @param buffer {Buffer}
	 */
	 static fromBuffer(buffer) {
		return User.deserialize(buffer);
	}
	
	/**
     * Deserialize a state data to commercial paper
     * @param {Buffer} data to form back into the object
     */
	 static deserialize(data) {
        return State.deserializeClass(data, User);
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
	 * @returns {User}
	 * @param userObject {Object}
	 */
	static createInstance(requestObject) {
		let currentDate = new Date();
		let userObject = {
			name: requestObject.name,
			aadharNumber: requestObject.aadharNumber,
			email: requestObject.email,
			phone: requestObject.phone,
			requestedAt: requestObject.createdAt,
			approvedAt: currentDate,
			upgradCoins: '0'
		};
		return new User(userObject);
	}
	
}

module.exports = User;
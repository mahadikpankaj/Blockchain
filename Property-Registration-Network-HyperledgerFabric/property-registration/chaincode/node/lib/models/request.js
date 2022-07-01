'use strict';

// class representing Request Entity
const State = require('../../ledger-api/state.js');
const utils=require('../utils/utility-functions.js');

class Request extends State {
	
	/**
	 * Constructor function
	 * @param requestObject
	 */
	constructor(requestObject) {
		if (requestObject.requestType === 'user') {
			super(Request.getClass(), [utils.formatKey(requestObject.name + '-' + requestObject.aadharNumber)]);
		} else {
			super(Request.getClass(), [utils.formatKey(requestObject.propertyId)]);
		}

        Object.assign(this, requestObject);
	}
	
	/**
	 * Get class of this model
	 * @returns {string}
	 */
	static getClass() {
		return 'org.property-registration-network.regnet.models.request';
	}
	
	/**
	 * Convert the buffer stream received from blockchain into an object of this model
	 * @param buffer {Buffer}
	 */
	 static fromBuffer(buffer) {
		return Request.deserialize(buffer);
	}
	
	/**
     * Deserialize a state data to commercial paper
     * @param {Buffer} data to form back into the object
     */
	 static deserialize(data) {
        return State.deserializeClass(data, Request);
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
	 * @returns {Request}
	 * @param requestObject {Object}
	 */
	static createUserRegistrationRequest(userName, aadharNumber, email, phone) {
		let currentDate = new Date();
		aadharNumber = utils.formatKey(aadharNumber);
		userName = utils.formatName(userName);
		let requestObject = {
			name: userName,
			aadharNumber: aadharNumber,
			email: email,
			phone: phone,
			createdAt: currentDate,
			requestType: 'user'
		};
		return new Request(requestObject);
	}
	
	/**
	 * Create a new instance of this model
	 * @returns {Request}
	 * @param requestObject {Object}
	 */
	 static createPropertyRegistrationRequest(userName, aadharNumber, propertyId, price) {
		let currentDate = new Date();
		let owner = utils.formatKey(userName+'-'+aadharNumber);

		let requestObject = {
			propertyId: propertyId,
			owner: owner,
			price: price,
			status: 'registered',
			createdAt: currentDate,
			requestType: 'property'
		};
		return new Request(requestObject);
	}
	

}

module.exports = Request;
'use strict';

// class representing Property Entity
const State = require('../../ledger-api/state.js');
const utils=require('../utils/utility-functions.js');

class Property extends State {
	
	/**
	 * Constructor function
	 * @param propertyObject
	 */
	constructor(propertyObject) {
		super(Property.getClass(), [utils.formatKey(propertyObject.propertyId)]);
        Object.assign(this, propertyObject);
	}
	
	/**
	 * Get class of this model
	 * @returns {string}
	 */
	static getClass() {
		return 'org.property-registration-network.regnet.models.property';
	}
	
	/**
	 * Convert the buffer stream received from blockchain into an object of this model
	 * @param buffer {Buffer}
	 */
	 static fromBuffer(buffer) {
		return Property.deserialize(buffer);
	}
	
	/**
     * Deserialize a state data to commercial paper
     * @param {Buffer} data to form back into the object
     */
	 static deserialize(data) {
        return State.deserializeClass(data, Property);
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
	 * @returns {Property}
	 * @param propertyObject {Object}
	 */
	static createInstance(requestObject) {
		let currentDate = new Date();
		let propertyObject = {
			propertyId: requestObject.propertyId,
			owner: requestObject.owner,
			price: requestObject.price,
			status: requestObject.status,
			requestedAt: requestObject.createdAt,
			approvedAt: currentDate
		};
		return new Property(propertyObject);
	}
	
}

module.exports = Property;
'use strict';

// class representing User Entity
const State = require('../../ledger-api/state.js');
const utils=require('../utils/utility-functions.js');

class Drug extends State {
	
	/**
	 * Constructor function
	 * @param drugObject
	 */
	constructor(drugObject) {
		super(Drug.getClass(), [utils.formatKey(drugObject.name), utils.formatKey(drugObject.serialNo)], "productID");
        Object.assign(this, drugObject);
	}
	
	/**
	 * Get class of this model
	 * @returns {string}
	 */
	static getClass() {
		return 'org.pharma-network.pharmanet.drug';
	}
	
	/**
	 * Convert the buffer stream received from blockchain into an object of this model
	 * @param buffer {Buffer}
	 */
	 static fromBuffer(buffer) {
		return Drug.deserialize(buffer);
	}
	
	/**
     * Deserialize a state data to commercial paper
     * @param {Buffer} data to form back into the object
     */
	 static deserialize(data) {
        return State.deserializeClass(data, Drug);
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
	 * @returns {Drug}
	 * @param companyCRN {string}
	 */
	static createInstance(drugName, serialNo, mfgDate, expDate, manufacturerKey) {
		let drugObject = {
			expiryDate: expDate,
			manufacturer: manufacturerKey,
			manufacturingDate: mfgDate,
			name: drugName,
			serialNo: serialNo,
			owner: manufacturerKey,
			shipment: []
		};

		return new Drug(drugObject);
	}
	
}

module.exports = Drug;
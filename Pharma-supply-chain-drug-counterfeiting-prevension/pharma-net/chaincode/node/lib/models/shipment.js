'use strict';

// class representing User Entity
const State = require('../../ledger-api/state.js');
const utils=require('../utils/utility-functions.js');

class Shipment extends State {
	
	/**
	 * Constructor function
	 * @param shipmentObject
	 */
	constructor(shipmentObject) {
		super(Shipment.getClass(), [utils.formatKey(shipmentObject.buyerCRN),  utils.formatKey(shipmentObject.drugName)], "shipmentID");
        Object.assign(this, shipmentObject);
	}
	
	/**
	 * Get class of this model
	 * @returns {string}
	 */
	static getClass() {
		return 'org.pharma-network.pharmanet.shipment';
	}
	
	/**
	 * Convert the buffer stream received from blockchain into an object of this model
	 * @param buffer {Buffer}
	 */
	 static fromBuffer(buffer) {
		return Shipment.deserialize(buffer);
	}
	
	/**
     * Deserialize a state data to commercial paper
     * @param {Buffer} data to form back into the object
     */
	 static deserialize(data) {
        return State.deserializeClass(data, Shipment);
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
	 * @returns {Shipment}
	 * @param  {string}
	 */
	static createInstance(sellerKey, buyerCRN, drugName, listOfAssets, transporterKey) {
		let shipmentObject = {
			buyerCRN: buyerCRN,
			drugName: drugName,
			creator: sellerKey,
			assets: listOfAssets,
			transporter: transporterKey,
			status: 'in-transit'
		};
		return new Shipment(shipmentObject);
	}
	
}

module.exports = Shipment;
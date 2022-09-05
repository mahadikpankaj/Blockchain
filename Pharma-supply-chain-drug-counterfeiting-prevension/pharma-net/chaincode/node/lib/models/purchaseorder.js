'use strict';

// class representing User Entity
const State = require('../../ledger-api/state.js');
const utils=require('../utils/utility-functions.js');

class PurchaseOrder extends State {
	
	/**
	 * Constructor function
	 * @param purchaseorderObject
	 */
	constructor(purchaseorderObject) {
		super(PurchaseOrder.getClass(), [utils.formatKey(purchaseorderObject.buyerCRN),  utils.formatKey(purchaseorderObject.drugName)], "poID");
        Object.assign(this, purchaseorderObject);
	}
	
	/**
	 * Get class of this model
	 * @returns {string}
	 */
	static getClass() {
		return 'org.pharma-network.pharmanet.purchaseorder';
	}
	
	/**
	 * Convert the buffer stream received from blockchain into an object of this model
	 * @param buffer {Buffer}
	 */
	 static fromBuffer(buffer) {
		return PurchaseOrder.deserialize(buffer);
	}
	
	/**
     * Deserialize a state data to commercial paper
     * @param {Buffer} data to form back into the object
     */
	 static deserialize(data) {
        return State.deserializeClass(data, PurchaseOrder);
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
	 * @returns {PurchaseOrder}
	 * @param  {string}
	 */
	static createInstance(buyerCRN, buyerKey, sellerKey, drugName, quantity) {
		let purchaseorderObject = {
			buyerCRN: buyerCRN,
			buyer: buyerKey,
			drugName: drugName.toUpperCase(),
			seller: sellerKey,
			quantity: quantity
		};
		return new PurchaseOrder(purchaseorderObject);
	}
	
}

module.exports = PurchaseOrder;
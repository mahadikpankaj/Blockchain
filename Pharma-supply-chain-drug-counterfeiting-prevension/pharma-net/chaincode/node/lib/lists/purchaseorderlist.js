'use strict';

// Utility class for collections of ledger states --  a state list
const StateList = require('../../ledger-api/statelist.js');
const PurchaseOrder = require('../models/purchaseorder.js');
const utils = require('../utils/utility-functions.js');

class PurchaseOrderList extends StateList{
	
	constructor(ctx) {
		super(ctx,  'org.pharma-network.pharmanet.purchaseorder');
		this.use(PurchaseOrder);
	}
	
	/**
	 * Returns the PurchaseOrder object stored in blockchain identified by this key
	 * @param purchaseorderKey
	 * @returns {Promise<PurchaseOrder>}
	 */

	 async getPurchaseOrder(buyerCRN, drugName) {
		const poKey = PurchaseOrder.makeKey([utils.formatKey(buyerCRN), utils.formatKey(drugName)]);
		return this.getState(poKey);
	}

	async getPurchaseOrderByCompositeKey(purchaseorderKey) {
		return this.getState(purchaseorderKey);
	}

	/**
	 * Adds a PurchaseOrder object to the blockchain
	 * @param purchaseorderObject {PurchaseOrder}
	 * @returns {Promise<void>}
	 */
	async addPurchaseOrder(purchaseorderObject) {
		return this.addState(purchaseorderObject);
	}
	
	/**
	 * Updates a PurchaseOrder object on the blockchain
	 * @param PurchaseOrderObject {PurchaseOrder}
	 * @returns {Promise<void>}
	 */
	async updatePurchaseOrder(purchaseorderObject) {
		return this.updateState(purchaseorderObject);
	}

	async getPurchaseOrderList(queryString) {
		return this.getStatesList(queryString);
	}

}

module.exports = PurchaseOrderList;
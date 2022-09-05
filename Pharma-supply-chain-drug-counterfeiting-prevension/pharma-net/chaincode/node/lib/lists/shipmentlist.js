'use strict';

// Utility class for collections of ledger states --  a state list
const StateList = require('../../ledger-api/statelist.js');
const Shipment = require('../models/shipment.js');
const utils = require('../utils/utility-functions.js');

class ShipmentList extends StateList{
	
	constructor(ctx) {
		super(ctx,  'org.pharma-network.pharmanet.shipment');
		this.use(Shipment);
	}
	
	/**
	 * Returns the Shipment object stored in blockchain identified by this key
	 * @param shipmentKey
	 * @returns {Promise<Shipment>}
	 */
	 async getShipment(buyerCRN, drugName) {
		const shipmentKey = Shipment.makeKey([utils.formatKey(buyerCRN), utils.formatKey(drugName)]);
		return this.getState(shipmentKey);
	}

	async getShipmentByCompositeKey(shipmentKey) {
		return this.getState(shipmentKey);
	}

	/**
	 * Adds a Shipment object to the blockchain
	 * @param shipmentObject {Shipment}
	 * @returns {Promise<void>}
	 */
	async addShipment(shipmentObject) {
		return this.addState(shipmentObject);
	}
	
	/**
	 * Updates a Shipment object on the blockchain
	 * @param ShipmentObject {Shipment}
	 * @returns {Promise<void>}
	 */
	async updateShipment(shipmentObject) {
		return this.updateState(shipmentObject);
	}

	async getShipmentList(queryString) {
		return this.getStatesList(queryString);
	}

}

module.exports = ShipmentList;
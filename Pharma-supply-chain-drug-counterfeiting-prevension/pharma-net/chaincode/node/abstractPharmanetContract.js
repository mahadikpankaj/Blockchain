'use strict';

const { Contract, Context } = require('fabric-contract-api');

const CompanyList = require('./lib/lists/companylist.js');
const DrugList = require('./lib/lists/druglist.js');
const PurchaseOrderList = require('./lib/lists/purchaseorderlist.js');
const ShipmentList = require('./lib/lists/shipmentlist.js');

// custom Context object to hold different lists objects needed for further processing
class PharmanetContext extends Context {
	constructor() {
		super();
		// Add various model lists to the context class object
		// this : the context instance
		this.companyList = new CompanyList(this);
		this.drugList = new DrugList(this);
		this.purchaseorderList = new PurchaseOrderList(this);
		this.shipmentList = new ShipmentList(this);
	}
}

// Parent Contract class that holds common logic for creating context, and common functions if any, so pharmacontract can hold functions related to business..
class AbstractPharmanetContract extends Contract {

	// name of this contract to refer with
	constructor(name='org.pharma-network.pharmanet') {
		super(name);
	}

	// Built in method used to build and return the context for this smart contract on every transaction
	createContext() {
		return new PharmanetContext();
	}

	/* ****** All custom functions are defined below ***** */

	/**
	 * 
	 * @param {PharmanetContext} ctx - Transaction Context for transactional functions of Pharmanet contract 
	 * @returns {string} the type of stackeholder ('manufacturer', 'distributor', 'retailer', 'transporter' or 'consumer')
	 */
	getStakeholderType(ctx){
		let mspId = ctx.clientIdentity.getMSPID();
		let stakeholderType = mspId.substring(0, mspId.indexOf("MSP"));
		return stakeholderType.toUpperCase();
	}
}

module.exports = AbstractPharmanetContract;
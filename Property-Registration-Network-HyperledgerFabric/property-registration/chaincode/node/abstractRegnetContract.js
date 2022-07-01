'use strict';

const { Contract, Context } = require('fabric-contract-api');

const User = require('./lib/models/user.js');
const Property = require('./lib/models/property.js');

const RequestList = require('./lib/lists/requestlist.js');
const UserList = require('./lib/lists/userlist.js');
const PropertyList = require('./lib/lists/propertylist.js');

const utils = require('./lib/utils/utility-functions.js');

// custom Context object to hold different lists objects needed for further processing
class RegnetContext extends Context {
	constructor() {
		super();
		// Add various model lists to the context class object
		// this : the context instance
		this.requestList = new RequestList(this);
		this.userList = new UserList(this);
		this.propertyList = new PropertyList(this);
	}
}

// Parent Contract class that holds common logic for creating context, and common functions that used by both registrar and users contracts e.g. viewUser, viewProperty.
class AbstractRegnetContract extends Contract {

	constructor(name='org.property-registration-network.regnet') {
		// Provide a custom name to refer to this smart contract
		super(name);
	}

	// Built in method used to build and return the context for this smart contract on every transaction invoke
	createContext() {
		return new RegnetContext();
	}

	/* ****** All custom functions are defined below ***** */

	/**
	 * @description Common method that gets called from viewUser from Users and registrar contracts.
	 * @param {Context} ctx 
	 * @param {string} name of the user 
	 * @param {string} aadharNumber of the user 
	 * @returns {Promise} Promise (resolves to get User object)
	 */

	async getUser(ctx, userName, aadharNumber) {
		const userKey = User.makeKey([utils.formatKey(userName + '-' + aadharNumber)]);
		return await ctx.userList
			.getUser(userKey)
			.catch(err => console.log(err));
	}

	/**
	 * @description Common method that gets called from viewProperty from Users and registrar contracts.
	 * @param {Context} ctx 
	 * @param {int} ID of the property to be viewed
	 * @returns {Promise} Promise (resolves to get Property object)
	 */
	async getProperty(ctx,  propertyId) {
		const propertyKey = Property.makeKey([utils.formatKey(propertyId) ]);
		return await ctx.propertyList
			.getProperty(propertyKey)
			.catch(err => console.log(err));
	}

	/**
	 * 
	 * @param {Context} ctx 
	 * @returns {string} the type of stackeholder (users or registrar)
	 */
	getStakeholderType(ctx){
		let mspId = ctx.clientIdentity.getMSPID();
		let stakeholderType = mspId.substring(0, mspId.indexOf("MSP"));
		return stakeholderType;
	}
}

module.exports = AbstractRegnetContract;
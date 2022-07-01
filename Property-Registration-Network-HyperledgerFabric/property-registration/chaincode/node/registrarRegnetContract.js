'use strict';

const AbstractRegnetContract = require('./abstractRegnetContract.js');
const User = require('./lib/models/user.js');
const Request = require('./lib/models/request.js');
const Property = require('./lib/models/property.js');
const utils=require('./lib/utils/utility-functions.js');
/**
 * Contract defines functions that that a registrar stakeholder need to perform
 */
class RegistrarRegnetContract extends AbstractRegnetContract {

	constructor() {
		// Provide a custom name to refer to this smart contract
		super('org.property-registration-network.regnet.registrar');
	}

	// This is a basic user defined function used at the time of instantiating the smart contract
	// to print the success message on console
	async instantiate(ctx) {
		console.log('chaincode \'regnet\' instantiated');
	}
	/* ****** All custom functions are defined below ***** */

	/**
	 * @description Retuns the User object from the blockchain
	 * @param {Context} ctx 
	 * @param {string} userName 
	 * @param {string} aadharNumber 
	 * @returns {User} user object
	 */
	async viewUser(ctx, userName, aadharNumber) {
		return await super.getUser(ctx, userName, aadharNumber).catch(err => console.log(err));
	}

		/**
	 * @description Retuns the Property object from the blockchain
	 * @param {Context} ctx 
	 * @param {int} propertyId 
	 * @returns {Property} property object
	 */
	async viewProperty(ctx, propertyId) {
		return await super.getProperty(ctx, propertyId).catch(err => console.log(err));
	}

	/**
	 * @description Approves the user registration request
	 * @param {Context} ctx 
	 * @param {string} userName 
	 * @param {string} aadharNumber 
	 * @returns {User} User object
	 */

	async approveNewUser(ctx, userName, aadharNumber) {

		let stakeholderType = super.getStakeholderType(ctx);
		if (stakeholderType !== 'registrar') {
			throw new Error( 'Stakeholder of type \'' + stakeholderType + '\' attempted to execute  \'approveNewUser\' operation, when only stakeholder of type \'registrar\' is allowed to execute.');
		}
		
		let userRequestKey = utils.formatKey(userName + '-' + aadharNumber);
		let requestKey = Request.makeKey([userRequestKey]);
		let userKey = User.makeKey([userRequestKey]);


		let user = await ctx.userList
			.getUser(userKey)
			.catch(err => console.log(err));

		if (user !== undefined) {
			throw new Error('User already exists for: ' + userName + '-' + aadharNumber + '.');
		}

		let queryObject = {};
		queryObject.selector = {};
		queryObject.selector.class = 'org.property-registration-network.regnet.models.request';
		queryObject.selector.key = requestKey;
		queryObject.selector.requestType = 'user';

		let queryString = JSON.stringify(queryObject);

		
		let requestList = await ctx.requestList
		.getRequestsList(queryString)
		.catch(err => console.log(err));

		
		if (requestList.length < 1) {
			throw new Error('Invalid Request ID. New User Request does not exist for: ' + userName + '-' + aadharNumber + '.');
		} else {
			let request = JSON.parse(requestList[0]);
			let newUserObject = User.createInstance(request);
			await ctx.userList.addUser(newUserObject).catch(err => console.log(err));
			await ctx.requestList.deleteRequest(requestKey).catch(err => console.log(err));
			return newUserObject;
		}
	}

	/**
	 * @description Approves the property registration request
	 * @param {Context} ctx 
	 * @param {string} userName 
	 * @param {string} aadharNumber 
	 * @returns {User} User object
	 */
	async approvePropertyRegistration(ctx, propertyId) {

		let stakeholderType = super.getStakeholderType(ctx);
		if (stakeholderType !== 'registrar') {
			throw new Error( 'Stakeholder of type \'' + stakeholderType + '\' attempted to execute  \'approvePropertyRegistration\' operation, when only stakeholder of type \'registrar\' is allowed to execute.');
		}

		let propertyRequestKey = utils.formatKey(propertyId);
		let requestKey = Request.makeKey([propertyRequestKey]);
		let propertyKey = Property.makeKey([propertyRequestKey]);


		let property = await ctx.propertyList
			.getProperty(propertyKey)
			.catch(err => console.log(err));

		if (property !== undefined) {
			throw new Error('Property already exists for: ' + propertyId + '.');
		}

		let queryObject = {};
		queryObject.selector = {};
		queryObject.selector.class = 'org.property-registration-network.regnet.models.request';
		queryObject.selector.key = requestKey;
		queryObject.selector.requestType = 'property';

		let queryString = JSON.stringify(queryObject);

		
		let requestList = await ctx.requestList
		.getRequestsList(queryString)
		.catch(err => console.log(err));

		
		if (requestList.length < 1) {
			throw new Error('Invalid Request ID. Property Registration Request does not exist for: ' + propertyId + '.');
		} else {
			let request = JSON.parse(requestList[0]);
			let newPropertyObject = Property.createInstance(request);
			await ctx.propertyList.addProperty(newPropertyObject).catch(err => console.log(err));
			await ctx.requestList.deleteRequest(requestKey).catch(err => console.log(err));
			return newPropertyObject;
		}
	}

}

module.exports = RegistrarRegnetContract;
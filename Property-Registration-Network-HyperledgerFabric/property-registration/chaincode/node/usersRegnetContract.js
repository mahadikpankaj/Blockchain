'use strict';

const AbstractRegnetContract = require('./abstractRegnetContract.js');
const Request = require('./lib/models/request.js');
const User = require('./lib/models/user.js');
const Property = require('./lib/models/property.js');
const utils = require('./lib/utils/utility-functions.js');

/**
 * Contract defines functions that that a users stakeholder need to perform
 */

class UsersRegnetContract extends AbstractRegnetContract {

	constructor() {
		// Provide a custom name to refer to this smart contract
		super('org.property-registration-network.regnet.users');
	}


	/* ****** All custom functions are defined below ***** */

	/**
	 * @description function to create registration request for user
	 * @param {RegnetContext} ctx 
	 * @param {string} userName - Full name of the user e.g. "Pankaj Mahadik"
	 * @param {string} aadharNumber - Aadhar number of the user e.g. "1111 2222 3333"
	 * @param {string} email - E-mail address of the user
	 * @param {string} phone - Phone number of the user
	 * @returns {Request} Request object
	 */

	async requestNewUser(ctx, userName, aadharNumber, email, phone) {
		let stakeholderType = super.getStakeholderType(ctx);
		if (stakeholderType !== 'users') {
			throw new Error( 'Stakeholder of type \'' + stakeholderType + '\' attempted to execute  \'requestNewUser\' operation, when only stakeholder of type \'users\' is allowed to execute.');
		}

// fetch user from the blockchain		
		let user = await super.getUser(userName, aadharNumber).catch(err => console.log(err));

		// if user already exists then throw error, else create new user registration request
		if (user !== undefined) {
			throw new Error('User Already Exists:' + userName + ', and Aadhar Number: ' + aadharNumber);
		}
		else {
			let requestKey = Request.makeKey([utils.formatKey(userName + '-' + aadharNumber)]);
			let queryObject = {};
			queryObject.selector = {};
			queryObject.selector.class = 'org.property-registration-network.regnet.models.request';
			queryObject.selector.key = requestKey;
			queryObject.selector.requestType = 'user';

			let queryString = JSON.stringify(queryObject);


			let requestList = await ctx.requestList
				.getRequestsList(queryString)
				.catch(err => console.log(err));

			if (requestList.length > 0) {
				throw new Error('Request already exists for user:' + userName + ', and Aadhar Number: ' + aadharNumber);
			} else {
				let newRequestObject = Request.createUserRegistrationRequest(userName, aadharNumber, email, phone);
				await ctx.requestList.addRequest(newRequestObject);
				return newRequestObject;
			}
		}
	}

	/**
	 * @description Retuns the Request object for registration of the user
	 * @param {RegnetContext} ctx 
	 * @param {string} userName - Full name of the user e.g. "Pankaj Mahadik"
	 * @param {string} aadharNumber - Aadhar number of the user e.g. "1111 2222 3333"
	 * @returns {Request} Request object
	 */

	async getUserRegistrationRequest(ctx, userName, aadharNumber) {

		const requestKey = Request.makeKey([utils.formatKey(userName + '-' + aadharNumber)]);
		let queryObject = {};
		queryObject.selector = {};
		queryObject.selector.class = 'org.property-registration-network.regnet.models.request';
		queryObject.selector.key = requestKey;
		queryObject.selector.requestType = 'user';

		let queryString = JSON.stringify(queryObject);

		let requestsList = await ctx.requestList
			.getRequestsList(queryString)
			.catch(err => console.log(err));

		console.log(requestsList);

		if (requestsList.length > 0) {
			return JSON.parse(requestsList[0]);
		}
		return null;
	}

	/**
	 * @description Retuns the string array of Request object of all user registration requests
	 * @param {RegnetContext} ctx 
	 * @returns {string[]} 
	 */

	async getAllUserRegistrationRequests(ctx) {
		let queryObject = {};
		queryObject.selector = {};
		queryObject.selector.class = 'org.property-registration-network.regnet.models.request';
		queryObject.selector.requestType = 'user';

		let queryString = JSON.stringify(queryObject);
		let requestsList = await ctx.requestList
			.getRequestsList(queryString)
			.catch(err => console.log(err));

		console.log(requestsList);
		return requestsList;
	}

	/**
	 * @description Retuns the User object corresponding to the user name and Aadhar number
	 * @param {RegnetContext} ctx 
	 * @param {string} userName - Full name of the user e.g. "Pankaj Mahadik"
	 * @param {string} aadharNumber - Aadhar number of the user e.g. "1111 2222 3333"
	 * @returns {User} User object
	 */

	async viewUser(ctx, userName, aadharNumber) {
		return await super.getUser(ctx, userName, aadharNumber).catch(err => console.log(err));
	}

	
	/**
	 * @description Retuns the Property object corresponding to the propertyId
	 * @param {RegnetContext} ctx 
	 * @param {string} propertyId - id of the property
	 * @returns {Property} Property object
	 */
	 async viewProperty(ctx, propertyId) {
		return await super.getProperty(ctx, propertyId).catch(err => console.log(err));
	}

	/**
	 * @description Retuns the string array of User objects of all users
	 * @param {RegnetContext} ctx 
	 * @returns {string[]} 
	 */

	async getAllUsers(ctx) {
		const queryString = '{"selector":{"class":"org.property-registration-network.regnet.models.user"}}';
		let usersList = await ctx.userList
			.getUsersList(queryString)
			.catch(err => console.log(err));

		console.log(usersList);
		return usersList;
	}

	/**
	 * @description function to create registration request of property
	 * @param {RegnetContext} ctx 
	 * @param {string} userName - Full name of the user e.g. "Pankaj Mahadik"
	 * @param {string} aadharNumber - Aadhar number of the user e.g. "1111 2222 3333"
	 * @param {string} propertyId - id of the property
	 * @param {string} price - Price of the property
	 * @returns {Request} Request object
	 */

	async propertyRegistrationRequest(ctx, userName, aadharNumber, propertyId, price) {
		let stakeholderType = super.getStakeholderType(ctx);
		if (stakeholderType !== 'users') {
			throw new Error( 'Stakeholder of type \'' + stakeholderType + '\' attempted to execute  \'propertyRegistrationRequest\' operation, when only stakeholder of type \'users\' is allowed to execute.');
		}

		let property = await this.getProperty(propertyId).catch(err => console.log(err));
		if (property !== undefined) {
			throw new Error('Property Already Exists:' + propertyId);
		}
		else {
			let queryObject = {};
			queryObject.selector = {};
			queryObject.selector.class = 'org.property-registration-network.regnet.models.request';
			queryObject.selector.propertyId = propertyId;
			queryObject.selector.requestType = 'property';

			let queryString = JSON.stringify(queryObject);


			let requestList = await ctx.requestList
				.getRequestsList(queryString)
				.catch(err => console.log(err));

			if (requestList.length > 0) {
				throw new Error('Request already exists for Property:' + propertyId);
			} else {
				let newRequestObject = Request.createPropertyRegistrationRequest(userName, aadharNumber, propertyId, price);
				await ctx.requestList.addRequest(newRequestObject);
				return newRequestObject;
			}
		}
	}

	/**
	 * @description Retuns the Property registration request object corresponding to the propertyId
	 * @param {RegnetContext} ctx 
	 * @param {string} propertyId - id of the property
	 * @returns {Request} Property Registration Request object
	 */

	async getPropertyRegistrationRequest(ctx, propertyId) {

		const requestKey = Request.makeKey([utils.formatKey(propertyId)]);
		let queryObject = {};
		queryObject.selector = {};
		queryObject.selector.class = 'org.property-registration-network.regnet.models.request';
		queryObject.selector.key = requestKey;
//		queryObject.selector.propertyId = propertyId;
		queryObject.selector.requestType = 'property';
		let queryString = JSON.stringify(queryObject);
		let requestsList = await ctx.requestList
			.getRequestsList(queryString)
			.catch(err => console.log(err));

		console.log(requestsList);
		if ( requestsList.length > 0 ){
			return JSON.parse(requestsList[0]);
		}
		return null;
	}

	/**
	 * @description Retuns the string array of Request object of all property registration requests
	 * @param {RegnetContext} ctx 
	 * @returns {string[]} 
	 */

	async getAllPropertyRegistrationRequests(ctx) {
		let queryObject = {};
		queryObject.selector = {};
		queryObject.selector.class = 'org.property-registration-network.regnet.models.request';
		queryObject.selector.requestType = 'property';
		let queryString = JSON.stringify(queryObject);
		let requestsList = await ctx.requestList
			.getRequestsList(queryString)
			.catch(err => console.log(err));

		console.log(requestsList);
		return requestsList;
	}

	/**
	 * @description Retuns the string array of property objects of a user
	 * @param {RegnetContext} ctx 
	 * @returns {string[]} 
	 */

	async getUserProperties(ctx, userName, aadharNumber) {
		// Create the composite key required to fetch record from blockchain
		const propertyKey = Property.makeKey([utils.formatKey(userName + '-' + aadharNumber)]);

		return await ctx.propertyList
			.getProperty(propertyKey)
			.catch(err => console.log(err));

	}

	/**
	 * @description Retuns the string array of property objects of all users
	 * @param {RegnetContext} ctx 
	 * @returns {string[]} 
	 */

	async getAllProperties(ctx) {
		const queryString = '{"selector":{"class":"org.property-registration-network.regnet.models.property"}}';
		let propertiesList = await ctx.propertyList
			.getPropertysList(queryString)
			.catch(err => console.log(err));

		console.log(propertiesList);
		return propertiesList;
	}

	/**
	 * @description Recharge the user object with the transaction amount (100, 500 or 1000 upgradCoins)
	 * @param {RegnetContext} ctx 
	 * @param {string} userName - Full name of the user e.g. "Pankaj Mahadik"
	 * @param {string} aadharNumber - Aadhar number of the user e.g. "1111 2222 3333"
	 * @param {string} transactionId 
	 * @returns {User} updated User object with recharged amount
	 */
	async rechargeAccount(ctx, userName, aadharNumber, transactionId ) {
		let stakeholderType = super.getStakeholderType(ctx);
		if (stakeholderType !== 'users') {
			throw new Error( 'Stakeholder of type \'' + stakeholderType + '\' attempted to execute  \'rechargeAccount\' operation, when only stakeholder of type \'users\' is allowed to execute.');
		}

		let user = await super.getUser(ctx, userName, aadharNumber).catch(err => console.log(err));
		if (user === undefined) {
			throw new Error('User does not exists for name: ' + userName + ' and Aadhar number: ' + aadharNumber + '.'); 
		}
		let amt  = 0;
		if (transactionId === 'upg100') {
			amt = 100;
		} else if (transactionId === 'upg500') {
			amt = 500;
		} else if (transactionId === 'upg1000') {
			amt = 1000;
		} else {
			throw new Error('Invalid Bank Transaction ID: ' + transactionId);
		}
		let newAmt = parseInt(user.upgradCoins) + amt;
		user.upgradCoins = newAmt.toString();
		ctx.userList.updateUser(user);

		return user;
	}	

	/**
	 * @description Set the status of the property to 'registered' or 'onSale'
	 * @param {RegnetContext} ctx 
	 * @param {string} propertyId 
	 * @param {string} status 
	 * @returns {Property} updated Property object with changed status
	 */
	async updateProperty(ctx, userName, aadharNumber, propertyId, status ) {
		let stakeholderType = super.getStakeholderType(ctx);
		if (stakeholderType !== 'users') {
			throw new Error( 'Stakeholder of type \'' + stakeholderType + '\' attempted to execute  \'updateProperty\' operation, when only stakeholder of type \'users\' is allowed to execute.');
		}

		if (!( status == 'registered' || status == 'onSale')){
			throw new Error('Invalid status: ' + status + '. Only allowed statuses are: registered, onSale');
		}

		let user = await super.getUser(ctx, userName, aadharNumber).catch(err => console.log(err));
		if (user === undefined) {
			throw new Error('User does not exists for name: ' + userName + ' and Aadhar number: ' + aadharNumber + '.'); 
		}

		let property = await super.getProperty(ctx, propertyId).catch(err => console.log(err));
		if (property === undefined) {
			throw new Error('Property does not exists for id: ' + propertyId + '.'); 
		}

		let currentUser = utils.formatKey(userName+'-'+aadharNumber);
		let propertyOwner = property.owner;
		if ( currentUser != propertyOwner){
			throw new Error('Current user: ' + currentUser + ' and Property owner: ' +propertyOwner + ' for propertyId '+ propertyId + ' are different.'); 
		}

		if (property.status == status){
			throw new Error("status of the property: " + propertyId + " is unchanged: " + status);
		}
		property.status = status;
		ctx.propertyList.updateProperty(property);

		return property;
	}	

	/**
	 * @description Transfer property from one user to another
	 * @param {RegnetContext} ctx 
 	 * @param {string} userName - Full name of the user e.g. "Pankaj Mahadik" (of the buyer)
	 * @param {string} aadharNumber - Aadhar number of the user e.g. "1111 2222 3333" (of the buyer)
	 * @param {string} propertyId - id of the property to be purchased
	 * @returns {Property} updated Property object reflecting new owner
	 */

	async purchaseProperty(ctx, userName, aadharNumber, propertyId) {

		// check if 'users' stakeholder is invoking the operation else throw error
		let stakeholderType = super.getStakeholderType(ctx);
		if (stakeholderType !== 'users') {
			throw new Error( 'Stakeholder of type \'' + stakeholderType + '\' attempted to execute  \'purchaseProperty\' operation, when only stakeholder of type \'users\' is allowed to execute.');
		}

		//check if the user (buyer) exists in the system
		let user = await super.getUser(ctx, userName, aadharNumber).catch(err => console.log(err));
		if (user === undefined) {
			throw new Error('User does not exists for name: ' + userName + ' and Aadhar number: ' + aadharNumber + '.'); 
		}

		//check if property to be transferred exists in the system
		let property = await super.getProperty(ctx, propertyId).catch(err => console.log(err));
		if (property === undefined) {
			throw new Error('Property does not exists for id: ' + propertyId + '.'); 
		}

		//check if the owner of the property itself is trying to purchase the property
		let currentUser = utils.formatKey(userName+'-'+aadharNumber);
		let propertyOwner = property.owner;
		let propertyStatus = property.status;
		if ( currentUser === propertyOwner){
			throw new Error('Owner: ' + currentUser + ' trying to buy own property: propertyId: '+ propertyId + '.'); 
		}

		// check if the property is marked for Sale (status should be onSale)
		if ( propertyStatus === 'registered'){
			throw new Error('Property having propertyId: '+ propertyId + ' is not marked for Sale, the status is registered, and not onSale'); 
		}

		let sellerKey = User.makeKey([propertyOwner]);
		let sellerUser = await ctx.userList.getUser(sellerKey).catch(err => console.log(err));
		let price = parseInt(property.price);
		let buyerBalance = parseInt(user.upgradCoins);
		let sellerBalance = parseInt(sellerUser.upgradCoins);
		
		// check if the buyer has sufficient balance to purchase the property
		if (price > buyerBalance) {
			throw new Error('Insufficient balance to purchase property: ID: ' + propertyId + ' Price: ' + price + " Balance: " + buyerBalance + ' Buyer:' + userName+'-'+aadharNumber);
		}

		// Everything is good.
		//add the amount equivalent to the price to the seller
		// deduct the amount equivalent to the price from the buyer
		// update the owner of the property to the buyer
		//change the status of the property to 'registered'
		let buyerBalanceNew = buyerBalance - price;
		let sellerBalanceNew = sellerBalance + price;

		property.status = 'registered';
		property.owner = currentUser;

		user.upgradCoins = buyerBalanceNew.toString();
		sellerUser.upgradCoins = sellerBalanceNew.toString();

		await ctx.userList.updateUser(user).catch(err => console.log(err));
		await ctx.userList.updateUser(sellerUser).catch(err => console.log(err));
		await ctx.propertyList.updateProperty(property).catch(err => console.log(err));

		return property;
	}	

}

module.exports = UsersRegnetContract;
'use strict';

const AbstractPharmanetContract = require('./abstractPharmanetContract.js');
const Company = require('./lib/models/company.js');
const Drug = require('./lib/models/drug.js');
const PurchaseOrder = require('./lib/models/purchaseorder.js');
const Shipment = require('./lib/models/shipment.js');
const utils = require('./lib/utils/utility-functions.js');

/**
 * Contract defines functions that used to update the pharma network
 */

class PharmanetContract extends AbstractPharmanetContract {

	constructor() {
		// Provide a custom name to refer to this smart contract
		super('org.pharma-network.pharmanet');
	}

	/**
	 * 
	 * Function invoked during instantiation of the chaincode of pharma-network
	 * 
	 * @param {PharmaContext} ctx - Transaction Context for transactional functions of Pharmanet contract 
	 */
	 async instantiate(ctx) {
		console.log('chaincode \'pharmanet\' instantiated by ' + super.getStakeholderType(ctx));
	}

	/**
	 * 
	 * Function used for query transaction to start chaincode linked to peer of the network
	 * 
	 * @param {PharmaContext} ctx - Transaction Context for transactional functions of Pharmanet contract 
	 */
	async warmUp(ctx) {
		console.log('brought up peer for ' + super.getStakeholderType(ctx));
	}

	/* ****** All custom functions are defined below ***** */

	/**
	 * 
	 * Function to register new company of either of types: manufacturer, distributor, retailer, transporter or consumer
	 * 
	 * @param {PharmaContext} ctx - Transaction Context for transactional functions of Pharmanet contract 
	 * @param {string} companyCRN - Company Registration Number 
	 * @param {string} companyName - Name of Company 
	 * @param {string} location - Location of Company 
	 * @param {string} organisationRole - Role of company in the pharma network 
	 * @returns {string} success or error message of operation
	 */
	async registerCompany(ctx, companyCRN, companyName, location, organisationRole) {
		companyCRN = companyCRN.toUpperCase();
		companyName = companyName.toUpperCase();
		location = location.toUpperCase();
		organisationRole = organisationRole.toUpperCase();

		console.log("registering company with: " + companyCRN + ", " + companyName + ", " + location + ", " + organisationRole);

		if (!utils.isRegisteredType(organisationRole)) {
			return ('Error: Invalid Organization Role: ' + organisationRole);
		}

		// validate that registration request of organisationRole received on peers of that type of organization.
		// e.g. company with role of manufacturer should be submitted peers of manufacturer of the network and so on.
		let orgType = super.getStakeholderType(ctx);
		if (orgType !== organisationRole) {
			return ("Error: registerCompany request for " + organisationRole + " should be submitted on peers of " + organisationRole + " organization, instead it submitted on: " + orgType);
		}

		// const companyCRN = utils.generateCRN(companyName);
		// fetch company from the blockchain	
		
		//Check if the company with companyCRN and companyName already exists on the network.
		console.log("before call to getCompany(): " + companyCRN + ", " + companyName + ", " + location + ", " + organisationRole);
		let company = await ctx.companyList.getCompany(companyCRN, companyName).catch(err => console.log(err));
		if (company) {
			//			throw new Error('Company Already Exists for companyCRN:' + companyCRN + ', and name: ' + companyName);
			return ('Error: Company Already Exists for companyCRN: ' + companyCRN + ', and name: ' + companyName);
		}
		else {
			// create new company object and add it to the ledger
			let newCompanyObject = Company.createInstance(companyCRN, companyName, location, organisationRole);
			newCompanyObject = await ctx.companyList.addCompany(newCompanyObject);
			console.log("newCompanyObject: " + JSON.stringify(newCompanyObject));
			return ("Success: " + "company registered with companyCRN: " + companyCRN + ", and companyName: " + companyName + " on pankaj-pharma-network");
		}
	}

	/**
	 * 
	 * Function to addDrug in the pharma-network.
	 * 
	 * @param {PharmaContext} ctx - Transaction Context for transactional functions of Pharmanet contract 
	 * @param {string} drugName - Name of Drug 
	 * @param {string} serialNo - Serial number of Drug 
	 * @param {string} mfgDate - Date of manufacturing of the drug specified by drugName and serialNo 
	 * @param {string} expDate - Date of expiry of the drug specified by drugName and serialNo 
	 * @param {string} companyCRN - Company Registration Number 
	 * @returns {string} success or error response of operation
	 */
	async addDrug(ctx, drugName, serialNo, mfgDate, expDate, companyCRN) {
		console.log("registering drug with: " + drugName + ", " + serialNo + ", " + mfgDate + ", " + expDate + ", " + companyCRN);
		serialNo = serialNo.toUpperCase();
		drugName = drugName.toUpperCase();
		companyCRN = companyCRN.toUpperCase();

		//verify if the company has role Manufacturer, send error response if not.
		let orgType = super.getStakeholderType(ctx);
		if (orgType !== 'MANUFACTURER') {
			return ("Error: addDrug request should be submitted on peers of MANUFACTURER organization, instead it submitted on: " + orgType);
		}

		// check if drug with drugName and serialNo already present on the netowrk.
		let drug = await ctx.drugList.getDrug(drugName, serialNo).catch(err => console.log(err));
		if (drug) {
			return ('Error: Drug Already Exists for drugName: ' + drugName + ', and serialNo: ' + serialNo);
		}

		// check if the company adding drug exists and have role of Manufacturer. If not, send the error response accordingly.
		let mfgCompany = await ctx.companyList.getCompanyUsingCRN(companyCRN);
		if (!mfgCompany) {
			return ('Error: Invalid companyCRN. Manufacturer does not exist for companyCRN: ' + companyCRN);
		}
		if (mfgCompany.organisationRole !== 'MANUFACTURER') {
			return ("Error: Only company with Manufacturer role can add the drug. companyCRN: " + companyCRN + " has role : " + mfgCompany.organisationRole);
		}
		let manufacturerKey = mfgCompany.companyID;


		// create the drug with the specified details and add to the network.
		let newDrugObject = Drug.createInstance(drugName, serialNo, mfgDate, expDate, manufacturerKey);
		newDrugObject = await ctx.drugList.addDrug(newDrugObject);
		console.log("newDrugObject: " + JSON.stringify(newDrugObject));
		return ("Success: " + "drug added with drugName: " + drugName + ", and serialNo: " + serialNo + " for manufacturer: " + companyCRN + " on pankaj-pharma-network");
	}

	/**
	 * 
	 * Function to create a Purchase Order on the network
	 * 
	 * @param {PharmaContext} ctx - Transaction Context for transactional functions of Pharmanet contract 
	 * @param {string} buyerCRN - Company Registration Number of buyer company 
	 * @param {string} sellerCRN - Company Registration Number of seller company 
	 * @param {string} drugName - Name of Drug 
	 * @param {string} quantity - quantity of drug to order 
	 * @returns {string} the success or error response of the operation
	 */
	async createPO(ctx, buyerCRN, sellerCRN, drugName, quantity) {
		buyerCRN = buyerCRN.toUpperCase();
		sellerCRN = sellerCRN.toUpperCase();
		drugName = drugName.toUpperCase();

		// check the MSP to which request is submitted. Only Distributor or Retailer can raise a Purchase Order
		let orgType = super.getStakeholderType(ctx);
		if (orgType !== 'DISTRIBUTOR' && orgType !== 'RETAILER') {
			return ("Error: createPO request should be submitted on peers of DISTRIBUTOR or RETAILER organization, instead it submitted on: " + orgType);
		}

		// verify the minimum ordered quantity is atleast one.
		if (quantity < 1) {
			return ("Error: Invalid purchase order request, quantity should be at least 1");
		}

		// check if company with buyerCRN exists
		let buyerCompany = await ctx.companyList.getCompanyUsingCRN(buyerCRN);
		if (!buyerCompany) {
			return ('Error: Invalid buyerCRN. Company does not exist for buyerCRN: ' + buyerCRN);
		}
		// check if the company has distributor or retailer role.
		if (!(buyerCompany.organisationRole === 'DISTRIBUTOR' || buyerCompany.organisationRole === 'RETAILER')) {
			return ("Error: Company with Distributor or Retailer role can create PO. buyerCRN: " + buyerCRN + " has role : " + buyerCompany.organisationRole);
		}

		// verify the PO request for retailer organization received on retailer network peers, and distributor organization on distributor network peers.
		if(orgType!==buyerCompany.organisationRole){
			return ("Error: createPO for: " + buyerCompany.organisationRole +" should be submitted on "+buyerCompany.organisationRole+", instead submitted on peers of : " + orgType);
		}

		// verify the seller company exists on the network
		let sellerCompany = await ctx.companyList.getCompanyUsingCRN(sellerCRN);
		if (!sellerCompany) {
			return ('Error: Invalid sellerCRN. Company does not exist for sellerCRN: ' + sellerCRN);
		}

		// distributor can purchase only from manufacturer, and retailer can purchase only from distributor.
		// verify the buyer and seller organizations fulfil this criteria.
		if (buyerCompany.organisationRole === 'DISTRIBUTOR') {
			if (sellerCompany.organisationRole !== 'MANUFACTURER') {
				return ('Error: buyer is DISTRIBUTOR, and can purchase from MANUFACTURER, but cannot purchase from seller that is: ' + sellerCompany.organisationRole);
			}
		} else if (buyerCompany.organisationRole === 'RETAILER') {
			if (sellerCompany.organisationRole !== 'DISTRIBUTOR') {
				return ('Error: buyer is RETAILER, and can purchase from DISTRIBUTOR, but cannot purchase from seller that is: ' + sellerCompany.organisationRole);
			}
		}

		// create new instance of purchase order and add it to the ledger
		let newPurchaseOrderObject = PurchaseOrder.createInstance(buyerCRN, buyerCompany.companyID, sellerCompany.companyID, drugName, quantity);
		newPurchaseOrderObject = await ctx.purchaseorderList.addPurchaseOrder(newPurchaseOrderObject);
		console.log("newPurchaseOrderObject: " + JSON.stringify(newPurchaseOrderObject));
		return ("Success: " + "purchase order added with buyerCRN: " + buyerCRN + ", sellerCRN: " + sellerCRN + ", drugName: " + drugName + " and quantity: " + quantity + " on pankaj-pharma-network");
	}

	/**
	 * 
	 * Function to create a shipment corresponding to the purchase order raised in the system earlier
	 * 
	 * @param {PharmaContext} ctx - Transaction Context for transactional functions of Pharmanet contract 
	 * @param {string} buyerCRN - Company Registration Number of buyer company 
	 * @param {string} drugName - Name of Drug 
	 * @param {string[]} listOfAssets - List of serial numbers of drugs 
	 * @param {string} transporterCRN - Company Registration Number of transporter company 
	 * @returns {string} success or error of the operation
	 */
	async createShipment(ctx, buyerCRN, drugName, listOfAssets, transporterCRN) {

		// Only manufacturer or distributor can create a shipment, hence verify the operation is called from peers of either of the network
		let orgType = super.getStakeholderType(ctx);
		if (orgType !== 'MANUFACTURER' && orgType !== 'DISTRIBUTOR') {
			return ("Error: createShipment request should be submitted on peers of MANUFACTURER or DISTRIBUTOR organization, instead it submitted on: " + orgType);
		}


		listOfAssets = JSON.parse(listOfAssets);
		buyerCRN = buyerCRN.toUpperCase();
		drugName = drugName.toUpperCase();

		// validate if list of assets is not empty
		if (listOfAssets.length < 1) {
			return ("Error: Invalid shipment request, list of assets is empty...!");
		}

		// convert all asset serial numbers in upper case
		for (let i = 0; i < listOfAssets.length; i++) {
			listOfAssets[i] = listOfAssets[i].toString().toUpperCase();
		}
		transporterCRN = transporterCRN.toUpperCase();

		// retrieve purchase order corresponding to the shipment request
		let currentPO = await ctx.purchaseorderList.getPurchaseOrder(buyerCRN, drugName);
		if (!currentPO){
			return ("Error: Invalid shipment request, purchase order for buyerCRN: " + buyerCRN + " and drugName: " + drugName + " does not found");
		}

		// verify the quantity in purchase order is the same as number of assets in the shipment
		if (currentPO.quantity != listOfAssets.length) {
			return ("Error: Invalid shipment request, number of items ordered in PO: " + currentPO.quantity + " and number of items requested in shipment: " + listOfAssets.length + " does not match");
		}

		//check if all assets in the assets list exist on the network, if either of those does not exist, sent it in the response
		let assetKeys = [];
		let invalidAssets = [];
		let assets = [];
		for (let i = 0; i < listOfAssets.length; i++) {
			let currentDrug = await ctx.drugList.getDrug(drugName, listOfAssets[i].toUpperCase());
			if (currentDrug) {
				assetKeys.push(currentDrug.productID);
				assets.push(currentDrug);
			} else {
				invalidAssets.push(listOfAssets[i]);
			}
		}

		// check if any invalid assets in the request, send the error mentioning those assets
		if (invalidAssets.length > 0) {
			let invalidSerialNos = invalidAssets.map(asset => asset.toString()).join(', ');
			return ("Error: Invalid shipment request, these items are not registered on network: " + invalidSerialNos);
		}

		// verify that the company with transporterCRN exists and have role as transporter, if not send the error back
		let transporter = await ctx.companyList.getCompanyUsingCRN(transporterCRN);
		if (!transporter) {
			return ("Error: Invalid shipment request, transporter with companyCRN: " + transporterCRN + " does not found on the network");
		}
		if (transporter.organisationRole !== 'TRANSPORTER') {
			return ("Error: Invalid shipment request, transporter with companyCRN: " + transporterCRN + " have " + transporter.organisationRole + ", only TRANSPORTER role is allowed");
		}

		let sellerKey = currentPO.seller;
		let transporterKey = transporter.companyID;

		// create new shipment object and add to the ledger
		let newShipmentObject = Shipment.createInstance(sellerKey, buyerCRN, drugName, assetKeys, transporterKey);
		newShipmentObject = await ctx.shipmentList.addShipment(newShipmentObject);
		console.log("newShipmentObject: " + JSON.stringify(newShipmentObject));

		// update the owner of each drug in the shipment with the transporter's composite key
		for (let i = 0; i < assets; i++) {
			assets[i].owner = transporterKey;
			await ctx.drugList.updateDrug(assets[i]);
		}

		return ("Success: " + "shipment created with buyerCRN: " + buyerCRN + ", drugName: " + drugName + " and transporterCRN: " + transporterCRN + " on pankaj-pharma-network");
	}

	/**
	 * 
	 * Function used by transpertor to update the shipment on the pharma network
	 * 
	 * @param {PharmaContext} ctx - Transaction Context for transactional functions of Pharmanet contract 
	 * @param {string} buyerCRN - Company Registration Number of buyer company 
	 * @param {string} drugName - Name of Drug 
	 * @param {string} transporterCRN - Company Registration Number of transporter company 
	 * @returns {string} success or error message as per the output of the operation
	 */
	async updateShipment(ctx, buyerCRN, drugName, transporterCRN) {

		// verify that this request is received on peers of transporter network.
		let orgType = super.getStakeholderType(ctx);
		if (orgType !== 'TRANSPORTER') {
			return ("Error: updateShipment request should be submitted on peers of TRANSPORTER organization, instead it submitted on: " + orgType);
		}


		buyerCRN = buyerCRN.toUpperCase();
		drugName = drugName.toUpperCase();
		transporterCRN = transporterCRN.toUpperCase();

		// fetch the shipment object corresponding to the buyer's CRN and drug name
		// send error if does not found
		let shipment = await ctx.shipmentList.getShipment(buyerCRN, drugName);
		if (!shipment) {
			return ("Error: Invalid update Shipment request, Shipment with buyerCRN: " + buyerCRN + " and drugName: " + drugName + " does not found");
		}

		// fetch the transporter using the transporterCRN, and verify it has role of transporter, else send the error back.
		let transporter = await ctx.companyList.getCompanyUsingCRN(transporterCRN);
		if (!transporter) {
			return ("Error: Invalid shipment update request, transporter with companyCRN: " + transporterCRN + " does not found on the network");
		}
		if (transporter.organisationRole !== 'TRANSPORTER') {
			return ("Error: Invalid shipment update request, transporter with companyCRN: " + transporterCRN + " have " + transporter.organisationRole + ", only TRANSPORTER role is allowed");
		}

		// fetch the transporter associated with the shipment, throw error if not found
		let shipmentTransporter = await ctx.companyList.getCompanyByCompositeKey(shipment.transporter);
		if (!shipmentTransporter) {
			return ("Error: Invalid shipment, transporter associated with the shipment not found")
		}

		// verify that the transporter associated with the shipment is same as the one sent to transporterCRN of this method
		if (shipment.transporter !== transporter.companyID) {
			return (`Invalid shipment update request initiated by ${transportCRN}, Shipment can be updated only by: ${shipmentTransporter.companyCRN}`);
		}

		// fetch the buyer from the ledger
		let buyer = await ctx.companyList.getCompanyUsingCRN(buyerCRN);
		if (!buyer) {
			return ("Error: Invalid shipment update request, buyer with companyCRN: " + buyerCRN + " does not found on the network");
		}

		// update the status of shipment to 'delivered', and update it to the ledger
		shipment.status = 'delivered';
		await ctx.shipmentList.updateShipment(shipment);

		// update owner of each asset in the asset list to the buyer,  and also add the shipment composite key to the list of shipmentids of each asset
		for (let i = 0; i < shipment.assets.length; i++) {
			let asset = await ctx.drugList.getDrugByCompositeKey(shipment.assets[i]);
			asset.owner = buyer.companyID;
			asset.shipment.push(shipment.shipmentID);
			await ctx.drugList.updateDrug(asset);
		}

		return ("Success: " + "status for Shipment with " + buyerCRN + "," + drugName + "and " + transporterCRN + " updated to delivered, and ownership of associated drugs transferred accordingly");
	}

	/**
	 * 
	 * Function to record the selling activity of a drug to an end consumer
	 * 
	 * @param {PharmaContext} ctx - Transaction Context for transactional functions of Pharmanet contract 
	 * @param {string} drugName - Name of Drug 
	 * @param {string} serialNo - Serial number of Drug 
	 * @param {string} retailerCRN - Company Registration Number of retailer company 
	 * @param {string} customerAadhar - Aadhar number of end customer 
	 * @returns {string} success or error of the operation
	 */
	async retailDrug(ctx, drugName, serialNo, retailerCRN, customerAadhar) {
		drugName = drugName.toUpperCase();
		serialNo = serialNo.toUpperCase();
		retailerCRN = retailerCRN.toUpperCase();
		customerAadhar = customerAadhar.toUpperCase();

		// verify this operation is called on peers of retailer network, else send the error back
		let orgType = super.getStakeholderType(ctx);
		if (orgType !== 'RETAILER') {
			return ("Error: retailDrug request should be submitted on peers of RETAILER organization, instead it submitted on: " + orgType);
		}

		// fetch the retailer company from the ledger and verify it has retailer role, send error if otherwise
		let retailer = await ctx.companyList.getCompanyUsingCRN(retailerCRN);
		if (!retailer) {
			return ("Error: Invalid retailDrug request, retailer with companyCRN: " + retailerCRN + " does not found on the network");
		}
		if (retailer.organisationRole !== 'RETAILER') {
			return ("Error: Invalid retailDrug request, retailer with companyCRN: " + retailerCRN + " have " + retailer.organisationRole + ", only RETAILER role is allowed");
		}

		// fetch the drug the retailer wish to sell to the customer, send error if not found
		let drug = await ctx.drugList.getDrug(drugName, serialNo);
		if (!drug) {
			return ("Error: Invalid drug details, drug with name: " + drugName + ", and serialNo: " + serialNo + " not found on network");
		}

		// verify that retailer is the owner of the drug, send error otherwise
		if (drug.owner !== retailer.companyID) {
			let ownerCompany = await ctx.companyList.getCompanyByCompositeKey(drug.owner);
			return ("Error: Retailer, who is owner of the drug, can sale the drug. Requester is: " + retailerCRN + ", however the drug owner is: " + ownerCompany.companyCRN);
		}

		// update the owner of drug to the Aadhar card number of customer, and update on the ledger
		drug.owner = customerAadhar;
		await ctx.drugList.updateDrug(drug);

		return ("Success: " + retailerCRN + " sold " + drugName + "-" + serialNo + " to " + customerAadhar);
	}

	/**
	 * 
	 * Function to retrieve current state of the Drug
	 * 
	 * @param {PharmaContext} ctx - Transaction Context for transactional functions of Pharmanet contract 
	 * @param {string} drugName - Name of Drug 
	 * @param {string} serialNo - Serial number of Drug 
	 * @returns {Drug} assocated with the drug name and serial number
	 */
	async viewDrugCurrentState(ctx, drugName, serialNo) {
		return this.viewDrug(ctx, drugName, serialNo);
	}

	/**
	 * 
	 * Function to retrieve history of the Drug
	 * 
	 * @param {PharmaContext} ctx - Transaction Context for transactional functions of Pharmanet contract 
	 * @param {string} drugName - Name of Drug 
	 * @param {string} serialNo - Serial number of Drug 
	 * @returns {Drug[]} list of all states of the drug after each transformation operation
	 */	
	async viewHistory(ctx, drugName, serialNo) {
		return await ctx.drugList.getDrugHistory(drugName, serialNo);
	}

	/**
	 * 
	 * Function to retrieve current state of the Drug
	 * 
	 * @param {PharmaContext} ctx - Transaction Context for transactional functions of Pharmanet contract 
	 * @param {string} drugName - Name of Drug 
	 * @param {string} serialNo - Serial number of Drug 
	 * @returns {Drug} assocated with the drug name and serial number
	 */
	async viewDrug(ctx, drugName, serialNo) {
		drugName = drugName.toUpperCase();
		serialNo = serialNo.toUpperCase();

		return await ctx.drugList.getDrug(drugName, serialNo).catch(err => console.log(err));
	}

	/**
	 * 
	 * Function to retrieve current state of the Company
	 * 
	 * @param {PharmaContext} ctx - Transaction Context for transactional functions of Pharmanet contract 
	 * @param {string} companyCRN - Company Registration Number 
	 * @param {string} companyName - Name of Company 
	 * @returns {Company} assocated with the company CRN and company Name
	 */
	async viewCompany(ctx, companyCRN, companyName) {
		companyCRN = companyCRN.toUpperCase();
		companyName = companyName.toUpperCase();
		return await ctx.companyList.getCompany(companyCRN, companyName).catch(err => console.log(err));
	}

	/**
	 * 
	 * Function to retrieve current state of the Purchase Order
	 * 
	 * @param {PharmaContext} ctx - Transaction Context for transactional functions of Pharmanet contract 
	 * @param {string} buyerCRN - Company Registration Number of buyer company 
	 * @param {string} drugName - Name of Drug 
	 * @returns {PurchaseOrder} assocated with the buyer CRN and drug name
	 */
	async viewPO(ctx, buyerCRN, drugName) {
		buyerCRN = buyerCRN.toUpperCase();
		drugName = drugName.toUpperCase();
		return await ctx.purchaseorderList.getPurchaseOrder(buyerCRN, drugName).catch(err => console.log(err));
	}

	
	/**
	 * 
	 * Function to retrieve current state of the Shipment
	 * 
	 * @param {PharmaContext} ctx - Transaction Context for transactional functions of Pharmanet contract 
	 * @param {string} buyerCRN - Company Registration Number of buyer company 
	 * @param {string} drugName - Name of Drug 
	 * @returns {Shipment} assocated with the buyer CRN and drug name
	 */
	 async viewShipment(ctx, buyerCRN, drugName) {
		buyerCRN = buyerCRN.toUpperCase();
		drugName = drugName.toUpperCase();
		let ShipmentDetails = {};
		let shipment = await ctx.shipmentList.getShipment(buyerCRN, drugName).catch(err => console.log(err));
		let drugAssets = [];
		ShipmentDetails.shipment=shipment;

		// fetch the drug object and populate in the assets list in the shipment response
		for(let i=0; i < shipment.assets.length; i++){
			let asset = await ctx.drugList.getDrugByCompositeKey(shipment.assets[i]);
			drugAssets.push(asset);
		}
		ShipmentDetails.assets=drugAssets;

		return ShipmentDetails;
	}

	/**
	 * 
	 * Function to retrieve current state of the Purchase Order
	 * 
	 * @param {PharmaContext} ctx - Transaction Context for transactional functions of Pharmanet contract 
	 * @param {string} companyType - Companies of companyType will be fetched('manufacturer', 'distributor', 'retailer', 'transporter' or 'consumer') to fetch. Keep empty or 'All' to retrieve all companies
	 * @returns {Company[]} of the type send in the companyType
	 */
	async getRegisteredCompanies(ctx, companyType = 'All') {
		// fetch all companies of given type, and fetch all companies if companyType is not provided
		let queryObject = {};
		queryObject.selector = {};
		queryObject.selector.class = Company.getClass();
		if (companyType !== 'All') {
			queryObject.selector.organisationRole = companyType.toUpperCase();
		}

		let queryString = JSON.stringify(queryObject);
		let companyList = await ctx.companyList
			.getCompanyList(queryString)
			.catch(err => console.log(err));

		console.log(companyList);
		return companyList;
	}
}

module.exports = PharmanetContract;
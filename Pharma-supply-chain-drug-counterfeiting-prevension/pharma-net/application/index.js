const express = require('express');
const app = express();
const cors = require('cors');
const port = 3000;

// Import all function modules
const addToWallet = require('./1_addToWallet');
const registerCompany = require('./2_registerCompany');
const viewCompany = require('./3_viewCompany');
const addDrug = require('./4_addDrug');
const viewDrug = require('./5_viewDrug');
const createPO = require('./6_createPO');
const viewPO = require('./7_viewPO');
const createShipment = require('./8_createShipment');
const viewShipment = require('./9_viewShipment');
const updateShipment = require('./10_updateShipment');
const retailDrug = require('./11_retailDrug');
const viewHistory = require('./12_viewHistory');
const viewDrugCurrentState = require('./13_viewDrugCurrentState');



// Define Express app settings
app.use(cors());
app.use(express.json()); // for parsing application/json
app.use(express.urlencoded({ extended: true })); // for parsing application/x-www-form-urlencoded
app.set('title', 'Pankaj\'s Pharma Application to prevent drug counterfeiting...!');

app.get('/', (req, res) => res.send('Pankaj welcomes you to Pharma network application...!'));

app.post('/addToWallet', (req, res) => {
	addToWallet.execute(req.body.orgGroupName, req.body.certificatePath, req.body.privateKeyPath)
			.then(() => {
				console.log('User credentials added to wallet for: ' + req.body.orgGroupName);
				const result = {
					status: 'success',
					message: 'User credentials added to wallet for: ' + req.body.orgGroupName
				};
				res.json(result);
			})
			.catch((e) => {
				const result = {
					status: 'error',
					message: 'Failed',
					error: e
				};
				res.status(500).send(result);
			});
});

app.post('/registerCompany', (req, res) => {
	console.log('registerCompany.req.body: ' + JSON.stringify(req.body));
	registerCompany.execute(req.body.orgGroupName, req.body.companyCRN, req.body.companyName, req.body.location, req.body.organizationRole)
			.then((response) => {
				console.log('registerCompany Invoke transaction completed');
				let result = {transactionType: 'Invoke'};

				if(response.startsWith('Error:')){
					result.status='error';
					result.message = response;
				}else{
					result.status='success';
					result.message = response;
				}
				res.json(result);
			}).catch((e) => {
				const result = {
					status: 'error',
					message: 'Failed',
					error: e
				};
				res.status(500).send(result);
			});
});

app.post('/viewCompany', (req, res) => {
	console.log('viewCompany.req.body: ' + JSON.stringify(req.body));
	viewCompany.execute(req.body.orgGroupName, req.body.companyCRN, req.body.companyName)
			.then((response) => {
				console.log('viewCompany Query transaction completed');
				let result = {transactionType: 'Query'};

				if(response.startsWith('Error:')){
					result.status='error';
					result.message = response;
				}else{
					result.status='success';
					result.company = JSON.parse(response);
				}
				res.json(result);
			}).catch((e) => {
				const result = {
					status: 'error',
					message: 'Failed',
					error: e
				};
				res.status(500).send(result);
			});
});

app.post('/addDrug', (req, res) => {
	console.log('addDrug.req.body: ' + JSON.stringify(req.body));
	addDrug.execute(req.body.orgGroupName, req.body.drugName, req.body.serialNo, req.body.mfgDate, req.body.expDate, req.body.companyCRN)
			.then((response) => {
				console.log('addDrug Invoke transaction completed');
				let result = {transactionType: 'Invoke'};

				if(response.startsWith('Error:')){
					result.status='error';
					result.message = response;
				}else{
					result.status='success';
					result.message = response;
				}
				res.json(result);
			}).catch((e) => {
				const result = {
					status: 'error',
					message: 'Failed',
					error: e
				};
				res.status(500).send(result);
			});
});

app.post('/viewDrug', (req, res) => {
	console.log('viewDrug.req.body: ' + JSON.stringify(req.body));
	viewDrug.execute(req.body.orgGroupName, req.body.drugName, req.body.serialNo)
			.then((response) => {
				console.log('viewDrug Query transaction completed');
				let result = {transactionType: 'Query'};

				if(response.startsWith('Error:')){
					result.status='error';
					result.message = response;
				}else{
					result.status='success';
					result.drug = JSON.parse(response);
				}
				res.json(result);
			}).catch((e) => {
				const result = {
					status: 'error',
					message: 'Failed',
					error: e
				};
				res.status(500).send(result);
			});
});

app.post('/createPO', (req, res) => {
	console.log('createPO.req.body: ' + JSON.stringify(req.body));
	createPO.execute(req.body.orgGroupName, req.body.buyerCRN, req.body.sellerCRN, req.body.drugName, req.body.quantity)
			.then((response) => {
				console.log('createPO Invoke transaction completed');
				let result = {transactionType: 'Invoke'};

				if(response.startsWith('Error:')){
					result.status='error';
					result.message = response;
				}else{
					result.status='success';
					result.message = response;
				}
				res.json(result);
			}).catch((e) => {
				const result = {
					status: 'error',
					message: 'Failed',
					error: e
				};
				res.status(500).send(result);
			});
});

app.post('/viewPO', (req, res) => {
	console.log('viewPO.req.body: ' + JSON.stringify(req.body));
	viewPO.execute(req.body.orgGroupName, req.body.buyerCRN, req.body.drugName)
			.then((response) => {
				console.log('viewPO Query transaction completed');
				let result = {transactionType: 'Query'};

				if(response.startsWith('Error:')){
					result.status='error';
					result.message = response;
				}else{
					result.status='success';
					result.purchaseOrder = JSON.parse(response);
				}
				res.json(result);
			}).catch((e) => {
				const result = {
					status: 'error',
					message: 'Failed',
					error: e
				};
				res.status(500).send(result);
			});
});


app.post('/createShipment', (req, res) => {
	console.log('createShipment.req.body: ' + JSON.stringify(req.body));
	createShipment.execute(req.body.orgGroupName, req.body.buyerCRN, req.body.drugName, req.body.listOfAssets, req.body.transporterCRN)
			.then((response) => {
				console.log('createShipment Invoke transaction completed');
				let result = {transactionType: 'Invoke'};

				if(response.startsWith('Error:')){
					result.status='error';
					result.message = response;
				}else{
					result.status='success';
					result.message = response;
				}
				res.json(result);
			}).catch((e) => {
				const result = {
					status: 'error',
					message: 'Failed',
					error: e
				};
				res.status(500).send(result);
			});
});

app.post('/viewShipment', (req, res) => {
	console.log('viewShipment.req.body: ' + JSON.stringify(req.body));
	viewShipment.execute(req.body.orgGroupName, req.body.buyerCRN, req.body.drugName)
			.then((response) => {
				console.log('viewShipment Query transaction completed');
				let result = {transactionType: 'Query'};

				if(response.startsWith('Error:')){
					result.status='error';
					result.message = response;
				}else{
					result.status='success';
					result.shipment = JSON.parse(response);
				}
				res.json(result);
			}).catch((e) => {
				const result = {
					status: 'error',
					message: 'Failed',
					error: e
				};
				res.status(500).send(result);
			});
});

app.post('/updateShipment', (req, res) => {
	console.log('updateShipment.req.body: ' + JSON.stringify(req.body));
	updateShipment.execute(req.body.orgGroupName, req.body.buyerCRN, req.body.drugName, req.body.transporterCRN)
			.then((response) => {
				console.log('updateShipment Invoke transaction completed');
				let result = {transactionType: 'Invoke'};

				if(response.startsWith('Error:')){
					result.status='error';
					result.message = response;
				}else{
					result.status='success';
					result.message = response;
				}
				res.json(result);
			}).catch((e) => {
				const result = {
					status: 'error',
					message: 'Failed',
					error: e
				};
				res.status(500).send(result);
			});
});

app.post('/retailDrug', (req, res) => {
	console.log('retailDrug.req.body: ' + JSON.stringify(req.body));
	retailDrug.execute(req.body.orgGroupName, req.body.drugName, req.body.serialNo, req.body.retailerCRN, req.body.customerAadhar)
			.then((response) => {
				console.log('retailDrug Invoke transaction completed');
				let result = {transactionType: 'Invoke'};

				if(response.startsWith('Error:')){
					result.status='error';
					result.message = response;
				}else{
					result.status='success';
					result.message = response;
				}
				res.json(result);
			}).catch((e) => {
				const result = {
					status: 'error',
					message: 'Failed',
					error: e
				};
				res.status(500).send(result);
			});
});

app.post('/viewHistory', (req, res) => {
	console.log('viewHistory.req.body: ' + JSON.stringify(req.body));
	viewHistory.execute(req.body.orgGroupName, req.body.drugName, req.body.serialNo)
			.then((response) => {
				console.log('viewHistory Query transaction completed');
				let result = {transactionType: 'Query'};

				if(response.startsWith('Error:')){
					result.status='error';
					result.message = response;
				}else{
					result.status='success';
					result.drug = JSON.parse(response);
				}
				res.json(result);
			}).catch((e) => {
				const result = {
					status: 'error',
					message: 'Failed',
					error: e
				};
				res.status(500).send(result);
			});
});

app.post('/viewDrugCurrentState', (req, res) => {
	console.log('viewDrugCurrentState.req.body: ' + JSON.stringify(req.body));
	viewDrugCurrentState.execute(req.body.orgGroupName, req.body.drugName, req.body.serialNo)
			.then((response) => {
				console.log('viewDrugCurrentState Query transaction completed');
				let result = {transactionType: 'Query'};

				if(response.startsWith('Error:')){
					result.status='error';
					result.message = response;
				}else{
					result.status='success';
					result.drug = JSON.parse(response);
				}
				res.json(result);
			}).catch((e) => {
				const result = {
					status: 'error',
					message: 'Failed',
					error: e
				};
				res.status(500).send(result);
			});
});

app.listen(port, () => console.log(`Distributed Pankaj-Pharma-network App listening on port ${port}!`));
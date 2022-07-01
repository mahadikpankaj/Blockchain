#!/bin/bash

CHANNEL_NAME="$1"
DELAY="$2"
LANGUAGE="$3"
TIMEOUT="$4"
VERBOSE="$5"
NO_CHAINCODE="$6"
: ${CHANNEL_NAME:="mychannel"}
: ${DELAY:="3"}
: ${LANGUAGE:="golang"}
: ${TIMEOUT:="10"}
: ${VERBOSE:="false"}
: ${NO_CHAINCODE:="false"}
LANGUAGE=`echo "$LANGUAGE" | tr [:upper:] [:lower:]`
COUNTER=1
MAX_RETRY=10


echo "Channel name : "$CHANNEL_NAME

# import utils
. scripts/utils.sh

# start the executtion of business cases
printMessage "Executing Use Cases"

# set below variables which will be used inside scripts to execute
# Invoke requestNewUser function for user: Pankaj
USERNAME="Pankaj Mahadik"
AADHAR="8844 4455 6677"
EMAIL="mahadikpankaj@gmail.com"
PHONE="9890787870"
printMessage "Invoking requestNewUser for user: ${USERNAME} and ${AADHAR} - (executing on peer0.users)"
requestNewUser "peer0" "users"

# Verify that new user registration request is created
printMessage "Querying Request object for user: ${USERNAME} and ${AADHAR} - (executing on peer0.users)"
chaincodeQueryUserRequest "peer0" "users" "Pankaj Mahadik" "8844 4455 6677" "email" "mahadikpankaj@gmail.com"

# invoke requestNewUser for user: Aakash
USERNAME="Aakash Bansal"
AADHAR="1122 3344 5566"
EMAIL="aakashbansal@gmail.com"
PHONE="8523698741"
printMessage "Invoking requestNewUser for user: ${USERNAME} and ${AADHAR} - (executing on peer0.users)"
requestNewUser "peer0" "users"

# Verify that the user registration request for Aakash is created
printMessage "Querying Request object for user: ${USERNAME} and ${AADHAR} - (executing on peer0.users)"
chaincodeQueryUserRequest "peer0" "users" "Aakash Bansal" "1122 3344 5566" "email" "aakashbansal@gmail.com"

# Query all the users in the system
printMessage "Querying all User Registration Requests - (executing on peer0.registrar)"
chaincodeQueryAllUserRegistrationRequests "peer0" "registrar"

# Approve user registration request for Pankaj
USERNAME="Pankaj Mahadik"
AADHAR="8844 4455 6677"
printMessage "Approving User Registration Request for user: ${USERNAME} and ${AADHAR} - (executing on peer0.registrar)"
chaincodeApproveUserRegistrationRequest "peer0" "registrar"
printMessage "Query the User object to verify is created for user: ${USERNAME} and ${AADHAR} - (executing on peer1.registrar)"
chaincodeQueryUser "peer1" "registrar" "Pankaj Mahadik" "8844 4455 6677" "email" "mahadikpankaj@gmail.com"

# Approve user registration request for Aakash
USERNAME="Aakash Bansal"
AADHAR="1122 3344 5566"
printMessage "Approving User Registration Request for user: ${USERNAME} and ${AADHAR} - (executing on peer1.registrar)"
chaincodeApproveUserRegistrationRequest "Peer1" "registrar"
# Verify the user is created
printMessage "Query the User object to verify is created for user: ${USERNAME} and ${AADHAR} - (executing on peer0.registrar)"
chaincodeQueryUser "peer0" "registrar" "Aakash Bansal" "1122 3344 5566" "email" "aakashbansal@gmail.com"

# Query all user objects in the system
printMessage "Query all Users in the system - (executing on peer0.users)"
chaincodeQueryAllUsers "peer0" "users"


# Create property registration request for user Pankaj.
USERNAME="Pankaj Mahadik"
AADHAR="8844 4455 6677"
PROPERTYID=1
PRICE=1000
printMessage "Create Property Registration request for PropertyId: ${PROPERTYID}, user: ${USERNAME} and ${AADHAR} - (executing on peer0.users)"
propertyRegistrationRequest "peer0" "users"
# Verify the property registration request is created
printMessage "Verify the property registration request created correctly for PropertyId: ${PROPERTYID} - (executing on peer0.registrar)"
chaincodeQueryPropertyRequest "peer0" "registrar" 1 "owner" "PANKAJMAHADIK-884444556677"

# Approve the property registration request
PROPERTYID=1
printMessage "Approve Property registration request for PropertyId: ${PROPERTYID} - (executing on peer0.registrar)"
chaincodeApprovePropertyRegistrationRequest "peer0" "registrar"

# Verify the property object is created
printMessage "Verify the property object created correctly for PropertyId: ${PROPERTYID} - (executing on peer0.users)"
chaincodeQueryProperty "peer0" "users" 1 "owner" "PANKAJMAHADIK-884444556677"

# Create property registration request for user Aakash.
USERNAME="Aakash Bansal"
AADHAR="1122 3344 5566"
PROPERTYID=2
PRICE=800
printMessage "Create Property Registration request for PropertyId: ${PROPERTYID}, user: ${USERNAME} and ${AADHAR} - (executing on peer0.users)"
propertyRegistrationRequest "peer0" "users"
# Verify the property registration request is created
printMessage "Verify the property registration request created correctly for PropertyId: ${PROPERTYID} - (executing on peer1.registrar)"
chaincodeQueryPropertyRequest "peer1" "registrar" 2 "owner" "AAKASHBANSAL-112233445566"

# Approve the property registration request
PROPERTYID=2
printMessage "Approve Property registration request for PropertyId: ${PROPERTYID} - (executing on peer1.registrar)"
chaincodeApprovePropertyRegistrationRequest "peer1" "registrar"
# Verify the property object is created
printMessage "Verify the property object created correctly for PropertyId: ${PROPERTYID} - (executing on peer0.users)"
chaincodeQueryProperty "peer0" "users" 2 "owner" "AAKASHBANSAL-112233445566"

# Query all properties in the system
printMessage "Query all Properties - (executing on peer0.users)"
chaincodeQueryAllProperties "peer0" "users"

# Recharge the account for user Pankaj with 100
USERNAME="Pankaj Mahadik"
AADHAR="8844 4455 6677"
TXNID="upg100"
printMessage "Invoke rechargeAccount of upg100 for user: ${USERNAME} and ${AADHAR} - (executing on peer0.users)"
chaincodeRechargeAccount "peer0" "users"
# Verify the Pankaj's account has balance of 100 upgradCoins
printMessage "Verify balance amount of 100 for user: ${USERNAME} and ${AADHAR} - (executing on peer0.registrar)"
chaincodeQueryUser "peer0" "registrar" "Pankaj Mahadik" "8844 4455 6677" "upgradCoins" "100"

# Recharge the account for user Pankaj with 500
USERNAME="Pankaj Mahadik"
AADHAR="8844 4455 6677"
TXNID="upg500"
printMessage "Invoke rechargeAccount of upg500 for user: ${USERNAME} and ${AADHAR} - (executing on peer0.users)"
chaincodeRechargeAccount "peer0" "users" 
# Verify the Pankaj's account has balance of 600 upgradCoins
printMessage "Verify balance amount of 600 for user: ${USERNAME} and ${AADHAR} - (executing on peer1.registrar)"
chaincodeQueryUser "peer1" "registrar" "Pankaj Mahadik" "8844 4455 6677" "upgradCoins" "600"

# Recharge the account for user Pankaj with 1000
USERNAME="Pankaj Mahadik"
AADHAR="8844 4455 6677"
TXNID="upg1000"
printMessage "Invoke rechargeAccount of upg1000 for user: ${USERNAME} and ${AADHAR} - (executing on peer0.users)"
chaincodeRechargeAccount "peer0" "users"
# Verify the Pankaj's account has balance of 1600 upgradCoins
printMessage "Verify balance amount of 1600 for user: ${USERNAME} and ${AADHAR} - (executing on peer0.users)"
chaincodeQueryUser "peer0" "users" "Pankaj Mahadik" "8844 4455 6677" "upgradCoins" "1600"

# Recharge the account for user Aakash with 100
USERNAME="Aakash Bansal"
AADHAR="1122 3344 5566"
TXNID="upg100"
printMessage "Invoke rechargeAccount of upg100 for user: ${USERNAME} and ${AADHAR} - (executing on peer0.users)"
chaincodeRechargeAccount "peer0" "users" 
# Verify the Aakash's account has balance of 100 upgradCoins
printMessage "Verify balance amount of 100 for user: ${USERNAME} and ${AADHAR} - (executing on peer1.registrar)"
chaincodeQueryUser "peer1" "registrar" "Aakash Bansal" "1122 3344 5566" "upgradCoins" "100"

# Recharge the account for user Aakash with 1000
USERNAME="Aakash Bansal"
AADHAR="1122 3344 5566"
TXNID="upg1000"
printMessage "Invoke rechargeAccount of upg1000 for user: ${USERNAME} and ${AADHAR} - (executing on peer0.users)"
chaincodeRechargeAccount "peer0" "users"
# Verify the Aakash's account has balance of 1000 upgradCoins
printMessage "Verify balance amount of 1100 for user: ${USERNAME} and ${AADHAR} - (executing on peer0.users)"
chaincodeQueryUser "peer0" "users" "Aakash Bansal" "1122 3344 5566" "upgradCoins" "1100"

# USERNAME="Pankaj Mahadik"
# AADHAR="8844 4455 6677"
# PROPERTYID="1"
# STATUS="onSale"
# chaincodeUpdateProperty "peer0" "users"
# chaincodeQueryProperty "peer1" "registrar" 1 "status" "onSale"

# Mark property for sale for property id: 2 
USERNAME="Aakash Bansal"
AADHAR="1122 3344 5566"
PROPERTYID="2"
STATUS="onSale"
printMessage "updateProperty for Sale for propertyId: ${PROPERTYID}, user: ${USERNAME} and ${AADHAR} - (executing on peer0.users)"
chaincodeUpdateProperty "peer0" "users"

# Verify the property status changed to onSale
printMessage "verify status is onSale for property propertyId: ${PROPERTYID} - (executing on peer0.users)"
chaincodeQueryProperty "peer0" "users" 2 "status" "onSale"

# Invoke purchaseProperty with Pankaj as buyer
USERNAME="Pankaj Mahadik"
AADHAR="8844 4455 6677"
PROPERTYID="2"
printMessage "Invoke purchaseProperty for propertyId: ${PROPERTYID}, buyer: ${USERNAME} and ${AADHAR} - (executing on peer0.users)"
chaincodePurchaseProperty "peer0" "users"
# Verify the property status is 'registered'
printMessage "Verify status of property is re-set to 'registered' for property: ${PROPERTYID} - (executing on peer0.registrar)"
chaincodeQueryProperty "peer0" "registrar" 2 "status" "registered"
# Verify owner of the property marked as Pankaj
printMessage "Verify Owner of property reflects ${USERNAME} for property: ${PROPERTYID} - (executing on peer1.registrar)"
chaincodeQueryProperty "peer1" "registrar" 2 "owner" "PANKAJMAHADIK-884444556677"
# Verify seller receives the price amount
printMessage "Verify Seller receives the amount of 800 as price for property: ${PROPERTYID}. Total=1100+800=1900 - (executing on peer0.users)"
chaincodeQueryUser "peer0" "users" "Aakash Bansal" "1122 3344 5566" "upgradCoins" "1900"
# verify buyer has spent the price amount
printMessage "Verify Buyer spend the amount of 800 as price for property: ${PROPERTYID}. Total=1600-800=800 - (executing on peer0.users)"
chaincodeQueryUser "peer0" "users" "Pankaj Mahadik" "8844 4455 6677" "upgradCoins" "800"

# Verify both the properties are owned by Pankaj
printMessage "Verify both the Properties owned by 'Pankaj Mahadik' - (executing on peer0.users)"
chaincodeQueryAllProperties "peer0" "users"


# Negative test cases

# Invoking new user registration request on registrar node.

# USERNAME="Upgrad User"
# AADHAR="1234 1234 1234"
# EMAIL="upgrad.user@gmail.com"
# PHONE="1234567890"
# printMessage "Invoking requestNewUser for user: ${USERNAME} and ${AADHAR} - (executing on peer0.registrar)"
# requestNewUser "peer0" "registrar"

# invoke purchaseProperty for an property whose status is not onSale.
# USERNAME="Aakash Bansal"
# AADHAR="1122 3344 5566"
# PROPERTYID="2"
# printMessage "Invoke purchaseProperty for propertyId: ${PROPERTYID}, buyer: ${USERNAME} and ${AADHAR} - (executing on peer0.users)"
# chaincodePurchaseProperty "peer0" "users"

# GoLang code is commented out for time being
#chaincodeQueryUserGolang "peer0" "registrar"

echo
echo "========= Congratulations...! pankaj_property_registration_network built and all use cases executed successfully =========== "
echo

exit 0

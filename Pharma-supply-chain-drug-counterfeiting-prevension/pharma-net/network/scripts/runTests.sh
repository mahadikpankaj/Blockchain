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


createAndVerifyManufacturers(){
    # Invoke registerCompany function for below Manufacturers
    EXPECTED_HIERARCHY_KEY="1"
    COMPANY_CRN="comp-manu-1"
    COMPANY_NAME="first"
    COMPANY_LOCATION="Location-1"
    ORG_ROLE="Manufacturer"
    peer_name='peer0'
    host_name='manufacturer'
    printMessage "Invoking registerCompany for company: ${COMPANY_CRN}, ${COMPANY_NAME}, ${COMPANY_LOCATION} and ${ORG_ROLE} - (executing on ${peer_name}.${host_name})"
    registerCompany ${peer_name} ${host_name}

    # Verify that company registered with appropriate hierarcyKey
    peer_name='peer1'
    host_name='manufacturer'
    printMessage "Querying Company object for company: ${COMPANY_CRN} and ${COMPANY_NAME} - (executing on ${peer_name}.${host_name})"
    chaincodeQueryCompany ${peer_name} ${host_name} "${COMPANY_CRN}" "${COMPANY_NAME}" "hierarchyKey" ${EXPECTED_HIERARCHY_KEY}

    COMPANY_CRN="COMP-MANU-2"
    COMPANY_NAME="Second Manufacturer"
    COMPANY_LOCATION="Location-2"
    ORG_ROLE="Manufacturer"
    peer_name='peer1'
    host_name='manufacturer'
    printMessage "Invoking registerCompany for company: ${COMPANY_CRN}, ${COMPANY_NAME}, ${COMPANY_LOCATION} and ${ORG_ROLE} - (executing on ${peer_name}.${host_name})"
    registerCompany ${peer_name} ${host_name}

    # Verify that company registered with appropriate hierarcyKey
    peer_name='peer0'
    host_name='manufacturer'
    printMessage "Querying Company object for company: ${COMPANY_CRN} and ${COMPANY_NAME} - (executing on ${peer_name}.${host_name})"
    chaincodeQueryCompany ${peer_name} ${host_name} "${COMPANY_CRN}" "${COMPANY_NAME}" "hierarchyKey" ${EXPECTED_HIERARCHY_KEY}
}

createAndVerifyDistributors(){
    # Invoke registerCompany function for below Distibutors
    EXPECTED_HIERARCHY_KEY="2"
    COMPANY_CRN="COMP-DIST-1"
    COMPANY_NAME="First Distributor"
    COMPANY_LOCATION="Location-1"
    ORG_ROLE="Distributor"
    peer_name='peer0'
    host_name='distributor'
    printMessage "Invoking registerCompany for company: ${COMPANY_CRN}, ${COMPANY_NAME}, ${COMPANY_LOCATION} and ${ORG_ROLE} - (executing on ${peer_name}.${host_name})"
    registerCompany ${peer_name} ${host_name}

    # Verify that company registered with appropriate hierarcyKey
    peer_name='peer1'
    host_name='distributor'
    printMessage "Querying Company object for company: ${COMPANY_CRN} and ${COMPANY_NAME} - (executing on ${peer_name}.${host_name})"
    chaincodeQueryCompany ${peer_name} ${host_name} "${COMPANY_CRN}" "${COMPANY_NAME}" "hierarchyKey" ${EXPECTED_HIERARCHY_KEY}


    COMPANY_CRN="COMP-DIST-2"
    COMPANY_NAME="Second Distributor"
    COMPANY_LOCATION="Location-2"
    ORG_ROLE="Distributor"
    peer_name='peer1'
    host_name='distributor'
    printMessage "Invoking registerCompany for company: ${COMPANY_CRN}, ${COMPANY_NAME}, ${COMPANY_LOCATION} and ${ORG_ROLE} - (executing on ${peer_name}.${host_name})"
    registerCompany ${peer_name} ${host_name}

    # Verify that company registered with appropriate hierarcyKey
    peer_name='peer0'
    host_name='distributor'
    printMessage "Querying Company object for company: ${COMPANY_CRN} and ${COMPANY_NAME} - (executing on ${peer_name}.${host_name})"
    chaincodeQueryCompany ${peer_name} ${host_name} "${COMPANY_CRN}" "${COMPANY_NAME}" "hierarchyKey" ${EXPECTED_HIERARCHY_KEY}
}

createAndVerifyRetailers(){
    # Invoke registerCompany function for below Retailers
    EXPECTED_HIERARCHY_KEY="3"
    COMPANY_CRN="COMP-RETL-1"
    COMPANY_NAME="First Retailer"
    COMPANY_LOCATION="Location-1"
    ORG_ROLE="Retailer"
    peer_name='peer0'
    host_name='retailer'
    printMessage "Invoking registerCompany for company: ${COMPANY_CRN}, ${COMPANY_NAME}, ${COMPANY_LOCATION} and ${ORG_ROLE} - (executing on ${peer_name}.${host_name})"
    registerCompany ${peer_name} ${host_name}

    # Verify that company registered with appropriate hierarcyKey
    peer_name='peer1'
    host_name='retailer'
    printMessage "Querying Company object for company: ${COMPANY_CRN} and ${COMPANY_NAME} - (executing on ${peer_name}.${host_name})"
    chaincodeQueryCompany ${peer_name} ${host_name} "${COMPANY_CRN}" "${COMPANY_NAME}" "hierarchyKey" ${EXPECTED_HIERARCHY_KEY}


    COMPANY_CRN="COMP-RETL-2"
    COMPANY_NAME="Second Retailer"
    COMPANY_LOCATION="Location-2"
    ORG_ROLE="Retailer"
    peer_name='peer1'
    host_name='retailer'
    printMessage "Invoking registerCompany for company: ${COMPANY_CRN}, ${COMPANY_NAME}, ${COMPANY_LOCATION} and ${ORG_ROLE} - (executing on ${peer_name}.${host_name})"
    registerCompany ${peer_name} ${host_name}

    # Verify that company registered with appropriate hierarcyKey
    peer_name='peer0'
    host_name='retailer'
    printMessage "Querying Company object for company: ${COMPANY_CRN} and ${COMPANY_NAME} - (executing on ${peer_name}.${host_name})"
    chaincodeQueryCompany ${peer_name} ${host_name} "${COMPANY_CRN}" "${COMPANY_NAME}" "hierarchyKey" ${EXPECTED_HIERARCHY_KEY}
}

createAndVerifyTransporters(){
    # Invoke registerCompany function for below Transporters
    EXPECTED_HIERARCHY_KEY=""
    COMPANY_CRN="COMP-TRNS-1"
    COMPANY_NAME="First Transporter"
    COMPANY_LOCATION="Location-1"
    ORG_ROLE="Transporter"
    peer_name='peer0'
    host_name='transporter'
    printMessage "Invoking registerCompany for company: ${COMPANY_CRN}, ${COMPANY_NAME}, ${COMPANY_LOCATION} and ${ORG_ROLE} - (executing on ${peer_name}.${host_name})"
    registerCompany ${peer_name} ${host_name}

    # Verify that company registered with appropriate hierarcyKey
    peer_name='peer1'
    host_name='transporter'
    printMessage "Querying Company object for company: ${COMPANY_CRN} and ${COMPANY_NAME} - (executing on ${peer_name}.${host_name})"
    chaincodeQueryCompany ${peer_name} ${host_name} "${COMPANY_CRN}" "${COMPANY_NAME}" "hierarchyKey" ${EXPECTED_HIERARCHY_KEY}


    COMPANY_CRN="COMP-TRNS-2"
    COMPANY_NAME="Second Transporter"
    COMPANY_LOCATION="Location-2"
    ORG_ROLE="Transporter"
    peer_name='peer1'
    host_name='transporter'
    printMessage "Invoking registerCompany for company: ${COMPANY_CRN}, ${COMPANY_NAME}, ${COMPANY_LOCATION} and ${ORG_ROLE} - (executing on ${peer_name}.${host_name})"
    registerCompany ${peer_name} ${host_name}

    # Verify that company registered with appropriate hierarcyKey
    peer_name='peer0'
    host_name='transporter'
    printMessage "Querying Company object for company: ${COMPANY_CRN} and ${COMPANY_NAME} - (executing on ${peer_name}.${host_name})"
    chaincodeQueryCompany ${peer_name} ${host_name} "${COMPANY_CRN}" "${COMPANY_NAME}" "hierarchyKey" ${EXPECTED_HIERARCHY_KEY}
}

createAndVerifyConsumers(){
    # Invoke registerCompany function for below Consumers
    EXPECTED_HIERARCHY_KEY=""
    COMPANY_CRN="COMP-TRNS-1"
    COMPANY_NAME="First Transporter"

    peer_name='peer0'
    host_name='consumer'
    printMessage "Querying Company object for company: ${COMPANY_CRN} and ${COMPANY_NAME} - (executing on ${peer_name}.${host_name})"
    chaincodeQueryCompany ${peer_name} ${host_name} "${COMPANY_CRN}" "${COMPANY_NAME}" "hierarchyKey" ${EXPECTED_HIERARCHY_KEY}

    COMPANY_CRN="COMP-TRNS-2"
    COMPANY_NAME="First Transporter"

    peer_name='peer1'
    host_name='consumer'
    printMessage "Querying Company object for company: ${COMPANY_CRN} and ${COMPANY_NAME} - (executing on ${peer_name}.${host_name})"
    chaincodeQueryCompany ${peer_name} ${host_name} "${COMPANY_CRN}" "${COMPANY_NAME}" "hierarchyKey" ${EXPECTED_HIERARCHY_KEY}

}

addDrugInvokation(){
    SERIAL_NO="SR-2"
    DRUG_NAME="DRG-1"
    MFG_DATE="today"
    EXP_DATE="tomorrow"
    COMPANY_CRN="COMP-MANU-1"

    addDrug "peer0" "manufacturer"

}

# start the executtion of business cases



printMessage "Executing Use Cases"

# instantiateCustomChaincode "peer0" "manufacturer"

# Create and verifies various companies with Manufacturer, Distributor, Retailer and Transporter roles.
createAndVerifyManufacturers
createAndVerifyDistributors
createAndVerifyRetailers
createAndVerifyTransporters
createAndVerifyConsumers
addDrugInvokation

echo
echo "========= Congratulations...! pankaj-pharma-network built and all use cases executed successfully ==========="
echo

# exit 0
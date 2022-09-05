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

startChaincodeForAllPeersOfAllOrganizations(){
    for org in 'manufacturer' 'distributor' 'retailer' 'consumer' 'transporter'; do
        for peer in 'peer0' 'peer1'; do
            echo "===================== starting peer ${peer}.${org} of pankaj-pharma-network ===================== "
            startChaincodeForPeerAsWarmUp ${peer} ${org}
            echo "===================== peer ${peer}.${org} of pankaj-pharma-network started successfully ===================== "
        done
    done
}

## Install chaincodes
 for org in 'manufacturer' 'distributor' 'retailer' 'transporter' 'consumer'; do
     for peer in 'peer0' 'peer1'; do
         printMessage "Installing chaincodes on ${peer}.${org}"
         installChaincode ${peer} ${org} "pharmanet" 1.0 "node" "/opt/gopath/src/github.com/chaincode/node"
         echo "===================== chaincode installed on ${peer}.${org} ===================== "
         echo
     done
 done

peer="peer0"
org="manufacturer"
printMessage "Instantiating chaincodes on ${peer}.${org}"
instantiateCustomChaincode ${peer} ${org}
echo " ===================== chaincode instantiated on ${peer}.${org} ===================== "
 
startChaincodeForAllPeersOfAllOrganizations

echo
echo " ========= All GOOD, pankaj-pharma-network installation, instantiation and warm-up completed =========== "
echo

# exit 0
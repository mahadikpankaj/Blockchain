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


## Install chaincode on peer0.registrar and peer0.users

printMessage "Installing chaincodes on peer0.registrar"
installChaincode "peer0" "registrar" "regnet" 1.0 "node" "/opt/gopath/src/github.com/chaincode/node"
#installChaincode "peer0" "registrar" "regnetgo" 1.0 "golang" "github.com/chaincode/go"

printMessage "Installing chaincodes on peer1.registrar"
installChaincode "peer1" "registrar" "regnet" 1.0 "node" "/opt/gopath/src/github.com/chaincode/node"
#installChaincode "peer1" "registrar" "regnetgo" 1.0 "golang" "github.com/chaincode/go"


printMessage "Installing chaincodes on peer0.users"
installChaincode "peer0" "users" "regnet" 1.0 "node" "/opt/gopath/src/github.com/chaincode/node"
#installChaincode "peer0" "users" "regnetgo" 1.0 "golang" "github.com/chaincode/go"

printMessage "Instantiating 'regnet' chaincode on peer0.registrar"
instantiateCustomChaincode "peer0" "registrar"
#instantiateCustomChaincodeGolang "peer0" "registrar"
 

echo
echo "========= All GOOD, pankaj_property_registration_network installation and instantiation completed =========== "
echo

exit 0

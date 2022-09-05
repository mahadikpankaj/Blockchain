#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#

# This is a collection of bash functions used by different scripts

ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/pharma-network.com/orderers/orderer.pharma-network.com/msp/tlscacerts/tlsca.pharma-network.com-cert.pem
PEER0_manufacturer_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/manufacturer.pharma-network.com/peers/peer0.manufacturer.pharma-network.com/tls/ca.crt
PEER1_manufacturer_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/manufacturer.pharma-network.com/peers/peer1.manufacturer.pharma-network.com/tls/ca.crt
PEER0_distributor_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/distributor.pharma-network.com/peers/peer0.distributor.pharma-network.com/tls/ca.crt
PEER1_distributor_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/distributor.pharma-network.com/peers/peer1.distributor.pharma-network.com/tls/ca.crt
PEER0_retailer_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/retailer.pharma-network.com/peers/peer0.retailer.pharma-network.com/tls/ca.crt
PEER1_retailer_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/retailer.pharma-network.com/peers/peer1.retailer.pharma-network.com/tls/ca.crt
PEER0_consumer_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/consumer.pharma-network.com/peers/peer0.consumer.pharma-network.com/tls/ca.crt
PEER1_consumer_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/consumer.pharma-network.com/peers/peer1.consumer.pharma-network.com/tls/ca.crt
PEER0_transporter_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/transporter.pharma-network.com/peers/peer0.transporter.pharma-network.com/tls/ca.crt
PEER1_transporter_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/transporter.pharma-network.com/peers/peer1.transporter.pharma-network.com/tls/ca.crt

# verify the result of the end-to-end test
verifyResult() {
  if [ $1 -ne 0 ]; then
    isSuccess=false
    echo "!!!!!!!!!!!!!!! "$2" !!!!!!!!!!!!!!!!"
    echo "========= ERROR !!! FAILED to execute End-2-End Scenario ==========="
    echo
    showErrorBanner
	  exit 1
  fi
}

# Set OrdererOrg.Admin globals
setOrdererGlobals() {
  CORE_PEER_LOCALMSPID="OrdererMSP"
  CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/pharma-network.com/orderers/orderer.pharma-network.com/msp/tlscacerts/tlsca.pharma-network.com-cert.pem
  CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/pharma-network.com/users/Admin@pharma-network.com/msp
}

setGlobals() {
  PEER=$1
  ORGNAME=$2
  if [ ${ORGNAME} == 'manufacturer' ]; then
    CORE_PEER_LOCALMSPID="manufacturerMSP"
    CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_manufacturer_CA
    CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/manufacturer.pharma-network.com/users/Admin@manufacturer.pharma-network.com/msp
    if [ $PEER == 'peer0' ]; then
      CORE_PEER_ADDRESS=peer0.manufacturer.pharma-network.com:7051
    elif [ $PEER == 'peer1' ]; then
      CORE_PEER_ADDRESS=peer1.manufacturer.pharma-network.com:8051
    else
      echo "================== ERROR !!! Unknown Peer ${PEER} for Organization ${ORGNAME}=================="
    fi
  elif [ ${ORGNAME} == 'distributor' ]; then
    CORE_PEER_LOCALMSPID="distributorMSP"
    CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_distributor_CA
    CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/distributor.pharma-network.com/users/Admin@distributor.pharma-network.com/msp
    if [ $PEER == 'peer0' ]; then
      CORE_PEER_ADDRESS=peer0.distributor.pharma-network.com:9051
    elif [ $PEER == 'peer1' ]; then
      CORE_PEER_ADDRESS=peer1.distributor.pharma-network.com:10051
    else
      echo "================== ERROR !!! Unknown Peer ${PEER} for Organization ${ORGNAME}=================="
    fi
  elif [ ${ORGNAME} == 'retailer' ]; then
    CORE_PEER_LOCALMSPID="retailerMSP"
    CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_retailer_CA
    CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/retailer.pharma-network.com/users/Admin@retailer.pharma-network.com/msp
    if [ $PEER == 'peer0' ]; then
      CORE_PEER_ADDRESS=peer0.retailer.pharma-network.com:11051
    elif [ $PEER == 'peer1' ]; then
      CORE_PEER_ADDRESS=peer1.retailer.pharma-network.com:12051
    else
      echo "================== ERROR !!! Unknown Peer ${PEER} for Organization ${ORGNAME}=================="
    fi
  elif [ ${ORGNAME} == 'consumer' ]; then
    CORE_PEER_LOCALMSPID="consumerMSP"
    CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_consumer_CA
    CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/consumer.pharma-network.com/users/Admin@consumer.pharma-network.com/msp
    if [ $PEER == 'peer0' ]; then
      CORE_PEER_ADDRESS=peer0.consumer.pharma-network.com:13051
    elif [ $PEER == 'peer1' ]; then
      CORE_PEER_ADDRESS=peer1.consumer.pharma-network.com:14051
    else
      echo "================== ERROR !!! Unknown Peer ${PEER} for Organization ${ORGNAME}=================="
    fi
  elif [ ${ORGNAME} == 'transporter' ]; then
    CORE_PEER_LOCALMSPID="transporterMSP"
    CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_transporter_CA
    CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/transporter.pharma-network.com/users/Admin@transporter.pharma-network.com/msp
    if [ $PEER == 'peer0' ]; then
      CORE_PEER_ADDRESS=peer0.transporter.pharma-network.com:15051
    elif [ $PEER == 'peer1' ]; then
      CORE_PEER_ADDRESS=peer1.transporter.pharma-network.com:16051
    else
      echo "================== ERROR !!! Unknown Peer ${PEER} for Organization ${ORGNAME}=================="
    fi
  else
    echo "================== ERROR !!! Unknown Organization ${ORGNAME} =================="
  fi

  if [ "$VERBOSE" == "true" ]; then
    env | grep CORE
  fi
}

updateAnchorPeers() {
  PEER=$1
  ORGNAME=$2
  setGlobals $PEER $ORGNAME

  if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
    set -x
    peer channel update -o orderer.pharma-network.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/${CORE_PEER_LOCALMSPID}anchors.tx >&log.txt
    res=$?
    set +x
  else
    set -x
    peer channel update -o orderer.pharma-network.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/${CORE_PEER_LOCALMSPID}anchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA >&log.txt
    res=$?
    set +x
  fi
  cat log.txt
  verifyResult $res "Anchor peer update failed"
  echo "===================== Anchor peers updated for org '$CORE_PEER_LOCALMSPID' on channel '$CHANNEL_NAME' ===================== "
  sleep $DELAY
  echo
}

## Sometimes Join takes time hence RETRY at least 5 times
joinChannelWithRetry() {
  PEER=$1
  ORGNAME=$2
  setGlobals $PEER $ORGNAME

  set -x
  peer channel join -b $CHANNEL_NAME.block >&log.txt
  res=$?
  set +x
  cat log.txt
  if [ $res -ne 0 -a $COUNTER -lt $MAX_RETRY ]; then
    COUNTER=$(expr $COUNTER + 1)
    echo "${PEER}.${ORGNAME} failed to join the channel, Retry after $DELAY seconds"
    sleep $DELAY
    joinChannelWithRetry $PEER $ORGNAME
  else
    COUNTER=1
  fi
  verifyResult $res "After $MAX_RETRY attempts, ${PEER}.${ORGNAME} has failed to join channel '$CHANNEL_NAME' "
}

installChaincode() {
  PEER=$1
  ORGNAME=$2
  CNAME=$3
  VERSION=$4
  CLANG=$5
  CC_SRC_PATH=$6
  setGlobals $PEER $ORGNAME
  set -x
  peer chaincode install -n ${CNAME} -v ${VERSION} -l ${CLANG} -p ${CC_SRC_PATH} >&log.txt
  res=$?
  set +x
  cat log.txt
  verifyResult $res "Chaincode installation on ${PEER}.${ORGNAME} has failed"
  echo "===================== Chaincode installed on ${PEER}.${ORGNAME} ===================== "
  echo
}

instantiateCustomChaincode() {
  PEER=$1
  ORGNAME=$2
  setGlobals $PEER $ORGNAME
  VERSION=${3:-1.0}
  echo
  echo "===================== Instantiating chaincode on ${PEER}.${ORGNAME} on channel '$CHANNEL_NAME' ===================== "
  # while 'peer chaincode' command can get the orderer endpoint from the peer
  # (if join was successful), let's supply it directly as we know it using
  # the "-o" option
  if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
    set -x
	peer chaincode instantiate -o orderer.pharma-network.com:7050 -C $CHANNEL_NAME -n pharmanet -l ${LANGUAGE} -v ${VERSION} -c '{"Args":["org.pharma-network.pharmanet:instantiate"]}' -P "OR ('manufacturerMSP.member','distributorMSP.member','retailerMSP.member','consumerMSP.member','transporterMSP.member')" >&log.txt
    res=$?
    set +x
  else
    set -x
	peer chaincode instantiate -o orderer.pharma-network.com:7050 --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME -n pharmanet -l ${LANGUAGE} -v ${VERSION} -c '{"Args":["org.pharma-network.pharmanet:instantiate"]}' -P "OR ('manufacturerMSP.member','distributorMSP.member','retailerMSP.member','consumerMSP.member','transporterMSP.member')" >&log.txt
    res=$?
    set +x
  fi
  cat log.txt
  verifyResult $res "Chaincode instantiation on ${PEER}.${ORGNAME} on channel '$CHANNEL_NAME' failed"
  echo "===================== Chaincode is instantiated on ${PEER}.${ORGNAME} on channel '$CHANNEL_NAME' ===================== "
  echo
  sleep $DELAY
}

upgradeChaincode() {
  PEER=$1
  ORGNAME=$2
  setGlobals $PEER $ORGNAME

  set -x
  peer chaincode upgrade -o orderer.pharma-network.com:7050 --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME -n mycc -v 2.0 -c '{"Args":["init","a","90","b","210"]}' -P "AND ('registrarMSP.peer','usersMSP.peer')"
  res=$?
  set +x
  cat log.txt
  verifyResult $res "Chaincode upgrade on ${PEER}.${ORGNAME} has failed"
  echo "===================== Chaincode is upgraded on ${PEER}.${ORGNAME} on channel '$CHANNEL_NAME' ===================== "
  echo
}

chaincodeQuery() {
  PEER=$1
  ORGNAME=$2
  CNAME=$3
  EXPECTED_RESULT=$4
  
  setGlobals $PEER $ORGNAME
  echo "===================== Querying on ${PEER}.${ORGNAME} on channel '$CHANNEL_NAME'... ===================== "
  local rc=1
  local starttime=$(date +%s)

  # continue to poll
  # we either get a successful response, or reach TIMEOUT
  while
    test "$(($(date +%s) - starttime))" -lt "$TIMEOUT" -a $rc -ne 0
  do
    sleep $DELAY
    echo "Attempting to Query ${PEER}.${ORGNAME} ...$(($(date +%s) - starttime)) secs"
    set -x
    peer chaincode query -C $CHANNEL_NAME -n ${CNAME} -c '{"Args":["query","a"]}' >&log.txt
    res=$?
    set +x
    test $res -eq 0 && VALUE=$(cat log.txt | awk '/Query Result/ {print $NF}')
    test "$VALUE" = "$EXPECTED_RESULT" && let rc=0
    # removed the string "Query Result" from peer chaincode query command
    # result. as a result, have to support both options until the change
    # is merged.
    test $rc -ne 0 && VALUE=$(cat log.txt | egrep '^[0-9]+$')
    test "$VALUE" = "$EXPECTED_RESULT" && let rc=0
  done
  echo
  cat log.txt
  if test $rc -eq 0; then
    echo "===================== Query successful on ${PEER}.${ORGNAME} on channel '$CHANNEL_NAME' ===================== "
  else
    echo "!!!!!!!!!!!!!!! Query result on ${PEER}.${ORGNAME} is INVALID !!!!!!!!!!!!!!!!"
    echo "================== ERROR !!! FAILED to execute End-2-End Scenario =================="
    echo
    showErrorBanner
	  exit 1
  fi
}

# fetchChannelConfig <channel_id> <output_json>
# Writes the current channel config for a given channel to a JSON file
fetchChannelConfig() {
  CHANNEL=$1
  OUTPUT=$2

  setOrdererGlobals

  echo "Fetching the most recent configuration block for the channel"
  if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
    set -x
    peer channel fetch config config_block.pb -o orderer.pharma-network.com:7050 -c $CHANNEL --cafile $ORDERER_CA
    set +x
  else
    set -x
    peer channel fetch config config_block.pb -o orderer.pharma-network.com:7050 -c $CHANNEL --tls --cafile $ORDERER_CA
    set +x
  fi

  echo "Decoding config block to JSON and isolating config to ${OUTPUT}"
  set -x
  configtxlator proto_decode --input config_block.pb --type common.Block | jq .data.data[0].payload.data.config >"${OUTPUT}"
  set +x
}

# signConfigtxAsPeerOrg <org> <configtx.pb>
# Set the peerOrg admin of an org and signing the config update
signConfigtxAsPeerOrg() {
  PEERORG=$1
  TX=$2
  setGlobals 'peer0' $PEERORG
  set -x
  peer channel signconfigtx -f "${TX}"
  set +x
}

# createConfigUpdate <channel_id> <original_config.json> <modified_config.json> <output.pb>
# Takes an original and modified config, and produces the config update tx
# which transitions between the two
createConfigUpdate() {
  CHANNEL=$1
  ORIGINAL=$2
  MODIFIED=$3
  OUTPUT=$4

  set -x
  configtxlator proto_encode --input "${ORIGINAL}" --type common.Config >original_config.pb
  configtxlator proto_encode --input "${MODIFIED}" --type common.Config >modified_config.pb
  configtxlator compute_update --channel_id "${CHANNEL}" --original original_config.pb --updated modified_config.pb >config_update.pb
  configtxlator proto_decode --input config_update.pb --type common.ConfigUpdate >config_update.json
  echo '{"payload":{"header":{"channel_header":{"channel_id":"'$CHANNEL'", "type":2}},"data":{"config_update":'$(cat config_update.json)'}}}' | jq . >config_update_in_envelope.json
  configtxlator proto_encode --input config_update_in_envelope.json --type common.Envelope >"${OUTPUT}"
  set +x
}

# parsePeerConnectionParameters $@
# Helper function that takes the parameters from a chaincode operation
# (e.g. invoke, query, instantiate) and checks for an even number of
# peers and associated org, then sets $PEER_CONN_PARMS and $PEERS
parsePeerConnectionParameters() {
  # check for uneven number of peer and org parameters
  if [ $(($# % 2)) -ne 0 ]; then
    showErrorBanner
	  exit 1
  fi

  PEER_CONN_PARMS=""
  PEERS=""
  setGlobals $1 $2

  while [ "$#" -gt 0 ]; do
    setGlobals $1 $2
    PEER="$1.${ORGNAME}"
    PEERS="$PEERS $PEER"
    PEER_CONN_PARMS="$PEER_CONN_PARMS --peerAddresses $CORE_PEER_ADDRESS"
    if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "true" ]; then
      PEERREF=`echo "$1" | tr [:lower:] [:upper:]`
      TLSINFO=$(eval echo "--tlsRootCertFiles \$${PEERREF}_${ORGNAME}_CA")
      PEER_CONN_PARMS="$PEER_CONN_PARMS $TLSINFO"
    fi
    # shift by two to get the next pair of peer/org parameters
    shift
    shift
  done
  # remove leading space for output
  PEERS="$(echo -e "$PEERS" | sed -e 's/^[[:space:]]*//')"
}

showStartedBanner(){
  echo
  echo
  echo "  ____    _____      _      ____    _____   _____   ____"
  echo " / ___|  |_   _|    / \\    |  _ \\  |_   _| | ____| |  _ \\"
  echo " \\___ \\    | |     / _ \\   | |_) |   | |   |  _|   | | | |"
  echo "  ___) |   | |    / ___ \\  |  _ <    | |   | |___  | |_| |"
  echo " |____/    |_|   /_/   \\_\\ |_| \\_\\   |_|   |_____| |____/"
  echo
  echo
}

showEndedBanner(){
  echo
  echo
  echo "   ____    ___    __  __   ____    _       _____   _____   _____   ____"
  echo "  / ___|  / _ \\  |  \\/  | |  _ \\  | |     | ____| |_   _| | ____| |  _ \\"
  echo " | |     | | | | | |\\/| | | |_) | | |     |  _|     | |   |  _|   | | | |"
  echo " | |___  | |_| | | |  | | |  __/  | |___  | |___    | |   | |___  | |_| |"
  echo "  \\____|  \\___/  |_|  |_| |_|     |_____| |_____|   |_|   |_____| |____/"
  echo
  echo

}

showErrorBanner(){
  errorShown=true
  echo
  echo
  echo "  _____   ____    ____     ___    ____"
  echo " | ____| |  _ \\  |  _ \\   / _ \\  |  _ \\"
  echo " |  _|   | |_) | | |_) | | | | | | |_) |"
  echo " | |___  |  _ <  |  _ <  | |_| | |  _ <"
  echo " |_____| |_| \\_\\ |_| \\_\\  \\___/  |_| \\_\\"
  echo
}

registerCompany() {
  parsePeerConnectionParameters $@
  res=$?
  verifyResult $res "Invoke transaction failed on channel '$CHANNEL_NAME' due to uneven number of peer and org parameters "

  # while 'peer chaincode' command can get the orderer endpoint from the
  # peer (if join was successful), let's supply it directly as we know
  # it using the "-o" option
  C_PARAMETER={\"Args\":[\"org.pharma-network.pharmanet:registerCompany\",\"${COMPANY_CRN}\",\"${COMPANY_NAME}\",\"${COMPANY_LOCATION}\",\"${ORG_ROLE}\"]}
  echo ${C_PARAMETER}
  if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
    set -x
    peer chaincode invoke -o orderer.pharma-network.com:7050 -C $CHANNEL_NAME -n pharmanet $PEER_CONN_PARMS -c "${C_PARAMETER}" >&log.txt
    res=$?
    set +x
  else
    set -x
    peer chaincode invoke -o orderer.pharma-network.com:7050 --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME -n pharmanet $PEER_CONN_PARMS -c "${C_PARAMETER}" >&log.txt
    res=$?
    set +x
  fi
  cat log.txt
  verifyResult $res "Invoke execution on $PEERS failed "
  # COMPANY_CRN=$(cat log.txt | grep -o "\\\\\"companyCRN\\\\\": *\\\\\"[^\\\\\"]*" | grep -o '[^"]*$')
  # echo "COMPANY_CRN: ${COMPANY_CRN}"
  echo "===================== Invoke transaction successful on $PEERS on channel '$CHANNEL_NAME' ===================== "
  echo
  sleep $DELAY
}

addDrug() {
  parsePeerConnectionParameters $@
  res=$?
  verifyResult $res "Invoke transaction failed on channel '$CHANNEL_NAME' due to uneven number of peer and org parameters "

  # while 'peer chaincode' command can get the orderer endpoint from the
  # peer (if join was successful), let's supply it directly as we know
  # it using the "-o" option
  C_PARAMETER={\"Args\":[\"org.pharma-network.pharmanet:addDrug\",\"${DRUG_NAME}\",\"${SERIAL_NO}\",\"${MFG_DATE}\",\"${EXP_DATE}\",\"${COMPANY_CRN}\"]}
  echo ${C_PARAMETER}
  if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
    set -x
    peer chaincode invoke -o orderer.pharma-network.com:7050 -C $CHANNEL_NAME -n pharmanet $PEER_CONN_PARMS -c "${C_PARAMETER}" >&log.txt
    res=$?
    set +x
  else
    set -x
    peer chaincode invoke -o orderer.pharma-network.com:7050 --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME -n pharmanet $PEER_CONN_PARMS -c "${C_PARAMETER}" >&log.txt
    res=$?
    set +x
  fi
  cat log.txt
  verifyResult $res "Invoke execution on $PEERS failed "
  # COMPANY_CRN=$(cat log.txt | grep -o "\\\\\"companyCRN\\\\\": *\\\\\"[^\\\\\"]*" | grep -o '[^"]*$')
  # echo "COMPANY_CRN: ${COMPANY_CRN}"
  echo "===================== Invoke transaction successful on $PEERS on channel '$CHANNEL_NAME' ===================== "
  echo
  sleep $DELAY
}

startChaincodeForPeerAsWarmUp() {
  parsePeerConnectionParameters $@
  res=$?
  verifyResult $res "warmUp query transaction failed on channel '$CHANNEL_NAME' due to uneven number of peer and org parameters "

  # while 'peer chaincode' command can get the orderer endpoint from the
  # peer (if join was successful), let's supply it directly as we know
  # it using the "-o" option
  C_PARAMETER={\"Args\":[\"org.pharma-network.pharmanet:warmUp\"]}
  echo ${C_PARAMETER}
  set -x
  peer chaincode query -C $CHANNEL_NAME -n pharmanet -c "$C_PARAMETER" >&log.txt
  res=$?
  set +x
  cat log.txt
  verifyResult $res "warmUp execution on $PEERS failed "
  # COMPANY_CRN=$(cat log.txt | grep -o "\\\\\"companyCRN\\\\\": *\\\\\"[^\\\\\"]*" | grep -o '[^"]*$')
  # echo "COMPANY_CRN: ${COMPANY_CRN}"
  echo "===================== warmUp query transaction successful on $PEERS on channel '$CHANNEL_NAME' ===================== "
  echo
  sleep $DELAY
}


chaincodeQueryCompany() {
  PEER=$1
  ORGNAME=$2
  COMPANY_CRN=$3
  COMPANY_NAME=$4
  setGlobals $PEER $ORGNAME
  VERIFICATION_FIELD=$5
  EXPECTED_RESULT=$6

  echo "===================== Querying on ${PEER}.${ORGNAME} on channel '$CHANNEL_NAME'... ===================== "
  local rc=1
  local starttime=$(date +%s)

  # continue to poll
  # we either get a successful response, or reach TIMEOUT
  while
    test "$(($(date +%s) - starttime))" -lt "$TIMEOUT" -a $rc -ne 0
  do
    sleep $DELAY
    echo "Attempting to Query ${PEER}.${ORGNAME} ...$(($(date +%s) - starttime)) secs"
    set -x
    C_PARAMETER={\"Args\":[\"org.pharma-network.pharmanet:viewCompany\",\"${COMPANY_CRN}\",\"${COMPANY_NAME}\"]}
    peer chaincode query -C $CHANNEL_NAME -n pharmanet -c "$C_PARAMETER" >&log.txt
    res=$?
    set +x
    test $res -eq 0 && VALUE=$(cat log.txt | awk '/Query Result/ {print $NF}')
  	VALUE=$(cat log.txt | grep -o "\"${VERIFICATION_FIELD}\": *\"[^\"]*" | grep -o '[^"]*$')
    test "$VALUE" = "$EXPECTED_RESULT" && let rc=0
    test $rc -ne 0 && VALUE=$(cat log.txt | egrep '^[0-9]+$')
	  VALUE=$(cat log.txt | grep -o "\"${VERIFICATION_FIELD}\": *\"[^\"]*" | grep -o '[^"]*$')
    test "$VALUE" = "$EXPECTED_RESULT" && let rc=0
  done
  echo "Actual Value for ${VERIFICATION_FIELD}: " \"$VALUE\"
  echo "Expected Value for ${VERIFICATION_FIELD}: " \"$EXPECTED_RESULT\"
  cat log.txt
  if test $rc -eq 0; then
    echo "===================== Query successful on ${PEER}.${ORGNAME} on channel '$CHANNEL_NAME' ===================== "
  else
    echo "!!!!!!!!!!!!!!! Query result on ${PEER}.${ORGNAME} is INVALID !!!!!!!!!!!!!!!!"
    echo "================== ERROR !!! FAILED to execute End-2-End Scenario =================="
    echo
    isSuccess=false
    showErrorBanner
	  exit 1
  fi
  sleep $DELAY
}

chaincodeQueryAllCompanies() {
  PEER=$1
  ORGNAME=$2
  setGlobals $PEER $ORGNAME
  EXPECTED_RESULT=$5
  echo "===================== Querying on ${PEER}.${ORGNAME} on channel '$CHANNEL_NAME'... ===================== "
  local rc=1
  local starttime=$(date +%s)

  # continue to poll
  # we either get a successful response, or reach TIMEOUT
  while
    test "$(($(date +%s) - starttime))" -lt "$TIMEOUT" -a $rc -ne 0
  do
    sleep $DELAY
    echo "Attempting to Query ${PEER}.${ORGNAME} ...$(($(date +%s) - starttime)) secs"
    set -x
    C_PARAMETER={\"Args\":[\"org.pharma-network.pharmanet:getRegisteredCompanies\"]}
    peer chaincode query -C $CHANNEL_NAME -n pharmanet -c $C_PARAMETER >&log.txt
    res=$?
    set +x
    test $res -eq 0 && VALUE=$(cat log.txt | awk '/Query Result/ {print $NF}')
    let rc=0
  done
  cat log.txt
  if test $rc -eq 0; then
    echo "===================== Query successful on ${PEER}.${ORGNAME} on channel '$CHANNEL_NAME' ===================== "
  else
    echo "!!!!!!!!!!!!!!! Query result on ${PEER}.${ORGNAME} is INVALID !!!!!!!!!!!!!!!!"
    echo "================== ERROR !!! FAILED to execute End-2-End Scenario =================="
    echo
    isSuccess=false
    showErrorBanner
	  exit 1
  fi
  sleep $DELAY
}

printMessage(){
  echo
  echo "----------------------------------------------------------------------------------------------"
  echo $1
  echo "----------------------------------------------------------------------------------------------"
  echo
}
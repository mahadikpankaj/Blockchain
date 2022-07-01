#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#

# This is a collection of bash functions used by different scripts

ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/property-registration-network.com/orderers/orderer.property-registration-network.com/msp/tlscacerts/tlsca.property-registration-network.com-cert.pem
PEER0_registrar_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/registrar.property-registration-network.com/peers/peer0.registrar.property-registration-network.com/tls/ca.crt
PEER1_registrar_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/registrar.property-registration-network.com/peers/peer1.registrar.property-registration-network.com/tls/ca.crt
PEER0_users_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/users.property-registration-network.com/peers/peer0.users.property-registration-network.com/tls/ca.crt
PEER1_users_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/users.property-registration-network.com/peers/peer1.users.property-registration-network.com/tls/ca.crt
PEER2_users_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/users.property-registration-network.com/peers/peer2.users.property-registration-network.com/tls/ca.crt

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
  CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/property-registration-network.com/orderers/orderer.property-registration-network.com/msp/tlscacerts/tlsca.property-registration-network.com-cert.pem
  CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/property-registration-network.com/users/Admin@property-registration-network.com/msp
}

setGlobals() {
  PEER=$1
  ORGNAME=$2
  if [ ${ORGNAME} == 'registrar' ]; then
    CORE_PEER_LOCALMSPID="registrarMSP"
    CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_registrar_CA
    CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/registrar.property-registration-network.com/users/Admin@registrar.property-registration-network.com/msp
    if [ $PEER == 'peer0' ]; then
      CORE_PEER_ADDRESS=peer0.registrar.property-registration-network.com:7051
    elif [ $PEER == 'peer1' ]; then
      CORE_PEER_ADDRESS=peer1.registrar.property-registration-network.com:8051
    fi
  elif [ ${ORGNAME} == 'users' ]; then
    CORE_PEER_LOCALMSPID="usersMSP"
    CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_users_CA
    CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/users.property-registration-network.com/users/Admin@users.property-registration-network.com/msp
    if [ $PEER == 'peer0' ]; then
      CORE_PEER_ADDRESS=peer0.users.property-registration-network.com:9051
    elif [ $PEER == 'peer1' ]; then
      CORE_PEER_ADDRESS=peer1.users.property-registration-network.com:10051
    elif [ $PEER == 'peer2' ]; then
      CORE_PEER_ADDRESS=peer2.users.property-registration-network.com:11051
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
    peer channel update -o orderer.property-registration-network.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/${CORE_PEER_LOCALMSPID}anchors.tx >&log.txt
    res=$?
    set +x
  else
    set -x
    peer channel update -o orderer.property-registration-network.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/${CORE_PEER_LOCALMSPID}anchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA >&log.txt
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
  echo "===================== Chaincode is installed on ${PEER}.${ORGNAME} ===================== "
  echo
}

instantiateCustomChaincode() {
  PEER=$1
  ORGNAME=$2
  setGlobals $PEER $ORGNAME
  VERSION=${3:-1.0}

  # while 'peer chaincode' command can get the orderer endpoint from the peer
  # (if join was successful), let's supply it directly as we know it using
  # the "-o" option
  if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
    set -x
	peer chaincode instantiate -o orderer.property-registration-network.com:7050 -C $CHANNEL_NAME -n regnet -l ${LANGUAGE} -v ${VERSION} -c '{"Args":["org.property-registration-network.regnet.registrar:instantiate"]}' -P "OR ('registrarMSP.member','usersMSP.member')" >&log.txt
    res=$?
    set +x
  else
    set -x
	peer chaincode instantiate -o orderer.property-registration-network.com:7050 --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME -n regnet -l ${LANGUAGE} -v ${VERSION} -c '{"Args":["org.property-registration-network.regnet.registrar:instantiate"]}' -P "OR ('registrarMSP.member','usersMSP.member')" >&log.txt
    res=$?
    set +x
  fi
  cat log.txt
  verifyResult $res "Chaincode instantiation on ${PEER}.${ORGNAME} on channel '$CHANNEL_NAME' failed"
  echo "===================== Chaincode is instantiated on ${PEER}.${ORGNAME} on channel '$CHANNEL_NAME' ===================== "
  echo
  sleep $DELAY
}

instantiateCustomChaincodeGolang() {
  PEER=$1
  ORGNAME=$2
  setGlobals $PEER $ORGNAME
  VERSION=${3:-1.0}

  # while 'peer chaincode' command can get the orderer endpoint from the peer
  # (if join was successful), let's supply it directly as we know it using
  # the "-o" option
  if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
    set -x
	peer chaincode instantiate -o orderer.property-registration-network.com:7050 -C $CHANNEL_NAME -n regnetgo -l ${LANGUAGE} -v ${VERSION} -c '{"Args":["Init"]}' -P "OR ('registrarMSP.member','usersMSP.member')" >&log.txt
    res=$?
    set +x
  else
    set -x
	peer chaincode instantiate -o orderer.property-registration-network.com:7050 --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME -n regnetgo -l ${LANGUAGE} -v ${VERSION} -c '{"Args":["Init"]}' -P "OR ('registrarMSP.member','usersMSP.member')" >&log.txt
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
  peer chaincode upgrade -o orderer.property-registration-network.com:7050 --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME -n mycc -v 2.0 -c '{"Args":["init","a","90","b","210"]}' -P "AND ('registrarMSP.peer','usersMSP.peer')"
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
    peer channel fetch config config_block.pb -o orderer.property-registration-network.com:7050 -c $CHANNEL --cafile $ORDERER_CA
    set +x
  else
    set -x
    peer channel fetch config config_block.pb -o orderer.property-registration-network.com:7050 -c $CHANNEL --tls --cafile $ORDERER_CA
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

requestNewUser() {
  parsePeerConnectionParameters $@
  res=$?
  verifyResult $res "Invoke transaction failed on channel '$CHANNEL_NAME' due to uneven number of peer and org parameters "

  # while 'peer chaincode' command can get the orderer endpoint from the
  # peer (if join was successful), let's supply it directly as we know
  # it using the "-o" option
  C_PARAMETER={\"Args\":[\"org.property-registration-network.regnet.users:requestNewUser\",\"${USERNAME}\",\"${AADHAR}\",\"${EMAIL}\",\"${PHONE}\"]}
  echo ${C_PARAMETER}
  if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
    set -x
    peer chaincode invoke -o orderer.property-registration-network.com:7050 -C $CHANNEL_NAME -n regnet $PEER_CONN_PARMS -c "${C_PARAMETER}" >&log.txt
    res=$?
    set +x
  else
    set -x
    peer chaincode invoke -o orderer.property-registration-network.com:7050 --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME -n regnet $PEER_CONN_PARMS -c "${C_PARAMETER}" >&log.txt
    res=$?
    set +x
  fi
  cat log.txt
  verifyResult $res "Invoke execution on $PEERS failed "
  echo "===================== Invoke transaction successful on $PEERS on channel '$CHANNEL_NAME' ===================== "
  echo
  sleep $DELAY
}

chaincodeApproveUserRegistrationRequest() {
  parsePeerConnectionParameters $@
  res=$?
  verifyResult $res "Invoke transaction failed on channel '$CHANNEL_NAME' due to uneven number of peer and org parameters "

  # while 'peer chaincode' command can get the orderer endpoint from the
  # peer (if join was successful), let's supply it directly as we know
  # it using the "-o" option
  C_PARAMETER={\"Args\":[\"org.property-registration-network.regnet.registrar:approveNewUser\",\"${USERNAME}\",\"${AADHAR}\"]}
  echo ${C_PARAMETER}
  if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
    set -x
    peer chaincode invoke -o orderer.property-registration-network.com:7050 -C $CHANNEL_NAME -n regnet $PEER_CONN_PARMS -c "${C_PARAMETER}" >&log.txt
    res=$?
    set +x
  else
    set -x
    peer chaincode invoke -o orderer.property-registration-network.com:7050 --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME -n regnet $PEER_CONN_PARMS -c "${C_PARAMETER}" >&log.txt
    res=$?
    set +x
  fi
  cat log.txt
  verifyResult $res "Invoke execution on $PEERS failed "
  echo "===================== Invoke transaction successful on $PEERS on channel '$CHANNEL_NAME' ===================== "
  echo
  sleep $DELAY
}

chaincodeQueryUserRequest() {
  PEER=$1
  ORGNAME=$2
  USERNAME=$3
  AADHAR=$4
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
    C_PARAMETER={\"Args\":[\"org.property-registration-network.regnet.users:getUserRegistrationRequest\",\"${USERNAME}\",\"${AADHAR}\"]}
    peer chaincode query -C $CHANNEL_NAME -n regnet -c "$C_PARAMETER" >&log.txt
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

chaincodeQueryAllUserRegistrationRequests() {
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
    C_PARAMETER={\"Args\":[\"org.property-registration-network.regnet.users:getAllUserRegistrationRequests\"]}
    peer chaincode query -C $CHANNEL_NAME -n regnet -c $C_PARAMETER >&log.txt
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


chaincodeQueryAllUsers() {
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
    C_PARAMETER={\"Args\":[\"org.property-registration-network.regnet.users:getAllUsers\"]}
    peer chaincode query -C $CHANNEL_NAME -n regnet -c $C_PARAMETER >&log.txt
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

chaincodeQueryUser() {
  PEER=$1
  ORGNAME=$2
  USERNAME=$3
  AADHAR=$4
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
    C_PARAMETER={\"Args\":[\"org.property-registration-network.regnet.users:viewUser\",\"${USERNAME}\",\"${AADHAR}\"]}
    peer chaincode query -C $CHANNEL_NAME -n regnet -c "$C_PARAMETER" >&log.txt
    res=$?
    set +x
    test $res -eq 0 && VALUE=$(cat log.txt | awk '/Query Result/ {print $NF}')
  	VALUE=$(cat log.txt | grep -o "\"${VERIFICATION_FIELD}\": *\"[^\"]*" | grep -o '[^"]*$')
    if test $VALUE = ""; then
      VALUE=$(cat log.txt | grep -o "\"${VERIFICATION_FIELD}\": *\"[^\"]*" | grep -o '[^"]*$')
    fi
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

chaincodeQueryUserGolang() {
  PEER=$1
  ORGNAME=$2
  USERNAME=$3
  AADHAR=$4
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
    C_PARAMETER={\"Args\":[\"getUser\",\"${USERNAME}\",\"${AADHAR}\"]}
    peer chaincode query -C $CHANNEL_NAME -n regnetgo -c "$C_PARAMETER" >&log.txt
    res=$?
    set +x
    rc=0
  done
  cat log.txt
  
  sleep $DELAY
}

propertyRegistrationRequest() {
  parsePeerConnectionParameters $@
  res=$?
  verifyResult $res "Invoke transaction failed on channel '$CHANNEL_NAME' due to uneven number of peer and org parameters "

  # while 'peer chaincode' command can get the orderer endpoint from the
  # peer (if join was successful), let's supply it directly as we know
  # it using the "-o" option
  C_PARAMETER={\"Args\":[\"org.property-registration-network.regnet.users:propertyRegistrationRequest\",\"${USERNAME}\",\"${AADHAR}\",\"${PROPERTYID}\",\"${PRICE}\"]}
  echo ${C_PARAMETER}
  if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
    set -x
    peer chaincode invoke -o orderer.property-registration-network.com:7050 -C $CHANNEL_NAME -n regnet $PEER_CONN_PARMS -c "${C_PARAMETER}" >&log.txt
    res=$?
    set +x
  else
    set -x
    peer chaincode invoke -o orderer.property-registration-network.com:7050 --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME -n regnet $PEER_CONN_PARMS -c "${C_PARAMETER}" >&log.txt
    res=$?
    set +x
  fi
  cat log.txt
  verifyResult $res "Invoke execution on $PEERS failed "
  echo "===================== Invoke transaction successful on $PEERS on channel '$CHANNEL_NAME' ===================== "
  echo
  sleep $DELAY
}


chaincodeQueryPropertyRequest() {
  PEER=$1
  ORGNAME=$2
  PROPERTYID=$3
  setGlobals $PEER $ORGNAME
  VERIFICATION_FIELD=$4
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
    C_PARAMETER={\"Args\":[\"org.property-registration-network.regnet.users:getPropertyRegistrationRequest\",\"${PROPERTYID}\"]}
    peer chaincode query -C $CHANNEL_NAME -n regnet -c "$C_PARAMETER" >&log.txt
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

chaincodeApprovePropertyRegistrationRequest() {
  parsePeerConnectionParameters $@
  res=$?
  verifyResult $res "Invoke transaction failed on channel '$CHANNEL_NAME' due to uneven number of peer and org parameters "

  # while 'peer chaincode' command can get the orderer endpoint from the
  # peer (if join was successful), let's supply it directly as we know
  # it using the "-o" option
  C_PARAMETER={\"Args\":[\"org.property-registration-network.regnet.registrar:approvePropertyRegistration\",\"${PROPERTYID}\"]}
  echo ${C_PARAMETER}
  if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
    set -x
    peer chaincode invoke -o orderer.property-registration-network.com:7050 -C $CHANNEL_NAME -n regnet $PEER_CONN_PARMS -c "${C_PARAMETER}" >&log.txt
    res=$?
    set +x
  else
    set -x
    peer chaincode invoke -o orderer.property-registration-network.com:7050 --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME -n regnet $PEER_CONN_PARMS -c "${C_PARAMETER}" >&log.txt
    res=$?
    set +x
  fi
  cat log.txt
  verifyResult $res "Invoke execution on $PEERS failed "
  echo "===================== Invoke transaction successful on $PEERS on channel '$CHANNEL_NAME' ===================== "
  echo
  sleep $DELAY
}

chaincodeQueryAllProperties(){
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
    C_PARAMETER={\"Args\":[\"org.property-registration-network.regnet.users:getAllProperties\"]}
    peer chaincode query -C $CHANNEL_NAME -n regnet -c $C_PARAMETER >&log.txt
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

chaincodeQueryProperty() {
  PEER=$1
  ORGNAME=$2
  PROPERTYID=$3
  setGlobals $PEER $ORGNAME
  VERIFICATION_FIELD=$4
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
    C_PARAMETER={\"Args\":[\"org.property-registration-network.regnet.users:viewProperty\",\"${PROPERTYID}\"]}
    peer chaincode query -C $CHANNEL_NAME -n regnet -c "$C_PARAMETER" >&log.txt
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

chaincodeRechargeAccount() {
  parsePeerConnectionParameters $@
  res=$?
  verifyResult $res "Invoke transaction failed on channel '$CHANNEL_NAME' due to uneven number of peer and org parameters "

  # while 'peer chaincode' command can get the orderer endpoint from the
  # peer (if join was successful), let's supply it directly as we know
  # it using the "-o" option
  C_PARAMETER={\"Args\":[\"org.property-registration-network.regnet.users:rechargeAccount\",\"${USERNAME}\",\"${AADHAR}\",\"${TXNID}\"]}
  echo ${C_PARAMETER}
  if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
    set -x
    peer chaincode invoke -o orderer.property-registration-network.com:7050 -C $CHANNEL_NAME -n regnet $PEER_CONN_PARMS -c "${C_PARAMETER}" >&log.txt
    res=$?
    set +x
  else
    set -x
    peer chaincode invoke -o orderer.property-registration-network.com:7050 --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME -n regnet $PEER_CONN_PARMS -c "${C_PARAMETER}" >&log.txt
    res=$?
    set +x
  fi
  cat log.txt
  verifyResult $res "Invoke execution on $PEERS failed "
  echo "===================== Invoke transaction successful on $PEERS on channel '$CHANNEL_NAME' ===================== "
  echo
  sleep $DELAY
}

chaincodeUpdateProperty() {
  parsePeerConnectionParameters $@
  res=$?
  verifyResult $res "Invoke transaction failed on channel '$CHANNEL_NAME' due to uneven number of peer and org parameters "

  # while 'peer chaincode' command can get the orderer endpoint from the
  # peer (if join was successful), let's supply it directly as we know
  # it using the "-o" option
  C_PARAMETER={\"Args\":[\"org.property-registration-network.regnet.users:updateProperty\",\"${USERNAME}\",\"${AADHAR}\",\"${PROPERTYID}\",\"${STATUS}\"]}
  echo ${C_PARAMETER}
  if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
    set -x
    peer chaincode invoke -o orderer.property-registration-network.com:7050 -C $CHANNEL_NAME -n regnet $PEER_CONN_PARMS -c "${C_PARAMETER}" >&log.txt
    res=$?
    set +x
  else
    set -x
    peer chaincode invoke -o orderer.property-registration-network.com:7050 --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME -n regnet $PEER_CONN_PARMS -c "${C_PARAMETER}" >&log.txt
    res=$?
    set +x
  fi
  cat log.txt
  verifyResult $res "Invoke execution on $PEERS failed "
  echo "===================== Invoke transaction successful on $PEERS on channel '$CHANNEL_NAME' ===================== "
  echo
  sleep $DELAY
}

chaincodePurchaseProperty() {
  parsePeerConnectionParameters $@
  res=$?
  verifyResult $res "Invoke transaction failed on channel '$CHANNEL_NAME' due to uneven number of peer and org parameters "

  # while 'peer chaincode' command can get the orderer endpoint from the
  # peer (if join was successful), let's supply it directly as we know
  # it using the "-o" option
  C_PARAMETER={\"Args\":[\"org.property-registration-network.regnet.users:purchaseProperty\",\"${USERNAME}\",\"${AADHAR}\",\"${PROPERTYID}\"]}
  echo ${C_PARAMETER}
  if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
    set -x
    peer chaincode invoke -o orderer.property-registration-network.com:7050 -C $CHANNEL_NAME -n regnet $PEER_CONN_PARMS -c "${C_PARAMETER}" >&log.txt
    res=$?
    set +x
  else
    set -x
    peer chaincode invoke -o orderer.property-registration-network.com:7050 --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME -n regnet $PEER_CONN_PARMS -c "${C_PARAMETER}" >&log.txt
    res=$?
    set +x
  fi
  cat log.txt
  verifyResult $res "Invoke execution on $PEERS failed "
  echo "===================== Invoke transaction successful on $PEERS on channel '$CHANNEL_NAME' ===================== "
  echo
  sleep $DELAY
}

printMessage(){
  echo
  echo "----------------------------------------------------------------------------------------------"
  echo $1
  echo "----------------------------------------------------------------------------------------------"
  echo
}
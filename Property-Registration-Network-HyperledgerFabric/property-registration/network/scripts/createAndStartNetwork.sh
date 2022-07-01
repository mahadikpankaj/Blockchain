#!/bin/bash
# import utils
. scripts/utils.sh

echo "Build network (create channel, join channel) "
echo
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


createChannel() {
	setGlobals 'peer0' 'registrar'

	if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
                set -x
		peer channel create -o orderer.property-registration-network.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/channel.tx >&log.txt
		res=$?
                set +x
	else
				set -x
		peer channel create -o orderer.property-registration-network.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/channel.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA >&log.txt
		res=$?
				set +x
	fi
	cat log.txt
	verifyResult $res "Channel creation failed"
	echo "===================== Channel '$CHANNEL_NAME' created ===================== "
	echo
}

joinChannel () {
	for org in 'registrar' 'users'; do
	    for peer in 'peer0' 'peer1'; do
			joinChannelWithRetry $peer $org
			echo "===================== ${peer}.${ORGNAME} joined channel '$CHANNEL_NAME' ===================== "
			sleep $DELAY
			echo
	    done
	done

	peer='peer2'
	org='users'
	joinChannelWithRetry $peer $org
	echo "===================== ${peer}.${ORGNAME} joined channel '$CHANNEL_NAME' ===================== "
	sleep $DELAY
	echo

}

## Create channel
printMessage "Creating channel..."
createChannel

## Join all the peers to the channel
printMessage "Having all peers join the channel..."
joinChannel

## Set the anchor peers for each org in the channel
printMessage "Updating anchor peers for registrar..."
updateAnchorPeers 'peer0' 'registrar'
printMessage "Updating anchor peers for users..."
updateAnchorPeers 'peer0' 'users'

echo
echo "========= All GOOD, pankaj_property_registration_network created successfully...! =========== "
echo

exit 0

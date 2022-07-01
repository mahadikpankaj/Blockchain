package main

import (
	"fmt"
	"time"

	"github.com/hyperledger/fabric/common/util"
	"github.com/hyperledger/fabric/core/chaincode/shim"
	pb "github.com/hyperledger/fabric/protos/peer"
)

type User struct {
	name         string
	aadharNumber string
	email        string
	phone        string
	upgradCoins  string
	requestedAt  time.Time
	approvedAt   time.Time
}

type RegChaincode struct {
}

func (reg *RegChaincode) Init(stub shim.ChaincodeStubInterface) pb.Response {

	return shim.Success([]byte("RegChaincode initialized successfully."))
}

func (reg *RegChaincode) Invoke(stub shim.ChaincodeStubInterface) pb.Response {
	fc, args := stub.GetFunctionAndParameters()
	if fc == "getUser" {
		return reg.getUser(stub, args)
	}
	return shim.Error("Called function is not defined in the chaincode ")
}
func (reg *RegChaincode) getUser(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	chainCodeArgs := util.ToChaincodeArgs("org.property-registration-network.regnet.users:viewUser", "args")
	response := stub.InvokeChaincode("regnet", chainCodeArgs, "property-registration-channel")

	if response.Status != shim.OK {
		return shim.Error(response.Message)
	}
	return shim.Success([]byte(response.Payload))
}
func main() {
	err := shim.Start(new(RegChaincode))
	if err != nil {
		fmt.Printf("RegChaincode instantiated")
	}
}

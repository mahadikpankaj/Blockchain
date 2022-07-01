// SPDX-License-Identifier: FTL
pragma solidity ^0.8.0;
// Author: Pankaj Mahadik
/** 
The overall logic and flow is as below:

The KYC contract has 3 major entieis: Customer, Bank and KYCRequest.

The deployer of the contract will get stored as admin user. This admin user is the only address who is allowed to add banks, remove banks
and modify the banks that are authorized to add and validate the KYC of customers.

Banks will collect the information of a customer and will call addCustomer function to add it to customers list.
Then the bank will call addRequest function so that all banks can verify and then register their vote (upVote or downVote) for this request.
One bank can vote (either upVote or downVote) only once for a customer.

modifyCustomer function will get called If some documents are updated for a customer and need to reinitiate the KYC process.
This will reset the earlier verification status upVote, downVote

The KYC status of customer is marked as verified if the count of upVotes is greater than the downVotes.
KYC status will makred as false in following 2 scenarios: 
i) if the count of downVotes is greater than upVotes
ii) if the count of downVotes is greater than 1/3 of the number of banks participating in the KYC process.

It assumes at least 6 banks are participating in the KYC process to evaluate the full functionality.

If the customer verification fails, the complaint count for the bank that has initiated the request will raised by one.
If the complaints count for a bank is greater than 1/3 of the total number of banks, then bank will be banned from the KYC process and cannot add it's vote.

Various events are defined, and they will get emitted when corresponding functionality will get executed
**/

contract KYC {
    //struct to define Customer entity
    struct Customer {
        string name; //name of customer, this is assumed to be unique.
        string data; //customer data
        address bankAddress; //address of bank that collects the customer data and initiates the verification request.
        bool kycStatus; // KYC status of customer if verified or not.
        uint256 upVotes; // number of banks that voted positively for the customer.
        uint256 downVotes; // number of banks that voted negatively for the customer.
    }

    //struct to define Bank entity
    struct Bank {
        string name; // name of bank
        address ethAddress; // address of bank
        string regNumber; // registration number of the bank
        uint256 complaintsReported; // number of complaints against the bank. If the customer KYC fails, the complaint count raised by one.
        uint256 kycRequestsInitiatedCount; // number of total kyc requests that a bank has initiated
        bool isAllowedToVote; // if the complaints count is more than 1/3 of the total number of banks, then the bank is banned from voting process.
    }

    //struct to define KYCRequest entity
    struct KYCRequest {
        string customerName; // name of customer which is unique
        string customerDataHash; //hash of link of customer data
        address bankAddress; //address of bank that initiated the request
    }

    // admin to hold the address of the deployer account
    address private admin;

    // to hold total number of banks in KYC process.
    uint256 private banksCount;

    // mapping to hold customer name and actual customer object
    mapping(string => Customer) private customersMapping;

    // mapping of address and bank object
    mapping(address => Bank) private banksMapping;

    // mapping of customer name and it's KYV verification request
    mapping(string => KYCRequest) private requestsMapping;

    // mapping of customer name and list of banks that have already voted for it.
    // this is used to avoid duplicate voting.
    mapping(string => address[]) private customerBankVotingArr;

    // event to be emitted when admin adds a bank
    event BankAdded(
        address indexed _by,
        address indexed _bankAddress,
        string _bankName
    );

    // event to be emitted when admin removes a bank
    event BankRemoved(
        address indexed _by,
        address indexed _bankAddress,
        string _bankName
    );

    // event to be emitted when admin modifies a bank  like allowed to vote or not
    event BankModified(
        address indexed _by,
        address indexed _bankAddress,
        string _bankName,
        bool _isAllowedToVote
    );

    // event to be emitted when a bank votes (up=true, down=false) for a customer
    event BankVoted(
        address indexed _bankAddress,
        string _customerName,
        bool isUpVote
    );

    // event to be emitted when the Bank status is changed
    event BankStatusUpdated(address indexed _bankAddress, bool _status);

    // event to be emitted when a bank adds a customer
    event CustomerAdded(address indexed _by, string _customerName);

    // event to be emitted when a bank modifies a customer
    event CustomerModified(address indexed _by, string _customerName);

    // event to be emitted when bank adds KYC request for a customer
    event KYCRequestAdded(address indexed _by, string _customerName);

    // event to be emitted when bank removes KYC request for a customer
    event KYCRequestRemoved(address indexed _by, string _customerName);

    // event to be emitted when the KYC status of a customer is changed
    event KYCStatusUpdated(string _customerName, bool _status);

    //constructor to initialize the admin address with the address of the deployer.
    constructor() {
        admin = msg.sender;
    }

    // modifier to check if the request initiated by admin address
    modifier onlyAdmin() {
        require(
            admin == msg.sender,
            "Only admin can perform this opeartion...!"
        );
        _;
    }

    // modifier to check if the request initiated by a bank, that is valid for KYC process
    modifier authorizedBank(address _bankAddress) {
        require(
            banksMapping[_bankAddress].ethAddress == _bankAddress,
            "Bank is not authorized...!"
        );
        _;
    }

    // Admin Interface functionalities
    // Functions to be carried out by admin
    // function to add a bank to verification process. Only admin can invoke this.
    function addBank(
        string memory _bankName,
        address _bankAddress,
        string memory _regNumber
    ) public onlyAdmin returns (bool) {
        require(
            banksMapping[_bankAddress].ethAddress == address(0),
            "This bank is already present as authorized bank"
        );
        banksMapping[_bankAddress].name = _bankName;
        banksMapping[_bankAddress].ethAddress = _bankAddress;
        banksMapping[_bankAddress].regNumber = _regNumber;
        banksMapping[_bankAddress].complaintsReported = 0;
        banksMapping[_bankAddress].isAllowedToVote = true;
        banksMapping[_bankAddress].kycRequestsInitiatedCount = 0;
        banksCount++;
        emit BankAdded(msg.sender, _bankAddress, _bankName);
        return true;
    }

    // function to allow or disallow a bank from voting. Only admin can invoke this.
    function modifyBankIsAllowedToVote(
        address _bankAddress,
        bool _isAllowedToVote
    ) public onlyAdmin returns (bool) {
        require(
            banksMapping[_bankAddress].ethAddress != address(0),
            "This bank is not present in list of authorized banks"
        );
        banksMapping[_bankAddress].isAllowedToVote = _isAllowedToVote;
        emit BankModified(
            msg.sender,
            _bankAddress,
            banksMapping[_bankAddress].name,
            _isAllowedToVote
        );
        return true;
    }

    // function to remove a bank from voting process, Only admin can invoke thisl
    function removeBank(address _bankAddress) public onlyAdmin returns (bool) {
        require(
            banksMapping[_bankAddress].ethAddress != address(0),
            "This bank is not present in list of authorized banks"
        );
        string memory bankName = banksMapping[_bankAddress].name;
        delete (banksMapping[_bankAddress]);
        banksCount--;
        emit BankRemoved(msg.sender, _bankAddress, bankName);
        return true;
    }

    // Bank Interface functionalities
    //Functions to be carried out by Bank(s)
    function addCustomer(
        string memory _customerName,
        string memory _customerData
    ) public authorizedBank(msg.sender) returns (bool) {
        require(
            customersMapping[_customerName].bankAddress == address(0),
            "Customer is already present, please call modifyCustomer to edit the customer data"
        );
        customersMapping[_customerName].name = _customerName;
        customersMapping[_customerName].data = _customerData;
        customersMapping[_customerName].bankAddress = msg.sender;
        customersMapping[_customerName].kycStatus = false;
        customersMapping[_customerName].upVotes = 0;
        customersMapping[_customerName].downVotes = 0;
        emit CustomerAdded(msg.sender, _customerName);
        return true;
    }

    function viewCustomer(string memory _customerName)
        public
        view
        returns (
            string memory,
            string memory,
            address,
            bool,
            uint256,
            uint256
        )
    {
        require(
            customersMapping[_customerName].bankAddress != address(0),
            "Customer is not present in the database"
        );
        return (
            customersMapping[_customerName].name,
            customersMapping[_customerName].data,
            customersMapping[_customerName].bankAddress,
            customersMapping[_customerName].kycStatus,
            customersMapping[_customerName].upVotes,
            customersMapping[_customerName].downVotes
        );
    }

    function modifyCustomer(
        string memory _customerName,
        string memory _newCustomerData
    ) public authorizedBank(msg.sender) {
        require(
            customersMapping[_customerName].bankAddress != address(0),
            "Customer is not present in the database"
        );
        delete (requestsMapping[_customerName]);
        delete (customerBankVotingArr[_customerName]);
        customersMapping[_customerName].data = _newCustomerData;
        customersMapping[_customerName].kycStatus = false;
        customersMapping[_customerName].upVotes = 0;
        customersMapping[_customerName].downVotes = 0;
        emit CustomerModified(msg.sender, _customerName);
    }

    function addRequest(
        string memory _customerName,
        string memory _customerDataHash
    ) public authorizedBank(msg.sender) returns (bool) {
        // validate that the customer is present in customers list.
        require(
            customersMapping[_customerName].bankAddress != address(0),
            "The customer is not present in customers list"
        );

        // validate that request for the customer is not already exist
        require(
            requestsMapping[_customerName].bankAddress == address(0),
            "KYC Request for the customer is already received and is in process..."
        );
        //increment the count of requests initiated by the bank
        address requestInitiatingBank = customersMapping[_customerName]
            .bankAddress;
        banksMapping[requestInitiatingBank].kycRequestsInitiatedCount++;

        requestsMapping[_customerName].customerName = _customerName;
        requestsMapping[_customerDataHash].customerDataHash = _customerDataHash;
        requestsMapping[_customerName].bankAddress = msg.sender;
        emit KYCRequestAdded(msg.sender, _customerName);
        return true;
    }

    function removeRequest(string memory _customerName) public returns (bool) {
        require(
            requestsMapping[_customerName].bankAddress != address(0),
            "KYC Request for the customer is not present"
        );
        delete (requestsMapping[_customerName]);
        delete (customerBankVotingArr[_customerName]);
        emit KYCRequestRemoved(msg.sender, _customerName);
        return true;
    }

    // function to check if a particular bank has voted for a customer request or not
    function hasBankVoted(string memory _customerName, address _bankAddress)
        internal
        view
        returns (bool)
    {
        bool bankVoted = false;
        for (
            uint256 i = 0;
            i < customerBankVotingArr[_customerName].length;
            i++
        ) {
            if (_bankAddress == customerBankVotingArr[_customerName][i]) {
                bankVoted = true;
                break;
            }
        }
        return bankVoted;
    }

    // function to add positive vote in verification process
    function upVoteCustomer(string memory _customerName) public returns (bool) {
        // check if customer exists in customers list
        require(
            requestsMapping[_customerName].bankAddress != address(0),
            "KYC Request for the customer is not present"
        );

        // check if bank has already voted for the customer
        require(
            !hasBankVoted(_customerName, msg.sender),
            "The bank has already voted for the customer"
        );

        // check if bank is allowed to vote
        require(
            banksMapping[msg.sender].isAllowedToVote,
            "bank is not allowed to vote"
        );

        customerBankVotingArr[_customerName].push(msg.sender);
        customersMapping[_customerName].upVotes += 1;
        emit BankVoted(msg.sender, _customerName, true);
        updateCustomerKYCStatus(_customerName);

        return true;
    }

    // function to add negative vote in verification process
    function downVoteCustomer(string memory _customerName)
        public
        returns (bool)
    {
        // check if customer exists in customer list
        require(
            requestsMapping[_customerName].bankAddress != address(0),
            "KYC Request for the customer is not present"
        );

        // check if bank has already voted for the customer
        require(
            !hasBankVoted(_customerName, msg.sender),
            "The bank has already voted for the customer"
        );

        // check if bank is allowed to vote
        require(
            banksMapping[msg.sender].isAllowedToVote,
            "bank is not allowed to vote"
        );

        customerBankVotingArr[_customerName].push(msg.sender);
        customersMapping[_customerName].downVotes += 1;

        emit BankVoted(msg.sender, _customerName, false);
        updateCustomerKYCStatus(_customerName);

        // as the customer getting  downVoted, hence the complaint count of verified bank should be increased.
        updateBankStatus(_customerName);
        return true;
    }

    // common function to check and set the KYC Status of the bank customer
    function updateCustomerKYCStatus(string memory _customerName)
        private
        returns (bool)
    {
        uint256 upVoteCount = customersMapping[_customerName].upVotes;
        uint256 downVoteCount = customersMapping[_customerName].downVotes;
        bool kycStatus = upVoteCount > downVoteCount;
        if (banksCount > 5) {
            if (downVoteCount > banksCount / 3) {
                kycStatus = false;
            }
        }
        customersMapping[_customerName].kycStatus = kycStatus;
        emit KYCStatusUpdated(_customerName, kycStatus);
        return true;
    }

    // update the status of bank if eligible to vote or not
    function updateBankStatus(string memory _customerName)
        private
        returns (bool)
    {
        address verifiedByBank = customersMapping[_customerName].bankAddress;
        banksMapping[verifiedByBank].complaintsReported++;
        uint256 bankComplaintsCount = banksMapping[verifiedByBank]
            .complaintsReported;
        if (banksCount > 5) {
            if (bankComplaintsCount > banksCount / 3) {
                banksMapping[verifiedByBank].isAllowedToVote = false;
                emit BankStatusUpdated(verifiedByBank, false);
            }
        }

        return true;
    }

    // function to retrieve the count of complaints against the bank
    function getBankComplaintsCount(address _bankAddress)
        public
        onlyAdmin
        view
        returns (uint256)
    {
        require(
            banksMapping[_bankAddress].ethAddress != address(0),
            "Specified bank is not present"
        );
        return banksMapping[_bankAddress].complaintsReported;
    }
}

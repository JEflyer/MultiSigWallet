//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

//import interface for interacting with transaction contract
import "./interfaces/ITransaction.sol";

//import IERC721
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

//import erc721receiver
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract MultiSig is IERC721Receiver {

    event NewUser(address user, uint8 userCount);
    event UserRemoved(address user, uint8 newUserCount);
    event SingleSign(address user, uint32 transactionId);
    event FullySigned(address[] user, uint32 transactionId);

    struct Data {
        address execAdd;
        address collection;
        address proposedBy;
        uint256 proposedPrice;
        uint8 signCount;
        mapping(address => bool) signedBy;
        bool active;
        bool transacted;
    }

    //wallet for making admin changes
    address private admin;
    
    //by defaut the bool is false 
    mapping(address => bool) private approvedWallets;
    
    uint32 transactionCount;

    //transaction Id to data
    mapping(uint32 => Data) private information;

    //keep a list of tokens owned by this contract for a given collection
    mapping(address => uint16[]) private tokens;

    uint8 minSignature;

    constructor(
        address[] memory addressesToAdd
    ){
        require(addressesToAdd.length < 8);
        transactionCount = 0;
        for(uint8 i=0; i< addressesToAdd.length; i++){  
            approvedWallets[addressesToAdd[i]] = true;
        }
        minSignature = uint8(addressesToAdd.length -1);
    }

    modifier onlyAdmin {
        require(msg.sender == admin, "OA");
        _;
    }

    modifier onlyApproved{
        require(approvedWallets[msg.sender] == true,"OAp");
        _;
    }

    //add wallet
    function addWallet(address wallet) onlyAdmin external {
        approvedWallets[wallet] = true;
    }

    //remove wallet
    function removeWallet(address wallet) onlyAdmin external {
        approvedWallets[wallet] = false;
    }

    //propose transaction
    function proposeTransaction(address execAdd, address collection, uint256 value) external onlyApproved {
        require(address(this).balance >= value);
        transactionCount +=1;
        information[transactionCount].execAdd = execAdd;
        information[transactionCount].proposedPrice = value;
        information[transactionCount].proposedBy = msg.sender;
        information[transactionCount].signedBy[msg.sender] = true;
        information[transactionCount].signCount += 1;
        information[transactionCount].active = true;
        information[transactionCount].collection = collection;
    }

    //sign transaction
    function signTransaction(uint32 transactionId) external onlyApproved {
        //check that wallet has not already signed
        require(information[transactionId].signedBy[msg.sender] == false);

        //check that the transaction is active
        require(information[transactionId].active);

        //sign & increase sign count
        information[transactionId].signedBy[msg.sender] = true;
        information[transactionId].signCount += 1;

        //if enough signs have been gathered execute transaction
        if(information[transactionId].signCount == minSignature){
            ITransaction(information[transactionId].execAdd).transact(information[transactionId].collection);
            
            information[transactionId].active = false;
            information[transactionId].transacted = true;
            
        }
    }


    //cancel transaction
    function cancelTransaction(uint32 transactionId)external onlyApproved{
        //check that the transaction is active
        require(information[transactionId].active);

        //check that msg.sender proposed this transaction
        require(information[transactionId].proposedBy == msg.sender);

        //cancel
        information[transactionId].active = false;
    }

    //get tx info
    function getTxInfo(uint32 transactionId) external view returns(
        address,
        address,
        address,
        uint256,
        uint8,
        bool,
        bool
    ){
        Data storage data = information[transactionId]; 
        return (data.execAdd, data.collection, data.proposedBy, data.proposedPrice, data.signCount, data.active, data.transacted);
    }

    //Send first NFT registered on the contract
    function fullSend(address to, address collection) external onlyApproved {
        IERC721(collection).safeTransferFrom(address(this), to, tokens[collection][tokens[collection].length -1]);
        tokens[collection].pop();
    }

    //save details
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) public virtual override returns (bytes4) {
        uint16[] storage arr = tokens[operator];
        arr[arr.length] = uint16(tokenId);
        return this.onERC721Received.selector;
    }
}
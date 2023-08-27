/**
Interface IERC721: This is an interface that defines the transferFrom function from the ERC-721 standard. 
This function is used to transfer ownership of an NFT from one address to another.

Contract Escrow: This is the main contract that implements the escrow functionality for NFT trades.

Constructor: Initializes the contract with the addresses of the NFT contract, seller, inspector, and lender.

Modifiers:

onlyBuyer: Restricts functions to be callable only by the buyer of a specific NFT.
onlySeller: Restricts functions to be callable only by the seller.
onlyInspector: Restricts functions to be callable only by the inspector.
State Variables:

nftAddress: The address of the NFT contract.
seller: The address of the seller.
inspector: The address of the inspector.
lender: The address of the lender.
Mappings:

isListed: Tracks whether an NFT is listed for sale.
purchasePrice: Stores the purchase price of each NFT.
escrowAmount: Stores the escrow amount required for each NFT.
buyer: Maps NFT IDs to their respective buyers.
inspectionPassed: Tracks whether an inspection has been passed for each NFT.
approval: Tracks approval statuses for the sale from different parties.
Functions:

list: Allows the seller to list an NFT for sale by transferring it to the contract and setting the sale details.

depositEarnest: Allows the buyer to deposit the earnest money required for the escrow.

updateInspectionStatus: Allows the inspector to update the inspection status of an NFT.

approveSale: Allows various parties (including buyer, seller, and lender) to approve the sale.

finalizeSale: Finalizes the sale by transferring NFT ownership and funds when all conditions are met.

cancelSale: Cancels the sale, handling earnest deposit refunds or transferring funds to the seller based on inspection status.

receive: Fallback function to accept Ether payments.

getBalance: Returns the contract's Ether balance.

Overall, this contract implements an escrow mechanism for trading NFTs with various conditions such as inspections, approvals, and specific parties' involvement. 
It ensures that the sale is only finalized when all requirements are met, and handles the cancellation of sales as well
**/


//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface IERC721 {
    function transferFrom(
        address _from,
        address _to,
        uint256 _id
    ) external;
}

contract Escrow {
    address public nftAddress;
    address payable public seller;
    address public inspector;
    address public lender;

    modifier onlyBuyer(uint256 _nftID) {
        require(msg.sender == buyer[_nftID], "Only buyer can call this method");
        _;
    }

    modifier onlySeller() {
        require(msg.sender == seller, "Only seller can call this method");
        _;
    }

    modifier onlyInspector() {
        require(msg.sender == inspector, "Only inspector can call this method");
        _;
    }

    mapping(uint256 => bool) public isListed;
    mapping(uint256 => uint256) public purchasePrice;
    mapping(uint256 => uint256) public escrowAmount;
    mapping(uint256 => address) public buyer;
    mapping(uint256 => bool) public inspectionPassed;
    mapping(uint256 => mapping(address => bool)) public approval;

    constructor(
        address _nftAddress,
        address payable _seller,
        address _inspector,
        address _lender
    ) {
        nftAddress = _nftAddress;
        seller = _seller;
        inspector = _inspector;
        lender = _lender;
    }

    function list(
        uint256 _nftID,
        address _buyer,
        uint256 _purchasePrice,
        uint256 _escrowAmount
    ) public payable onlySeller {
        // Transfer NFT from seller to this contract
        IERC721(nftAddress).transferFrom(msg.sender, address(this), _nftID);

        isListed[_nftID] = true;
        purchasePrice[_nftID] = _purchasePrice;
        escrowAmount[_nftID] = _escrowAmount;
        buyer[_nftID] = _buyer;
    }

    // Put Under Contract (only buyer - payable escrow)
    function depositEarnest(uint256 _nftID) public payable onlyBuyer(_nftID) {
        require(msg.value >= escrowAmount[_nftID]);
    }

    // Update Inspection Status (only inspector)
    function updateInspectionStatus(uint256 _nftID, bool _passed)
        public
        onlyInspector
    {
        inspectionPassed[_nftID] = _passed;
    }

    // Approve Sale
    function approveSale(uint256 _nftID) public {
        approval[_nftID][msg.sender] = true;
    }

    // Finalize Sale
    // -> Require inspection status (add more items here, like appraisal)
    // -> Require sale to be authorized
    // -> Require funds to be correct amount
    // -> Transfer NFT to buyer
    // -> Transfer Funds to Seller
    function finalizeSale(uint256 _nftID) public {
        require(inspectionPassed[_nftID]);
        require(approval[_nftID][buyer[_nftID]]);
        require(approval[_nftID][seller]);
        require(approval[_nftID][lender]);
        require(address(this).balance >= purchasePrice[_nftID]);

        isListed[_nftID] = false;

        (bool success, ) = payable(seller).call{value: address(this).balance}(
            ""
        );
        require(success);

        IERC721(nftAddress).transferFrom(address(this), buyer[_nftID], _nftID);
    }

    // Cancel Sale (handle earnest deposit)
    // -> if inspection status is not approved, then refund, otherwise send to seller
    function cancelSale(uint256 _nftID) public {
        if (inspectionPassed[_nftID] == false) {
            payable(buyer[_nftID]).transfer(address(this).balance);
        } else {
            payable(seller).transfer(address(this).balance);
        }
    }

    receive() external payable {}

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}

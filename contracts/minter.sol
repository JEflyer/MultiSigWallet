//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

//import ERC721 enumerable
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract Minter is ERC721Enumerable {


    using Strings for uint256;
    address payable public owner;
    uint256 public price;
    uint256 soldId;

    mapping(uint256 => string) private _tokenURIs;
    uint256 public nftsMinted;

    uint256 public totalCurrentlyMintable;
    uint256 totalLimit = 10000;

    bool revealed;

    // Base URI
    string private _baseURIextended = "https://gateway.pinata.cloud/ipfs/";
    string private CID = "QmXKqmzGt6WmEBoTQN38FPiLPvugGPhqQjTXbEfQ8JVF4x/";

    constructor(
        uint256 _price
    ) ERC721("name","sym"){
        nftsMinted = 0;
        owner = payable(msg.sender);
        price = _price;
        totalCurrentlyMintable = 0;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }    

    function setBaseURI(string memory baseURI_) external onlyOwner {
        _baseURIextended = baseURI_;
    }

    function _setTokenURI(uint256 tokenId, string memory uri) internal virtual {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI set of nonexistent token"
        );
        _tokenURIs[tokenId] = uri;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseURIextended;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();

        
        return string(abi.encodePacked(base, CID, _tokenURI, ".JSON"));
        
    }

    function mint(uint8 _amount) public payable {

        if (msg.sender != owner) {
            require(msg.value >= price * _amount, "Not enough ether was sent");
            owner.transfer(msg.value);
        }
        require(_amount <= 10, "You can not mint more than 10 at a time");

        require(
            nftsMinted + _amount <= totalCurrentlyMintable,
            "Can not mint more than the limit"
        );

        for (uint8 i = 0; i < _amount; i++) {
            nftsMinted = nftsMinted + 1;
            _mint(msg.sender, nftsMinted);
            _setTokenURI(nftsMinted, nftsMinted.toString());
        }
    }


    function walletOfOwner(address queryWallet)
        public
        view
        returns (uint256[] memory)
    {
        uint256 ownerTokenCount = balanceOf(queryWallet);
        uint256[] memory tokenIds = new uint256[](ownerTokenCount);
        for (uint16 i; i < ownerTokenCount; i++) {
            tokenIds[i] = tokenOfOwnerByIndex(queryWallet, i);
        }
        return tokenIds;
    }




}
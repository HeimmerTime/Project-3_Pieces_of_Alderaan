pragma solidity ^0.6.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v3.4/contracts/token/ERC721/ERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v3.4/contracts/access/Ownable.sol";
//import  "vrf-solidity/contracts/VRF.sol";
import "https://github.com/smartcontractkit/chainlink-brownie-contracts/blob/main/contracts/src/v0.6/VRFConsumerBase.sol";

contract AlderaanCollectible is ERC721, VRFConsumerBase  {
   uint256 public tokenCounter;
    enum Planetoid{Isatabith, Terrarium, Crevasse, Juranno, Imperial, Aldera, Cloudshape_Falls}
    // add other things
    mapping(bytes32 => address) public requestIdToSender;
    mapping(bytes32 => string) public requestIdToTokenURI;
    mapping(uint256 => Planetoid) public tokenIdToMint;
    mapping(bytes32 => uint256) public requestIdToTokenId;
    event requestedCollectible(bytes32 indexed requestId); 


    bytes32 internal keyHash;
    uint256 internal fee;
    uint256 public randomResult;
    constructor(address _VRFCoordinator, address _LinkToken, bytes32 _keyhash)
    public 
   
    VRFConsumerBase (_VRFCoordinator, _LinkToken)
    ERC721("MosEisley_Mint", "ALDRN")

    
    {
        tokenCounter = 0;
        keyHash = _keyhash;
        fee = 0.1 * 10 ** 18;

    }
    
        
        
    function createCollectible(string memory tokenURI, uint256 userProvidedSeed) 
        public returns (bytes32){
            bytes32 requestId = requestRandomness(keyHash, fee, userProvidedSeed);
            requestIdToSender[requestId] = msg.sender;
            requestIdToTokenURI[requestId] = tokenURI;
            emit requestedCollectible(requestId);
    }

    function fulfillRandomness(bytes32 requestId, uint256 randomNumber) internal {
        address planetoidOwner = requestIdToSender[requestId];
        string memory tokenURI = requestIdToTokenURI[requestId];
        uint256 newItemId = tokenCounter;
        _safeMint(planetoidOwner,newItemId);
        setTokenURI(newItemId, tokenURI);
        Planetoid planetoid= Planetoid(randomNumber % 3); 
        tokenIdToPlanetoid[newItemId] = planetoid;
        requestIdToTokenId[requestId] = newItemId;
        tokenCounter = tokenCounter + 1;
    }

    function setTokenURI(uint256 tokenId, string memory _tokenURI) public {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: transfer caller is not owner nor approved"
        );
        setTokenURI(newItemId, _tokenURI);
    }
}
//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";
import "./storage/NFTStorage.sol";

contract AcidBoyz is ERC721URIStorage, VRFConsumerBase {
    NFTStorage nftstrg;
    uint256 private tokenId;
    uint256 count = 5;
    address payable public owner;
    
    event AcidBoyMinted(uint256 indexed tokenId, string tokenURI);

    mapping (bytes32 => address) private senderToRequestid;

    uint256 private randomResult;
    bytes32 internal keyHash;
    uint256 internal fee;

    /**
     * Network: Rinkeby
     * Chainlink VRF Coordinator address: 0xb3dCcb4Cf7a26f6cf6B120Cf5A73875B7BBc655B
     * LINK token address:                0x01BE23585060835E02B77ef475b0Cc51aA1e0709   
     * Key Hash: 0x2ed0feb3e7fd2022120aa84fab1945545a9f2ffc9076fd6156fa96eaff4c1311
     */
    constructor(address _nftStorage) 
        ERC721("Acid-boyz", "ACDBZ")
        VRFConsumerBase(
            0xb3dCcb4Cf7a26f6cf6B120Cf5A73875B7BBc655B,
            0x01BE23585060835E02B77ef475b0Cc51aA1e0709
        )
    {
        keyHash = 0x2ed0feb3e7fd2022120aa84fab1945545a9f2ffc9076fd6156fa96eaff4c1311;
        fee = 0.1 * 10 ** 18;
        nftstrg = NFTStorage(_nftStorage);
        owner = payable(msg.sender);
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Access denied");
        _;
    }

    modifier priceCheck {
        if (count >= 4) {
            require(msg.value == 25000000000000000, "Not enough ether provided to mint()");
            _;
        } else if (count < 4) {
            require(msg.value == 55000000000000000, "Not enough ether provided to mint()");
            _;
        } else if (count <= 0) {
            revert();
        }
    }

    function getRandomNumber() private returns(bytes32 requestId) {
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK - fill contract with faucet");
        return requestRandomness(keyHash, fee);
    }

    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        randomResult = (randomness % nftstrg.getArrayLength()) + 1;
        string memory tokenURI = getTokenURI(randomResult);
        tokenId++;
        _mint(senderToRequestid[requestId], tokenId);
        _setTokenURI(tokenId, tokenURI);
        emit AcidBoyMinted(tokenId, tokenURI);
    }

    function mint() external payable priceCheck {
        senderToRequestid[getRandomNumber()] = msg.sender;
        count--;
    }

    function getTokenURI(uint256 rand) private pure returns(string memory) {
        return string(abi.encodePacked(
            "https://ipfs.io/ipfs/QmdWigZe82LRoSLit4BzhB6HTJRNYgGtZk4FxSrKduQyeS/", 
            Strings.toString(rand),
            ".json"));
    }

    function withdraw() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    function selfdescturct() external onlyOwner {
        selfdestruct(owner);
    }
}
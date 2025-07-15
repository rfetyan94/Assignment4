// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ISourceBridge {
function owner() external view returns (address);
}

contract DestinationContract {
address public admin;
address public sourceBridgeAddress;

```
uint256 public nextTokenId = 0;

// Inventory pool of available tokens
uint256[] public availableTokens;

// Mapping of tokenId => owner (if wrapped)
mapping(uint256 => address) public wrappedTokens;

event TokenCreated(uint256 tokenId);
event TokenWrapped(uint256 tokenId, address recipient);
event TokenUnwrapped(uint256 tokenId, address owner);

constructor(address _sourceBridgeAddress) {
    admin = msg.sender;
    sourceBridgeAddress = _sourceBridgeAddress;
}

modifier onlyAdmin() {
    require(msg.sender == admin, "Not admin");
    _;
}

modifier onlySourceBridgeOwner() {
    require(
        msg.sender == ISourceBridge(sourceBridgeAddress).owner(),
        "Unauthorized: Not source bridge owner"
    );
    _;
}

// --- 1. Create Tokens ---
function createTokens(uint256 amount) public onlyAdmin {
    for (uint256 i = 0; i < amount; i++) {
        availableTokens.push(nextTokenId);
        emit TokenCreated(nextTokenId);
        nextTokenId++;
    }
}

// --- 2. Wrap Tokens ---
function wrapToken(address recipient) public onlySourceBridgeOwner {
    require(availableTokens.length > 0, "No tokens available");
    uint256 tokenId = availableTokens[availableTokens.length - 1];
    availableTokens.pop();

    wrappedTokens[tokenId] = recipient;

    emit TokenWrapped(tokenId, recipient);
}

// --- 3. Unwrap Tokens ---
function unwrapToken(uint256 tokenId) public {
    require(wrappedTokens[tokenId] == msg.sender, "Not token owner");

    delete wrappedTokens[tokenId];
    availableTokens.push(tokenId);

    emit TokenUnwrapped(tokenId, msg.sender);
}

// --- Admin: Update bridge address ---
function updateSourceBridge(address _newSourceBridgeAddress) public onlyAdmin {
    sourceBridgeAddress = _newSourceBridgeAddress;
}

// --- Helper ---
function getAvailableTokenCount() public view returns (uint256) {
    return availableTokens.length;
}
```

}

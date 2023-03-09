// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

contract ReactionManager {

    struct Reaction {
        address contractAddress;
        string functionSignature;
        bytes parameters;
    }

    address public constant DEPOSITOR_ACCOUNT = 0xDeaDDEaDDeAdDeAdDEAdDEaddeAddEAdDEAd0001;
    address owner;
    mapping (address => Reaction) reactions;

    constructor() {
        owner = msg.sender;
    }

    function updateOwner(address newOwner) public {
        require(msg.sender == owner, "Only the owner can update the owner");
        owner = newOwner;
    }

    function registerReaction(address watchedAddress, address contractAddress, string memory functionSignature, bytes memory parameters) public {

        // Check that setter the contractAddress itself
        require(msg.sender == contractAddress, "Only the called contract itself can register a reaction");

        reactions[watchedAddress] = Reaction(contractAddress, functionSignature, parameters);
    }

    function react(address watchedAddress) public {
        require(msg.sender == DEPOSITOR_ACCOUNT, "Only the depositor account can trigger a reaction");

        Reaction storage reaction = reactions[watchedAddress];
        require(reaction.contractAddress != address(0), "No reaction registered for this address");

        // TODO: Optionally log the returnData
        (bool success, bytes memory returnData) = reaction.contractAddress.call(abi.encodeWithSignature(reaction.functionSignature, reaction.parameters));
        require(success, "Call to reaction contract failed");
    }
}
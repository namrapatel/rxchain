// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

contract Reactivity {

    struct Reaction {
        address contractAddress;
        string functionSignature;
        bytes parameters;
    }

    mapping (address => Reaction) reactions;

    function registerReaction(address watchedAddress, address contractAddress, string memory functionSignature, bytes memory parameters) public {
        reactions[watchedAddress] = Reaction(contractAddress, functionSignature, parameters);
    }

    function react(address watchedAddress) public {
        Reaction storage reaction = reactions[watchedAddress];
        require(reaction.contractAddress != address(0), "No reaction registered for this address");

        (bool success, bytes memory returnData) = reaction.contractAddress.call(abi.encodeWithSignature(reaction.functionSignature, reaction.parameters));
        require(success, "Call to reaction contract failed");
    }
}
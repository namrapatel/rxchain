// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

contract Reactivity {

    struct Reaction {
        address contractAddress;
        bytes4 functionSignature;
        bytes parameters;
    }

    mapping (address => Reaction) reactions;

    function registerReaction(address watchedAddress, address contractAddress, bytes4 functionSignature, bytes memory parameters) public {
        reactions[watchedAddress] = Reaction(contractAddress, functionSignature, parameters);
    }

    function react(address watchedAddress) public {
        Reaction storage reaction = reactions[watchedAddress];
        require(reaction.contractAddress != address(0), "No reaction registered for this address");

        (bool success, bytes memory returnData) = reaction.contractAddress.call(abi.encodeWithSignature(bytes4ToString(reaction.functionSignature), reaction.parameters));
        require(success, "Call to reaction contract failed");
    }

    // Helper function to convert bytes4 to string
    function toHexDigit(uint8 d) pure internal returns (byte) {
        if (0 <= d && d <= 9) {
            return byte(uint8(byte('0')) + d);
        } else if (10 <= uint8(d) && uint8(d) <= 15) {
            return byte(uint8(byte('a')) + d - 10);
        }
        revert();
    }

    function fromCode(bytes4 code) public view returns (string) {
        bytes memory result = new bytes(10);
        result[0] = byte('0');
        result[1] = byte('x');
        for (uint i=0; i<4; ++i) {
            result[2*i+2] = toHexDigit(uint8(code[i])/16);
            result[2*i+3] = toHexDigit(uint8(code[i])%16);
        }
        return string(result);
    }

}
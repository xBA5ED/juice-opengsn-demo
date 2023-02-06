// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { IJBPaymentTerminal } from "@jbx-protocol/juice-contracts-v3/contracts/interfaces/IJBPaymentTerminal.sol";
import { ERC2771Recipient } from  "@opengsn/contracts/src/ERC2771Recipient.sol";
import { IJB721Delegate } from "@jbx-protocol/juice-721-delegate/contracts/interfaces/IJB721Delegate.sol";

contract JBMinter is ERC2771Recipient {

    uint256 immutable projectId;
    uint16 immutable tierToMint;
    uint256 immutable priceToMint;

    IJBPaymentTerminal immutable JBETHTerminal;

    constructor(
        uint256 _projectId,
        address _terminal,
        uint16 _tierToMint,
        uint256 _priceToMint,
        address _forwarder
    ) {
        projectId = _projectId;
        JBETHTerminal = IJBPaymentTerminal(_terminal);
        tierToMint = _tierToMint;
        priceToMint = _priceToMint;
        _setTrustedForwarder(_forwarder);
    }

    function mint(
        string calldata _memo
    ) 
      external
      payable
    {
        require(msg.value == priceToMint);

        // Craft the metadata: claim from the highest tier
        uint16[] memory rawMetadata = new uint16[](1);
        rawMetadata[0] = uint16(tierToMint);
        bytes memory metadata = abi.encode(
            bytes32(0),
            bytes32(0),
            type(IJB721Delegate).interfaceId,
            true,
            rawMetadata
        );

        JBETHTerminal.pay{value: address(this).balance}(
            projectId,
            100,
            address(0),
            _msgSender(),
            0, /* _minReturnedTokens */
            false, /* _preferClaimedTokens */
            /* _memo */
            string.concat(unicode"⛽: ", _memo),
            /* _delegateMetadata */
            metadata
        );
    }
}
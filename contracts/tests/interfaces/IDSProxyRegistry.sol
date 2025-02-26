// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

interface IDSProxyRegistry {
    // deploys a new proxy instance
    // sets custom owner of proxy
    function build(address owner) external returns (address proxy);
}

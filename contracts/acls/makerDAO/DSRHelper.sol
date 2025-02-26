// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

interface IMakerProxyRegistry {
    function proxies(address _owner) external view returns (address);

    function build() external returns (address);
}

interface IDSRAuthorizer {
    function setProxy(address _ds_proxy) external;
}

contract DSRHelper {
    IMakerProxyRegistry public immutable maker_proxy_registry =
        IMakerProxyRegistry(0x4678f0a6958e4D2Bc4F1BAF7Bc52E8F3564f3fE4);

    //@dev safe deleagetcall it to create ds proxy and config authroizer
    function createProxyAndInitAuthorizer(address _authorizer) external returns (address proxy) {
        // get safe
        address safe = address(this);
        //get authorizer
        IDSRAuthorizer dsr_authorizer = IDSRAuthorizer(_authorizer);
        // query if owner has created a proxy
        proxy = maker_proxy_registry.proxies(safe);

        if (proxy == address(0)) {
            //case1: owner not have proxy, create one
            proxy = maker_proxy_registry.build();
            dsr_authorizer.setProxy(proxy);
        } else {
            dsr_authorizer.setProxy(proxy);
        }
    }
}

// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "../../base/BaseSimpleACL.sol";

contract DSRWithdrawAuthorizer is BaseSimpleACL {
    bytes32 public constant NAME = "DSRWithdrawAuthorizer";
    uint256 public constant VERSION = 1;

    //DSR related
    address public constant pot = 0x197E90f9FAD81970bA7976f33CbD77088E5D7cf7;
    address public constant dai_join = 0x9759A6Ac90977b93B58547b4A71c78317f391A28;
    address public constant dss_proxy_action = 0x07ee93aEEa0a36FfF2A9B95dd22Bd6049EE54f26;
    address public ds_proxy;

    constructor(address _owner, address _caller) BaseSimpleACL(_owner, _caller) {}

    function execute(address to, bytes memory data) external onlyContract(ds_proxy) {
        require(to == dss_proxy_action, "Not valid dss_proxy_action");
        (bool success, ) = address(this).staticcall(data);
        require(success, "Not valid daiJoin or pot address");
    }

    function exit(address _dai_join, address _pot, uint _wad) external {
        require(dai_join == _dai_join, "Not valid daiJoin");
        require(pot == _pot, "Not valid pot");
    }

    function exitAll(address _dai_join, address _pot) external {
        require(dai_join == _dai_join, "Not valid daiJoin");
        require(pot == _pot, "Not valid pot");
    }

    function setProxy(address _ds_proxy) external onlyOwner {
        ds_proxy = _ds_proxy;
    }

    function contracts() public view override returns (address[] memory _contracts) {
        _contracts = new address[](1);
        _contracts[0] = ds_proxy;
    }
}

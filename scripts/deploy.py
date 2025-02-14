from brownie import *

base_root_authorizer = '0x1ccaeF5bdEbF73A0953D91EEa94dd7a29C07B0DE'

def deploy_bifrost2_base():
    owner = '0x30d1498DF98f41fAC8Ae89999f051708f90C5993'
    deployer = accounts.load('bifrost2_base_deployer')
    Bifrost2BaseDodoACL.deploy(owner, base_root_authorizer, {'from': deployer}, publish_source=True)

def main():
    return

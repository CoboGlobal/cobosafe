from tests.libtest import b32

NETWORK_NAME = "development"


def test_rolemanager(FlatRoleManager, owner, delegate):
    flat_rolemanager = FlatRoleManager.deploy(owner, {"from": owner})

    role = b32(b"role1")
    decoded_role = "0x" + role.hex()
    role2 = b32(b"role2")

    flat_rolemanager.addRoles([role, role2], {"from": owner})
    assert [bytes(i) for i in flat_rolemanager.getAllRoles()] == [role, role2]

    # already added.
    flat_rolemanager.addRoles([role], {"from": owner})

    flat_rolemanager.grantRoles([role], [delegate], {"from": owner})

    assert flat_rolemanager.getRoles(delegate) == [decoded_role]

    assert flat_rolemanager.getDelegates() == [delegate]

    flat_rolemanager.revokeRoles([role], [delegate], {"from": owner})

    assert flat_rolemanager.getRoles(delegate) == []
    assert flat_rolemanager.getDelegates() == []

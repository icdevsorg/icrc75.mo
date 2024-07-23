export const idlFactory = ({ IDL }) => {
  const CandyShared = IDL.Rec();
  const DataItem__1 = IDL.Rec();
  const Permission = IDL.Variant({
    'Read' : IDL.Null,
    'Write' : IDL.Null,
    'Admin' : IDL.Null,
    'Permissions' : IDL.Null,
  });
  const List = IDL.Text;
  const PropertyShared = IDL.Record({
    'value' : CandyShared,
    'name' : IDL.Text,
    'immutable' : IDL.Bool,
  });
  CandyShared.fill(
    IDL.Variant({
      'Int' : IDL.Int,
      'Map' : IDL.Vec(IDL.Tuple(IDL.Text, CandyShared)),
      'Nat' : IDL.Nat,
      'Set' : IDL.Vec(CandyShared),
      'Nat16' : IDL.Nat16,
      'Nat32' : IDL.Nat32,
      'Nat64' : IDL.Nat64,
      'Blob' : IDL.Vec(IDL.Nat8),
      'Bool' : IDL.Bool,
      'Int8' : IDL.Int8,
      'Ints' : IDL.Vec(IDL.Int),
      'Nat8' : IDL.Nat8,
      'Nats' : IDL.Vec(IDL.Nat),
      'Text' : IDL.Text,
      'Bytes' : IDL.Vec(IDL.Nat8),
      'Int16' : IDL.Int16,
      'Int32' : IDL.Int32,
      'Int64' : IDL.Int64,
      'Option' : IDL.Opt(CandyShared),
      'Floats' : IDL.Vec(IDL.Float64),
      'Float' : IDL.Float64,
      'Principal' : IDL.Principal,
      'Array' : IDL.Vec(CandyShared),
      'ValueMap' : IDL.Vec(IDL.Tuple(CandyShared, CandyShared)),
      'Class' : IDL.Vec(PropertyShared),
    })
  );
  const DataItem = IDL.Variant({
    'Int' : IDL.Int,
    'Map' : IDL.Vec(IDL.Tuple(IDL.Text, CandyShared)),
    'Nat' : IDL.Nat,
    'Set' : IDL.Vec(CandyShared),
    'Nat16' : IDL.Nat16,
    'Nat32' : IDL.Nat32,
    'Nat64' : IDL.Nat64,
    'Blob' : IDL.Vec(IDL.Nat8),
    'Bool' : IDL.Bool,
    'Int8' : IDL.Int8,
    'Ints' : IDL.Vec(IDL.Int),
    'Nat8' : IDL.Nat8,
    'Nats' : IDL.Vec(IDL.Nat),
    'Text' : IDL.Text,
    'Bytes' : IDL.Vec(IDL.Nat8),
    'Int16' : IDL.Int16,
    'Int32' : IDL.Int32,
    'Int64' : IDL.Int64,
    'Option' : IDL.Opt(CandyShared),
    'Floats' : IDL.Vec(IDL.Float64),
    'Float' : IDL.Float64,
    'Principal' : IDL.Principal,
    'Array' : IDL.Vec(CandyShared),
    'ValueMap' : IDL.Vec(IDL.Tuple(CandyShared, CandyShared)),
    'Class' : IDL.Vec(PropertyShared),
  });
  const Subaccount = IDL.Vec(IDL.Nat8);
  const Account = IDL.Record({
    'owner' : IDL.Principal,
    'subaccount' : IDL.Opt(Subaccount),
  });
  const Identity = IDL.Principal;
  const ListItem = IDL.Variant({
    'List' : List,
    'DataItem' : DataItem,
    'Account' : Account,
    'Identity' : Identity,
  });
  const PermissionListItem = IDL.Tuple(Permission, ListItem);
  const PermissionList = IDL.Vec(PermissionListItem);
  const ICRC16Map = IDL.Vec(IDL.Tuple(IDL.Text, DataItem));
  const NamespaceRecordShared = IDL.Record({
    'permissions' : PermissionList,
    'members' : IDL.Vec(ListItem),
    'metadata' : ICRC16Map,
    'namespace' : IDL.Text,
  });
  const InitArgs = IDL.Opt(
    IDL.Record({
      'existingNamespaces' : IDL.Opt(IDL.Vec(NamespaceRecordShared)),
    })
  );
  const List__2 = IDL.Text;
  const ListItem__2 = IDL.Variant({
    'List' : List,
    'DataItem' : DataItem,
    'Account' : Account,
    'Identity' : Identity,
  });
  const Permission__1 = IDL.Variant({
    'Read' : IDL.Null,
    'Write' : IDL.Null,
    'Admin' : IDL.Null,
    'Permissions' : IDL.Null,
  });
  const Permission__2 = IDL.Variant({
    'Read' : IDL.Null,
    'Write' : IDL.Null,
    'Admin' : IDL.Null,
    'Permissions' : IDL.Null,
  });
  const List__1 = IDL.Text;
  const DataItemMap = IDL.Vec(IDL.Tuple(IDL.Text, DataItem__1));
  const PropertyShared__1 = IDL.Record({
    'value' : DataItem__1,
    'name' : IDL.Text,
    'immutable' : IDL.Bool,
  });
  DataItem__1.fill(
    IDL.Variant({
      'Int' : IDL.Int,
      'Map' : DataItemMap,
      'Nat' : IDL.Nat,
      'Set' : IDL.Vec(DataItem__1),
      'Nat16' : IDL.Nat16,
      'Nat32' : IDL.Nat32,
      'Nat64' : IDL.Nat64,
      'Blob' : IDL.Vec(IDL.Nat8),
      'Bool' : IDL.Bool,
      'Int8' : IDL.Int8,
      'Ints' : IDL.Vec(IDL.Int),
      'Nat8' : IDL.Nat8,
      'Nats' : IDL.Vec(IDL.Nat),
      'Text' : IDL.Text,
      'Bytes' : IDL.Vec(IDL.Nat8),
      'Int16' : IDL.Int16,
      'Int32' : IDL.Int32,
      'Int64' : IDL.Int64,
      'Option' : IDL.Opt(DataItem__1),
      'Floats' : IDL.Vec(IDL.Float64),
      'Float' : IDL.Float64,
      'Principal' : IDL.Principal,
      'Array' : IDL.Vec(DataItem__1),
      'ValueMap' : IDL.Vec(IDL.Tuple(DataItem__1, DataItem__1)),
      'Class' : IDL.Vec(PropertyShared__1),
    })
  );
  const Subaccount__1 = IDL.Vec(IDL.Nat8);
  const Account__1 = IDL.Record({
    'owner' : IDL.Principal,
    'subaccount' : IDL.Opt(Subaccount__1),
  });
  const Identity__1 = IDL.Principal;
  const ListItem__1 = IDL.Variant({
    'List' : List__1,
    'DataItem' : DataItem__1,
    'Account' : Account__1,
    'Identity' : Identity__1,
  });
  const PermissionListItem__1 = IDL.Tuple(Permission__2, ListItem__1);
  const PermissionListItem__2 = IDL.Tuple(Permission__2, ListItem__1);
  const PermissionList__1 = IDL.Vec(PermissionListItem__2);
  const ListRecord = IDL.Record({
    'metadata' : IDL.Opt(DataItemMap),
    'list' : List__1,
  });
  const AuthorizedRequestItem = IDL.Tuple(
    ListItem__1,
    IDL.Vec(IDL.Vec(List__1)),
  );
  const ManageRequestItem = IDL.Variant({
    'UpdateDefaultTake' : IDL.Nat,
    'UpdatePermittedDrift' : IDL.Nat,
    'UpdateTxWindow' : IDL.Nat,
    'UpdateMaxTake' : IDL.Nat,
  });
  const ManageRequest = IDL.Vec(ManageRequestItem);
  const ManageResultError = IDL.Variant({
    'Unauthorized' : IDL.Null,
    'Other' : IDL.Text,
  });
  const ManageResult = IDL.Opt(
    IDL.Variant({ 'Ok' : IDL.Null, 'Err' : ManageResultError })
  );
  const ManageResponse = IDL.Vec(ManageResult);
  const ManageListMembershipAction = IDL.Variant({
    'Add' : ListItem__1,
    'Remove' : ListItem__1,
  });
  const ManageListMembershipRequestItem = IDL.Record({
    'action' : ManageListMembershipAction,
    'list' : List__1,
    'memo' : IDL.Opt(IDL.Vec(IDL.Nat8)),
    'from_subaccount' : IDL.Opt(Subaccount__1),
    'created_at_time' : IDL.Opt(IDL.Nat),
  });
  const ManageListMembershipRequest = IDL.Vec(ManageListMembershipRequestItem);
  const TransactionID = IDL.Nat;
  const ManageListMembershipError = IDL.Variant({
    'NotFound' : IDL.Null,
    'Unauthorized' : IDL.Null,
    'Other' : IDL.Text,
  });
  const ManageListMembershipResult = IDL.Opt(
    IDL.Variant({ 'Ok' : TransactionID, 'Err' : ManageListMembershipError })
  );
  const ManageListMembershipResponse = IDL.Vec(ManageListMembershipResult);
  const DataItemMap__1 = IDL.Vec(IDL.Tuple(IDL.Text, DataItem__1));
  const ManageListPropertyRequestAction = IDL.Variant({
    'Metadata' : IDL.Record({
      'key' : IDL.Text,
      'value' : IDL.Opt(DataItem__1),
    }),
    'Rename' : IDL.Text,
    'ChangePermissions' : IDL.Variant({
      'Read' : IDL.Variant({ 'Add' : ListItem__1, 'Remove' : ListItem__1 }),
      'Write' : IDL.Variant({ 'Add' : ListItem__1, 'Remove' : ListItem__1 }),
      'Admin' : IDL.Variant({ 'Add' : ListItem__1, 'Remove' : ListItem__1 }),
      'Permissions' : IDL.Variant({
        'Add' : ListItem__1,
        'Remove' : ListItem__1,
      }),
    }),
    'Delete' : IDL.Null,
    'Create' : IDL.Record({
      'members' : IDL.Vec(ListItem__1),
      'admin' : IDL.Opt(ListItem__1),
      'metadata' : DataItemMap,
    }),
  });
  const ManageListPropertyRequestItem = IDL.Record({
    'action' : ManageListPropertyRequestAction,
    'list' : List__1,
    'memo' : IDL.Opt(IDL.Vec(IDL.Nat8)),
    'from_subaccount' : IDL.Opt(Subaccount__1),
    'created_at_time' : IDL.Opt(IDL.Nat),
  });
  const ManageListPropertiesRequest = IDL.Vec(ManageListPropertyRequestItem);
  const ManageListPropertyError = IDL.Variant({
    'IllegalAdmin' : IDL.Null,
    'IllegalPermission' : IDL.Null,
    'NotFound' : IDL.Null,
    'Unauthorized' : IDL.Null,
    'Other' : IDL.Text,
    'Exists' : IDL.Null,
  });
  const ManageListPropertyResult = IDL.Opt(
    IDL.Variant({ 'Ok' : TransactionID, 'Err' : ManageListPropertyError })
  );
  const ManageListPropertyResponse = IDL.Vec(ManageListPropertyResult);
  const Token = IDL.Service({
    'deposit_cycles' : IDL.Func([], [], []),
    'icrc_75_get_list_lists' : IDL.Func(
        [List__2, IDL.Opt(List__2), IDL.Opt(IDL.Nat)],
        [IDL.Vec(List__2)],
        ['query'],
      ),
    'icrc_75_get_list_members_admin' : IDL.Func(
        [List__2, IDL.Opt(ListItem__2), IDL.Opt(IDL.Nat)],
        [IDL.Vec(ListItem__2)],
        ['query'],
      ),
    'icrc_75_get_list_permissions_admin' : IDL.Func(
        [
          List__2,
          IDL.Opt(Permission__1),
          IDL.Opt(PermissionListItem__1),
          IDL.Opt(IDL.Nat),
        ],
        [PermissionList__1],
        ['query'],
      ),
    'icrc_75_get_lists' : IDL.Func(
        [IDL.Opt(IDL.Text), IDL.Bool, IDL.Opt(List__2), IDL.Opt(IDL.Nat)],
        [IDL.Vec(ListRecord)],
        ['query'],
      ),
    'icrc_75_is_member' : IDL.Func(
        [IDL.Vec(AuthorizedRequestItem)],
        [IDL.Vec(IDL.Bool)],
        ['query'],
      ),
    'icrc_75_manage' : IDL.Func([ManageRequest], [ManageResponse], []),
    'icrc_75_manage_list_membership' : IDL.Func(
        [ManageListMembershipRequest],
        [ManageListMembershipResponse],
        [],
      ),
    'icrc_75_member_of' : IDL.Func(
        [ListItem__2, IDL.Opt(List__2), IDL.Opt(IDL.Nat)],
        [IDL.Vec(List__2)],
        ['query'],
      ),
    'icrc_75_metadata' : IDL.Func([], [DataItemMap__1], ['query']),
    'manage_list_properties' : IDL.Func(
        [ManageListPropertiesRequest],
        [ManageListPropertyResponse],
        [],
      ),
  });
  return Token;
};
export const init = ({ IDL }) => {
  const CandyShared = IDL.Rec();
  const Permission = IDL.Variant({
    'Read' : IDL.Null,
    'Write' : IDL.Null,
    'Admin' : IDL.Null,
    'Permissions' : IDL.Null,
  });
  const List = IDL.Text;
  const PropertyShared = IDL.Record({
    'value' : CandyShared,
    'name' : IDL.Text,
    'immutable' : IDL.Bool,
  });
  CandyShared.fill(
    IDL.Variant({
      'Int' : IDL.Int,
      'Map' : IDL.Vec(IDL.Tuple(IDL.Text, CandyShared)),
      'Nat' : IDL.Nat,
      'Set' : IDL.Vec(CandyShared),
      'Nat16' : IDL.Nat16,
      'Nat32' : IDL.Nat32,
      'Nat64' : IDL.Nat64,
      'Blob' : IDL.Vec(IDL.Nat8),
      'Bool' : IDL.Bool,
      'Int8' : IDL.Int8,
      'Ints' : IDL.Vec(IDL.Int),
      'Nat8' : IDL.Nat8,
      'Nats' : IDL.Vec(IDL.Nat),
      'Text' : IDL.Text,
      'Bytes' : IDL.Vec(IDL.Nat8),
      'Int16' : IDL.Int16,
      'Int32' : IDL.Int32,
      'Int64' : IDL.Int64,
      'Option' : IDL.Opt(CandyShared),
      'Floats' : IDL.Vec(IDL.Float64),
      'Float' : IDL.Float64,
      'Principal' : IDL.Principal,
      'Array' : IDL.Vec(CandyShared),
      'ValueMap' : IDL.Vec(IDL.Tuple(CandyShared, CandyShared)),
      'Class' : IDL.Vec(PropertyShared),
    })
  );
  const DataItem = IDL.Variant({
    'Int' : IDL.Int,
    'Map' : IDL.Vec(IDL.Tuple(IDL.Text, CandyShared)),
    'Nat' : IDL.Nat,
    'Set' : IDL.Vec(CandyShared),
    'Nat16' : IDL.Nat16,
    'Nat32' : IDL.Nat32,
    'Nat64' : IDL.Nat64,
    'Blob' : IDL.Vec(IDL.Nat8),
    'Bool' : IDL.Bool,
    'Int8' : IDL.Int8,
    'Ints' : IDL.Vec(IDL.Int),
    'Nat8' : IDL.Nat8,
    'Nats' : IDL.Vec(IDL.Nat),
    'Text' : IDL.Text,
    'Bytes' : IDL.Vec(IDL.Nat8),
    'Int16' : IDL.Int16,
    'Int32' : IDL.Int32,
    'Int64' : IDL.Int64,
    'Option' : IDL.Opt(CandyShared),
    'Floats' : IDL.Vec(IDL.Float64),
    'Float' : IDL.Float64,
    'Principal' : IDL.Principal,
    'Array' : IDL.Vec(CandyShared),
    'ValueMap' : IDL.Vec(IDL.Tuple(CandyShared, CandyShared)),
    'Class' : IDL.Vec(PropertyShared),
  });
  const Subaccount = IDL.Vec(IDL.Nat8);
  const Account = IDL.Record({
    'owner' : IDL.Principal,
    'subaccount' : IDL.Opt(Subaccount),
  });
  const Identity = IDL.Principal;
  const ListItem = IDL.Variant({
    'List' : List,
    'DataItem' : DataItem,
    'Account' : Account,
    'Identity' : Identity,
  });
  const PermissionListItem = IDL.Tuple(Permission, ListItem);
  const PermissionList = IDL.Vec(PermissionListItem);
  const ICRC16Map = IDL.Vec(IDL.Tuple(IDL.Text, DataItem));
  const NamespaceRecordShared = IDL.Record({
    'permissions' : PermissionList,
    'members' : IDL.Vec(ListItem),
    'metadata' : ICRC16Map,
    'namespace' : IDL.Text,
  });
  const InitArgs = IDL.Opt(
    IDL.Record({
      'existingNamespaces' : IDL.Opt(IDL.Vec(NamespaceRecordShared)),
    })
  );
  return [InitArgs];
};

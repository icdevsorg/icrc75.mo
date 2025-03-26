export const idlFactory = ({ IDL }) => {
  const CandyShared = IDL.Rec();
  const DataItem__1 = IDL.Rec();
  const Value = IDL.Rec();
  const ValueShared = IDL.Rec();
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
  const ListItem__1 = IDL.Variant({
    'List' : List,
    'DataItem' : DataItem,
    'Account' : Account,
    'Identity' : Identity,
  });
  const PermissionListItem = IDL.Tuple(Permission, ListItem__1);
  const PermissionList = IDL.Vec(PermissionListItem);
  const ListItem = IDL.Variant({
    'List' : List,
    'DataItem' : DataItem,
    'Account' : Account,
    'Identity' : Identity,
  });
  const ICRC16MapItem = IDL.Tuple(IDL.Text, DataItem);
  const ICRC16Map = IDL.Vec(ICRC16MapItem);
  const NamespaceRecordShared = IDL.Record({
    'permissions' : PermissionList,
    'members' : IDL.Vec(IDL.Tuple(ListItem, IDL.Opt(ICRC16Map))),
    'metadata' : ICRC16Map,
    'namespace' : IDL.Text,
  });
  const InitArgs = IDL.Record({
    'existingNamespaces' : IDL.Opt(IDL.Vec(NamespaceRecordShared)),
    'cycleShareTimerID' : IDL.Opt(IDL.Nat),
    'certificateNonce' : IDL.Opt(IDL.Nat),
  });
  ValueShared.fill(
    IDL.Variant({
      'Int' : IDL.Int,
      'Map' : IDL.Vec(IDL.Tuple(IDL.Text, ValueShared)),
      'Nat' : IDL.Nat,
      'Blob' : IDL.Vec(IDL.Nat8),
      'Text' : IDL.Text,
      'Array' : IDL.Vec(ValueShared),
    })
  );
  const Value__1 = IDL.Variant({
    'Int' : IDL.Int,
    'Map' : IDL.Vec(IDL.Tuple(IDL.Text, ValueShared)),
    'Nat' : IDL.Nat,
    'Blob' : IDL.Vec(IDL.Nat8),
    'Text' : IDL.Text,
    'Array' : IDL.Vec(ValueShared),
  });
  const ICRC10Record = IDL.Record({ 'url' : IDL.Text, 'name' : IDL.Text });
  const List__1 = IDL.Text;
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
  const List__2 = IDL.Text;
  const DataItemMap__1 = IDL.Vec(IDL.Tuple(IDL.Text, DataItem__1));
  const PropertyShared__1 = IDL.Record({
    'value' : DataItem__1,
    'name' : IDL.Text,
    'immutable' : IDL.Bool,
  });
  DataItem__1.fill(
    IDL.Variant({
      'Int' : IDL.Int,
      'Map' : DataItemMap__1,
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
  const ListItem__3 = IDL.Variant({
    'List' : List__2,
    'DataItem' : DataItem__1,
    'Account' : Account__1,
    'Identity' : Identity__1,
  });
  const PermissionListItem__1 = IDL.Tuple(Permission__2, ListItem__3);
  const PermissionListItem__2 = IDL.Tuple(Permission__2, ListItem__3);
  const PermissionList__1 = IDL.Vec(PermissionListItem__2);
  const ListRecord = IDL.Record({
    'metadata' : IDL.Opt(DataItemMap__1),
    'list' : List__2,
  });
  const Time = IDL.Nat;
  const ActionId = IDL.Record({ 'id' : IDL.Nat, 'time' : Time });
  const Action = IDL.Record({
    'aSync' : IDL.Opt(IDL.Nat),
    'actionType' : IDL.Text,
    'params' : IDL.Vec(IDL.Nat8),
    'retries' : IDL.Nat,
  });
  const ActionDetail = IDL.Tuple(ActionId, Action);
  const TimerId = IDL.Nat;
  const Stats__1 = IDL.Record({
    'timers' : IDL.Nat,
    'maxExecutions' : IDL.Nat,
    'minAction' : IDL.Opt(ActionDetail),
    'cycles' : IDL.Nat,
    'nextActionId' : IDL.Nat,
    'nextTimer' : IDL.Opt(TimerId),
    'expectedExecutionTime' : IDL.Opt(Time),
    'lastExecutionTime' : Time,
  });
  const Stats = IDL.Record({
    'tt' : Stats__1,
    'permittedDrift' : IDL.Nat,
    'defaultTake' : IDL.Nat,
    'owner' : IDL.Principal,
    'memberIndexCount' : IDL.Nat,
    'permissionsIndexCount' : IDL.Nat,
    'cycleShareTimerID' : IDL.Opt(IDL.Nat),
    'namespaceStoreCount' : IDL.Nat,
    'maxTake' : IDL.Nat,
    'txWindow' : IDL.Nat,
  });
  const AuthorizedRequestItem = IDL.Tuple(
    ListItem__3,
    IDL.Vec(IDL.Vec(List__2)),
  );
  const ManageRequestItem = IDL.Variant({
    'UpdateDefaultTake' : IDL.Nat,
    'UpdatePermittedDrift' : IDL.Nat,
    'UpdateTxWindow' : IDL.Nat,
    'UpdateMaxTake' : IDL.Nat,
  });
  const ManageRequest = IDL.Vec(ManageRequestItem);
  const ManageResultError = IDL.Variant({
    'TooManyRequests' : IDL.Null,
    'Unauthorized' : IDL.Null,
    'Other' : IDL.Text,
  });
  const ManageResult = IDL.Opt(
    IDL.Variant({ 'Ok' : IDL.Null, 'Err' : ManageResultError })
  );
  const ManageResponse = IDL.Vec(ManageResult);
  const MapModifier = IDL.Tuple(IDL.Text, IDL.Opt(DataItem__1));
  const ManageListMembershipAction = IDL.Variant({
    'Add' : IDL.Tuple(ListItem__3, IDL.Opt(DataItemMap__1)),
    'Remove' : ListItem__3,
    'Update' : IDL.Tuple(ListItem__3, MapModifier),
  });
  const ManageListMembershipRequestItem = IDL.Record({
    'action' : ManageListMembershipAction,
    'list' : List__2,
    'memo' : IDL.Opt(IDL.Vec(IDL.Nat8)),
    'from_subaccount' : IDL.Opt(Subaccount__1),
    'created_at_time' : IDL.Opt(IDL.Nat),
  });
  const ManageListMembershipRequest = IDL.Vec(ManageListMembershipRequestItem);
  const TransactionID = IDL.Nat;
  const ManageListMembershipError = IDL.Variant({
    'TooManyRequests' : IDL.Null,
    'NotFound' : IDL.Null,
    'Unauthorized' : IDL.Null,
    'Other' : IDL.Text,
    'Exists' : IDL.Null,
  });
  const ManageListMembershipResult = IDL.Opt(
    IDL.Variant({ 'Ok' : TransactionID, 'Err' : ManageListMembershipError })
  );
  const ManageListMembershipResponse = IDL.Vec(ManageListMembershipResult);
  const ManageListPropertyRequestAction = IDL.Variant({
    'Metadata' : IDL.Record({
      'key' : IDL.Text,
      'value' : IDL.Opt(DataItem__1),
    }),
    'Rename' : IDL.Text,
    'ChangePermissions' : IDL.Variant({
      'Read' : IDL.Variant({ 'Add' : ListItem__3, 'Remove' : ListItem__3 }),
      'Write' : IDL.Variant({ 'Add' : ListItem__3, 'Remove' : ListItem__3 }),
      'Admin' : IDL.Variant({ 'Add' : ListItem__3, 'Remove' : ListItem__3 }),
      'Permissions' : IDL.Variant({
        'Add' : ListItem__3,
        'Remove' : ListItem__3,
      }),
    }),
    'Delete' : IDL.Null,
    'Create' : IDL.Record({
      'members' : IDL.Vec(IDL.Tuple(ListItem__3, IDL.Opt(DataItemMap__1))),
      'admin' : IDL.Opt(ListItem__3),
      'metadata' : DataItemMap__1,
    }),
  });
  const ManageListPropertyRequestItem = IDL.Record({
    'action' : ManageListPropertyRequestAction,
    'list' : List__2,
    'memo' : IDL.Opt(IDL.Vec(IDL.Nat8)),
    'from_subaccount' : IDL.Opt(Subaccount__1),
    'created_at_time' : IDL.Opt(IDL.Nat),
  });
  const ManageListPropertyRequest = IDL.Vec(ManageListPropertyRequestItem);
  const ManageListPropertyError = IDL.Variant({
    'TooManyRequests' : IDL.Null,
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
  const DataItemMap = IDL.Vec(IDL.Tuple(IDL.Text, DataItem__1));
  Value.fill(
    IDL.Variant({
      'Int' : IDL.Int,
      'Map' : IDL.Vec(IDL.Tuple(IDL.Text, Value)),
      'Nat' : IDL.Nat,
      'Blob' : IDL.Vec(IDL.Nat8),
      'Text' : IDL.Text,
      'Array' : IDL.Vec(Value),
    })
  );
  const IdentityToken__1 = IDL.Variant({
    'Int' : IDL.Int,
    'Map' : IDL.Vec(IDL.Tuple(IDL.Text, Value)),
    'Nat' : IDL.Nat,
    'Blob' : IDL.Vec(IDL.Nat8),
    'Text' : IDL.Text,
    'Array' : IDL.Vec(Value),
  });
  const IdentityRequestError = IDL.Variant({
    'ExpirationError' : IDL.Null,
    'NotFound' : IDL.Null,
    'NotAMember' : IDL.Null,
    'Other' : IDL.Text,
  });
  const IdentityRequestResult = IDL.Variant({
    'Ok' : IdentityToken__1,
    'Err' : IdentityRequestError,
  });
  const IdentityToken = IDL.Variant({
    'Int' : IDL.Int,
    'Map' : IDL.Vec(IDL.Tuple(IDL.Text, Value)),
    'Nat' : IDL.Nat,
    'Blob' : IDL.Vec(IDL.Nat8),
    'Text' : IDL.Text,
    'Array' : IDL.Vec(Value),
  });
  const IdentityCertificate = IDL.Record({
    'token' : IdentityToken__1,
    'certificate' : IDL.Vec(IDL.Nat8),
    'witness' : IDL.Vec(IDL.Nat8),
  });
  const ICRC75List = IDL.Service({
    'auto_init' : IDL.Func([], [], []),
    'deposit_cycles' : IDL.Func([], [], []),
    'getLedger' : IDL.Func([], [IDL.Vec(Value__1)], ['query']),
    'get_cycle_balance' : IDL.Func([], [IDL.Nat], ['query']),
    'icrc10_supported_standards' : IDL.Func(
        [],
        [IDL.Vec(ICRC10Record)],
        ['query'],
      ),
    'icrc75_get_list_lists' : IDL.Func(
        [List__1, IDL.Opt(List__1), IDL.Opt(IDL.Nat)],
        [IDL.Vec(List__1)],
        ['query'],
      ),
    'icrc75_get_list_members_admin' : IDL.Func(
        [List__1, IDL.Opt(ListItem__2), IDL.Opt(IDL.Nat)],
        [IDL.Vec(ListItem__2)],
        ['query'],
      ),
    'icrc75_get_list_permissions_admin' : IDL.Func(
        [
          List__1,
          IDL.Opt(Permission__1),
          IDL.Opt(PermissionListItem__1),
          IDL.Opt(IDL.Nat),
        ],
        [PermissionList__1],
        ['query'],
      ),
    'icrc75_get_lists' : IDL.Func(
        [IDL.Opt(IDL.Text), IDL.Bool, IDL.Opt(List__1), IDL.Opt(IDL.Nat)],
        [IDL.Vec(ListRecord)],
        ['query'],
      ),
    'icrc75_get_stats' : IDL.Func([], [Stats], ['query']),
    'icrc75_is_member' : IDL.Func(
        [IDL.Vec(AuthorizedRequestItem)],
        [IDL.Vec(IDL.Bool)],
        ['query'],
      ),
    'icrc75_manage' : IDL.Func([ManageRequest], [ManageResponse], []),
    'icrc75_manage_list_membership' : IDL.Func(
        [ManageListMembershipRequest],
        [ManageListMembershipResponse],
        [],
      ),
    'icrc75_manage_list_properties' : IDL.Func(
        [ManageListPropertyRequest],
        [ManageListPropertyResponse],
        [],
      ),
    'icrc75_member_of' : IDL.Func(
        [ListItem__2, IDL.Opt(List__1), IDL.Opt(IDL.Nat)],
        [IDL.Vec(List__1)],
        ['query'],
      ),
    'icrc75_metadata' : IDL.Func([], [DataItemMap], ['query']),
    'icrc75_request_token' : IDL.Func(
        [ListItem__2, List__1, IDL.Opt(IDL.Nat)],
        [IdentityRequestResult],
        [],
      ),
    'icrc75_retrieve_token' : IDL.Func(
        [IdentityToken],
        [IdentityCertificate],
        ['query'],
      ),
  });
  return ICRC75List;
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
  const ListItem__1 = IDL.Variant({
    'List' : List,
    'DataItem' : DataItem,
    'Account' : Account,
    'Identity' : Identity,
  });
  const PermissionListItem = IDL.Tuple(Permission, ListItem__1);
  const PermissionList = IDL.Vec(PermissionListItem);
  const ListItem = IDL.Variant({
    'List' : List,
    'DataItem' : DataItem,
    'Account' : Account,
    'Identity' : Identity,
  });
  const ICRC16MapItem = IDL.Tuple(IDL.Text, DataItem);
  const ICRC16Map = IDL.Vec(ICRC16MapItem);
  const NamespaceRecordShared = IDL.Record({
    'permissions' : PermissionList,
    'members' : IDL.Vec(IDL.Tuple(ListItem, IDL.Opt(ICRC16Map))),
    'metadata' : ICRC16Map,
    'namespace' : IDL.Text,
  });
  const InitArgs = IDL.Record({
    'existingNamespaces' : IDL.Opt(IDL.Vec(NamespaceRecordShared)),
    'cycleShareTimerID' : IDL.Opt(IDL.Nat),
    'certificateNonce' : IDL.Opt(IDL.Nat),
  });
  return [IDL.Opt(InitArgs)];
};

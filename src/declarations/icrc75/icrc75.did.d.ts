import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import type { IDL } from '@dfinity/candid';

export interface Account {
  'owner' : Principal,
  'subaccount' : [] | [Subaccount],
}
export interface Account__1 {
  'owner' : Principal,
  'subaccount' : [] | [Subaccount__1],
}
export interface Action {
  'aSync' : [] | [bigint],
  'actionType' : string,
  'params' : Uint8Array | number[],
  'retries' : bigint,
}
export type ActionDetail = [ActionId, Action];
export interface ActionId { 'id' : bigint, 'time' : Time }
export type AuthorizedRequestItem = [ListItem__2, Array<Array<List__2>>];
export type CandyShared = { 'Int' : bigint } |
  { 'Map' : Array<[string, CandyShared]> } |
  { 'Nat' : bigint } |
  { 'Set' : Array<CandyShared> } |
  { 'Nat16' : number } |
  { 'Nat32' : number } |
  { 'Nat64' : bigint } |
  { 'Blob' : Uint8Array | number[] } |
  { 'Bool' : boolean } |
  { 'Int8' : number } |
  { 'Ints' : Array<bigint> } |
  { 'Nat8' : number } |
  { 'Nats' : Array<bigint> } |
  { 'Text' : string } |
  { 'Bytes' : Uint8Array | number[] } |
  { 'Int16' : number } |
  { 'Int32' : number } |
  { 'Int64' : bigint } |
  { 'Option' : [] | [CandyShared] } |
  { 'Floats' : Array<number> } |
  { 'Float' : number } |
  { 'Principal' : Principal } |
  { 'Array' : Array<CandyShared> } |
  { 'ValueMap' : Array<[CandyShared, CandyShared]> } |
  { 'Class' : Array<PropertyShared> };
export type DataItem = { 'Int' : bigint } |
  { 'Map' : Array<[string, CandyShared]> } |
  { 'Nat' : bigint } |
  { 'Set' : Array<CandyShared> } |
  { 'Nat16' : number } |
  { 'Nat32' : number } |
  { 'Nat64' : bigint } |
  { 'Blob' : Uint8Array | number[] } |
  { 'Bool' : boolean } |
  { 'Int8' : number } |
  { 'Ints' : Array<bigint> } |
  { 'Nat8' : number } |
  { 'Nats' : Array<bigint> } |
  { 'Text' : string } |
  { 'Bytes' : Uint8Array | number[] } |
  { 'Int16' : number } |
  { 'Int32' : number } |
  { 'Int64' : bigint } |
  { 'Option' : [] | [CandyShared] } |
  { 'Floats' : Array<number> } |
  { 'Float' : number } |
  { 'Principal' : Principal } |
  { 'Array' : Array<CandyShared> } |
  { 'ValueMap' : Array<[CandyShared, CandyShared]> } |
  { 'Class' : Array<PropertyShared> };
export type DataItemMap = Array<[string, DataItem__1]>;
export type DataItemMap__1 = Array<[string, DataItem__1]>;
export type DataItem__1 = { 'Int' : bigint } |
  { 'Map' : DataItemMap__1 } |
  { 'Nat' : bigint } |
  { 'Set' : Array<DataItem__1> } |
  { 'Nat16' : number } |
  { 'Nat32' : number } |
  { 'Nat64' : bigint } |
  { 'Blob' : Uint8Array | number[] } |
  { 'Bool' : boolean } |
  { 'Int8' : number } |
  { 'Ints' : Array<bigint> } |
  { 'Nat8' : number } |
  { 'Nats' : Array<bigint> } |
  { 'Text' : string } |
  { 'Bytes' : Uint8Array | number[] } |
  { 'Int16' : number } |
  { 'Int32' : number } |
  { 'Int64' : bigint } |
  { 'Option' : [] | [DataItem__1] } |
  { 'Floats' : Array<number> } |
  { 'Float' : number } |
  { 'Principal' : Principal } |
  { 'Array' : Array<DataItem__1> } |
  { 'ValueMap' : Array<[DataItem__1, DataItem__1]> } |
  { 'Class' : Array<PropertyShared__1> };
export interface ICRC10Record { 'url' : string, 'name' : string }
export type ICRC16Map = Array<ICRC16MapItem>;
export type ICRC16MapItem = [string, DataItem];
export type Identity = Principal;
export interface IdentityCertificate {
  'token' : IdentityToken__1,
  'certificate' : Uint8Array | number[],
  'witness' : Uint8Array | number[],
}
export type IdentityRequestError = { 'ExpirationError' : null } |
  { 'NotFound' : null } |
  { 'NotAMember' : null } |
  { 'Other' : string };
export type IdentityRequestResult = { 'Ok' : IdentityToken__1 } |
  { 'Err' : IdentityRequestError };
export type IdentityToken = { 'Int' : bigint } |
  { 'Map' : Array<[string, Value]> } |
  { 'Nat' : bigint } |
  { 'Blob' : Uint8Array | number[] } |
  { 'Text' : string } |
  { 'Array' : Array<Value> };
export type IdentityToken__1 = { 'Int' : bigint } |
  { 'Map' : Array<[string, Value]> } |
  { 'Nat' : bigint } |
  { 'Blob' : Uint8Array | number[] } |
  { 'Text' : string } |
  { 'Array' : Array<Value> };
export type Identity__1 = Principal;
export type InitArgs = [] | [
  {
    'existingNamespaces' : [] | [Array<NamespaceRecordShared>],
    'cycleShareTimerID' : [] | [bigint],
    'certificateNonce' : [] | [bigint],
  }
];
export type List = string;
export type ListItem = { 'List' : List } |
  { 'DataItem' : DataItem } |
  { 'Account' : Account } |
  { 'Identity' : Identity };
export type ListItem__1 = { 'List' : List } |
  { 'DataItem' : DataItem } |
  { 'Account' : Account } |
  { 'Identity' : Identity };
export type ListItem__2 = { 'List' : List__2 } |
  { 'DataItem' : DataItem__1 } |
  { 'Account' : Account__1 } |
  { 'Identity' : Identity__1 };
export interface ListRecord {
  'metadata' : [] | [DataItemMap__1],
  'list' : List__2,
}
export type List__1 = string;
export type List__2 = string;
export type ManageListMembershipAction = { 'Add' : ListItem__2 } |
  { 'Remove' : ListItem__2 };
export type ManageListMembershipError = { 'TooManyRequests' : null } |
  { 'NotFound' : null } |
  { 'Unauthorized' : null } |
  { 'Other' : string } |
  { 'Exists' : null };
export type ManageListMembershipRequest = Array<
  ManageListMembershipRequestItem
>;
export interface ManageListMembershipRequestItem {
  'action' : ManageListMembershipAction,
  'list' : List__2,
  'memo' : [] | [Uint8Array | number[]],
  'from_subaccount' : [] | [Subaccount__1],
  'created_at_time' : [] | [bigint],
}
export type ManageListMembershipResponse = Array<ManageListMembershipResult>;
export type ManageListMembershipResult = [] | [
  { 'Ok' : TransactionID } |
    { 'Err' : ManageListMembershipError } |
    { 'TooManyRequests' : null }
];
export type ManageListPropertyError = { 'TooManyRequests' : null } |
  { 'IllegalAdmin' : null } |
  { 'IllegalPermission' : null } |
  { 'NotFound' : null } |
  { 'Unauthorized' : null } |
  { 'Other' : string } |
  { 'Exists' : null };
export type ManageListPropertyRequest = Array<ManageListPropertyRequestItem>;
export type ManageListPropertyRequestAction = {
    'Metadata' : { 'key' : string, 'value' : [] | [DataItem__1] }
  } |
  { 'Rename' : string } |
  {
    'ChangePermissions' : {
        'Read' : { 'Add' : ListItem__2 } |
          { 'Remove' : ListItem__2 }
      } |
      { 'Write' : { 'Add' : ListItem__2 } | { 'Remove' : ListItem__2 } } |
      { 'Admin' : { 'Add' : ListItem__2 } | { 'Remove' : ListItem__2 } } |
      { 'Permissions' : { 'Add' : ListItem__2 } | { 'Remove' : ListItem__2 } }
  } |
  { 'Delete' : null } |
  {
    'Create' : {
      'members' : Array<ListItem__2>,
      'admin' : [] | [ListItem__2],
      'metadata' : DataItemMap__1,
    }
  };
export interface ManageListPropertyRequestItem {
  'action' : ManageListPropertyRequestAction,
  'list' : List__2,
  'memo' : [] | [Uint8Array | number[]],
  'from_subaccount' : [] | [Subaccount__1],
  'created_at_time' : [] | [bigint],
}
export type ManageListPropertyResponse = Array<ManageListPropertyResult>;
export type ManageListPropertyResult = [] | [
  { 'Ok' : TransactionID } |
    { 'Err' : ManageListPropertyError }
];
export type ManageRequest = Array<ManageRequestItem>;
export type ManageRequestItem = { 'UpdateDefaultTake' : bigint } |
  { 'UpdatePermittedDrift' : bigint } |
  { 'UpdateTxWindow' : bigint } |
  { 'UpdateMaxTake' : bigint };
export type ManageResponse = Array<ManageResult>;
export type ManageResult = [] | [
  { 'Ok' : null } |
    { 'Err' : ManageResultError }
];
export type ManageResultError = { 'TooManyRequests' : null } |
  { 'Unauthorized' : null } |
  { 'Other' : string };
export interface NamespaceRecordShared {
  'permissions' : PermissionList,
  'members' : Array<ListItem>,
  'metadata' : ICRC16Map,
  'namespace' : string,
}
export type Permission = { 'Read' : null } |
  { 'Write' : null } |
  { 'Admin' : null } |
  { 'Permissions' : null };
export type PermissionList = Array<PermissionListItem>;
export type PermissionListItem = [Permission, ListItem];
export type PermissionListItem__1 = [Permission__2, ListItem__2];
export type PermissionListItem__2 = [Permission__2, ListItem__2];
export type PermissionList__1 = Array<PermissionListItem__2>;
export type Permission__1 = { 'Read' : null } |
  { 'Write' : null } |
  { 'Admin' : null } |
  { 'Permissions' : null };
export type Permission__2 = { 'Read' : null } |
  { 'Write' : null } |
  { 'Admin' : null } |
  { 'Permissions' : null };
export interface PropertyShared {
  'value' : CandyShared,
  'name' : string,
  'immutable' : boolean,
}
export interface PropertyShared__1 {
  'value' : DataItem__1,
  'name' : string,
  'immutable' : boolean,
}
export interface Stats {
  'tt' : Stats__1,
  'permittedDrift' : bigint,
  'defaultTake' : bigint,
  'owner' : Principal,
  'memberIndexCount' : bigint,
  'permissionsIndexCount' : bigint,
  'cycleShareTimerID' : [] | [bigint],
  'namespaceStoreCount' : bigint,
  'maxTake' : bigint,
  'txWindow' : bigint,
}
export interface Stats__1 {
  'timers' : bigint,
  'maxExecutions' : bigint,
  'minAction' : [] | [ActionDetail],
  'cycles' : bigint,
  'nextActionId' : bigint,
  'nextTimer' : [] | [TimerId],
  'expectedExecutionTime' : [] | [Time],
  'lastExecutionTime' : Time,
}
export type Subaccount = Uint8Array | number[];
export type Subaccount__1 = Uint8Array | number[];
export type Time = bigint;
export type TimerId = bigint;
export interface Token {
  'auto_init' : ActorMethod<[], undefined>,
  'deposit_cycles' : ActorMethod<[], undefined>,
  'getLedger' : ActorMethod<[], Array<Value__1>>,
  'get_cycle_balance' : ActorMethod<[], bigint>,
  'icrc10_supported_standards' : ActorMethod<[], Array<ICRC10Record>>,
  'icrc75_get_list_lists' : ActorMethod<
    [List__1, [] | [List__1], [] | [bigint]],
    Array<List__1>
  >,
  'icrc75_get_list_members_admin' : ActorMethod<
    [List__1, [] | [ListItem__1], [] | [bigint]],
    Array<ListItem__1>
  >,
  'icrc75_get_list_permissions_admin' : ActorMethod<
    [
      List__1,
      [] | [Permission__1],
      [] | [PermissionListItem__1],
      [] | [bigint],
    ],
    PermissionList__1
  >,
  'icrc75_get_lists' : ActorMethod<
    [[] | [string], boolean, [] | [List__1], [] | [bigint]],
    Array<ListRecord>
  >,
  'icrc75_get_stats' : ActorMethod<[], Stats>,
  'icrc75_is_member' : ActorMethod<
    [Array<AuthorizedRequestItem>],
    Array<boolean>
  >,
  'icrc75_manage' : ActorMethod<[ManageRequest], ManageResponse>,
  'icrc75_manage_list_membership' : ActorMethod<
    [ManageListMembershipRequest],
    ManageListMembershipResponse
  >,
  'icrc75_manage_list_properties' : ActorMethod<
    [ManageListPropertyRequest],
    ManageListPropertyResponse
  >,
  'icrc75_member_of' : ActorMethod<
    [ListItem__1, [] | [List__1], [] | [bigint]],
    Array<List__1>
  >,
  'icrc75_metadata' : ActorMethod<[], DataItemMap>,
  'icrc75_request_token' : ActorMethod<
    [ListItem__1, List__1, [] | [bigint]],
    IdentityRequestResult
  >,
  'icrc75_retrieve_token' : ActorMethod<[IdentityToken], IdentityCertificate>,
}
export type TransactionID = bigint;
export type Value = { 'Int' : bigint } |
  { 'Map' : Array<[string, Value]> } |
  { 'Nat' : bigint } |
  { 'Blob' : Uint8Array | number[] } |
  { 'Text' : string } |
  { 'Array' : Array<Value> };
export type ValueShared = { 'Int' : bigint } |
  { 'Map' : Array<[string, ValueShared]> } |
  { 'Nat' : bigint } |
  { 'Blob' : Uint8Array | number[] } |
  { 'Text' : string } |
  { 'Array' : Array<ValueShared> };
export type Value__1 = { 'Int' : bigint } |
  { 'Map' : Array<[string, ValueShared]> } |
  { 'Nat' : bigint } |
  { 'Blob' : Uint8Array | number[] } |
  { 'Text' : string } |
  { 'Array' : Array<ValueShared> };
export interface _SERVICE extends Token {}
export declare const idlFactory: IDL.InterfaceFactory;
export declare const init: (args: { IDL: typeof IDL }) => IDL.Type[];

import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import type { IDL } from '@dfinity/candid';

export interface Account {
  'owner' : Principal,
  'subaccount' : [] | [Uint8Array | number[]],
}
export interface Action {
  'aSync' : [] | [bigint],
  'actionType' : string,
  'params' : Uint8Array | number[],
  'retries' : bigint,
}
export type ActionDetail = [ActionId, Action];
export interface ActionId { 'id' : bigint, 'time' : Time }
export interface ArgList {
  'nextCycleActionId' : [] | [bigint],
  'maxExecutions' : [] | [bigint],
  'nextActionId' : bigint,
  'lastActionIdReported' : [] | [bigint],
  'lastCycleReport' : [] | [bigint],
  'initialTimers' : Array<[ActionId, Action]>,
  'expectedExecutionTime' : Time,
  'lastExecutionTime' : Time,
}
export type Args = [] | [ArgList];
export interface EmitableEvent {
  'eventId' : bigint,
  'broadcaster' : Principal,
  'source' : Principal,
  'data' : ICRC16,
  'headers' : [] | [ICRC16Map],
  'prevEventId' : [] | [bigint],
  'timestamp' : bigint,
  'namespace' : string,
}
export interface Event {
  'eventId' : bigint,
  'source' : Principal,
  'data' : ICRC16,
  'headers' : [] | [ICRC16Map],
  'prevEventId' : [] | [bigint],
  'timestamp' : bigint,
  'namespace' : string,
}
export interface EventNotification {
  'eventId' : bigint,
  'source' : Principal,
  'data' : ICRC16__1,
  'headers' : [] | [ICRC16Map__1],
  'prevEventId' : [] | [bigint],
  'filter' : [] | [string],
  'timestamp' : bigint,
  'notificationId' : bigint,
  'namespace' : string,
}
export interface EventNotification__1 {
  'eventId' : bigint,
  'source' : Principal,
  'data' : ICRC16__3,
  'headers' : [] | [ICRC16Map__2],
  'prevEventId' : [] | [bigint],
  'filter' : [] | [string],
  'timestamp' : bigint,
  'notificationId' : bigint,
  'namespace' : string,
}
export interface GenericError { 'message' : string, 'error_code' : bigint }
export type ICRC16 = { 'Int' : bigint } |
  { 'Map' : Array<[string, ICRC16]> } |
  { 'Nat' : bigint } |
  { 'Set' : Array<ICRC16> } |
  { 'Nat16' : number } |
  { 'Nat32' : number } |
  { 'Nat64' : bigint } |
  { 'Blob' : Uint8Array | number[] } |
  { 'Bool' : boolean } |
  { 'Int8' : number } |
  { 'Nat8' : number } |
  { 'Nats' : Array<bigint> } |
  { 'Text' : string } |
  { 'Bytes' : Uint8Array | number[] } |
  { 'Int16' : number } |
  { 'Int32' : number } |
  { 'Int64' : bigint } |
  { 'Option' : [] | [ICRC16] } |
  { 'Floats' : Array<number> } |
  { 'Float' : number } |
  { 'Principal' : Principal } |
  { 'Array' : Array<ICRC16> } |
  { 'ValueMap' : Array<[ICRC16, ICRC16]> } |
  { 'Class' : Array<ICRC16Property> };
export type ICRC16Map = Array<[string, ICRC16]>;
export type ICRC16MapItem = [string, ICRC16__3];
export type ICRC16Map__1 = Array<[string, ICRC16__1]>;
export type ICRC16Map__2 = Array<ICRC16MapItem>;
export interface ICRC16Property {
  'value' : ICRC16,
  'name' : string,
  'immutable' : boolean,
}
export interface ICRC16Property__1 {
  'value' : ICRC16__1,
  'name' : string,
  'immutable' : boolean,
}
export interface ICRC16Property__2 {
  'value' : ICRC16__3,
  'name' : string,
  'immutable' : boolean,
}
export type ICRC16__1 = { 'Int' : bigint } |
  { 'Map' : ICRC16Map__1 } |
  { 'Nat' : bigint } |
  { 'Set' : Array<ICRC16__1> } |
  { 'Nat16' : number } |
  { 'Nat32' : number } |
  { 'Nat64' : bigint } |
  { 'Blob' : Uint8Array | number[] } |
  { 'Bool' : boolean } |
  { 'Int8' : number } |
  { 'Nat8' : number } |
  { 'Nats' : Array<bigint> } |
  { 'Text' : string } |
  { 'Bytes' : Uint8Array | number[] } |
  { 'Int16' : number } |
  { 'Int32' : number } |
  { 'Int64' : bigint } |
  { 'Option' : [] | [ICRC16__1] } |
  { 'Floats' : Array<number> } |
  { 'Float' : number } |
  { 'Principal' : Principal } |
  { 'Array' : Array<ICRC16__1> } |
  { 'ValueMap' : Array<[ICRC16__1, ICRC16__1]> } |
  { 'Class' : Array<ICRC16Property__1> };
export type ICRC16__3 = { 'Int' : bigint } |
  { 'Map' : Array<[string, ICRC16__3]> } |
  { 'Nat' : bigint } |
  { 'Set' : Array<ICRC16__3> } |
  { 'Nat16' : number } |
  { 'Nat32' : number } |
  { 'Nat64' : bigint } |
  { 'Blob' : Uint8Array | number[] } |
  { 'Bool' : boolean } |
  { 'Int8' : number } |
  { 'Nat8' : number } |
  { 'Nats' : Array<bigint> } |
  { 'Text' : string } |
  { 'Bytes' : Uint8Array | number[] } |
  { 'Int16' : number } |
  { 'Int32' : number } |
  { 'Int64' : bigint } |
  { 'Option' : [] | [ICRC16__3] } |
  { 'Floats' : Array<number> } |
  { 'Float' : number } |
  { 'Principal' : Principal } |
  { 'Array' : Array<ICRC16__3> } |
  { 'ValueMap' : Array<[ICRC16__3, ICRC16__3]> } |
  { 'Class' : Array<ICRC16Property__2> };
export interface ICRC75Item { 'principal' : Principal, 'namespace' : Namespace }
export interface InitArgs {
  'restore' : [] | [
    {
      'previousEventIDs' : Array<[string, [bigint, bigint]]>,
      'pendingEvents' : Array<EmitableEvent>,
    }
  ],
}
export type Namespace = string;
export interface NewEvent {
  'data' : ICRC16,
  'headers' : [] | [ICRC16Map],
  'namespace' : string,
}
export interface PublicationRecord { 'id' : bigint, 'namespace' : string }
export type PublishError = { 'GenericError' : GenericError } |
  { 'PublicationNotFound' : null } |
  { 'Unauthorized' : null };
export interface Publisher {
  'get_stats' : ActorMethod<[], Stats>,
  'get_stats2' : ActorMethod<
    [],
    {
      'outputStream' : Array<ICRC16__3>,
      'outputTimer' : [] | [bigint],
      'ledgerFee' : bigint,
      'publishErrors' : Array<[NewEvent, PublishError]>,
      'joinCounter' : bigint,
      '_publisherRegistered' : boolean,
    }
  >,
  'icrc72_handle_notification' : ActorMethod<
    [Array<EventNotification>],
    undefined
  >,
  'join' : ActorMethod<
    [Account, bigint],
    { 'Ok' : bigint } |
      { 'Err' : string }
  >,
  'registerPublisher' : ActorMethod<[], boolean>,
}
export interface Stats {
  'tt' : Stats__2,
  'log' : Array<string>,
  'icrc72Subscriber' : Stats__1,
  'error' : [] | [string],
  'orchestrator' : Principal,
  'readyForPublications' : boolean,
  'eventsProcessing' : boolean,
  'previousEventIds' : Array<[string, [bigint, bigint]]>,
  'pendingEvents' : Array<EmitableEvent>,
  'broadcasters' : Array<[string, Array<Principal>]>,
  'publications' : Array<[bigint, PublicationRecord]>,
  'replays' : Array<
    [
      bigint,
      [
        string,
        [] | [Principal],
        [] | [string],
        [] | [[bigint, bigint]],
        [bigint, [] | [bigint]],
      ],
    ]
  >,
  'replayStatus' : Array<[bigint, [bigint, boolean]]>,
  'drainEventId' : [] | [ActionId],
  'icrc72OrchestratorCanister' : Principal,
  'eventHistory' : Array<[bigint, Event]>,
}
export interface Stats__1 {
  'tt' : Stats__2,
  'log' : Array<string>,
  'subscriptions' : Array<[bigint, SubscriptionRecord]>,
  'readyForSubscription' : boolean,
  'backlogs' : Array<[bigint, Array<[bigint, EventNotification__1]>]>,
  'validBroadcasters' : { 'list' : Array<Principal> } |
    { 'icrc75' : ICRC75Item },
  'confirmTimer' : [] | [bigint],
  'icrc85' : {
    'activeActions' : bigint,
    'nextCycleActionId' : [] | [bigint],
    'lastActionReported' : [] | [bigint],
  },
  'error' : [] | [string],
  'confirmAccumulator' : Array<[Principal, Array<[bigint, bigint]>]>,
  'broadcasters' : Array<[bigint, Array<Principal>]>,
  'replays' : Array<
    [
      bigint,
      [
        string,
        [] | [Principal],
        [] | [string],
        [] | [[bigint, bigint]],
        [bigint, [] | [bigint]],
      ],
    ]
  >,
  'lastEventId' : Array<[string, Array<[bigint, bigint]>]>,
  'replayStatus' : Array<[bigint, [bigint, bigint]]>,
  'icrc72OrchestratorCanister' : Principal,
}
export interface Stats__2 {
  'timers' : bigint,
  'maxExecutions' : bigint,
  'minAction' : [] | [ActionDetail],
  'cycles' : bigint,
  'nextActionId' : bigint,
  'nextTimer' : [] | [TimerId],
  'expectedExecutionTime' : [] | [Time],
  'lastExecutionTime' : Time,
}
export interface SubscriptionRecord {
  'id' : bigint,
  'config' : ICRC16Map__2,
  'namespace' : string,
}
export type Time = bigint;
export type TimerId = bigint;
export interface _SERVICE extends Publisher {}
export declare const idlFactory: IDL.InterfaceFactory;
export declare const init: (args: { IDL: typeof IDL }) => IDL.Type[];

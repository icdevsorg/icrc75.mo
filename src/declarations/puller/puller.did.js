export const idlFactory = ({ IDL }) => {
  const ICRC16 = IDL.Rec();
  const ICRC16__1 = IDL.Rec();
  const ICRC16__3 = IDL.Rec();
  const ICRC16Property = IDL.Record({
    'value' : ICRC16,
    'name' : IDL.Text,
    'immutable' : IDL.Bool,
  });
  ICRC16.fill(
    IDL.Variant({
      'Int' : IDL.Int,
      'Map' : IDL.Vec(IDL.Tuple(IDL.Text, ICRC16)),
      'Nat' : IDL.Nat,
      'Set' : IDL.Vec(ICRC16),
      'Nat16' : IDL.Nat16,
      'Nat32' : IDL.Nat32,
      'Nat64' : IDL.Nat64,
      'Blob' : IDL.Vec(IDL.Nat8),
      'Bool' : IDL.Bool,
      'Int8' : IDL.Int8,
      'Nat8' : IDL.Nat8,
      'Nats' : IDL.Vec(IDL.Nat),
      'Text' : IDL.Text,
      'Bytes' : IDL.Vec(IDL.Nat8),
      'Int16' : IDL.Int16,
      'Int32' : IDL.Int32,
      'Int64' : IDL.Int64,
      'Option' : IDL.Opt(ICRC16),
      'Floats' : IDL.Vec(IDL.Float64),
      'Float' : IDL.Float64,
      'Principal' : IDL.Principal,
      'Array' : IDL.Vec(ICRC16),
      'ValueMap' : IDL.Vec(IDL.Tuple(ICRC16, ICRC16)),
      'Class' : IDL.Vec(ICRC16Property),
    })
  );
  const ICRC16Map = IDL.Vec(IDL.Tuple(IDL.Text, ICRC16));
  const EmitableEvent = IDL.Record({
    'eventId' : IDL.Nat,
    'broadcaster' : IDL.Principal,
    'source' : IDL.Principal,
    'data' : ICRC16,
    'headers' : IDL.Opt(ICRC16Map),
    'prevEventId' : IDL.Opt(IDL.Nat),
    'timestamp' : IDL.Nat,
    'namespace' : IDL.Text,
  });
  const InitArgs = IDL.Record({
    'restore' : IDL.Opt(
      IDL.Record({
        'previousEventIDs' : IDL.Vec(
          IDL.Tuple(IDL.Text, IDL.Tuple(IDL.Nat, IDL.Nat))
        ),
        'pendingEvents' : IDL.Vec(EmitableEvent),
      })
    ),
  });
  const Time = IDL.Nat;
  const ActionId = IDL.Record({ 'id' : IDL.Nat, 'time' : Time });
  const Action = IDL.Record({
    'aSync' : IDL.Opt(IDL.Nat),
    'actionType' : IDL.Text,
    'params' : IDL.Vec(IDL.Nat8),
    'retries' : IDL.Nat,
  });
  const ArgList = IDL.Record({
    'nextCycleActionId' : IDL.Opt(IDL.Nat),
    'maxExecutions' : IDL.Opt(IDL.Nat),
    'nextActionId' : IDL.Nat,
    'lastActionIdReported' : IDL.Opt(IDL.Nat),
    'lastCycleReport' : IDL.Opt(IDL.Nat),
    'initialTimers' : IDL.Vec(IDL.Tuple(ActionId, Action)),
    'expectedExecutionTime' : Time,
    'lastExecutionTime' : Time,
  });
  const Args = IDL.Opt(ArgList);
  const ActionDetail = IDL.Tuple(ActionId, Action);
  const TimerId = IDL.Nat;
  const Stats__2 = IDL.Record({
    'timers' : IDL.Nat,
    'maxExecutions' : IDL.Nat,
    'minAction' : IDL.Opt(ActionDetail),
    'cycles' : IDL.Nat,
    'nextActionId' : IDL.Nat,
    'nextTimer' : IDL.Opt(TimerId),
    'expectedExecutionTime' : IDL.Opt(Time),
    'lastExecutionTime' : Time,
  });
  const ICRC16Property__2 = IDL.Record({
    'value' : ICRC16__3,
    'name' : IDL.Text,
    'immutable' : IDL.Bool,
  });
  ICRC16__3.fill(
    IDL.Variant({
      'Int' : IDL.Int,
      'Map' : IDL.Vec(IDL.Tuple(IDL.Text, ICRC16__3)),
      'Nat' : IDL.Nat,
      'Set' : IDL.Vec(ICRC16__3),
      'Nat16' : IDL.Nat16,
      'Nat32' : IDL.Nat32,
      'Nat64' : IDL.Nat64,
      'Blob' : IDL.Vec(IDL.Nat8),
      'Bool' : IDL.Bool,
      'Int8' : IDL.Int8,
      'Nat8' : IDL.Nat8,
      'Nats' : IDL.Vec(IDL.Nat),
      'Text' : IDL.Text,
      'Bytes' : IDL.Vec(IDL.Nat8),
      'Int16' : IDL.Int16,
      'Int32' : IDL.Int32,
      'Int64' : IDL.Int64,
      'Option' : IDL.Opt(ICRC16__3),
      'Floats' : IDL.Vec(IDL.Float64),
      'Float' : IDL.Float64,
      'Principal' : IDL.Principal,
      'Array' : IDL.Vec(ICRC16__3),
      'ValueMap' : IDL.Vec(IDL.Tuple(ICRC16__3, ICRC16__3)),
      'Class' : IDL.Vec(ICRC16Property__2),
    })
  );
  const ICRC16MapItem = IDL.Tuple(IDL.Text, ICRC16__3);
  const ICRC16Map__2 = IDL.Vec(ICRC16MapItem);
  const SubscriptionRecord = IDL.Record({
    'id' : IDL.Nat,
    'config' : ICRC16Map__2,
    'namespace' : IDL.Text,
  });
  const EventNotification__1 = IDL.Record({
    'eventId' : IDL.Nat,
    'source' : IDL.Principal,
    'data' : ICRC16__3,
    'headers' : IDL.Opt(ICRC16Map__2),
    'prevEventId' : IDL.Opt(IDL.Nat),
    'filter' : IDL.Opt(IDL.Text),
    'timestamp' : IDL.Nat,
    'notificationId' : IDL.Nat,
    'namespace' : IDL.Text,
  });
  const Namespace = IDL.Text;
  const ICRC75Item = IDL.Record({
    'principal' : IDL.Principal,
    'namespace' : Namespace,
  });
  const Stats__1 = IDL.Record({
    'tt' : Stats__2,
    'log' : IDL.Vec(IDL.Text),
    'subscriptions' : IDL.Vec(IDL.Tuple(IDL.Nat, SubscriptionRecord)),
    'readyForSubscription' : IDL.Bool,
    'backlogs' : IDL.Vec(
      IDL.Tuple(IDL.Nat, IDL.Vec(IDL.Tuple(IDL.Nat, EventNotification__1)))
    ),
    'validBroadcasters' : IDL.Variant({
      'list' : IDL.Vec(IDL.Principal),
      'icrc75' : ICRC75Item,
    }),
    'confirmTimer' : IDL.Opt(IDL.Nat),
    'icrc85' : IDL.Record({
      'activeActions' : IDL.Nat,
      'nextCycleActionId' : IDL.Opt(IDL.Nat),
      'lastActionReported' : IDL.Opt(IDL.Nat),
    }),
    'error' : IDL.Opt(IDL.Text),
    'confirmAccumulator' : IDL.Vec(
      IDL.Tuple(IDL.Principal, IDL.Vec(IDL.Tuple(IDL.Nat, IDL.Nat)))
    ),
    'broadcasters' : IDL.Vec(IDL.Tuple(IDL.Nat, IDL.Vec(IDL.Principal))),
    'replays' : IDL.Vec(
      IDL.Tuple(
        IDL.Nat,
        IDL.Tuple(
          IDL.Text,
          IDL.Opt(IDL.Principal),
          IDL.Opt(IDL.Text),
          IDL.Opt(IDL.Tuple(IDL.Nat, IDL.Nat)),
          IDL.Tuple(IDL.Nat, IDL.Opt(IDL.Nat)),
        ),
      )
    ),
    'lastEventId' : IDL.Vec(
      IDL.Tuple(IDL.Text, IDL.Vec(IDL.Tuple(IDL.Nat, IDL.Nat)))
    ),
    'replayStatus' : IDL.Vec(IDL.Tuple(IDL.Nat, IDL.Tuple(IDL.Nat, IDL.Nat))),
    'icrc72OrchestratorCanister' : IDL.Principal,
  });
  const PublicationRecord = IDL.Record({
    'id' : IDL.Nat,
    'namespace' : IDL.Text,
  });
  const Event = IDL.Record({
    'eventId' : IDL.Nat,
    'source' : IDL.Principal,
    'data' : ICRC16,
    'headers' : IDL.Opt(ICRC16Map),
    'prevEventId' : IDL.Opt(IDL.Nat),
    'timestamp' : IDL.Nat,
    'namespace' : IDL.Text,
  });
  const Stats = IDL.Record({
    'tt' : Stats__2,
    'log' : IDL.Vec(IDL.Text),
    'icrc72Subscriber' : Stats__1,
    'error' : IDL.Opt(IDL.Text),
    'orchestrator' : IDL.Principal,
    'readyForPublications' : IDL.Bool,
    'eventsProcessing' : IDL.Bool,
    'previousEventIds' : IDL.Vec(
      IDL.Tuple(IDL.Text, IDL.Tuple(IDL.Nat, IDL.Nat))
    ),
    'pendingEvents' : IDL.Vec(EmitableEvent),
    'broadcasters' : IDL.Vec(IDL.Tuple(IDL.Text, IDL.Vec(IDL.Principal))),
    'publications' : IDL.Vec(IDL.Tuple(IDL.Nat, PublicationRecord)),
    'replays' : IDL.Vec(
      IDL.Tuple(
        IDL.Nat,
        IDL.Tuple(
          IDL.Text,
          IDL.Opt(IDL.Principal),
          IDL.Opt(IDL.Text),
          IDL.Opt(IDL.Tuple(IDL.Nat, IDL.Nat)),
          IDL.Tuple(IDL.Nat, IDL.Opt(IDL.Nat)),
        ),
      )
    ),
    'replayStatus' : IDL.Vec(IDL.Tuple(IDL.Nat, IDL.Tuple(IDL.Nat, IDL.Bool))),
    'drainEventId' : IDL.Opt(ActionId),
    'icrc72OrchestratorCanister' : IDL.Principal,
    'eventHistory' : IDL.Vec(IDL.Tuple(IDL.Nat, Event)),
  });
  const NewEvent = IDL.Record({
    'data' : ICRC16,
    'headers' : IDL.Opt(ICRC16Map),
    'namespace' : IDL.Text,
  });
  const GenericError = IDL.Record({
    'message' : IDL.Text,
    'error_code' : IDL.Nat,
  });
  const PublishError = IDL.Variant({
    'GenericError' : GenericError,
    'PublicationNotFound' : IDL.Null,
    'Unauthorized' : IDL.Null,
  });
  const ICRC16Map__1 = IDL.Vec(IDL.Tuple(IDL.Text, ICRC16__1));
  const ICRC16Property__1 = IDL.Record({
    'value' : ICRC16__1,
    'name' : IDL.Text,
    'immutable' : IDL.Bool,
  });
  ICRC16__1.fill(
    IDL.Variant({
      'Int' : IDL.Int,
      'Map' : ICRC16Map__1,
      'Nat' : IDL.Nat,
      'Set' : IDL.Vec(ICRC16__1),
      'Nat16' : IDL.Nat16,
      'Nat32' : IDL.Nat32,
      'Nat64' : IDL.Nat64,
      'Blob' : IDL.Vec(IDL.Nat8),
      'Bool' : IDL.Bool,
      'Int8' : IDL.Int8,
      'Nat8' : IDL.Nat8,
      'Nats' : IDL.Vec(IDL.Nat),
      'Text' : IDL.Text,
      'Bytes' : IDL.Vec(IDL.Nat8),
      'Int16' : IDL.Int16,
      'Int32' : IDL.Int32,
      'Int64' : IDL.Int64,
      'Option' : IDL.Opt(ICRC16__1),
      'Floats' : IDL.Vec(IDL.Float64),
      'Float' : IDL.Float64,
      'Principal' : IDL.Principal,
      'Array' : IDL.Vec(ICRC16__1),
      'ValueMap' : IDL.Vec(IDL.Tuple(ICRC16__1, ICRC16__1)),
      'Class' : IDL.Vec(ICRC16Property__1),
    })
  );
  const EventNotification = IDL.Record({
    'eventId' : IDL.Nat,
    'source' : IDL.Principal,
    'data' : ICRC16__1,
    'headers' : IDL.Opt(ICRC16Map__1),
    'prevEventId' : IDL.Opt(IDL.Nat),
    'filter' : IDL.Opt(IDL.Text),
    'timestamp' : IDL.Nat,
    'notificationId' : IDL.Nat,
    'namespace' : IDL.Text,
  });
  const Account = IDL.Record({
    'owner' : IDL.Principal,
    'subaccount' : IDL.Opt(IDL.Vec(IDL.Nat8)),
  });
  const Publisher = IDL.Service({
    'get_stats' : IDL.Func([], [Stats], ['query']),
    'get_stats2' : IDL.Func(
        [],
        [
          IDL.Record({
            'outputStream' : IDL.Vec(ICRC16__3),
            'outputTimer' : IDL.Opt(IDL.Nat),
            'ledgerFee' : IDL.Nat,
            'publishErrors' : IDL.Vec(IDL.Tuple(NewEvent, PublishError)),
            'joinCounter' : IDL.Nat,
            '_publisherRegistered' : IDL.Bool,
          }),
        ],
        ['query'],
      ),
    'icrc72_handle_notification' : IDL.Func(
        [IDL.Vec(EventNotification)],
        [],
        ['oneway'],
      ),
    'join' : IDL.Func(
        [Account, IDL.Nat],
        [IDL.Variant({ 'Ok' : IDL.Nat, 'Err' : IDL.Text })],
        [],
      ),
    'registerPublisher' : IDL.Func([], [IDL.Bool], []),
  });
  return Publisher;
};
export const init = ({ IDL }) => {
  const ICRC16 = IDL.Rec();
  const ICRC16Property = IDL.Record({
    'value' : ICRC16,
    'name' : IDL.Text,
    'immutable' : IDL.Bool,
  });
  ICRC16.fill(
    IDL.Variant({
      'Int' : IDL.Int,
      'Map' : IDL.Vec(IDL.Tuple(IDL.Text, ICRC16)),
      'Nat' : IDL.Nat,
      'Set' : IDL.Vec(ICRC16),
      'Nat16' : IDL.Nat16,
      'Nat32' : IDL.Nat32,
      'Nat64' : IDL.Nat64,
      'Blob' : IDL.Vec(IDL.Nat8),
      'Bool' : IDL.Bool,
      'Int8' : IDL.Int8,
      'Nat8' : IDL.Nat8,
      'Nats' : IDL.Vec(IDL.Nat),
      'Text' : IDL.Text,
      'Bytes' : IDL.Vec(IDL.Nat8),
      'Int16' : IDL.Int16,
      'Int32' : IDL.Int32,
      'Int64' : IDL.Int64,
      'Option' : IDL.Opt(ICRC16),
      'Floats' : IDL.Vec(IDL.Float64),
      'Float' : IDL.Float64,
      'Principal' : IDL.Principal,
      'Array' : IDL.Vec(ICRC16),
      'ValueMap' : IDL.Vec(IDL.Tuple(ICRC16, ICRC16)),
      'Class' : IDL.Vec(ICRC16Property),
    })
  );
  const ICRC16Map = IDL.Vec(IDL.Tuple(IDL.Text, ICRC16));
  const EmitableEvent = IDL.Record({
    'eventId' : IDL.Nat,
    'broadcaster' : IDL.Principal,
    'source' : IDL.Principal,
    'data' : ICRC16,
    'headers' : IDL.Opt(ICRC16Map),
    'prevEventId' : IDL.Opt(IDL.Nat),
    'timestamp' : IDL.Nat,
    'namespace' : IDL.Text,
  });
  const InitArgs = IDL.Record({
    'restore' : IDL.Opt(
      IDL.Record({
        'previousEventIDs' : IDL.Vec(
          IDL.Tuple(IDL.Text, IDL.Tuple(IDL.Nat, IDL.Nat))
        ),
        'pendingEvents' : IDL.Vec(EmitableEvent),
      })
    ),
  });
  const Time = IDL.Nat;
  const ActionId = IDL.Record({ 'id' : IDL.Nat, 'time' : Time });
  const Action = IDL.Record({
    'aSync' : IDL.Opt(IDL.Nat),
    'actionType' : IDL.Text,
    'params' : IDL.Vec(IDL.Nat8),
    'retries' : IDL.Nat,
  });
  const ArgList = IDL.Record({
    'nextCycleActionId' : IDL.Opt(IDL.Nat),
    'maxExecutions' : IDL.Opt(IDL.Nat),
    'nextActionId' : IDL.Nat,
    'lastActionIdReported' : IDL.Opt(IDL.Nat),
    'lastCycleReport' : IDL.Opt(IDL.Nat),
    'initialTimers' : IDL.Vec(IDL.Tuple(ActionId, Action)),
    'expectedExecutionTime' : Time,
    'lastExecutionTime' : Time,
  });
  const Args = IDL.Opt(ArgList);
  return [
    IDL.Opt(
      IDL.Record({
        'icrc72PublisherArgs' : IDL.Opt(InitArgs),
        'ttArgs' : IDL.Opt(Args),
        'orchestrator' : IDL.Principal,
      })
    ),
  ];
};

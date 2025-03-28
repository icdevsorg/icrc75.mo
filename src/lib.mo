import Blob "mo:base/Blob";
import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import CertifiedData "mo:base/CertifiedData";
import Cycles "mo:base/ExperimentalCycles";
import D "mo:base/Debug";
import Error "mo:base/Error";
import Int "mo:base/Int";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Nat8 "mo:base/Nat8";
import Principal "mo:base/Principal";
import Text "mo:base/Text";
import Time "mo:base/Time";
import List "mo:base/List";
import Timer "mo:base/Timer";
import CertTree "mo:ic-certification/CertTree";

import TT "mo:timer-tool";
import ovsfixed "mo:ovs-fixed";
import Star "mo:star/star";
import RepIndy "mo:rep-indy-hash";

import MigrationLib "./migrations";
import MigrationTypes "./migrations/types";

import ClassPlusLib "mo:class-plus";
import Vector "mo:vector";
import ICRC16 "mo:candy/types";
import ICRC16Conversion "mo:candy/icrc16/conversion";
import Value "mo:cbor/Value";


import Service "./service";


module {

  ///MARK: Migration Types
  /// # State
  ///
  /// Encapsulates the entire state across versions, facilitating data migration.
  /// It is a variant that includes possible format versions of the  state, enabling seamless upgrades to the system.
  ///
  /// ## Example
  ///
  /// ```
  /// let initialState = ICRC75.initialState();
  /// let currentState = #v0_1_0(#data(initialState));
  /// ```
  public type State =               MigrationTypes.State;

  /// # CurrentState
  ///
  /// Represents the current version of the  state, including all necessary data like store and resources.
  /// This is the state format that the ledger operates on at runtime.
  ///
  public type CurrentState =        MigrationTypes.Current.State;
  public type Environment =         MigrationTypes.Current.Environment;

  public type InitArgs =            MigrationTypes.Current.InitArgs;

  public type Value =           MigrationTypes.Current.Value;
  public type ICRC16Map =           MigrationTypes.Current.ICRC16Map;
  public type ICRC16MapItem =      MigrationTypes.Current.ICRC16MapItem;
  public type DataItem =            MigrationTypes.Current.DataItem;
  public type List =                MigrationTypes.Current.List;
  public type ListItem =            MigrationTypes.Current.ListItem;
  public type Identity =            MigrationTypes.Current.Identity;
  public type Account =             MigrationTypes.Current.Account;

  public type IdentityToken =       Service.IdentityToken;
  public type IdentityCertificate = Service.IdentityCertificate;
  public type IdentityRequestResult = Service.IdentityRequestResult;
 
  public type ListRecord =            MigrationTypes.Current.ListRecord;
  public type Permission =          MigrationTypes.Current.Permission;
  public type PermissionList =          MigrationTypes.Current.PermissionList;
  public type PermissionListItem = MigrationTypes.Current.PermissionListItem;

  public type ManageRequest =       MigrationTypes.Current.ManageRequest;
  public type ManageRequestItem =   MigrationTypes.Current.ManageRequestItem;
  public type ManageResponse =     MigrationTypes.Current.ManageResponse;
  public type ManageResult =        MigrationTypes.Current.ManageResult;
  public type Stats =               MigrationTypes.Current.Stats;
  public type MembershipChangeListener = MigrationTypes.Current.MembershipChangeListener;
  public type PropertyChangeListener = MigrationTypes.Current.PropertyChangeListener;


  public type ManageListMembershipRequest = MigrationTypes.Current.ManageListMembershipRequest;
  public type ManageListMembershipResponse = MigrationTypes.Current.ManageListMembershipResponse;
  public type ManageListMembershipResult = MigrationTypes.Current.ManageListMembershipResult;

  public type AuthorizedRequestItem = MigrationTypes.Current.AuthorizedRequestItem;

  public type CanChangeMembership = MigrationTypes.Current.CanChangeMembership;
  public type CanChangeProperty = MigrationTypes.Current.CanChangeProperty;

  public type NamespaceRecord = MigrationTypes.Current.NamespaceRecord;

  public type ManageListPropertyRequest = MigrationTypes.Current.ManageListPropertyRequest;
  public type ManageListPropertyResponse = MigrationTypes.Current.ManageListPropertyResponse;
  public type ManageListPropertyResult = MigrationTypes.Current.ManageListPropertyResult;
  public type ManageListPropertyError = MigrationTypes.Current.ManageListPropertyError;
  public type DataItemMap = MigrationTypes.Current.DataItemMap;
  public type DataItemMapItem = MigrationTypes.Current.DataItemMapItem;


  /// # `initialState`
  ///
  /// Creates and returns the initial state of the ICRC-75 system.
  ///
  /// ## Returns
  ///
  /// `State`: The initial state object based on the `v0_0_0` version specified by the `MigrationTypes.State` variant.
  ///
  /// ## Example
  ///
  /// ```
  /// let state = ICRC75.initialState();
  /// ```
  public func initialState() : State {#v0_0_0(#data)};

  /// # currentStateVersion
  ///
  /// Indicates the current version of the ledger state that this ICRC-75 implementation is using.
  /// It is used for data migration purposes to ensure compatibility across different ledger state formats.
  ///
  /// ## Value
  ///
  /// `#v0_1_0(#id)`: A unique identifier representing the version of the  state format currently in use, as defined by the `State` data type.
  public let Migration = MigrationLib;
  public let currentStateVersion = #v0_2_0(#id);
  public let init = Migration.migrate;

  public let migrate = Migration.migrate;
  
  public let Map = MigrationTypes.Current.Map;
  public let Set = MigrationTypes.Current.Set;

  public let BTree = MigrationTypes.Current.BTree;
  public let Vector = MigrationTypes.Current.Vector;

 

  public let listItemHash = MigrationTypes.Current.listItemHash;


  public func Init<system>(config : {
    manager: ClassPlusLib.ClassPlusInitializationManager;
    initialState: State;
    args : ?InitArgs;
    pullEnvironment : ?(() -> Environment);
    onInitialize: ?(ICRC75 -> async*());
    onStorageChange : ((State) ->())
  }) :()-> ICRC75{

    D.print("Subscriber Init");
    switch(config.pullEnvironment){
      case(?val) {
        D.print("pull environment has value");
        
      };
      case(null) {
        D.print("pull environment is null");
      };
    };  
    ClassPlusLib.ClassPlus<system,
      ICRC75, 
      State,
      InitArgs,
      Environment>({config with constructor = ICRC75}).get;
  };




  /// #class ICRC75
  /// Initializes the state of the ICRC75 class.
  /// - Parameters:
  ///     - stored: `?State` - An optional initial state to start with; if `null`, the initial state is derived from the `initialState` function.
  ///     - canister: `Principal` - The principal of the canister where this class is used.
  ///     - environment: `Environment` - The environment settings for various ICRC standards-related configurations.
  /// - Returns: No explicit return value as this is a class constructor function.
  public class ICRC75(stored: ?State, caller: Principal, canister: Principal, args: ?InitArgs, environment_passed: ?Environment, storageChanged: (State) -> ()){

    let debug_channel= {
      var announce = true;
      var queryItem = true;
      var managemember = true;
      var managelist = true;
      var certificate = true;
      var timerTool = true;
    };

    public var vecLog = Vector.new<Text>();

    private func d(doLog : Bool, message: Text) {
      if(doLog){
        Vector.add(vecLog, Nat.toText(Int.abs(Time.now())) # " " # message);
        if(Vector.size(vecLog) > 5000){
          vecLog := Vector.new<Text>();
        };
        D.print(message);
      };
    };

    let environment = switch(environment_passed){
      case(?val) val;
      case(null) {
        D.trap("Environment is required");
      };
    };

    debug d(debug_channel.announce, debug_show(("ICRC75 initializing", canister)));

    /// # State
    ///
    /// Encapsulates the entire state across versions, facilitating data migration.
    /// It is a variant that includes possible format versions of the ledger state, enabling seamless upgrades to the system.
    ///
    /// ## Example
    ///
    /// ```
    /// let initialState = ICRC75.initialState();
    /// let currentState = #v0_1_0(#data(initialState));
    /// ```
    var state : CurrentState = switch(stored){
      case(null) {
        debug d(debug_channel.announce, debug_show(("ICRC75 initializing with initialState")));
        let #v0_2_0(#data(foundState)) = init(initialState(), currentStateVersion, args, caller);
        foundState;
      };
      case(?val) {
        let #v0_2_0(#data(foundState)) = init(val, currentStateVersion, args, caller);
        foundState;
      };
    };



    storageChanged(#v0_2_0(#data(state)));

    public func initTimer<system>() : () {
      debug d(debug_channel.announce, debug_show(("ICRC75 in init starting timer tool")));
      ensureTT<system>();
    };

    
    /// # `get_state`
    ///
    /// Acquires the current state of the ledger, which reflects all the approvals and the setup of the ledger,
    /// along with any other metadata maintained.
    ///
    /// ## Returns
    ///
    /// `CurrentState`: All encompassing state structure that includes account balances, approval mappings,
    /// and ledger configuration, as defined in `MigrationTypes.Current.State`.
    ///
    /// ## Example
    ///
    /// ```
    /// let currentState = myICRC75Instance.get_state();
    /// ```
    public func get_state() :  CurrentState {
      return state;
    };

  
    /// `metadata`
    ///
    /// Retrieves all metadata associated with the token ledger relative to icrc75
    /// If no metadata is found, the method initializes default metadata based on the state and the canister Principal.
    ///
    /// Returns:
    /// `MetaData`: A record containing all metadata entries for this ledger.
    public func metadata() : ICRC16Map {
        [("txWindow", #Nat(state.metadata.txWindow)),
        ("maxTake", #Nat(state.metadata.maxTake)),
        ("defaultTake", #Nat(state.metadata.defaultTake)),
        ("permitedDrift", #Nat(state.metadata.permittedDrift)),
        ("maxQuery", #Nat(state.metadata.maxQuery)),
        ("maxUpdate", #Nat(state.metadata.maxUpdate))];
    };


    //events
    ///MARK: Listeners
    private let membershipChangeListeners = Vector.new<(Text, MembershipChangeListener )>();
    private let propertyChangeListeners = Vector.new<(Text, PropertyChangeListener)>();


    type Listener<T> = (Text, T);

    /// Generic function to register a listener.
    ///
    /// Parameters:
    ///     namespace: Text - The namespace identifying the listener.
    ///     remote_func: T - A callback function to be invoked.
    ///     listeners: Vector<Listener<T>> - The list of listeners.
    public func registerListener<T>(namespace: Text, remote_func: T, listeners: Vector.Vector<Listener<T>>) {
      let listener: Listener<T> = (namespace, remote_func);
      switch(Vector.indexOf<Listener<T>>(listener, listeners, func(a: Listener<T>, b: Listener<T>) : Bool {
        Text.equal(a.0, b.0);
      })){
        case(?index){
          Vector.put<Listener<T>>(listeners, index, listener);
        };
        case(null){
          Vector.add<Listener<T>>(listeners, listener);
        };
      };
    };

    /// # register_membershipChangeListener
    ///
    /// Registers a listener that will be triggered after a successful transfer batch operation.
    ///
    /// ## Parameters
    ///
    /// - `namespace`: `Text` - A unique name identifying the listener.
    /// - `remote_func`: `TokenBatchlListener` - A callback function that will be invoked with token batch notifications.
    ///
    /// ## Remarks
    ///
    /// The registered listener callback function receives notifications containing details about the token batc operation and the corresponding transaction ID. It is useful for tracking delegation events as token owners grant spend permissions to third parties. Note that transfer notifications will also be sent from icrc1.
    public func registerMembershipChangeListener(namespace: Text, remote_func : MembershipChangeListener){
      registerListener<MembershipChangeListener>(namespace, remote_func, membershipChangeListeners);
    };

    public func registerPropertyChangeListener(namespace: Text, remote_func :PropertyChangeListener){
      registerListener<PropertyChangeListener>(namespace, remote_func, propertyChangeListeners);
    };


    let OneDay =  86_400_000_000_000;

    ///MARK: actor mangement

    var _haveTimer : ?Bool = null;



    private func ensureTT<system>(){
      let haveTimer = switch(_haveTimer){
        case(?val) val;
        case(null){
           let result = (switch(environment.advanced){
              case(?val) {
                switch(val.icrc85.kill_switch){
                  case(null) true;
                  case(?val) val;
                };
              };
              case(null) true;
            });
          _haveTimer := ?result;
          result;
        };
      };
      debug d(debug_channel.announce, debug_show(("ensureTT", haveTimer)));
      if(haveTimer == true){
        ignore tt<system>();
      };
    };

    /// Updates actor information such as transaction and query variables.
    /// - Parameters:
    ///     - request: `[UpdateLedgerInfoRequest]` - A list of requests containing the updates to be applied to the ledger.
    /// - Returns: `[Bool]` - An array of booleans indicating the success of each update request.
    public func updateProperties<system>(caller : Principal, request: ManageRequest) : ManageResponse{

      //make sure tt is set
      ensureTT<system>();
      if(request.size() > state.metadata.maxUpdate){
        return [?#Err(#TooManyRequests)];
      };
      state.icrc85.activeActions := state.icrc85.activeActions + 1;
      ignore ensureCycleShare<system>();
      if(state.owner != caller){
        return [?#Err(#Unauthorized)];
      };

      let results = Buffer.Buffer<ManageResult>(1);
      
      for(thisItem in request.vals()){
        switch(thisItem){
          case(#UpdateDefaultTake(val)){
            state.metadata.defaultTake := val;
          };
          case(#UpdateMaxTake(val)){
            state.metadata.maxTake := val;
          };
          case(#UpdatePermittedDrift(val)){
            state.metadata.permittedDrift := val;
          };
          case(#UpdateTxWindow(val)){
            state.metadata.txWindow := val;
          };
          case(#UpdateOwner(val)){
            state.owner := val;
          };
        };
        results.add(?(#Ok));
      };
      
      return Buffer.toArray(results);
    };



    /// # `get_stats`
    ///
    /// Provides statistics that summarize the current ledger state, including the max transfers and balance checks,
    /// the limits that are set, and the overall ledger setup.
    ///
    /// ## Returns
    ///
    /// `Stats`: A snapshot structure representing ledger statistics like the number of approvals set up,
    /// the configurations of the ledger, as well as the indexing status for quick lookup.
    ///
    /// ## Example
    ///
    /// ```
    /// let statistics = myICRC75Instance.get_stats();
    /// ```
    public func get_stats() : Stats {
      return {
        cycleShareTimerID = state.icrc85.nextCycleActionId;
        namespaceStoreCount = BTree.size(state.namespaceStore);
        memberIndexCount = Map.size(state.memberIndex);
        permissionsIndexCount  = Map.size(state.permissionsIndex);
        txWindow = state.metadata.txWindow;
        maxTake = state.metadata.maxTake;
        defaultTake = state.metadata.defaultTake;
        permittedDrift = state.metadata.permittedDrift;
        owner = state.owner;
        tt = query_tt().getStats();
        //todo: return timer-tool stats
        
      };
    };

    private func query_tt() : TT.TimerTool {
      switch(tt_){
        case(?val) val;
        case(null){
          debug d(debug_channel.announce, "No timer tool set up");
          let foundClass = switch(environment.tt){
            case(?val) val;
            case(null){
              D.trap("No timer tool yet");
            };
          };
          foundClass;
        };
      };
    };

    public func accountToValue(acc : MigrationTypes.Current.Account) : MigrationTypes.Current.Value {
      let vec = Vector.new<MigrationTypes.Current.Value>();
      Vector.add(vec, #Blob(Principal.toBlob(acc.owner)));
      switch(acc.subaccount){
        case(null){};
        case(?val){
          Vector.add(vec, #Blob(val));
        };
      };

      return #Array(Vector.toArray(vec));
    };

    private func fileMember(member : MigrationTypes.Current.ListItem, metadata : ?MigrationTypes.Current.ICRC16Map, record: NamespaceRecord) : () {
      ignore Map.add(record.members, listItemHash, member, metadata);
      let found = switch(Map.get(state.memberIndex, listItemHash, member)){
          case(?val) val;
          case(null){
            let newSet = Set.new<Text>();
            ignore Map.put(state.memberIndex, listItemHash, member, newSet);
            newSet;
          };
        };
      Set.add(found, Set.thash, record.namespace);
      
    };

    private func removeMember(member : MigrationTypes.Current.ListItem, record: NamespaceRecord) : () {
      Map.delete(record.members, listItemHash, member);
      let found = switch(Map.get(state.memberIndex, listItemHash, member)){
          case(?val) val;
          case(null) return;
        };
      Set.delete(found, Set.thash, record.namespace);
    };


    ///MARK: ICRC75 UPDATE

  

    public func manage_list_membership(caller: Principal, request: Service.ManageListMembershipRequest, canChange: CanChangeMembership) : async* ManageListMembershipResponse {

      ensureTT<system>();
      if(request.size() > state.metadata.maxUpdate){
        return [?#Err(#TooManyRequests)];
      };
      state.icrc85.activeActions := state.icrc85.activeActions + 1;
      ignore ensureCycleShare<system>();
      //check permissions
      let cache = Map.new<Text, NamespaceRecord>();

      let results = Buffer.Buffer<ManageListMembershipResult>(1);
      
      label proc for(thisItem in request.vals()){
        //check permissions
        let foundCache = switch(Map.get(cache, Map.thash, thisItem.list # Principal.toText(caller))){
          case(?cacheItem) cacheItem;
          case(null){
            let found = switch(BTree.get(state.namespaceStore, Text.compare, thisItem.list)){
              case(?record) record;
              case(null) {
                results.add(?#Err(#NotFound));
                continue proc;
              };
            };
            
            if(Set.has<ListItem>(found.permissions.admin, listItemHash, #Identity(caller))){
                //cache the record
                ignore Map.put<Text, NamespaceRecord>(cache, Map.thash, thisItem.list # Principal.toText(caller), found);
            } else if(Set.has<ListItem>(found.permissions.write, listItemHash, #Identity(caller))) {
                //cache the record
                ignore Map.put(cache, Map.thash, thisItem.list # Principal.toText(caller), found);
            } else if(findIdentityInCollectionList(caller, found.permissions.admin)){
              ignore Map.put(cache, Map.thash, thisItem.list # Principal.toText(caller), found);
            } else if(findIdentityInCollectionList(caller, found.permissions.write)){
              ignore Map.put(cache, Map.thash, thisItem.list # Principal.toText(caller), found);
            } else{
              results.add(?#Err(#Unauthorized));
              continue proc;
            };
            
            found;
          };
        };

        let (listItem : ListItem, metadata : ?MigrationTypes.Current.DataItemMap, modifier : ?MigrationTypes.Current.MapModifier, actionText: Text) = switch(thisItem.action){
          case(#Add(val)){
             (val.0, val.1, null, "add");
          };
          case(#Remove(val)){
            (val, null, null, "remove");
          };
          case(#Update(val)){
            (val.0,null, ?val.1, "remove");
          };
        };

        if(actionText == "add"){
          switch(Map.get(foundCache.members, listItemHash, listItem)){
            case(?val){
              results.add(?#Err(#Exists));
              continue proc;
            };
            case(null){};
          };
        } else if(actionText == "remove"){ 
          switch(Map.get(foundCache.members, listItemHash, listItem)){
            case(null){
              results.add(?#Err(#NotFound));
              continue proc;
            };
            case(?val){};
          };
        } else if(actionText == "update"){
          switch(Map.get(foundCache.members, listItemHash, listItem)){
            case(null){
              results.add(?#Err(#NotFound));
              continue proc;
            };
            case(?val){

              //check if the modifier is valid
              switch(modifier){
                case(?mod){
                  switch(mod.1){
                    case(?metadataValue){
                      //changing or setting the value
                      switch(val){
                        case(?oldval){
                          let newMap = Buffer.Buffer<DataItemMapItem>(oldval.size());
                          label procLoop for(thisItem in oldval.vals()){
                            if(thisItem.0 == mod.0){
                              newMap.add((mod.0, metadataValue));
                              continue procLoop;
                            };
                            newMap.add(thisItem);
                          };
                          ignore Map.put(foundCache.members, listItemHash, listItem, ?Buffer.toArray<DataItemMapItem>(newMap));
                        };
                        case(null){
                          //create a new map with this value
                          let newMap = Buffer.Buffer<DataItemMap>(1);
                          ignore Map.put(foundCache.members, listItemHash, listItem, ?[(mod.0, metadataValue)]);
                        };
                      };
                    }; //remove the item
                    case(null){
                      switch(val){
                        case(?oldval){
                          let newMap = Buffer.Buffer<DataItemMapItem>(oldval.size());
                          label procLoop for(thisItem in oldval.vals()){
                            if(thisItem.0 == mod.0){
                              //remove it
                              continue procLoop;
                            };
                            newMap.add(thisItem);
                          };
                          if(newMap.size() == 0){
                            ignore Map.put(foundCache.members, listItemHash, listItem, null);
                          } else {
                            ignore Map.put(foundCache.members, listItemHash, listItem, ?Buffer.toArray<DataItemMapItem>(newMap));
                          };
                        };
                        case(null){
                          results.add(?#Err(#NotFound));
                          continue proc;
                        };
                      };
                    };
                  }
                  
                };
                case(null){};
              };
            };
          };
        };

        let trxTop = Buffer.Buffer<(Text, Value)>(1);
        trxTop.add(("btype", #Text("75memChange")));
        if(thisItem.created_at_time == null){
          trxTop.add(("ts", #Nat(Int.abs(Time.now()))));
        };

        let trx = Buffer.Buffer<(Text, Value)>(1);
        switch(thisItem.created_at_time){
          case(?time){
            trx.add(("ts", #Nat(time)));
          };
          case(null){};
        };
        switch(thisItem.memo){
          case(?memo){
            trx.add(("memo", #Blob(memo)));
          };
          case(null){};
        };
        trx.add(("changer", #Blob(Principal.toBlob(caller))));
        trx.add(("list", #Text(thisItem.list)));

        switch(listItem){
          case(#DataItem(di)){
            trx.add(("dataItem", ICRC16Conversion.candySharedToValue(di)));
          };
          case(#Identity(id)){
            trx.add(("identity", #Blob(Principal.toBlob(id))));
          };
          case(#Account(acc)){
            trx.add(("account", accountToValue(acc)));
          };
          case(#List(acc)){
            trx.add(("listItem", #Text(acc)));
          };
        };
        switch(metadata){
          case(?val){
            
            trx.add(("metadata", ICRC16Conversion.candySharedToValue(#Map(val))));
       
          };
          case(null){};
        };

        switch(modifier){
          case(?val){
            trx.add(("metadataChange", #Array([#Text(val.0), switch(val.1){
              case(?val){
                ICRC16Conversion.candySharedToValue(#Option(?val));
              };
              case(null){
                ICRC16Conversion.candySharedToValue(#Option(null));
              };
            }])));
          };
          case(null){};
        };

        switch(thisItem.from_subaccount){
          case(?from_subaccount){
            trx.add(("from_subaccount", #Blob(from_subaccount)));
          };
          case(null){};
        };

        trx.add(("change", #Text(actionText)));
        let (finalTrx, finalTrxTop) = switch(canChange){
          case(?interceptor){
            switch(interceptor){
              case(#Sync(aFunc)){
                switch(aFunc<system>(#Map(Buffer.toArray<(Text,Value)>(trx)),?#Map(Buffer.toArray<(Text,Value)>(trxTop)))){
                  case(#ok(val)) val;
                  case(#err(err)){
                    results.add(?#Err(#Other(err)));
                    continue proc;
                  };
                };
              };
              case(#Async(aFunc)){
                switch(await* aFunc<system>(#Map(Buffer.toArray<(Text,Value)>(trx)),?#Map(Buffer.toArray<(Text,Value)>(trxTop)))){
                  case(#awaited(val)) val;
                  case(#trappable(val)){
                    //clear the cache because rights may have changed
                    Map.clear(cache);
                    val;
                  };
                  case(#err(#trappable(err))){
                    results.add(?#Err(#Other(err)));
                    continue proc;
                  };
                  case(#err(#awaited(err))){
                    Map.clear(cache);
                    results.add(?#Err(#Other(err)));
                    continue proc;
                  };
                };
              };
            };
          };
          case(null){(#Map(Buffer.toArray(trx)),?#Map(Buffer.toArray(trxTop)))};
        };

        if(actionText == "add"){
          fileMember(listItem, metadata, foundCache);
        } else if(actionText == "remove") {
          removeMember(listItem, foundCache);
          ignore Map.remove(foundCache.members, listItemHash, listItem);
        } else {
          switch(modifier){
            case(?mod){
              
            };
            case(null){};
          };
        };

        let trxid = switch(environment.addRecord){
          case(?addRecord){
            addRecord<system>(finalTrx, finalTrxTop);
          };
          case(null){
            0;
          };
        };

        for(thisListener in Vector.vals(membershipChangeListeners)){
         
          thisListener.1<system>(thisItem, trxid);
           
        };
        
        results.add(?(#Ok(trxid)));
      };
      
      return Buffer.toArray(results);
    };

    //Note: This does not validate for custom logic held in the canUpdate function
    public func validate_manage_list_membership(caller: Principal, request: ManageListMembershipRequest) : async* {
      #Ok: Text;
      #Err: Text;
    } {
      if(request.size() > state.metadata.maxUpdate){
        return #Err("Too many Requests");
      };

      //check permissions
      let cache = Map.new<Text, NamespaceRecord>();

      let results = Buffer.Buffer<ManageListMembershipResult>(1);

      let descriptionText = Buffer.Buffer<Text>(1);
      
      label proc for(thisItem in request.vals()){
        //check permissions
        let foundCache = switch(Map.get(cache, Map.thash, thisItem.list # Principal.toText(caller))){
          case(?cacheItem) cacheItem;
          case(null){
            let found = switch(BTree.get(state.namespaceStore, Text.compare, thisItem.list)){
              case(?record) record;
              case(null) {
                return #Err("Cannot find List" # debug_show(("list", thisItem.list)));
              };
            };

            
            
            if(Set.has<ListItem>(found.permissions.admin, listItemHash, #Identity(caller))){
                //cache the record
                ignore Map.put<Text, NamespaceRecord>(cache, Map.thash, thisItem.list # Principal.toText(caller), found);
            } else if(Set.has<ListItem>(found.permissions.write, listItemHash, #Identity(caller))) {
                //cache the record
                ignore Map.put(cache, Map.thash, thisItem.list # Principal.toText(caller), found);
            } else if(findIdentityInCollectionList(caller, found.permissions.admin)){
              ignore Map.put(cache, Map.thash, thisItem.list # Principal.toText(caller), found);
            } else if(findIdentityInCollectionList(caller, found.permissions.write)){
              ignore Map.put(cache, Map.thash, thisItem.list # Principal.toText(caller), found);
            } else{
              return #Err("Principal does not have correct permissions" # debug_show(("list", thisItem.list, "caller", caller)));
              results.add(?#Err(#Unauthorized));
            };
            
            found;
          };
        };

        

        switch(thisItem.action){
          case(#Add(val)){
            descriptionText.add("Add " # debug_show(val) # " to " # debug_show(thisItem.list));
          };
          case(#Remove(val)){
            descriptionText.add("Remove " # debug_show(val) # " to " # debug_show(thisItem.list));
          };
        };
      };

      return #Ok(Text.join("\n", Buffer.toArray<Text>(descriptionText).vals()));
    };

    public func manage_list_properties(caller: Principal, request: ManageListPropertyRequest, canChange: CanChangeProperty) : async* ManageListPropertyResponse {

      ensureTT<system>();
      if(request.size() > state.metadata.maxUpdate){
        return [?#Err(#TooManyRequests)];
      };
      state.icrc85.activeActions := state.icrc85.activeActions + 1;
      ignore ensureCycleShare<system>();
      //check permissions
      let cache = Map.new<Text, NamespaceRecord>();
      let cachePermissions = Map.new<Text, NamespaceRecord>();
      let results = Buffer.Buffer<ManageListPropertyResult>(1);
      
      label proc for(thisItem in request.vals()){
        let actionText =switch(thisItem.action){
          case(#Create(_)){
             "create";
          };
          case(#Rename(_)){
             "rename";
          };
          case(#Delete){
             "delete";
          };
          case(#Metadata(_)){
             "metadata";
          };
          case(#ChangePermissions(_)){
             "permissions";
          };
        };

        //check permissions
        let search = if(actionText == "permissions"){
          switch(Map.get(cachePermissions, Map.thash, thisItem.list # Principal.toText(caller))){
            case(null){
              Map.get(cache, Map.thash, thisItem.list # Principal.toText(caller))
            };
            case(?cacheItem) ?cacheItem;
            };
        } else {
          Map.get(cache, Map.thash, thisItem.list # Principal.toText(caller))
        };

        if(actionText != "create"){
          let foundCache = switch(search){
            case(?cacheItem) cacheItem;
            case(null){
              let found = switch(BTree.get(state.namespaceStore, Text.compare, thisItem.list)){
                case(?record) record;
                case(null) {
                  results.add(?#Err(#NotFound));
                  continue proc;
                };
              };
              
              if(Set.has<ListItem>(found.permissions.admin, listItemHash, #Identity(caller))){
                  //cache the record
                  ignore Map.put<Text,NamespaceRecord>(cache, Map.thash, thisItem.list # Principal.toText(caller), found);
              } else if(Set.has<ListItem>(found.permissions.permissions, listItemHash, #Identity(caller))) {
                  //cache the record
                  ignore Map.put(cachePermissions, Map.thash, thisItem.list # Principal.toText(caller), found);
              } else if(findIdentityInCollectionList(caller, found.permissions.admin)){
                ignore Map.put<Text,NamespaceRecord>(cache, Map.thash, thisItem.list # Principal.toText(caller), found);
              } else if(findIdentityInCollectionList(caller, found.permissions.permissions)){
                ignore Map.put<Text,NamespaceRecord>(cachePermissions, Map.thash, thisItem.list # Principal.toText(caller), found);
              } else {
                //check action for permission
                results.add(?#Err(#Unauthorized));
                continue proc;
              };
              
              found;
            };
          };
        };

        let trxTop = Buffer.Buffer<(Text, Value)>(1);
        let trx = Buffer.Buffer<(Text, Value)>(1);

        
        switch(thisItem.action){
          case(#Create(val)){
            debug d(debug_channel.announce,debug_show(("In Create list", thisItem)));
            
            switch(BTree.get(state.namespaceStore, Text.compare, thisItem.list)){
              case(?record) {
                results.add(?#Err(#Exists));
                continue proc;
              };
              case(null){};
            };


            trxTop.add(("btype", #Text("75listCreate")));
            trx.add(("creator", #Blob(Principal.toBlob(caller))));
            trx.add(("list", #Text(thisItem.list)));
            if(val.metadata.size() > 0){
              trx.add(("metadata", ICRC16Conversion.candySharedToValue(#Map(val.metadata))));
            };
            if(val.members.size() > 0){
              let listBuffer = Buffer.Buffer<Value>(val.members.size());
              label listItemsToValue for(thisItem in val.members.vals()){
                let itemBuffer = Buffer.Buffer<Value>(3);
                switch(thisItem.0){
                  case(#DataItem(di)){
                    itemBuffer.add(#Text("dataItem"));
                    itemBuffer.add(ICRC16Conversion.candySharedToValue(di));
                  };
                  case(#Identity(id)){
                    itemBuffer.add(#Text("identity"));
                    itemBuffer.add(#Blob(Principal.toBlob(id)));
                  };
                  case(#Account(acc)){
                    itemBuffer.add(#Text("account"));
                    itemBuffer.add(accountToValue(acc));
                  };
                  case(#List(acc)){
                    itemBuffer.add(#Text("list"));
                    itemBuffer.add(#Text(acc));
                  };
                };

                switch(thisItem.1){
                  case(null){};
                  case(?val){
                    itemBuffer.add(ICRC16Conversion.candySharedToValue(#Map(val)));
                  }
                };
                listBuffer.add(#Array(listBuffer.toArray()));
              };
              trx.add(("members", ICRC16Conversion.candySharedToValue(#Array(listBuffer.toArray()))));
            };
              
           
            switch(val.admin){
              case(?#Identity(admin)){
                trx.add(("initialAdmin", #Blob(Principal.toBlob(admin))));
              };
              case(?#List(admin)){
                trx.add(("initialAdmin", #Text(admin)));
              };
              case(?_){
                results.add(?(#Err(#IllegalAdmin)));
                continue proc;
              };
              case(null){
                trx.add(("initialAdmin", #Blob(Principal.toBlob(caller))));
              };
            };
          };
          case(#Rename(val)){
            switch(BTree.get(state.namespaceStore, Text.compare, val)){
              case(?record) {
                results.add(?#Err(#Exists));
                continue proc;
              };
              case(null){};
            };
            trxTop.add(("btype", #Text("75listModify")));
            trx.add(("list", #Text(thisItem.list)));
            trx.add(("modifier", #Blob(Principal.toBlob(caller))));
            trx.add(("newName", #Text(val)));
          };
          case(#Delete){
            trxTop.add(("btype", #Text("75listDelete")));
            trx.add(("list", #Text(thisItem.list)));
            trx.add(("modifier", #Blob(Principal.toBlob(caller))));
          };
          case(#Metadata(val)){
            trxTop.add(("btype", #Text("75listModify")));
            trx.add(("list", #Text(thisItem.list)));
            trx.add(("modifier", #Blob(Principal.toBlob(caller))));
            switch(val.value){
              case(?metadata){
               trx.add(("metadata", #Map([(val.key, ICRC16Conversion.candySharedToValue(metadata))])));
              };
              case(null){
                trx.add(("metadataDel", #Text(val.key)));
              };
            };
          };
          case(#ChangePermissions(val)){
            trxTop.add(("btype", #Text("75permChange")));
            trx.add(("changer", #Blob(Principal.toBlob(caller))));
            trx.add(("list", #Text(thisItem.list)));
            switch(val){
              case(#Read(#Add(#Identity(val)))){
                trx.add(("action", #Text("add")));
                trx.add(("perm", #Text("read")));
                trx.add(("targetIdentity", #Blob(Principal.toBlob(val))));
              };
              case(#Read(#Add(#List(val)))){
                trx.add(("action", #Text("add")));
                trx.add(("perm", #Text("read")));
                trx.add(("targetList", #Text(val)));
              };
              case(#Read(#Add(_))){
                results.add(?(#Err(#IllegalPermission)));
              };
              
              case(#Read(#Remove(#Identity(val)))){
                trx.add(("action", #Text("remove")));
                trx.add(("perm", #Text("read")));
                trx.add(("targetIdentity", #Blob(Principal.toBlob(val))));
              };
              case(#Read(#Remove(#List(val)))){
                trx.add(("action", #Text("remove")));
                trx.add(("perm", #Text("read")));
                trx.add(("targetList", #Text(val)));
              };
              case(#Read(#Remove(_))){
                results.add(?(#Err(#IllegalPermission)));
              };
              case(#Write(#Add(#Identity(val)))){
                //anon can't be given write
                if(val == anonPrincipal){
                  results.add(?(#Err(#Unauthorized)));
                  continue proc;
                };
                trx.add(("action", #Text("add")));
                trx.add(("perm", #Text("write")));
                trx.add(("targetIdentity", #Blob(Principal.toBlob(val))));
              };
              case(#Write(#Add(#List(val)))){
                trx.add(("action", #Text("add")));
                trx.add(("perm", #Text("write")));
                trx.add(("targetList", #Text(val)));
              };
              case(#Write(#Add(_))){
                results.add(?(#Err(#IllegalPermission)));
              };
              
              case(#Write(#Remove(#Identity(val)))){
                trx.add(("action", #Text("remove")));
                trx.add(("perm", #Text("write")));
                trx.add(("targetIdentity", #Blob(Principal.toBlob(val))));
              };
              case(#Write(#Remove(#List(val)))){
                trx.add(("action", #Text("remove")));
                trx.add(("perm", #Text("write")));
                trx.add(("targetList", #Text(val)));
              };
              case(#Write(#Remove(_))){
                results.add(?(#Err(#IllegalPermission)));
              };
              case(#Admin(#Add(#Identity(val)))){
                 //anon can't be given admin
                if(val == anonPrincipal){
                  results.add(?(#Err(#Unauthorized)));
                  continue proc;
                };
                trx.add(("action", #Text("add")));
                trx.add(("perm", #Text("admin")));
                trx.add(("targetIdentity", #Blob(Principal.toBlob(val))));
              };
              case(#Admin(#Add(#List(val)))){
                trx.add(("action", #Text("add")));
                trx.add(("perm", #Text("admin")));
                trx.add(("targetList", #Text(val)));
              };
              case(#Admin(#Add(_))){
                results.add(?(#Err(#IllegalPermission)));
              };
              case(#Admin(#Remove(#Identity(val)))){
                trx.add(("action", #Text("remove")));
                trx.add(("perm", #Text("admin")));
                trx.add(("targetIdentity", #Blob(Principal.toBlob(val))));
              };
              case(#Admin(#Remove(#List(val)))){
                trx.add(("action", #Text("remove")));
                trx.add(("perm", #Text("admin")));
                trx.add(("targetList", #Text(val)));
              };
              case(#Admin(#Remove(_))){
                results.add(?(#Err(#IllegalPermission)));
              };
              case(#Permissions(#Add(#Identity(val)))){
                 //anon can't be given permissions permission
                if(val == anonPrincipal){
                  results.add(?(#Err(#Unauthorized)));
                  continue proc;
                };
                trx.add(("action", #Text("add")));
                trx.add(("perm", #Text("permissions")));
                trx.add(("targetIdentity", #Blob(Principal.toBlob(val))));
              };
              case(#Permissions(#Add(#List(val)))){
                trx.add(("action", #Text("add")));
                trx.add(("perm", #Text("permissions")));
                trx.add(("targetList", #Text(val)));
              };
              case(#Permissions(#Add(_))){
                results.add(?(#Err(#IllegalPermission)));
              };
              
              case(#Permissions(#Remove(#Identity(val)))){
                trx.add(("action", #Text("remove")));
                trx.add(("perm", #Text("permissions")));
                trx.add(("targetIdentity", #Blob(Principal.toBlob(val))));
              };
              case(#Permissions(#Remove(#List(val)))){
                trx.add(("action", #Text("remove")));
                trx.add(("perm", #Text("permissions")));
                trx.add(("targetList", #Text(val)));
              };
              case(#Permissions(#Remove(_))){
                results.add(?(#Err(#IllegalPermission)));
              };
            };
          };
        };


        if(thisItem.created_at_time == null){
          trxTop.add(("ts", #Nat(Int.abs(Time.now()))));
        };

        switch(thisItem.created_at_time){
          case(?time){
            trx.add(("ts", #Nat(time)));
          };
          case(null){};
        };
        switch(thisItem.memo){
          case(?memo){
            trx.add(("memo", #Blob(memo)));
          };
          case(null){};
        };

        switch(thisItem.from_subaccount){
          case(?from_subaccount){
            trx.add(("from_subaccount", #Blob(from_subaccount)));
          };
          case(null){};
        };


        let (finalTrx, finalTrxTop) = switch(canChange){
          case(?interceptor){
            switch(interceptor){
              case(#Sync(aFunc)){
                switch(aFunc<system>(#Map(Buffer.toArray<(Text,Value)>(trx)),?#Map(Buffer.toArray<(Text,Value)>(trxTop)))){
                  case(#ok(val)) val;
                  case(#err(err)){
                    results.add(?#Err(#Other(err)));
                    continue proc;
                  };
                };
              };
              case(#Async(aFunc)){
                switch(await* aFunc<system>(#Map(Buffer.toArray<(Text,Value)>(trx)),?#Map(Buffer.toArray<(Text,Value)>(trxTop)))){
                  case(#awaited(val)) val;
                  case(#trappable(val)){
                    //clear the cache because rights may have changed
                    Map.clear(cache);
                    val;
                  };
                  case(#err(#trappable(err))){
                    results.add(?#Err(#Other(err)));
                    continue proc;
                  };
                  case(#err(#awaited(err))){
                    Map.clear(cache);
                    results.add(?#Err(#Other(err)));
                    continue proc;
                  };
                };
              };
            };
          };
          case(null){(#Map(Buffer.toArray(trx)),?#Map(Buffer.toArray(trxTop)))};
        };

        switch(thisItem.action){
          case(#Create(val)){
            switch(BTree.get(state.namespaceStore, Text.compare, thisItem.list)){
              case(?record) {
                results.add(?#Err(#Exists));
                continue proc;
              };
              case(null){};
            };
            let record = {
              namespace = thisItem.list;
              permissions = {
                read = Set.new<MigrationTypes.Current.ListItem>();
                write = Set.new<MigrationTypes.Current.ListItem>();
                permissions = Set.new<MigrationTypes.Current.ListItem>();
                admin = switch(val.admin){
                  case(?#Identity(val)){
                    Set.fromIter<ListItem>( [#Identity(val)].vals(), listItemHash);
                  };
                  case(?#List(val)){
                    Set.fromIter<ListItem>([#List(val)].vals(), listItemHash);
                  };
                  case(null){
                    Set.fromIter<ListItem>([#Identity(caller):ListItem].vals(), listItemHash);
                  };
                  case(_){
                    results.add(?#Err(#IllegalAdmin));
                    continue proc;
                  };
                };
              };
              members = Map.fromIter<ListItem, ?DataItemMap>(val.members.vals(), listItemHash);
              metadata = val.metadata;
            };
            addNamespaceToStore(record);
          };
          case(#Rename(val)){
            switch(BTree.get(state.namespaceStore, Text.compare, val)){
              case(?record) {
                results.add(?#Err(#Exists));
                continue proc;
              };
              case(null){};
            };
            let oldRecord = switch(BTree.get(state.namespaceStore, Text.compare, thisItem.list)){
              case(?record) record;
              case(null) {
                results.add(?#Err(#NotFound));
                continue proc;
              };
            };
            
            let newRecord = {
              oldRecord with namespace = val;
            };
            removeNamespaceFromStore(oldRecord);
            addNamespaceToStore(newRecord);
          };
          case(#Delete){
            let oldRecord = switch(BTree.get(state.namespaceStore, Text.compare, thisItem.list)){
              case(?record) record;
              case(null) {
                results.add(?#Err(#NotFound));
                continue proc;
              };
            };
            removeNamespaceFromStore(oldRecord);
          };
          case(#Metadata(val)){
            let oldRecord = switch(BTree.get(state.namespaceStore, Text.compare, thisItem.list)){
              case(?record) record;
              case(null) {
                results.add(?#Err(#NotFound));
                continue proc;
              };
            };
            let newRecord = {
              oldRecord with metadata = switch(val.value){
                case(?aval){
                  let aMap = Map.fromIter<Text, DataItem>(oldRecord.metadata.vals(), Map.thash);
                  ignore Map.put(aMap, Map.thash, val.key, aval);
                  Map.toArray(aMap);
                };
                case(null){
                  let aMap = Map.fromIter<Text, DataItem>(oldRecord.metadata.vals(), Map.thash);
                  ignore Map.remove(aMap, Map.thash, val.key);
                  Map.toArray(aMap);
                };
              };
            };
            ignore BTree.insert(state.namespaceStore, Text.compare, thisItem.list, newRecord);
          };
          case(#ChangePermissions(val)){
            let oldRecord : NamespaceRecord = switch(BTree.get(state.namespaceStore, Text.compare, thisItem.list)){
              case(?record) record;
              case(null) {
                results.add(?#Err(#NotFound));
                continue proc;
              };
            };
            switch(val){
              case(#Read(#Add(newItem))){
                switch(newItem){
                  case(#DataItem(_)){
                    results.add(?(#Err(#IllegalPermission)));
                    continue proc;
                  };
                  case(#Account(_)){
                    results.add(?(#Err(#IllegalPermission)));
                    continue proc;
                  };
                  case(_){}
                };
                if(Set.has<ListItem>(oldRecord.permissions.read, listItemHash, newItem : ListItem) == false){
                  
                    Set.add(oldRecord.permissions.read, listItemHash, newItem);
                    addPermissionIndex(thisItem.list, newItem);
                
                } else {};
              };
              
              case(#Read(#Remove(removeItem))){
                switch(removeItem){
                  case(#DataItem(_)){
                    results.add(?(#Err(#IllegalPermission)));
                    continue proc;
                  };
                  case(#Account(_)){
                    results.add(?(#Err(#IllegalPermission)));
                    continue proc;
                  };
                  case(_){}
                };
                if(Set.has(oldRecord.permissions.read, listItemHash, removeItem)){
                    ignore Set.remove(oldRecord.permissions.read, listItemHash, removeItem);
                } else{
                    results.add(?(#Err(#NotFound)));
                    continue proc;
                };
                if(
                  Set.has(oldRecord.permissions.read, listItemHash,removeItem)== false
                  and
                  Set.has(oldRecord.permissions.write, listItemHash,removeItem)== false
                  and
                  Set.has(oldRecord.permissions.admin, listItemHash,removeItem)== false
                  and
                  Set.has(oldRecord.permissions.permissions, listItemHash,removeItem)== false
                ){
                  removePermissionFromIndex(thisItem.list, [removeItem].vals());
                };
              };
              case(#Write(#Add(newItem))){
                switch(newItem){
                  case(#DataItem(_)){
                    results.add(?(#Err(#IllegalPermission)));
                    continue proc;
                  };
                  case(#Account(_)){
                    results.add(?(#Err(#IllegalPermission)));
                    continue proc;
                  };
                  case(_){}
                };
                if(Set.has(oldRecord.permissions.write, listItemHash, newItem) == false){
                  
                  Set.add(oldRecord.permissions.write, listItemHash, newItem);
                  addPermissionIndex(thisItem.list, newItem);
                } else {};
              };

              
              case(#Write(#Remove(removeItem))){
                switch(removeItem){
                  case(#DataItem(_)){
                    results.add(?(#Err(#IllegalPermission)));
                    continue proc;
                  };
                  case(#Account(_)){
                    results.add(?(#Err(#IllegalPermission)));
                    continue proc;
                  };
                  case(_){}
                };
                if(Set.has(oldRecord.permissions.write, listItemHash, removeItem)){
                    ignore Set.remove(oldRecord.permissions.write, listItemHash,removeItem);
                } else {
                  results.add(?(#Err(#NotFound)));
                };
                if(
                  Set.has(oldRecord.permissions.read, listItemHash,removeItem)== false
                  and
                  Set.has(oldRecord.permissions.write, listItemHash,removeItem)== false
                  and
                  Set.has(oldRecord.permissions.admin, listItemHash,removeItem)== false
                  and
                  Set.has(oldRecord.permissions.permissions, listItemHash,removeItem)== false
                ){
                  removePermissionFromIndex(thisItem.list, [removeItem].vals());
                };
              };
              
        
              case(#Admin(#Add(newItem))){
                switch(newItem){
                  case(#DataItem(_)){
                    results.add(?(#Err(#IllegalPermission)));
                    continue proc;
                  };
                  case(#Account(_)){
                    results.add(?(#Err(#IllegalPermission)));
                    continue proc;
                  };
                  case(_){}
                };
                if(Set.has(oldRecord.permissions.admin, listItemHash, newItem) == false){
                    Set.add(oldRecord.permissions.admin, listItemHash, newItem);
                  
                    addPermissionIndex(thisItem.list, newItem);
                };
              };
              case(#Admin(#Remove(removeItem))){
                
                switch(removeItem){
                  case(#DataItem(_)){
                    results.add(?(#Err(#IllegalPermission)));
                    continue proc;
                  };
                  case(#Account(_)){
                    results.add(?(#Err(#IllegalPermission)));
                    continue proc;
                  };
                  case(_){}
                };
                if(Set.has(oldRecord.permissions.admin, listItemHash, removeItem)){
                  ignore Set.remove(oldRecord.permissions.admin, listItemHash,removeItem);
                } else {
                  results.add(?(#Err(#NotFound)));
                  continue proc;
                };
                if(
                  Set.has(oldRecord.permissions.read, listItemHash,removeItem)== false
                  and
                  Set.has(oldRecord.permissions.write, listItemHash,removeItem)== false
                  and
                  Set.has(oldRecord.permissions.admin, listItemHash,removeItem)== false
                  and
                  Set.has(oldRecord.permissions.permissions, listItemHash,removeItem)== false
                ){
                  removePermissionFromIndex(thisItem.list, [removeItem].vals());
                };
              };
              
              case(#Permissions(#Add(newItem : ListItem))){
                switch(newItem){
                  case(#DataItem(_)){
                    results.add(?(#Err(#IllegalPermission)));
                    continue proc;
                  };
                  case(#Account(_)){
                    results.add(?(#Err(#IllegalPermission)));
                    continue proc;
                  };
                  case(_){}
                };
                if(Set.has(oldRecord.permissions.permissions :Set.Set<ListItem>, listItemHash, newItem) == false){
                  Set.add(oldRecord.permissions.permissions, listItemHash, newItem);
                  addPermissionIndex(thisItem.list, newItem);
                };
              };
            
              
              case(#Permissions(#Remove(removeItem))){
                switch(removeItem){
                  case(#DataItem(_)){
                    results.add(?(#Err(#IllegalPermission)));
                    continue proc;
                  };
                  case(#Account(_)){
                    results.add(?(#Err(#IllegalPermission)));
                    continue proc;
                  };
                  case(_){}
                };
               if(Set.has(oldRecord.permissions.permissions, listItemHash, removeItem)){
                  ignore Set.remove(oldRecord.permissions.permissions, listItemHash, removeItem);
                } else {
                  results.add(?(#Err(#NotFound)));
                  continue proc;
                };
                if(
                  Set.has(oldRecord.permissions.read, listItemHash,removeItem) == false
                  and
                  Set.has(oldRecord.permissions.write, listItemHash,removeItem) == false
                  and
                  Set.has(oldRecord.permissions.admin, listItemHash,removeItem) == false
                  and
                  Set.has(oldRecord.permissions.permissions, listItemHash,removeItem) == false
                ){
                  removePermissionFromIndex(thisItem.list, [removeItem].vals());
                };
              };
            };
          };
        };

        let trxid = switch(environment.addRecord){
          case(?addRecord){
            D.print(debug_show(("Adding record", finalTrx, finalTrxTop)));
            addRecord<system>(finalTrx, finalTrxTop);
          };
          case(null){
            D.print(debug_show(("No add record provided", finalTrx, finalTrxTop)));
            0;
          };
        };

        D.print(debug_show(("Calling listener", Vector.size(propertyChangeListeners),trxid )));
         
        for(thisListener in Vector.vals(propertyChangeListeners)){
          D.print(debug_show(("Calling listener", thisItem,trxid)));
         
          thisListener.1<system>(thisItem, trxid);
           
        };
        
        results.add(?(#Ok(trxid)));
      };
      
      return Buffer.toArray(results);
    };


    //Note: This does not validate for custom logic held in the canUpdate function
    public func validate_manage_list_properties(caller: Principal, request: ManageListPropertyRequest) : async* {
      #Ok: Text;
      #Err: Text;
    } {

      if(request.size() > state.metadata.maxUpdate){
        return #Err("Too many Requests");
      };

      //check permissions
      let cache = Map.new<Text, NamespaceRecord>();
      let cachePermissions = Map.new<Text, NamespaceRecord>();
      let descriptionText = Buffer.Buffer<Text>(1);
      
      label proc for(thisItem in request.vals()){

        let actionText =switch(thisItem.action){
          case(#Create(_)){
             "Create";
          };
          case(#Rename(_)){
             "Rename";
          };
          case(#Delete){
             "Delete";
          };
          case(#Metadata(_)){
             "Update Metadata";
          };
          case(#ChangePermissions(_)){
             "Change Permission";
          };
        };

        //check permissions
        let search = if(actionText == "Change Permission"){
          switch(Map.get(cachePermissions, Map.thash, thisItem.list # Principal.toText(caller))){
            case(null){
              Map.get(cache, Map.thash, thisItem.list # Principal.toText(caller))
            };
            case(?cacheItem) ?cacheItem;
            };
        } else {
          Map.get(cache, Map.thash, thisItem.list # Principal.toText(caller))
        };

        if(actionText != "Create"){
          let foundCache = switch(search){
            case(?cacheItem) cacheItem;
            case(null){
              let found = switch(BTree.get(state.namespaceStore, Text.compare, thisItem.list)){
                case(?record) record;
                case(null) {
                  return #Err("Cannot find List " # debug_show(("list", thisItem.list)));
                  continue proc;
                };
              };
              
              if(Set.has<ListItem>(found.permissions.admin, listItemHash, #Identity(caller))){
                  //cache the record
                  ignore Map.put<Text,NamespaceRecord>(cache, Map.thash, thisItem.list # Principal.toText(caller), found);
              } else if(Set.has<ListItem>(found.permissions.permissions, listItemHash, #Identity(caller))) {
                  //cache the record
                  ignore Map.put(cachePermissions, Map.thash, thisItem.list # Principal.toText(caller), found);
              } else if(findIdentityInCollectionList(caller, found.permissions.admin)){
                ignore Map.put<Text,NamespaceRecord>(cache, Map.thash, thisItem.list # Principal.toText(caller), found);
              } else if(findIdentityInCollectionList(caller, found.permissions.permissions)){
                ignore Map.put<Text,NamespaceRecord>(cachePermissions, Map.thash, thisItem.list # Principal.toText(caller), found);
              } else {
                //check action for permission
                return #Err("Principal does not have correct permissions" # debug_show(("list", thisItem.list, "caller", caller, "action", actionText, thisItem.action)));
              };
              
              found;
            };
          };
        };

        
        switch(thisItem.action){
          case(#Create(val)){
            descriptionText.add("Create list " # thisItem.list # " with admin and metadata " #debug_show(val));
          };
          case(#Rename(val)){
            descriptionText.add("Rename list " # thisItem.list # " to " # val);
          };
          case(#Delete){
            descriptionText.add("Delete list " # thisItem.list);
          };
          case(#Metadata(val)){
            descriptionText.add("Update metadata for list " # thisItem.list # " with " # debug_show(val));
          };
          case(#ChangePermissions(val)){
            descriptionText.add("Change permissions for list " # thisItem.list # " with " # debug_show(val));
          };
        };
      };
      
      return #Ok(Text.join("\n", Buffer.toArray<Text>(descriptionText).vals()));
    };

    ignore environment.icrc10_register_supported_standards({
        name = "ICRC-75";
        url = "https://github.com/dfinity/ICRC/ICRCs/ICRC-75";
    });

    ///MARK: Queries
    
    public let anonPrincipal = Principal.fromText("2vxsx-fae");

    public func get_lists(caller: Principal, filter: ?Text, bMetadata: Bool, prev: ?List, take : ?Nat) : [ListRecord]{

      //find the string value that is one less than prev
      let beforePrev =  switch(prev){
        case(?val) ?(val # "\u{0000}");
        case(null) null;
      }; 

      let start = switch(beforePrev){
        case(?val) val;
        case(null) {
          switch(filter){
            case(?val) val;
            case(null) "";
          };
        };
      };

      let end = switch(filter){
        case(?val) val # "\u{fffd}";
        case(null) "\u{fffd}";
      };

      let results = Buffer.Buffer<ListRecord>(1);

      var maxTake = switch(take){
        case(?val) val;
        case(null) state.metadata.defaultTake;
      };

      if(maxTake > state.metadata.maxTake){
        maxTake := state.metadata.maxTake;
      };

      label search for(thisItem in BTree.scanLimit<List, NamespaceRecord>(state.namespaceStore, Text.compare, start, end, #fwd, maxTake).results.vals()){
        //only show items if read permission or anon has read
        switch(
          Set.has<ListItem>(thisItem.1.permissions.admin, listItemHash, #Identity(caller)), 
          Set.has<ListItem>(thisItem.1.permissions.read, listItemHash, #Identity(caller)), 
          Set.has<ListItem>(thisItem.1.permissions.read, listItemHash, #Identity(anonPrincipal))){
          case(false, false, false){
            if(findIdentityInCollectionList(caller, thisItem.1.permissions.admin) == false){
              if(findIdentityInCollectionList(caller, thisItem.1.permissions.read) == false){
                if(findIdentityInCollectionList(anonPrincipal, thisItem.1.permissions.read) == true){
                  
                } else {
                  continue search;
                };
              };
            };
          };
          case(_,_,_){};
        };
        
        results.add({
          list = thisItem.1.namespace;
          metadata = switch(bMetadata){
            case(true){
              ?thisItem.1.metadata;
            };
            case(false){
              null;
            };
          };
        });
        if(results.size() == maxTake){
          break search;
        };
      };

      return Buffer.toArray(results);
    };

    public func findIdentityInList(principal : Principal, list : Text) : Bool{
      return findIdentityInListDepth(principal, list, 0);
    };

    //todo: refactor to use a set of lists for cicular check
    private func findIdentityInListDepth(principal : Principal, list : Text, depth: Nat) : Bool{
      if(depth > 10){
        return false;
      };
      let ?record = BTree.get(state.namespaceStore, Text.compare, list) else return false;
      let found = switch(Map.get(record.members, listItemHash, #Identity(principal))){
        case(?val) return true;
        case(null) false;
      };
      if(found){
        return true;
      } else {
        for(thisList in Map.entries(record.members)){
          switch(thisList.0){
            case(#List(val)){
              if(findIdentityInListDepth(principal, val, depth + 1)){
                return true;
              };
            };
            case(_){};
          };
        };
      };
      return false;
    };

    public func listChain(caller: Principal, list : Text, depth: Nat) : Set.Set<Text>{
      debug d(debug_channel.announce, debug_show(("ListChain", list, depth)));
      if(depth > 10){
        return Set.new<Text>();
      };

      let result = Set.new<Text>();

      let ?record = Map.get(state.memberIndex, listItemHash, #List(list)) else  return Set.new<Text>();

      label search for(thisItem in Set.keys(record)){

        switch(BTree.get(state.namespaceStore, Text.compare, thisItem)){
          case(?record){
            debug d(debug_channel.queryItem, debug_show(("Found record", record)));
            //check permissions
            if(Set.has<ListItem>(record.permissions.admin, listItemHash, #Identity(caller)) == false){
              if(Set.has<ListItem>(record.permissions.read, listItemHash, #Identity(caller)) == false){
                if(findIdentityInCollectionList(caller, record.permissions.admin) == false){
                  if(findIdentityInCollectionList(caller, record.permissions.read) == false){
                    continue search;
                  };
                };
              };
            };
          };
          case(null){
            debug d(debug_channel.queryItem, debug_show(("Not found record", thisItem)));
            continue search;
          };
        };
      };

      debug d(debug_channel.announce, debug_show(("ListChain has member index", record)));

      label proc for(thisItem in Set.keys(record)){
        if(Set.has(result, Set.thash, thisItem)){
          debug d(debug_channel.announce, debug_show(("ListChain has member continuing ", thisItem)));
          continue proc;
        };
        Set.add(result, Set.thash, thisItem);
        for(thisSub in Set.keys(listChain(caller, thisItem, depth + 1)))
        {
          debug d(debug_channel.announce, debug_show(("ListChain has member adding ", thisSub)));
          Set.add(result, Set.thash, thisSub );
        };
      };

      return result;
    };

    public func findListInList(namespace : List, list : Text) : Bool{
      return findListInListDepth(namespace, list, 0);
    };

    private func findListInListDepth(namespace : List, list : Text, depth: Nat) : Bool{
      if(depth > 10){
        return false;
      };
      let ?record = BTree.get(state.namespaceStore, Text.compare, list) else return false;
      let found = switch(Map.get(record.members, listItemHash, #List(namespace))){
        case(?val) return true;
        case(null) false;
      };
      if(found){
        return true;
      } else {
        for(thisList in Map.entries(record.members)){
          switch(thisList.0){
            case(#List(val)){
              if(findListInListDepth(namespace, val, depth + 1)){
                return true;
              };
            };
            case(_){};
          };
        };
      };
      return false;
    };

    public func get_list_members_admin(caller: Principal, namespace: Text, prev: ?ListItem, take : ?Nat) : [(ListItem, ?DataItemMap)]{

      let ?record = BTree.get(state.namespaceStore, Text.compare, namespace) else return [];

      switch(
        Set.has<ListItem>(record.permissions.admin, listItemHash, #Identity(caller)), 
        Set.has<ListItem>(record.permissions.read, listItemHash, #Identity(caller)),
        Set.has<ListItem>(record.permissions.read, listItemHash, #Identity(anonPrincipal))){
        case(false, false, false){
          if(findIdentityInCollectionList(caller, record.permissions.admin) == false){
            if(findIdentityInCollectionList(caller, record.permissions.read) == false){
              if(findIdentityInCollectionList(anonPrincipal, record.permissions.read) == true){}
              else{
                return [];
              };
            };
          };
        };
        case(_,_,_){};
      };

      let results = Buffer.Buffer<(ListItem, ?DataItemMap)>(1);

      var maxTake = switch(take){
        case(?val) val;
        case(null) state.metadata.defaultTake;
      };

      if(maxTake > state.metadata.maxTake){
        maxTake := state.metadata.maxTake;
      };

      var bFound = switch(prev){
        case(?val) false;
        case(null) true;
      };

      label search for(thisItem in Map.entries(record.members)){
        if(bFound){
          results.add((thisItem.0, thisItem.1));
          if(results.size() == maxTake){
            break search;
          };
        } else{
          switch(prev){
            case(?prev){
              if(listItemHash.1(prev, thisItem.0)){
                bFound := true;
              };
            };
            case(null){};
          };
        };
      };

      return Buffer.toArray(results);
    };

    public func findIdentityInCollectionList(principal : Principal, collection : Set.Set<ListItem>) : Bool{
      for(thisItem in Set.keys<ListItem>(collection)){
        switch(thisItem){
          case(#List(val)){
            if(findIdentityInListDepth(principal, val, 0)){
              return true;
            };
          };
          case(_){};
        };
      };
      return false;
    };

    public func get_list_permission_admin(caller: Principal, namespace: Text, filter: ?Permission, prev: ?PermissionListItem, take : ?Nat) : PermissionList{

      let ?record = BTree.get(state.namespaceStore, Text.compare, namespace) else return [];

      switch(
        Set.has<ListItem>(record.permissions.admin, listItemHash, #Identity(caller)), 
        Set.has<ListItem>(record.permissions.permissions, listItemHash, #Identity(caller)),
        Set.has<ListItem>(record.permissions.read, listItemHash, #Identity(anonPrincipal))){
        case(false, false, false){
          if(findIdentityInCollectionList(caller, record.permissions.admin) == false){
            if(findIdentityInCollectionList(caller, record.permissions.permissions) == false){
              if(findIdentityInCollectionList(anonPrincipal, record.permissions.read) == true){}
              else{
                return [];
              };
            };
          };
        };
        case(_,_,_){};
      };

      let results = Buffer.Buffer<PermissionListItem>(1);

      var maxTake = switch(take){
        case(?val) val;
        case(null) state.metadata.defaultTake;
      };

      if(maxTake > state.metadata.maxTake){
        maxTake := state.metadata.maxTake;
      };

      var bFound = switch(prev){
        case(?val) false;
        case(null) true;
      };

      let (scanRead, scanWrite, scanAdmin, scanPermissions) = switch(filter){
        case(?#Read){
          (true, false, false, false);
        };
        case(?#Write){
          (false, true, false, false);
        };
        case(?#Admin){
          (false, false, true, false);
        };
        case(?#Permissions){
          (false, false, false, true);
        };
        case(null){
          (true, true, true, true);
        };
      };

      let (skipRead, skipWrite, skipAdmin, skipPermissions) = switch(prev){
        case(null){
          (false, false, false, false);
        };
        case(?prev){
          switch(prev.0){
            case(#Read){
              (false, false, false, false);
            };
            case(#Write){
              (true, false, false, false);
            };
            case(#Admin){
              (true, true, false, false);
            };
            case(#Permissions){
              (true, true, true, false);
            };
          };
        };
      };


      //todo: refactor this DNRY
      if(scanRead and skipRead==false){
        label searchRead for(thisItem in Set.keys<ListItem>(record.permissions.read)){
          if(bFound){
            results.add((#Read, thisItem));
            if(results.size() == maxTake){
              break searchRead;
            };
          } else{
            switch(prev){
              case(?prev){
                if(prev.0 == #Read and prev.1 == thisItem) bFound := true;
              };
              case(null){};
            };
          };
        };
      };
      
      if(scanWrite and skipWrite==false){
        label searchWrite for(thisItem in Set.keys<ListItem>(record.permissions.write)){
          if(bFound){
            results.add((#Write, thisItem));
            if(results.size() == maxTake){
              break searchWrite;
            };
          } else{
            switch(prev){
              case(?prev){
                if(prev.0 == #Write and prev.1 == thisItem) bFound := true;
              };
              case(null){};
            };
          };
        };
      };

      if(scanAdmin and skipAdmin==false){
        label searchAdmin for(thisItem in Set.keys<ListItem>(record.permissions.admin)){
          if(bFound){
            results.add((#Admin, thisItem));
            if(results.size() == maxTake){
              break searchAdmin;
            };
          } else{
            switch(prev){
              case(?prev){
                if(prev.0 == #Admin and prev.1 == thisItem) bFound := true;
              };
              case(null){};
            };
          };
        };
      };

      if(scanPermissions and skipPermissions==false){
        label searchPermissions for(thisItem in Set.keys<ListItem>(record.permissions.permissions)){
          if(bFound){
            results.add((#Permissions, thisItem));
            if(results.size() == maxTake){
              break searchPermissions;
            };
          } else{
            switch(prev){
              case(?prev){
                if(prev.0 == #Permissions and prev.1 == thisItem) bFound := true;
              };
              case(null){};
            };
          };
        };
      };
      return Buffer.toArray(results);
    };

    public func get_list_lists(caller: Principal, namespace: List, prev: ?List, take : ?Nat) : [List]{
      debug d(debug_channel.announce, debug_show(("Get list lists", namespace, prev, take)));
      let ?record = BTree.get(state.namespaceStore, Text.compare, namespace) else return [];

      switch(
        Set.has<ListItem>(record.permissions.admin, listItemHash, #Identity(caller)), 
        Set.has<ListItem>(record.permissions.read, listItemHash, #Identity(caller)),
        Set.has<ListItem>(record.permissions.read, listItemHash, #Identity(anonPrincipal))){
        case(false, false, false){
          if(findIdentityInCollectionList(caller, record.permissions.admin) == false){
            if(findIdentityInCollectionList(caller, record.permissions.read) == false){
              if(findIdentityInCollectionList(anonPrincipal, record.permissions.read) == true){}
              else{
                return [];
              };
            };
          };
        };
        case(_,_,_){};
      };

      let results = Buffer.Buffer<List>(1);

      var maxTake = switch(take){
        case(?val) val;
        case(null) state.metadata.defaultTake;
      };

      if(maxTake > state.metadata.maxTake){
        maxTake := state.metadata.maxTake;
      };

      var bFound = switch(prev){
        case(?val) false;
        case(null) true;
      };

      debug d(debug_channel.announce, debug_show(("Get list lists bFound", bFound, Map.toArray(record.members))));

      label search for(thisItem in Map.entries(record.members)){
        if(bFound){
          switch(thisItem.0){
            case(#List(val)){
              results.add(val);
              if(results.size() == maxTake){
                break search;
              };
            };
            case(_){};
          };
        } else{
          switch(prev){
            case(?prev){
              if(listItemHash.1(#List(prev), thisItem.0)){
                bFound := true;
              };
               debug d(debug_channel.announce, debug_show(("Get list lists bFound now?", bFound)));
            };
            case(null){};
          };
        };
        
      };

      return Buffer.toArray(results);
    };

    public func member_of(caller: Principal, listItem: ListItem, prev: ?List, take : ?Nat) : [List]{
      debug d(debug_channel.announce, debug_show(("Member of", listItem)));
      let results = Buffer.Buffer<List>(1);

      var maxTake = switch(take){
        case(?val) val;
        case(null) state.metadata.defaultTake;
      };

      if(maxTake > state.metadata.maxTake){
        maxTake := state.metadata.maxTake;
      };

      var bFound = switch(prev){
        case(?val) false;
        case(null) true;
      };

      let foundIndex = switch(Map.get(state.memberIndex, listItemHash, listItem)){
        case(?val) val;
        case(null) {
          debug d(debug_channel.queryItem, debug_show(("no idex found in ", state.memberIndex)));
          return [];
        };
      };

      debug d(debug_channel.queryItem, debug_show(("Found index", foundIndex)));

      label search for(thisItem in Set.keys(foundIndex)){

        switch(BTree.get(state.namespaceStore, Text.compare, thisItem)){
          case(?record){
            debug d(debug_channel.queryItem, debug_show(("Found record", record)));
            //check permissions
            if(Set.has<ListItem>(record.permissions.admin, listItemHash, #Identity(caller)) == false){
              if(Set.has<ListItem>(record.permissions.read, listItemHash, #Identity(caller)) == false){
                if(findIdentityInCollectionList(caller, record.permissions.admin) == false){
                  if(findIdentityInCollectionList(caller, record.permissions.read) == false){
                    continue search;
                  };
                };
              };
            };
          };
          case(null){
            debug d(debug_channel.queryItem, debug_show(("Not found record", thisItem)));
            continue search;
          };
        };

        if(bFound == false){
          switch(prev){
            case(?prev){
              if(prev == thisItem){
                debug d(debug_channel.queryItem, debug_show(("Found prev", prev)));
                bFound := true;
              };
            };
            case(null){};
          };
        } else {
          debug d(debug_channel.queryItem, debug_show(("Adding record", thisItem)));
          results.add(thisItem);
          if(results.size() == maxTake){
            debug d(debug_channel.queryItem, debug_show(("Breaking size", results.size())));
            break search;
          };
        };
      };

      debug d(debug_channel.queryItem, debug_show(("Results before sub list", Buffer.toArray(results))));

      for(thisItem in results.vals()){
        debug d(debug_channel.queryItem, debug_show(("Checking sub list", thisItem)));
        //are these lists a member of any other lists
        for(thisSub in Set.keys(listChain(caller, thisItem, 0))){
          debug d(debug_channel.queryItem, debug_show(("Adding sub list", thisSub)));
          results.add(thisSub);
        };
      };

      return Buffer.toArray(results);
    };

   

    public func is_member(caller: Principal, request : [AuthorizedRequestItem]) : [Bool]{
      debug d(debug_channel.announce, debug_show(("Is member", request)));
      let results = Buffer.Buffer<Bool>(1);

      label proc for(thisItem in request.vals()){
        debug d(debug_channel.queryItem, debug_show(("Processing item", thisItem)));

        //get the lists this item is on
        let foundSet = switch(Map.get(state.memberIndex, listItemHash, thisItem.0)){
          case(?val) val;
          case(null) {
            debug d(debug_channel.queryItem, debug_show(("Not found", thisItem.0)));
            results.add(false);
            continue proc;
          }
        };

        let foundLists = Set.fromIter(Set.keys(foundSet), Set.thash);

        for(thisList in Set.keys(foundSet)){
          for(thisSub in Set.keys(listChain(caller, thisList, 0))){
            Set.add(foundLists, Set.thash, thisSub);
          };
        };

        //let foundSet = listChain(caller, thisItem.0, 0);

        //check the binary check
        label ands for(thisCheck in thisItem.1.vals()){
          debug d(debug_channel.queryItem, debug_show(("Processing check ands ", thisCheck)));
          //top levels are anded together
          label ors for(thisOr in thisCheck.vals()){
            debug d(debug_channel.queryItem, debug_show(("Processing check ors ", thisOr)));
            //or levels are or'd together
            if(Set.has(foundLists, Set.thash, thisOr)){
              debug d(debug_channel.queryItem, debug_show(("Found", thisOr)));
              continue ands;
            };

            //if we get here, we didn't find it and our or and will fail
            debug d(debug_channel.queryItem, debug_show(("Failed", thisOr)));
            results.add(false);
            continue proc;
          };
        };
        //if we get here then all the ors passed and we can add a true
        debug d(debug_channel.queryItem, debug_show(("Passed", thisItem)));
        results.add(true);
      };
      
      debug d(debug_channel.queryItem, debug_show(("Results", Buffer.toArray(results))));
      return Buffer.toArray(results);
    };

    ///MARK: Utils

    private func listItemsToValue(items: [ListItem]) : [Value]{
      let results = Buffer.Buffer<Value>(1);
      for(thisItem in items.vals()){
        switch(thisItem){
          case(#List(val)){
            results.add(#Text(val));
          };
          case(#Identity(val)){
            results.add(#Blob(Principal.toBlob(val)));
          };
          case(#Account(val)){
            switch(val.subaccount){
              case(?subaccount){
                results.add(#Array([#Blob(Principal.toBlob(val.owner)), #Blob(subaccount)]));
              };
              case(null){
                results.add(#Array([#Blob(Principal.toBlob(val.owner))]));
              };
            };
          };
          case(#DataItem(val)){
            results.add(ICRC16Conversion.candySharedToValue(val));
          };
        };
      };
      return Buffer.toArray(results);
    };

    private func addPermissionIndex(namespace: Text, permission: MigrationTypes.Current.ListItem){
      let found = switch(Map.get(state.permissionsIndex, listItemHash, permission)){
        case(?val) val;
        case(null){
          let newSet = Set.new<Text>();
          ignore Map.put(state.permissionsIndex, listItemHash, permission, newSet);
          newSet;
        };
      };
      Set.add(found, Set.thash, namespace);
    };

    private func removePermissionFromIndex(namespace : Text, items: Iter.Iter<MigrationTypes.Current.ListItem>){
      for(thisPermission in items){
        switch(Map.get(state.permissionsIndex, listItemHash, thisPermission)){
          case(?val){
            ignore Set.remove(val, Set.thash, namespace);
            if(Set.size(val) == 0){
              ignore Map.remove(state.permissionsIndex, listItemHash, thisPermission)
            };
          };
          case(null){};
        };
      };
    };

    private func removeMemberFromIndex(namespace : Text, items: Iter.Iter<MigrationTypes.Current.ListItem>){
      for(thisMember in items){
        switch(Map.get(state.memberIndex, listItemHash, thisMember)){
          case(?val){
            ignore Set.remove(val, Set.thash, namespace);
            if(Set.size(val) == 0){
              ignore Map.remove(state.memberIndex, listItemHash, thisMember)
            };
          };
          case(null){};
        };
      };
    };

    private func namespaceEq(a: NamespaceRecord, b:NamespaceRecord) : Bool {
      if(a.namespace != b.namespace){
        return false;
      };
      if(a.permissions.read.size() != b.permissions.read.size()){
        return false;
      };
      if(a.permissions.write.size() != b.permissions.write.size()){
        return false;
      };
      if(a.permissions.admin.size() != b.permissions.admin.size()){
        return false;
      };
      if(a.permissions.permissions.size() != b.permissions.permissions.size()){
        return false;
      };
      if(a.members.size() != b.members.size()){
        return false;
      };
       if(a.metadata.size() != b.metadata.size()){
        return false;
      };

      for(thisPermission in Set.keys(a.permissions.read)){
        if(Set.has<ListItem>(b.permissions.read, listItemHash, thisPermission)== false){
          return false;
        };
      };
      for(thisPermission in Set.keys(a.permissions.admin)){
        if(Set.has<ListItem>(b.permissions.read, listItemHash, thisPermission : ListItem) == false){
          return false;
        };
      };
      for(thisPermission in Set.keys(a.permissions.write)){
        if(Set.has<ListItem>(b.permissions.read, listItemHash, thisPermission) == false){
          return false;
        };
      };
      for(thisPermission in Set.keys(a.permissions.permissions)){
        if( Set.has<ListItem>(b.permissions.read, listItemHash, thisPermission) == false){
          return false;
        };
      };
      
      
      for(thisMember in Map.keys(a.members)){
        switch(Map.get(b.members, listItemHash, thisMember)){
          case(null){
            return false;
          };
          case(?val){};
        };
      };

     
      for(thisMetadata in a.metadata.vals()){
        if(Array.indexOf(thisMetadata, b.metadata, func(a: (Text, DataItem), b: (Text,DataItem)) : Bool{
          if(Text.equal(a.0, b.0) and ICRC16.eqShared(a.1, b.1)){
            return true;
          };
          return false;
        }) == null){
          return false;
        };
      };

      return true;
    };

    private func removeNamespaceFromStore(record: NamespaceRecord){
       removePermissionFromIndex(record.namespace, Set.keys(record.permissions.read));
       removePermissionFromIndex(record.namespace, Set.keys(record.permissions.write));
       removePermissionFromIndex(record.namespace, Set.keys(record.permissions.admin));
       removePermissionFromIndex(record.namespace, Set.keys(record.permissions.permissions));

      removeMemberFromIndex(record.namespace, Map.keys(record.members));
      ignore BTree.delete(state.namespaceStore, Text.compare, record.namespace);
    };

    private func addNamespaceToStore(record: NamespaceRecord){
      //clean old indexes
      
      switch(BTree.get(state.namespaceStore, Text.compare, record.namespace)){
        case(?oldRecord){
          if(namespaceEq(oldRecord, record)){
            return;
          };
          removeNamespaceFromStore(oldRecord);
        };
        case(null){};
      };

      //add new items
      ignore BTree.insert<Text, NamespaceRecord>(state.namespaceStore, Text.compare, record.namespace, record);
     
      for(thisPermission in Set.keys(record.permissions.read)){
        addPermissionIndex(record.namespace, thisPermission);
      };
      for(thisPermission in Set.keys(record.permissions.permissions)){
       addPermissionIndex(record.namespace, thisPermission);
      };
      for(thisPermission in Set.keys(record.permissions.write)){
       addPermissionIndex(record.namespace, thisPermission);
      };
      for(thisPermission in Set.keys(record.permissions.admin)){
       addPermissionIndex(record.namespace, thisPermission);
      };

      for(thisMember in Map.entries(record.members)){
        let found = switch(Map.get(state.memberIndex, listItemHash, thisMember.0)){
          case(?val) val;
          case(null){
            let newSet = Set.new<Text>();
            ignore Map.put(state.memberIndex, listItemHash, thisMember.0, newSet);
            newSet;
          };
        };
        Set.add(found, Set.thash, record.namespace);
      };
    };

    public func get_supported_blocks() : [{
      block_type : Text;
      url : Text;
    }] {

      return [
        {
          block_type = "75permChange";
          url = "https://github.com/dfinity/ICRC/ICRCs/ICRC-75";
        },
        {
          block_type = "75memChange";
          url = "https://github.com/dfinity/ICRC/ICRCs/ICRC-75";
        },
        {
          block_type = "75listCreate";
          url = "https://github.com/dfinity/ICRC/ICRCs/ICRC-75";
        },
        {
          block_type = "75listModify";
          url = "https://github.com/dfinity/ICRC/ICRCs/ICRC-75";
        },
        {
          block_type = "75listDelete";
          url = "https://github.com/dfinity/ICRC/ICRCs/ICRC-75";
        },
        {
          block_type = "75listCreate";
          url = "https://github.com/dfinity/ICRC/ICRCs/ICRC-75";
        },
      ];
    };

    //MARK: Certifications

    public func listItemAsValue(item: ListItem) : (Text, ICRC16.ValueShared){ 
      switch(item){
        case(#List(val)){
          ("listItem", #Text(val));
        };
        case(#Identity(val)){
          ("identity", #Blob(Principal.toBlob(val)));
        };
        case(#Account(val)){
          switch(val.subaccount){
            case(?sub){
              ("account", #Array([#Blob(Principal.toBlob(val.owner)),#Blob(sub)]));
            };
            case(null){
             ("account", #Array([#Blob(Principal.toBlob(val.owner))]));
            };
          };
        };
        case(#DataItem(val)){
          ("dataItem", ICRC16Conversion.candySharedToValue(val));
        };
      };
    };

    public func request_token<system>(caller: Principal, item: ListItem, list: List, exp: ?Nat) :  IdentityRequestResult {

      //todo: set a timer for clean up of old tokens
      //todo: gate somehow?

      //getList

      let ?thisList = BTree.get(state.namespaceStore, Text.compare, list) else {
        debug d(debug_channel.certificate, "List not found");
        return #Err(#NotFound);
      };


      //validate item is part of the list
      let isMember = is_member(canister, [(item, [[list]])]);

      if(isMember.size() == 0){
        return #Err(#NotAMember);
      };

      if(isMember[0] == false){
         return #Err(#NotAMember);
      };

      //validate expirtion
      let maxValid = if(thisList.metadata.size() > 0){
        switch(Array.find<ICRC16MapItem>(thisList.metadata, func (x: ICRC16MapItem){
          x.0 == "icrc75:maxValidNS";
        })){
          case(null) null;
          case(?val){
            switch(val.1){
              case(#Nat(assignedMax)){
                switch(exp){
                  case(null){?assignedMax};
                  case(?val){
                    if(val > assignedMax){
                      debug d(debug_channel.certificate, "Exp too long");
                       return #Err(#ExpirationError);
                    } else {
                      ?assignedMax;
                    };
                  };
                };
              };
              case(_) null;
            };
            
          };
        };
       } else null;

       let expToUse = switch(maxValid, exp){
         case(?max, ?val){
           if(val < max){
             ?val;
           } else {
             ?max;
           };
         };
         case(null, ?val){
           ?val;
         };
         case(?max, null){
           ?max;
         };
          case(null, null){
            null;
          };
       };

      let itemMapItem : ICRC16MapItem = listItemAsValue(item);

      let timeUsed = get_time();
      let nonceUsed = state.certificateNonce;
      

      let token : ICRC16.ValueShared = ICRC16Conversion.candySharedToValue(#Map(switch(expToUse){
        case(null){
          [
            itemMapItem,
            ("namespace", #Text(list)),
            ("issued", #Nat(timeUsed)),
            ("authority", #Blob(Principal.toBlob(canister))),
            ("nonce", #Nat(nonceUsed))
          ];
        };
        case(?val){
          [
           itemMapItem,
            ("namespace", #Text(list)),
            ("issued", #Nat(timeUsed)),
            ("expires", #Nat(timeUsed + val)),
            ("authority", #Blob(Principal.toBlob(canister))),
            ("nonce", #Nat(state.certificateNonce))
          ];
        };
      }));

      //certify the new record if the cert store is provided

      switch(environment.get_certificate_store){
        
        case(?gcs){
          debug d(debug_channel.certificate, "have store" # debug_show(gcs()));
          let store = gcs();
          let ct = CertTree.Ops(store);
          ct.put([Text.encodeUtf8("icrc75:certs"), encodeBigEndian(state.certificateNonce)], Blob.fromArray(RepIndy.hash_val(token)));
          ct.setCertifiedData();
          state.certificateNonce := state.certificateNonce + 1;

          switch(environment.updated_certification){
            case(?uc){
              debug d(debug_channel.certificate, "have cert update");
              ignore uc(store);
            };
            case(_){};
          };
        };
        case(_){};
      };

      return #Ok(token);
    };

    public func retrieve_token(caller: Principal, token : IdentityToken ) : IdentityCertificate {

      let expires = switch(token){
        case(#Map(val)){
          switch(Array.find<ICRC16MapItem>(val, func(x: ICRC16MapItem){
            x.0 == "expires";
          })){
            case(null) null;
            case(?val){
              switch(val.1){
                case(#Nat(val)){
                  ?val;
                };
                case(_) null;
              };
            };
          };
        };
        case(_){
          D.trap("Invalid token");
        };
      };

      switch(expires){
        case(?exp){
          if(exp < get_time()){
            D.trap("Expired token");
          };
        };
        case(null){};
      };  

      let nonce : Nat = switch(token){
        case(#Map(val)){
          switch(Array.find<ICRC16MapItem>(val, func(x: ICRC16MapItem){
            x.0 == "nonce";
          })){
            case(null) D.trap("No nonce found");
            case(?val){
              switch(val.1){
                case(#Nat(val)){
                  val;
                };
                case(_) D.trap("Invalid nonce");
              };
            };
          };
        };
        case(_){
          D.trap("Invalid token");
        };
      };

      switch(environment.get_certificate_store){
        case(?gcs){
          let ct = CertTree.Ops(gcs());
          let foundWitness = ct.reveal([Text.encodeUtf8("icrc75:certs"), encodeBigEndian(nonce)]);
          switch(foundWitness){
            case(#empty){
              D.trap("No witness found");
            };
            case(_){};

          };

          let witness = ct.encodeWitness(foundWitness);
          return {
            token = token;
            witness = witness;
            certificate = switch(CertifiedData.getCertificate()){
              case(null){
                debug d(debug_channel.certificate, "certified returned null");
                D.trap("certified returned null");
              };
              case(?val) val;
            };
          };
        };
        case(_){
          D.trap("No store");
        };
      };
    };

    /// Encodes a number as big-endian bytes
    ///
    /// Arguments:
    /// - `nat`: The number to encode
    ///
    /// Returns:
    /// - The encoded bytes
    func encodeBigEndian(nat: Nat): Blob {
      var tempNat = nat;
      var bitCount = 0;
      while (tempNat > 0) {
        bitCount += 1;
        tempNat /= 2;
      };
      let byteCount = (bitCount + 7) / 8;

      var buffer = Buffer.Buffer<Nat8>(byteCount);
      for (i in Iter.range(0, byteCount-1)) {
        let byteValue = Nat.div(nat, Nat.pow(256, i)) % 256;
        buffer.insert(i, Nat8.fromNat(byteValue));
      };

      let item = Array.reverse(Buffer.toArray(buffer));
      return Blob.fromArray(item);
    };

    private func get_time() : Nat {
      Int.abs(Time.now());
    };

    ///////////
    // ICRC85 ovs
    //////////

    private var _icrc85init = false;

    private func ensureCycleShare<system>() : (){
      if(_icrc85init == true) return;
      _icrc85init := true;

      ignore Timer.setTimer<system>(#nanoseconds(OneDay), scheduleCycleShare);

      tt<system>().registerExecutionListenerAsync(?"icrc85:ovs:shareaction:icrc75", handleIcrc85Action : TT.ExecutionAsyncHandler);
    };

    private func scheduleCycleShare<system>() : async() {
      //check to see if it already exists
      debug d(debug_channel.announce, "in schedule cycle share");
      switch(state.icrc85.nextCycleActionId){
        case(?val){
          switch(Map.get(tt<system>().getState().actionIdIndex, Map.nhash, val)){
            case(?time) {
              //already in the queue
              return;
            };
            case(null) {};
          };
        };
        case(null){};
      };

      let result = tt<system>().setActionSync<system>(get_time(), ({actionType = "icrc85:ovs:shareaction:icrc75"; params = Blob.fromArray([]);}));
      state.icrc85.nextCycleActionId := ?result.id;
    };

    private func handleIcrc85Action<system>(id: TT.ActionId, action: TT.Action) : async* Star.Star<TT.ActionId, TT.Error>{

      D.print("in handle timer async " # debug_show((id,action)));
      switch(action.actionType){
        case("icrc85:ovs:shareaction:icrc75"){
          await* shareCycles<system>();
          #awaited(id);
        };
        case(_) #trappable(id);
      };
    };

    private func shareCycles<system>() : async*(){
      debug d(debug_channel.announce, "in share cycles ");
      let lastReportId = switch(state.icrc85.lastActionReported){
        case(?val) val;
        case(null) 0;
      };

      debug d(debug_channel.announce, "last report id " # debug_show(lastReportId));

      let actions = if(state.icrc85.activeActions > 0){
        state.icrc85.activeActions;
      } else {1;};

      debug d(debug_channel.announce, "actions " # debug_show(actions));

      state.icrc85.activeActions := 0;

      var cyclesToShare = 1_000_000_000_000; //1 XDR

      if(actions > 0){
        let additional = Nat.div(actions, 10000);
        debug d(debug_channel.announce, "additional " # debug_show(additional));
        cyclesToShare := cyclesToShare + (additional * 1_000_000_000_000);
        if(cyclesToShare > 100_000_000_000_000) cyclesToShare := 100_000_000_000_000;
      };

      debug d(debug_channel.announce, "cycles to share" # debug_show(cyclesToShare));

      try{
        await* ovsfixed.shareCycles<system>({
          environment = do?{environment.advanced!.icrc85};
          namespace = "org.icdevs.libraries.icrc75";
          actions = 1;
          schedule = func <system>(period: Nat) : async* (){
            let result = tt<system>().setActionSync<system>(get_time() + period, {actionType = "icrc85:ovs:shareaction:icrc75"; params = Blob.fromArray([]);});
            state.icrc85.nextCycleActionId := ?result.id;
          };
          cycles = cyclesToShare;
        });
      } catch(e){
        debug d(debug_channel.announce, "error sharing cycles" # Error.message(e));
      };

    };

  private func reportTTExecution(execInfo: TT.ExecutionReport): Bool{
    debug d(debug_channel.timerTool, "CANISTER: TimerTool Execution: " # debug_show(execInfo));
    return false;
  };

  private func reportTTError(errInfo: TT.ErrorReport) : ?Nat{
    debug d(debug_channel.timerTool, "CANISTER: TimerTool Error: " # debug_show(errInfo));
    return null;
  };

    private var tt_ : ?TT.TimerTool = null;


    private func tt<system>() : TT.TimerTool {
      switch(tt_){
        case(?val) val;
        case(null){
          
          let foundClass = switch(environment.tt){
            case(?val){
              tt_ := ?val;
              val : TT.TimerTool;
            };
            case(null){
              //todo: recover from existing state?

              let initManager = ClassPlusLib.ClassPlusInitializationManager(state.owner, canister, true);

              

              let local_tt  = TT.Init<system>({
                manager = initManager;
                initialState = switch(state.tt){
                  case(null) TT.initialState();
                  case(val) switch(val){
                    case(?val) val;
                    case(null) TT.initialState();
                  };
                };
                args = null;
                pullEnvironment = ?(func() : TT.Environment {
                  {      
                    advanced = null;
                    reportExecution = ?reportTTExecution;
                    reportError = ?reportTTError;
                    syncUnsafe = null;
                    reportBatch = null;
                  };
                });

                onInitialize = ?(func (newClass: TT.TimerTool) : async* () {
                  D.print("Initializing TimerTool");
                  newClass.initialize<system>();
                  //do any work here necessary for initialization
                });
                onStorageChange = func(a_state: TT.State) {
                  state.tt := ?a_state;
                }
              });

              tt_ := ?(local_tt() : TT.TimerTool);
              local_tt();
            };
            
          };
          

          foundClass.registerExecutionListenerAsync(?"icrc85:ovs:shareaction:icrc75", handleIcrc85Action : TT.ExecutionAsyncHandler);
          debug d(debug_channel.announce, "Timer tool set up");
          ignore Timer.setTimer<system>(#nanoseconds(OneDay), scheduleCycleShare);

          foundClass;
        };
      };
    };

  };
};

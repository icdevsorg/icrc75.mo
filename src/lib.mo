import Blob "mo:base/Blob";
import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import D "mo:base/Debug";
import Int "mo:base/Int";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Nat64 "mo:base/Nat64";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Text "mo:base/Text";
import Time "mo:base/Time";
import List "mo:base/List";
import Account "mo:icrc1-mo/ICRC1/Account";


import Migration "./migrations";
import MigrationTypes "./migrations/types";

import Service "./service";


module {

  let debug_channel = {
    announce = false;
    transfer = true;
    approve = true;
  };

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
  public type DataItem =            MigrationTypes.Current.DataItem;
  public type List =                MigrationTypes.Current.List;
  public type ListItem =            MigrationTypes.Current.ListItem;
  public type Identity =            MigrationTypes.Current.Identity;
  public type Account =             MigrationTypes.Current.Account;
 
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

  public type ManageListPropertiesRequest = MigrationTypes.Current.ManageListPropertiesRequest;
  public type ManageListPropertyResponse = MigrationTypes.Current.ManageListPropertyResponse;
  public type ManageListPropertyResult = MigrationTypes.Current.ManageListPropertyResult;
  public type ManageListPropertyError = MigrationTypes.Current.ManageListPropertyError;



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
  public let currentStateVersion = #v0_1_0(#id);

  public let init = Migration.migrate;
  
  public let Map = MigrationTypes.Current.Map;
  public let Set = MigrationTypes.Current.Set;

  public let BTree = MigrationTypes.Current.BTree;

  public let Vector = MigrationTypes.Current.Vector;

  public let ICRC16 = MigrationTypes.Current.ICRC16;
  public let ICRC16Conversion = MigrationTypes.Current.ICRC16Conversion;

  public let listItemHash = MigrationTypes.Current.listItemHash;

  /// #class ICRC75
  /// Initializes the state of the ICRC75 class.
  /// - Parameters:
  ///     - stored: `?State` - An optional initial state to start with; if `null`, the initial state is derived from the `initialState` function.
  ///     - canister: `Principal` - The principal of the canister where this class is used.
  ///     - environment: `Environment` - The environment settings for various ICRC standards-related configurations.
  /// - Returns: No explicit return value as this is a class constructor function.
  public class ICRC75(stored: ?State, canister: Principal, environment: Environment){

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
        let #v0_1_0(#data(foundState)) = init(initialState(),currentStateVersion, null, canister);
        foundState;
      };
      case(?val) {
        let #v0_1_0(#data(foundState)) = init(val,currentStateVersion, null, canister);
        foundState;
      };
    };

    public let migrate = Migration.migrate;

    
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
    /// let currentState = myICRC4Instance.get_state();
    /// ```
    public func get_state() :  CurrentState {
      return state;
    };

  
    /// `metadata`
    ///
    /// Retrieves all metadata associated with the token ledger relative to icrc4
    /// If no metadata is found, the method initializes default metadata based on the state and the canister Principal.
    ///
    /// Returns:
    /// `MetaData`: A record containing all metadata entries for this ledger.
    public func metadata() : ICRC16Map {
        [("txWindow", #Nat(state.metadata.txWindow)),
        ("maxTake", #Nat(state.metadata.maxTake)),
        ("defaultTake", #Nat(state.metadata.defaultTake)),
        ("permitedDrift", #Nat(state.metadata.permittedDrift))]
    };


    //events
    ///MARK: Listeners
    private let membershipChangeListeners = Vector.new<(Text,MembershipChangeListener )>();
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

    ///MARK: actor mangement

    /// Updates actor information such as transaction and query variables.
    /// - Parameters:
    ///     - request: `[UpdateLedgerInfoRequest]` - A list of requests containing the updates to be applied to the ledger.
    /// - Returns: `[Bool]` - An array of booleans indicating the success of each update request.
    public func updateProperties(caller : Principal, request: ManageRequest) : ManageResponse{

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
    /// let statistics = myICRC4Instance.get_stats();
    /// ```
    public func get_stats() : Stats {
      return {
        
        namespaceStoreCount = BTree.size(state.namespaceStore);
        memberIndexCount = Map.size(state.memberIndex);
        permissionsIndexCount  = Map.size(state.permissionsIndex);
        txWindow = state.metadata.txWindow;
        maxTake = state.metadata.maxTake;
        defaultTake = state.metadata.defaultTake;
        permittedDrift = state.metadata.permittedDrift;
        owner = state.owner;
        
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

    ///MARK: ICRC75 UPDATE

    public func manage_list_membership(caller: Principal, request: ManageListMembershipRequest, canChange: CanChangeMembership) : async* ManageListMembershipResponse {
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

        let trxTop = Buffer.Buffer<(Text, Value)>(1);
        trxTop.add(("btype", #Text("memChange")));
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

        
  

        let (val, actionText) =switch(thisItem.action){
          case(#Add(val)){
             (val,"add");
          };
          case(#Remove(val)){
            (val,"remove");
          };
        };

        switch(val){
          case(#DataItem(di)){
            trx.add(("dataItem", ICRC16Conversion.CandySharedToValue(di)));
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
          Set.add(foundCache.members, listItemHash, val);
        } else {
          ignore Set.remove(foundCache.members, listItemHash, val);
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

    public func manage_list_properties(caller: Principal, request: ManageListPropertiesRequest, canChange: CanChangeProperty) : async* ManageListPropertyResponse {
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
            debug if(debug_channel.announce) {
              D.print(debug_show(("In Create list", thisItem)));
            };
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
              trx.add(("metadata", ICRC16Conversion.CandySharedToValue(#Map(val.metadata))));
            };
            if(val.members.size() > 0){
              trx.add(("members", ICRC16Conversion.CandySharedToValue(#Array(listItemsToValue(val.members)))));
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
            trx.add(("caller", #Blob(Principal.toBlob(caller))));
            trx.add(("newName", #Text(val)));
          };
          case(#Delete){
            trxTop.add(("btype", #Text("75listDelete")));
            trx.add(("caller", #Blob(Principal.toBlob(caller))));
          };
          case(#Metadata(val)){
            trxTop.add(("btype", #Text("75listModify")));
            trx.add(("caller", #Blob(Principal.toBlob(caller))));
            switch(val.value){
              case(?metadata){
               trx.add(("metadata", #Map([(val.key, ICRC16Conversion.CandySharedToValue(metadata))])));
              };
              case(null){
                trx.add(("metadataDel", #Text(val.key)));
              };
            };
          };
          case(#ChangePermissions(val)){
            trxTop.add(("btype", #Text("75permChange")));
            trx.add(("caller", #Blob(Principal.toBlob(caller))));
            switch(val){
              case(#Read(#Add(#Identity(val)))){
                trx.add(("action", #Text("add")));
                trx.add(("perm", #Text("read")));
                trx.add(("identity", #Blob(Principal.toBlob(val))));
              };
              case(#Read(#Add(#List(val)))){
                trx.add(("action", #Text("add")));
                trx.add(("perm", #Text("read")));
                trx.add(("list", #Text(val)));
              };
              case(#Read(#Add(_))){
                results.add(?(#Err(#IllegalPermission)));
              };
              
              case(#Read(#Remove(#Identity(val)))){
                trx.add(("action", #Text("remove")));
                trx.add(("perm", #Text("read")));
                trx.add(("identity", #Blob(Principal.toBlob(val))));
              };
              case(#Read(#Remove(#List(val)))){
                trx.add(("action", #Text("remove")));
                trx.add(("perm", #Text("read")));
                trx.add(("list", #Text(val)));
              };
              case(#Read(#Remove(_))){
                results.add(?(#Err(#IllegalPermission)));
              };
              case(#Write(#Add(#Identity(val)))){
                trx.add(("action", #Text("add")));
                trx.add(("perm", #Text("write")));
                trx.add(("identity", #Blob(Principal.toBlob(val))));
              };
              case(#Write(#Add(#List(val)))){
                trx.add(("action", #Text("add")));
                trx.add(("perm", #Text("write")));
                trx.add(("list", #Text(val)));
              };
              case(#Write(#Add(_))){
                results.add(?(#Err(#IllegalPermission)));
              };
              
              case(#Write(#Remove(#Identity(val)))){
                trx.add(("action", #Text("remove")));
                trx.add(("perm", #Text("write")));
                trx.add(("identity", #Blob(Principal.toBlob(val))));
              };
              case(#Write(#Remove(#List(val)))){
                trx.add(("action", #Text("remove")));
                trx.add(("perm", #Text("write")));
                trx.add(("list", #Text(val)));
              };
              case(#Write(#Remove(_))){
                results.add(?(#Err(#IllegalPermission)));
              };
              case(#Admin(#Add(#Identity(val)))){
                trx.add(("action", #Text("add")));
                trx.add(("perm", #Text("admin")));
                trx.add(("identity", #Blob(Principal.toBlob(val))));
              };
              case(#Admin(#Add(#List(val)))){
                trx.add(("action", #Text("add")));
                trx.add(("perm", #Text("admin")));
                trx.add(("list", #Text(val)));
              };
              case(#Admin(#Add(_))){
                results.add(?(#Err(#IllegalPermission)));
              };
              case(#Admin(#Remove(#Identity(val)))){
                trx.add(("action", #Text("remove")));
                trx.add(("perm", #Text("admin")));
                trx.add(("identity", #Blob(Principal.toBlob(val))));
              };
              case(#Admin(#Remove(#List(val)))){
                trx.add(("action", #Text("remove")));
                trx.add(("perm", #Text("admin")));
                trx.add(("list", #Text(val)));
              };
              case(#Admin(#Remove(_))){
                results.add(?(#Err(#IllegalPermission)));
              };
              case(#Permissions(#Add(#Identity(val)))){
                trx.add(("action", #Text("add")));
                trx.add(("perm", #Text("permissions")));
                trx.add(("identity", #Blob(Principal.toBlob(val))));
              };
              case(#Permissions(#Add(#List(val)))){
                trx.add(("action", #Text("add")));
                trx.add(("perm", #Text("permissions")));
                trx.add(("list", #Text(val)));
              };
              case(#Permissions(#Add(_))){
                results.add(?(#Err(#IllegalPermission)));
              };
              
              case(#Permissions(#Remove(#Identity(val)))){
                trx.add(("action", #Text("remove")));
                trx.add(("perm", #Text("permissions")));
                trx.add(("identity", #Blob(Principal.toBlob(val))));
              };
              case(#Permissions(#Remove(#List(val)))){
                trx.add(("action", #Text("remove")));
                trx.add(("perm", #Text("permissions")));
                trx.add(("list", #Text(val)));
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
              members = Set.fromIter(val.members.vals(), listItemHash);
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

    ignore environment.icrc10_register_supported_standards({
        name = "ICRC-75";
        url = "https://github.com/dfinity/ICRC/ICRCs/ICRC-75/";
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
        switch(Set.has<ListItem>(thisItem.1.permissions.admin, listItemHash, #Identity(caller)), Set.has<ListItem>(thisItem.1.permissions.read, listItemHash, #Identity(caller)), Set.has<ListItem>(thisItem.1.permissions.read, listItemHash, #Identity(anonPrincipal))){
          case(false, false, false){
            if(findIdentityInCollectionList(caller, thisItem.1.permissions.admin) == false){
              if(findIdentityInCollectionList(caller, thisItem.1.permissions.read) == false){
                continue search;
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
      let found = Set.has<ListItem>(record.members, listItemHash, #Identity(principal));
      if(found){
        return true;
      } else {
        for(thisList in Set.keys<ListItem>(record.members)){
          switch(thisList){
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

    public func findListInList(namespace : List, list : Text) : Bool{
      return findListInListDepth(namespace, list, 0);
    };

    private func findListInListDepth(namespace : List, list : Text, depth: Nat) : Bool{
      if(depth > 10){
        return false;
      };
      let ?record = BTree.get(state.namespaceStore, Text.compare, list) else return false;
      let found = Set.has<ListItem>(record.members, listItemHash, #List(namespace));
      if(found){
        return true;
      } else {
        for(thisList in Set.keys<ListItem>(record.members)){
          switch(thisList){
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

    public func get_list_members_admin(caller: Principal, namespace: Text, prev: ?ListItem, take : ?Nat) : [ListItem]{

      let ?record = BTree.get(state.namespaceStore, Text.compare, namespace) else return [];

      switch(Set.has<ListItem>(record.permissions.admin, listItemHash, #Identity(caller)), Set.has<ListItem>(record.permissions.read, listItemHash, #Identity(caller))){
        case(false, false){
          if(findIdentityInCollectionList(caller, record.permissions.admin) == false){
            if(findIdentityInCollectionList(caller, record.permissions.read) == false){
              return [];
            };
          };
        };
        case(_,_){};
      };

      let results = Buffer.Buffer<ListItem>(1);

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

      label search for(thisItem in Set.keys<ListItem>(record.members)){
        if(bFound){
          results.add(thisItem);
          if(results.size() == maxTake){
            break search;
          };
        } else{
          switch(prev){
            case(?prev){
              if(prev == thisItem) bFound := true;
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

      switch(Set.has<ListItem>(record.permissions.admin, listItemHash, #Identity(caller)), Set.has<ListItem>(record.permissions.permissions, listItemHash, #Identity(caller))){
        case(false, false){
          if(findIdentityInCollectionList(caller, record.permissions.admin) == false){
            if(findIdentityInCollectionList(caller, record.permissions.permissions) == false){
              return [];
            };
          };
        };
        case(_,_){};
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
      let ?record = BTree.get(state.namespaceStore, Text.compare, namespace) else return [];

      switch(Set.has<ListItem>(record.permissions.admin, listItemHash, #Identity(caller)), Set.has<ListItem>(record.permissions.read, listItemHash, #Identity(caller))){
        case(false, false){
          if(findIdentityInCollectionList(caller, record.permissions.admin) == false){
            if(findIdentityInCollectionList(caller, record.permissions.read) == false){
              return [];
            };
          };
        };
        case(_,_){};
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

      label search for(thisItem in Set.keys<ListItem>(record.members)){
        if(bFound){
          switch(thisItem){
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
              if(prev == thisItem) bFound := true;
            };
            case(null){};
          };
        };
        
      };

      return Buffer.toArray(results);
    };

    public func member_of(caller: Principal, listItem: ListItem, prev: ?List, take : ?Nat) : [List]{
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
        case(null) return [];
      };

      label search for(thisItem in Set.keys(foundIndex)){

        switch(BTree.get(state.namespaceStore, Text.compare, thisItem)){
          case(?record){
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
            continue search;
          };
        };

        if(bFound == false){
          switch(prev){
            case(?prev){
              if(prev == thisItem){
                bFound := true;
              };
            };
            case(null){};
          };
        } else {
          results.add(thisItem);
          if(results.size() == maxTake){
            break search;
          };
        };
      };

      return Buffer.toArray(results);
    };

    public func is_member(caller: Principal, request : [AuthorizedRequestItem]) : [Bool]{
      let results = Buffer.Buffer<Bool>(1);

      label proc for(thisItem in request.vals()){

        //get the lists this item is on
        let foundSet = switch(Map.get(state.memberIndex, listItemHash, thisItem.0)){
          case(?val) val;
          case(null) {
            results.add(false);
            continue proc;
          }
        };

        //check the binary check
        label ands for(thisCheck in thisItem.1.vals()){
          //top levels are anded together
          label ors for(thisOr in thisCheck.vals()){
            //or levels are or'd together
            if(Set.has(foundSet, Set.thash, thisOr)){
              continue ors;
            } else {

              //test
              for(thisItem in Set.keys(foundSet)){
                if(findListInList(thisOr, thisItem)){
                  continue ors;
                };
              };

              /*
              //look in list of lists
              switch(Map.get(state.memberIndex, listItemHash, #List(thisOr))){
                case(?val){
                  for(thisListItem in Set.keys(val)){
                    if(Set.has(foundSet, Set.thash, thisListItem)){
                      continue ors;
                    }
                  };
                };
                case(null){};
              };
            };
            */
            };

            //if we get here, we didn't find it and our and will fail
            results.add(false);
            break ands;
          };
          //if we get here then all the ors passed and we can add a true
          results.add(true);
        };
      };
      

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
            results.add(ICRC16Conversion.CandySharedToValue(val));
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
      
      
      for(thisMember in Set.keys(a.members)){
        if( Set.has<ListItem>(b.members, listItemHash, thisMember) == false){
          return false;
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

      removeMemberFromIndex(record.namespace, Set.keys(record.members));
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

      for(thisMember in Set.keys(record.members)){
        let found = switch(Map.get(state.memberIndex, listItemHash, thisMember)){
          case(?val) val;
          case(null){
            let newSet = Set.new<Text>();
            ignore Map.put(state.memberIndex, listItemHash, thisMember, newSet);
            newSet;
          };
        };
        Set.add(found, Set.thash, record.namespace);
      };
    };
  };
};

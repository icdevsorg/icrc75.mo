// please do not import any types from your project outside migrations folder here
// it can lead to bugs when you change those types later, because migration types should not be changed
// you should also avoid importing these types anywhere in your project directly from here
// use MigrationTypes.Current property instead

import Array "mo:core/Array";
import Blob "mo:core/Blob";
import Bool "mo:base/Bool";
import Iter "mo:core/Iter";
import Order "mo:core/Order";
import Principal "mo:core/Principal";
import BaseText "mo:base/Text";
import BasePrincipal "mo:base/Principal";
import Result "mo:core/Result";
import Text "mo:core/Text";
import Nat "mo:core/Nat";
import Int "mo:core/Int";

import Nat8 "mo:core/Nat8";
import Nat16 "mo:base/Nat16";
import Nat32 "mo:core/Nat32";
import Nat64 "mo:core/Nat64";
import Int8 "mo:base/Int8";
import Int16 "mo:base/Int16";
import Int32 "mo:base/Int32";
import Int64 "mo:base/Int64";
import Float "mo:core/Float";

import MapLib "mo:core/Map";
import SetLib "mo:core/Set";
import VecLib "mo:vector";
import Star "mo:star/star";
import BTreeLib "mo:stableheapbtreemap/BTree";

import ICRC16Lib "mo:candy/types";
import ICRC16ConversionLib "mo:candy/conversion";
import TT "mo:timer-tool";
import OVSTypes "mo:ovs-fixed";
import CertTree "mo:ic-certification/CertTree";

import v0_2_0Types "../v000_002_000/types";

module {

  public let ONE_DAY = 86400000000000 : Nat; //NanoSeconds
  public let ONE_MINUTE = 60000000000 : Nat; //NanoSeconds

  /// Re-export TimerTool type for external use
  public type TimerTool = TT.TimerTool;

  /// `ICRC85State`
  ///
  /// Represents the state for ICRC-85 Open Value Sharing (OVS).
  /// Tracks active actions (transactions) and scheduling for cycle sharing.
  public type ICRC85State = OVSTypes.State;

  /// `ICRC85Environment`
  ///
  /// Environment configuration for ICRC-85 Open Value Sharing.
  /// Allows customization of cycle sharing behavior.
  public type ICRC85Environment = OVSTypes.Environment;

  /// Vector provides an interface to a vector-like collection.
  public let Vector = VecLib;

  /// Map provides an interface to a key-value storage collection using mo:core/Map.
  public let Map = MapLib;

  public let BTree = BTreeLib;

  public let ICRC16 = ICRC16Lib;
  public let ICRC16Conversion = ICRC16ConversionLib;

  /// Set provides an interface to a set-like collection using mo:core/Set.
  public let Set = SetLib;

  public type Identity = Principal;

  public type Account = {
        owner : Principal;
        subaccount : ?Subaccount;
  };

  public type DataItem = ICRC16.CandyShared;
  public type Value = ICRC16.ValueShared;

  public type List = Text;

  public type ListRecord = {
    list : List;
    metadata : ?ICRC16Map;
  };

  public type ListItem = {
    #Account : Account;
    #Identity : Identity;
    #DataItem : DataItem;
    #List : List;
  };

  public type Subaccount = Blob;

  public type Permission = {
    #Admin;
    #Read;
    #Write;
    #Permissions;
  };

  public type ICRC16Map = [ICRC16MapItem];

  public type ICRC16MapItem = (Text, DataItem);

  public type ICRC85Options = {
    kill_switch: ?Bool;
    handler: ?(([(Text, ICRC16Map)]) -> ());
    period: ?Nat;
    tree: ?[Text];
    asset: ?Text;
    platform: ?Text;
    collector: ?Principal;
    advanced: ?OVSTypes.AdvancedEnvironment;
  };

  /// PermissionCollection uses mo:core/Set
  public type PermissionCollection = {
    read : Set.Set<ListItem>;
    write : Set.Set<ListItem>;
    admin : Set.Set<ListItem>;
    permissions : Set.Set<ListItem>;
  };

  public type PermissionList = [PermissionListItem];
  public type PermissionListItem = (Permission, ListItem);

  public type NamespaceRecord = {
    namespace : Text;
    permissions : PermissionCollection;
    members : Map.Map<ListItem, ?ICRC16Map>;
    metadata : ICRC16Map;
  };

  public type NamespaceRecordShared = {
    namespace : Text;
    permissions : PermissionList;
    members : [(ListItem, ?ICRC16Map)];
    metadata : ICRC16Map;
  };

  public type Domain = [Text];

  public type ManageListMembershipAction = {
    #Add : (ListItem, ?DataItemMap);
    #Remove : ListItem;
    #Update : (ListItem, MapModifier);
  };
  public type MapModifier = (Text, ?DataItem);

  public type ManageListMembershipRequestItem = {
    list : List;
    memo : ?Blob;
    created_at_time : ?Nat;
    from_subaccount : ?Blob;
    action : ManageListMembershipAction;
  };

  public type MembershipChangeListener = <system>(ManageListMembershipRequestItem, trxid: Nat) -> ();

  public type ManageListPropertyRequestAction = {
    #Create : {
      admin : ?ListItem;
      metadata : ICRC16Map;
      members : [(ListItem, ?DataItemMap)];
    };
    #Rename : Text; 
    #Delete;
    #Metadata : {
      key : Text;
      value : ?DataItem;
    }; 
    #ChangePermissions : {
      #Read : {
        #Add : ListItem;
        #Remove : ListItem;
      };
      #Write : {
        #Add : ListItem;
        #Remove : ListItem;
      };
      #Admin : {
        #Add : ListItem;
        #Remove : ListItem;
      };
      #Permissions : {
        #Add : ListItem;
        #Remove : ListItem;
      };
    } 
  };

  public type ManageListPropertyRequestItem = {
    list : List;
    memo : ?Blob;
    from_subaccount: ?Subaccount;
    created_at_time : ?Nat;
    action : ManageListPropertyRequestAction;
  };

  public type ManageListPropertyError = {
    #Unauthorized;
    #NotFound;
    #Exists;
    #IllegalAdmin;
    #TooManyRequests;
    #IllegalPermission;
    #Other : Text;
  };

  public type ManageListPropertyResponse = [ManageListPropertyResult];

  public type ManageListPropertyResult = ?{
    #Ok : TransactionID;
    #Err : ManageListPropertyError;
  };

  public type DataItemMap = [(Text, DataItem)];
  public type DataItemMapItem = (Text, DataItem);

  public type ManageRequest = [ManageRequestItem];

  public type ManageRequestItem = {
    #UpdateDefaultTake : Nat;
    #UpdateMaxTake : Nat;
    #UpdatePermittedDrift : Nat;
    #UpdateTxWindow : Nat;
    #UpdateOwner : Principal;
  };

  public type ManageResultError = {
    #Unauthorized;
    #TooManyRequests;
    #Other : Text;
  };

  public type TransactionID = Nat;

  public type ManageResult = ?{
    #Ok;
    #Err : ManageResultError;
  };

  public type AuthorizedRequestItem = (ListItem, [[List]]);

  public type ManageResponse = [ManageResult];

  public type ManageListMembershipRequest = [ManageListMembershipRequestItem];

  public type ManageListPropertyRequest = [ManageListPropertyRequestItem];

  public type ManageListMembershipError = {
    #Unauthorized;
    #NotFound;
    #TooManyRequests;
    #Exists;
    #Other : Text;
  };

  public type ManageListMembershipResponse = [ManageListMembershipResult];

  public type ManageListMembershipResult = ?{
    #Ok : TransactionID;
    #Err : ManageListMembershipError;
  };

  ///Mark: Interceptors

  public type CanChangeMembership = ?{
    #Sync : (<system>(trx: ICRC16.ValueShared, trxtop: ?ICRC16.ValueShared) -> Result.Result<(trx: ICRC16.ValueShared, trxtop: ?ICRC16.ValueShared), Text>);
    #Async : (<system>(trx: ICRC16.ValueShared, trxtop: ?ICRC16.ValueShared) -> async* Star.Star<(trx: ICRC16.ValueShared, trxtop: ?ICRC16.ValueShared), Text>);
  };

  public type CanChangeProperty = ?{
    #Sync : (<system>(trx: ICRC16.ValueShared, trxtop: ?ICRC16.ValueShared) -> Result.Result<(trx: ICRC16.ValueShared, trxtop: ?ICRC16.ValueShared), Text>);
    #Async : (<system>(trx: ICRC16.ValueShared, trxtop: ?ICRC16.ValueShared) -> async* Star.Star<(trx: ICRC16.ValueShared, trxtop: ?ICRC16.ValueShared), Text>);
  };

  ///MARK: Listeners

  public type PropertyChangeListener = <system>(ManageListPropertyRequestItem, trxid: Nat) -> ();

  ///MARK: Hashing and Equality

  public let domainEq = func(a: Domain, b:Domain) : Bool {
    Array.equal<Text>(a, b, Text.equal);
  };

  public func domainHash32(a : Domain) : Nat32{
    var accumulator = 0 : Nat32;
    var idx = 0;
    for(val in a.vals()){
      accumulator +%= Nat32.fromNat(idx);
      accumulator +%= BaseText.hash(val);
      idx += 1;
    };
    return accumulator;
  };

  public let domainHash = (domainHash32, domainEq);

  public func ICRC16ArrayCompare(a: [DataItem], b: [DataItem]) : Order.Order {
    let aSize = a.size();
    let bSize = b.size();
    let minSize = if (aSize < bSize) aSize else bSize;
    
    var i = 0;
    while (i < minSize) {
      switch(dataItemCompare(a[i], b[i])){
        case(#equal) {};
        case(#less) return #less;
        case(#greater) return #greater;
      };
      i += 1;
    };
    Nat.compare(aSize, bSize);
  };

  public func ICRC16MapCompare(araw: ICRC16Map, braw: ICRC16Map) : Order.Order {
    let a = Array.sort<(Text, DataItem)>(araw, func(x, y) { Text.compare(x.0, y.0) });
    let b = Array.sort<(Text, DataItem)>(braw, func(x, y) { Text.compare(x.0, y.0) });
    
    let aSize = a.size();
    let bSize = b.size();
    let minSize = if (aSize < bSize) aSize else bSize;
    
    var i = 0;
    while (i < minSize) {
      switch(Text.compare(a[i].0, b[i].0)){
        case(#equal) {};
        case(#less) return #less;
        case(#greater) return #greater;
      };
      switch(dataItemCompare(a[i].1, b[i].1)){
        case(#equal) {};
        case(#less) return #less;
        case(#greater) return #greater;
      };
      i += 1;
    };
    Nat.compare(aSize, bSize);
  };

  public func ICRC16ValueMapCompare(araw: [(DataItem, DataItem)], braw: [(DataItem, DataItem)]) : Order.Order {
    let a = Array.sort<(DataItem, DataItem)>(araw, func(x, y) { dataItemCompare(x.0, y.0) });
    let b = Array.sort<(DataItem, DataItem)>(braw, func(x, y) { dataItemCompare(x.0, y.0) });
    
    let aSize = a.size();
    let bSize = b.size();
    let minSize = if (aSize < bSize) aSize else bSize;
    
    var i = 0;
    while (i < minSize) {
      switch(dataItemCompare(a[i].0, b[i].0)){
        case(#equal) {};
        case(#less) return #less;
        case(#greater) return #greater;
      };
      switch(dataItemCompare(a[i].1, b[i].1)){
        case(#equal) {};
        case(#less) return #less;
        case(#greater) return #greater;
      };
      i += 1;
    };
    Nat.compare(aSize, bSize);
  };

  public func ICRC16SetCompare(araw: [DataItem], braw: [DataItem]) : Order.Order {
    let a = Array.sort<DataItem>(araw, dataItemCompare);
    let b = Array.sort<DataItem>(braw, dataItemCompare);
    
    let aSize = a.size();
    let bSize = b.size();
    let minSize = if (aSize < bSize) aSize else bSize;
    
    var i = 0;
    while (i < minSize) {
      switch(dataItemCompare(a[i], b[i])){
        case(#equal) {};
        case(#less) return #less;
        case(#greater) return #greater;
      };
      i += 1;
    };
    Nat.compare(aSize, bSize);
  };

  public func ICRC16ClassCompare(araw: [ICRC16.PropertyShared], braw: [ICRC16.PropertyShared]) : Order.Order {
    let a = Array.sort<ICRC16.PropertyShared>(araw, func(x, y) { Text.compare(x.name, y.name) });
    let b = Array.sort<ICRC16.PropertyShared>(braw, func(x, y) { Text.compare(x.name, y.name) });
    
    let aSize = a.size();
    let bSize = b.size();
    let minSize = if (aSize < bSize) aSize else bSize;
    
    var i = 0;
    while (i < minSize) {
      switch(Text.compare(a[i].name, b[i].name)){
        case(#equal) {};
        case(#less) return #less;
        case(#greater) return #greater;
      };
      switch(dataItemCompare(a[i].value, b[i].value)){
        case(#equal) {};
        case(#less) return #less;
        case(#greater) return #greater;
      };
      switch(Bool.compare(a[i].immutable, b[i].immutable)){
        case(#equal) {};
        case(#less) return #less;
        case(#greater) return #greater;
      };
      i += 1;
    };
    Nat.compare(aSize, bSize);
  };

  public func ICRC16OptionCompare(a: ?DataItem, b: ?DataItem) : Order.Order {
    switch(a, b){
      case(?aVal, ?bVal) return dataItemCompare(aVal, bVal);
      case(?_, null) return #greater;
      case(null, ?_) return #less;
      case(null, null) return #equal;
    };
  };

  public func floatArrayCompare(a: [Float], b: [Float]) : Order.Order {
    let aSize = a.size();
    let bSize = b.size();
    let minSize = if (aSize < bSize) aSize else bSize;
    
    var i = 0;
    while (i < minSize) {
      switch(Float.compare(a[i], b[i])){
        case(#equal) {};
        case(#less) return #less;
        case(#greater) return #greater;
      };
      i += 1;
    };
    Nat.compare(aSize, bSize);
  };

  public func intArrayCompare(a: [Int], b: [Int]) : Order.Order {
    let aSize = a.size();
    let bSize = b.size();
    let minSize = if (aSize < bSize) aSize else bSize;
    
    var i = 0;
    while (i < minSize) {
      switch(Int.compare(a[i], b[i])){
        case(#equal) {};
        case(#less) return #less;
        case(#greater) return #greater;
      };
      i += 1;
    };
    Nat.compare(aSize, bSize);
  };

  public func natArrayCompare(a: [Nat], b: [Nat]) : Order.Order {
    let aSize = a.size();
    let bSize = b.size();
    let minSize = if (aSize < bSize) aSize else bSize;
    
    var i = 0;
    while (i < minSize) {
      switch(Nat.compare(a[i], b[i])){
        case(#equal) {};
        case(#less) return #less;
        case(#greater) return #greater;
      };
      i += 1;
    };
    Nat.compare(aSize, bSize);
  };

  public func nat8ArrayCompare(a: [Nat8], b: [Nat8]) : Order.Order {
    let aSize = a.size();
    let bSize = b.size();
    let minSize = if (aSize < bSize) aSize else bSize;
    
    var i = 0;
    while (i < minSize) {
      switch(Nat8.compare(a[i], b[i])){
        case(#equal) {};
        case(#less) return #less;
        case(#greater) return #greater;
      };
      i += 1;
    };
    Nat.compare(aSize, bSize);
  };

  public func dataItemCompare(a: DataItem, b: DataItem) : Order.Order {
    switch (a, b) {
        case (#Array(aVal), #Array(bVal)) return ICRC16ArrayCompare(aVal, bVal);
        case (#Array(_), _) return #less;
        case (_, #Array(_)) return #greater;
        
        case (#Blob(aVal), #Blob(bVal)) return Blob.compare(aVal, bVal);
        case (#Blob(_), _) return #less;
        case (_, #Blob(_)) return #greater;
        
        case (#Bool(aVal), #Bool(bVal)) return Bool.compare(aVal, bVal);
        case (#Bool(_), _) return #less;
        case (_, #Bool(_)) return #greater;
        
        case (#Bytes(aVal), #Bytes(bVal)) return Blob.compare(Blob.fromArray(aVal), Blob.fromArray(bVal));
        case (#Bytes(_), _) return #less;
        case (_, #Bytes(_)) return #greater;
        
        case (#Class(aVal), #Class(bVal)) return ICRC16ClassCompare(aVal, bVal);
        case (#Class(_), _) return #less;
        case (_, #Class(_)) return #greater;
        
        case (#Float(aVal), #Float(bVal)) return Float.compare(aVal, bVal);
        case (#Float(_), _) return #less;
        case (_, #Float(_)) return #greater;
        
        case (#Floats(aVal), #Floats(bVal)) return floatArrayCompare(aVal, bVal);
        case (#Floats(_), _) return #less;
        case (_, #Floats(_)) return #greater;
        
        case (#Int(aVal), #Int(bVal)) return Int.compare(aVal, bVal);
        case (#Int(_), _) return #less;
        case (_, #Int(_)) return #greater;
        
        case (#Int16(aVal), #Int16(bVal)) return Int16.compare(aVal, bVal);
        case (#Int16(_), _) return #less;
        case (_, #Int16(_)) return #greater;
        
        case (#Int32(aVal), #Int32(bVal)) return Int32.compare(aVal, bVal);
        case (#Int32(_), _) return #less;
        case (_, #Int32(_)) return #greater;
        
        case (#Int64(aVal), #Int64(bVal)) return Int64.compare(aVal, bVal);
        case (#Int64(_), _) return #less;
        case (_, #Int64(_)) return #greater;
        
        case (#Int8(aVal), #Int8(bVal)) return Int8.compare(aVal, bVal);
        case (#Int8(_), _) return #less;
        case (_, #Int8(_)) return #greater;
        
        case (#Ints(aVal), #Ints(bVal)) return intArrayCompare(aVal, bVal);
        case (#Ints(_), _) return #less;
        case (_, #Ints(_)) return #greater;
        
        case (#Map(aVal), #Map(bVal)) return ICRC16MapCompare(aVal, bVal);
        case (#Map(_), _) return #less;
        case (_, #Map(_)) return #greater;
        
        case (#Nat(aVal), #Nat(bVal)) return Nat.compare(aVal, bVal);
        case (#Nat(_), _) return #less;
        case (_, #Nat(_)) return #greater;
        
        case (#Nat16(aVal), #Nat16(bVal)) return Nat16.compare(aVal, bVal);
        case (#Nat16(_), _) return #less;
        case (_, #Nat16(_)) return #greater;
        
        case (#Nat32(aVal), #Nat32(bVal)) return Nat32.compare(aVal, bVal);
        case (#Nat32(_), _) return #less;
        case (_, #Nat32(_)) return #greater;
        
        case (#Nat64(aVal), #Nat64(bVal)) return Nat64.compare(aVal, bVal);
        case (#Nat64(_), _) return #less;
        case (_, #Nat64(_)) return #greater;
        
        case (#Nat8(aVal), #Nat8(bVal)) return Nat8.compare(aVal, bVal);
        case (#Nat8(_), _) return #less;
        case (_, #Nat8(_)) return #greater;
        
        case (#Nats(aVal), #Nats(bVal)) return natArrayCompare(aVal, bVal);
        case (#Nats(_), _) return #less;
        case (_, #Nats(_)) return #greater;
        
        case (#Option(aVal), #Option(bVal)) return ICRC16OptionCompare(aVal, bVal);
        case (#Option(_), _) return #less;
        case (_, #Option(_)) return #greater;
        
        case (#Principal(aVal), #Principal(bVal)) return Principal.compare(aVal, bVal);
        case (#Principal(_), _) return #less;
        case (_, #Principal(_)) return #greater;
        
        case (#Set(aVal), #Set(bVal)) return ICRC16SetCompare(aVal, bVal);
        case (#Set(_), _) return #less;
        case (_, #Set(_)) return #greater;
        
        case (#Text(aVal), #Text(bVal)) return Text.compare(aVal, bVal);
        case (#Text(_), _) return #less;
        case (_, #Text(_)) return #greater;
        
        case (#ValueMap(aVal), #ValueMap(bVal)) return ICRC16ValueMapCompare(aVal, bVal);
        case (#ValueMap(_), _) return #less;
        case (_, #ValueMap(_)) return #greater;
    }
  };


  public let nullBlob : Blob = "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00";

  /// `account_hash32`
  public func account_hash32(a : Account) : Nat32 {
    var accumulator = BasePrincipal.hash(a.owner);
    switch(a.subaccount){
      case(null) {
        accumulator +%= Blob.hash(nullBlob);
      };
      case(?val) {
        accumulator +%= Blob.hash(val);
      };
    };
    return accumulator;
  };

  /// `account_eq`
  public func account_eq(a : Account, b : Account) : Bool {
    if(a.owner != b.owner) return false;
    switch(a.subaccount, b.subaccount){
      case(null, null) return true;
      case(?vala, ?valb) return vala == valb;
      case(null, ?val) return val == nullBlob;
      case(?val, null) return val == nullBlob;
    };
  };

  /// `account_compare`
  public func account_compare(a : Account, b : Account) : Order.Order {
    switch(Principal.compare(a.owner, b.owner)) {
      case(#equal) {
        switch(a.subaccount, b.subaccount){
          case(null, null) return #equal;
          case(?vala, ?valb) return Blob.compare(vala, valb);
          case(null, ?valb) {
            if(valb == nullBlob) return #equal;
            return #less;
          };
          case(?vala, null) {
            if(vala == nullBlob) return #equal;
            return #greater;
          };
        };
      };
      case(other) return other;
    };
  };

  public let ahash = (account_hash32, account_eq);

  public let listItemEq = func(a: ListItem, b: ListItem) : Bool {
    switch(a, b){
      case(#Account(aAcc), #Account(bAcc)) return account_eq(aAcc, bAcc);
      case(#Identity(aId), #Identity(bId)) return Principal.equal(aId, bId);
      case(#DataItem(aData), #DataItem(bData)) return ICRC16.eqShared(aData, bData);
      case(#List(aList), #List(bList)) return Text.equal(aList, bList);
      case(_, _) return false;
    };
  };

  public let listItemCompare = func(a: ListItem, b: ListItem) : Order.Order {
    switch(a, b){
      case(#Account(aAcc), #Account(bAcc)) return account_compare(aAcc, bAcc);
      case(#Account(_), _) return #less;
      case(_, #Account(_)) return #greater;
      case(#DataItem(aData), #DataItem(bData)) return dataItemCompare(aData, bData);
      case(#DataItem(_), _) return #less;
      case(_, #DataItem(_)) return #greater;
      case(#Identity(aId), #Identity(bId)) return Principal.compare(aId, bId);
      case(#Identity(_), _) return #less;
      case(_, #Identity(_)) return #greater;
      case(#List(aList), #List(bList)) return Text.compare(aList, bList);
    };
  };

  public func listItemHash32(a : ListItem) : Nat32 {
    switch(a){
      case(#Account(acc)) return account_hash32(acc);
      case(#Identity(id)) return BasePrincipal.hash(id);
      case(#DataItem(data)) return ICRC16.hashShared(data);
      case(#List(list)) return BaseText.hash(list);
    };
  };

  public let listItemHash = (listItemHash32, listItemEq);

  ///MARK: Core
  /// Stats contains general statistics about the ledger and approvals in the system.
  public type Stats = {
    namespaceStoreCount : Nat;
    memberIndexCount : Nat;
    permissionsIndexCount : Nat;
    cycleShareTimerID : ?Nat;
    txWindow : Nat;
    defaultTake : Nat;
    maxTake : Nat;
    permittedDrift : Nat;
    owner: Principal;
    tt: TT.Stats;
  };

  /// Environment defines the context in which the token ledger operates.
  public type Environment = {
    advanced : ?{
      icrc85 : ICRC85Options;
    };
    org_icdevs_timer_tool : TT.TimerTool;
    updated_certification : ?((CertTree.Store) -> Bool);
    get_certificate_store : ?(() -> CertTree.Store);
    addRecord: ?(<system>(Value, ?Value) -> Nat);
    icrc10_register_supported_standards : (({
        name: Text;
        url : Text;
    }) -> Bool);
  };

  /// InitArgs represents the initialization arguments for setting up an ICRC75 token canister
  public type InitArgsOption = ?InitArgs;

  public type InitArgs = {
      existingNamespaces : ?[NamespaceRecordShared];
      certificateNonce : ?Nat;
      cycleShareTimerID : ?Nat;
  };
  
  ///MARK: State

  /// State represents the entire state of the ledger, containing ledger configurations, approvals, and indices.
  /// Uses mo:core/Map and mo:core/Set instead of mo:map9
  public type State = {
    var certificateNonce: Nat;
    var cycleShareTimerID: ?Nat;
    namespaceStore : BTree.BTree<Text, NamespaceRecord>;
    memberIndex : Map.Map<ListItem, Set.Set<List>>;
    permissionsIndex : Map.Map<ListItem, Set.Set<List>>;
    var owner : Principal;
    var org_icdevs_ovs_fixed_state: OVSTypes.State;
    metadata: {
      var defaultTake: Nat;
      var maxTake: Nat;
      var permittedDrift: Nat;
      var txWindow: Nat;
      var maxQuery: Nat;
      var maxUpdate: Nat;
    };
  };
};

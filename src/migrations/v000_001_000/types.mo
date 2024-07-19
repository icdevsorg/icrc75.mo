// please do not import any types from your project outside migrations folder here
// it can lead to bugs when you change those types later, because migration types should not be changed
// you should also avoid importing these types anywhere in your project directly from here
// use MigrationTypes.Current property instead

import Array "mo:base/Array";
import Blob "mo:base/Blob";
import Bool "mo:base/Bool";
import Iter "mo:base/Iter";
import Order "mo:base/Order";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Int "mo:base/Int";

import Nat8 "mo:base/Nat8";
import Nat16 "mo:base/Nat16";
import Nat32 "mo:base/Nat32";
import Nat64 "mo:base/Nat64";
import Int8 "mo:base/Int8";
import Int16 "mo:base/Int16";
import Int32 "mo:base/Int32";
import Int64 "mo:base/Int64";
import Float "mo:base/Float";


import MapLib "mo:map9/Map";
import SetLib "mo:map9/Set";
import VecLib "mo:vector";
import Star "mo:star/star";
import BTreeLib "mo:stableheapbtreemap/BTree";

import ICRC16Lib "mo:candy/types";
import ICRC16ConversionLib "mo:candy/conversion";
import Account "mo:icrc1-mo/ICRC1/Account";

module {

  public let ONE_DAY = 86400000000000 : Nat; //NanoSeconds
  public let ONE_MINUTE = 60000000000 : Nat; //NanoSeconds

  /// Vector provides an interface to a vector-like collection.
  public let Vector = VecLib;

  /// Map provides an interface to a key-value storage collection.
  public let Map = MapLib;

  public let BTree = BTreeLib;

  public let ICRC16 = ICRC16Lib;
  public let ICRC16Conversion = ICRC16ConversionLib;

  /// Set provides an interface to a set-like collection, storing unique elements.
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

  public type ICRC16Map = [(Text, DataItem)];

  public type ICRC85Options = {
    kill_switch: ?Bool;
    handler: ?(([(Text, Nat, ICRC16Map)]) -> ());
    period: ?Nat;
    tree: ?[Text];
    collector: ?Principal;
  };

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
    members : Set.Set<ListItem>;
    metadata : ICRC16Map;
  };

  public type NamespaceRecordShared = {
    namespace : Text;
    permissions : PermissionList;
    members : [ListItem];
    metadata : ICRC16Map;
  };

  public type Domain = [Text];

  public type ManageListMembershipAction = {
    #Add : ListItem;
    #Remove : ListItem;
  };

  public type ManageListMembershipRequestItem = {
    list : List;
    memo : ?Blob;
    created_at_time : ?Nat;
    from_subaccount : ?Blob;
    action : ManageListMembershipAction;
  };

  public type ManageListPropertyRequestAction = {
    #Create : {
      admin : ?ListItem;
      metadata : ICRC16Map;
      members : [ListItem];
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
    created_at_time : ?Nat;
    from_subaccount : ?Blob;
    action : ManageListPropertyRequestAction;
  };

  public type ManageListPropertyError = {
    #Unauthorized;
    #NotFound;
    #Exists;
    #IllegalAdmin;
    #IllegalPermission;
    #Other : Text;
  };

  public type ManageListPropertyResponse = [ManageListPropertyResult];

  public type ManageListPropertyResult = ?{
    #Ok : TransactionID;
    #Err : ManageListPropertyError;
  };


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

  public type ManageListPropertiesRequest = [ManageListPropertyRequestItem];

  public type ManageListMembershipError = {
    #Unauthorized;
    #NotFound;
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

  public type MembershipChangeListener = <system>(ManageListMembershipRequestItem, trxid: Nat) -> ();

  public type PropertyChangeListener = <system>(ManageListPropertyRequestItem, trxid: Nat) -> ();

  ///MARK: Hashing and Equality

  public let domainEq = func(a: Domain, b:Domain) : Bool {
    Array.equal<Text>(a,b, Text.equal);
  };

  public func domainHash32(a : Domain) : Nat32{
    var accumulator = 0 : Nat32;
    var idx = 0;
    for(val in a.vals()){
      accumulator +%= Map.nhash.0(idx);
      accumulator +%= Map.thash.0(val);
      idx += 1;
    };
    return accumulator;
  };

  public let domainHash = (domainHash32, domainEq);

  public func ICRC16ArrayCompare(a: [DataItem], b: [DataItem]) : Order.Order {
    
    for(i in Iter.range(0, a.size()-1)){
      switch(dataItemCompare(a[i],b[i])){
        case(#equal){};
        case(#less) return #less;
        case(#greater) return #greater;
      };
    };
    if(a.size() > b.size())
      return #greater;
    if(a.size() < b.size())
      return #less;
    return #equal;
  };

  public func ICRC16MapCompare(araw: ICRC16Map, braw: ICRC16Map) : Order.Order {

    //sort by key
    let a = Array.sort<(Text, DataItem)>(araw, func(a,b){
      Text.compare(a.0,b.0);
    });
    let b = Array.sort<(Text, DataItem)>(braw, func(a,b){
      Text.compare(a.0,b.0);
    });
    
    for(i in Iter.range(0, a.size()-1)){
      switch(Text.compare(a[i].0,b[i].0)){
        case(#equal){};
        case(#less) return #less;
        case(#greater) return #greater;
      };
      switch(dataItemCompare(a[i].1,b[i].1)){
        case(#equal){};
        case(#less) return #less;
        case(#greater) return #greater;
      };
    };
    if(a.size() > b.size())
      return #greater;
    if(a.size() < b.size())
      return #less;
    return #equal;
  };

  public func ICRC16ValueMapCompare(araw: [(DataItem, DataItem)], braw: [(DataItem,DataItem)]) : Order.Order {

    //sort by key
    let a = Array.sort<(DataItem, DataItem)>(araw, func(a,b){
      dataItemCompare(a.0,b.0);
    });
    let b = Array.sort<(DataItem, DataItem)>(braw, func(a,b){
      dataItemCompare(a.0,b.0);
    });
    
    for(i in Iter.range(0, a.size()-1)){
      switch(dataItemCompare(a[i].0,b[i].0)){
        case(#equal){};
        case(#less) return #less;
        case(#greater) return #greater;
      };
      switch(dataItemCompare(a[i].1,b[i].1)){
        case(#equal){};
        case(#less) return #less;
        case(#greater) return #greater;
      };
    };
    if(a.size() > b.size())
      return #greater;
    if(a.size() < b.size())
      return #less;
    return #equal;
  };

  public func ICRC16SetCompare(araw: [DataItem], braw: [DataItem]) : Order.Order {
    //sort by key
    let a = Array.sort<DataItem>(araw, func(a,b){
      dataItemCompare(a,b);
    });
    let b = Array.sort<DataItem>(braw, func(a,b){
      dataItemCompare(a,b);
    });
    
    for(i in Iter.range(0, a.size()-1)){
      switch(dataItemCompare(a[i],b[i])){
        case(#equal){};
        case(#less) return #less;
        case(#greater) return #greater;
      };
    };
    if(a.size() > b.size())
      return #greater;
    if(a.size() < b.size())
      return #less;
    return #equal;
  };

  public func ICRC16ClassCompare(araw: [ICRC16.PropertyShared], braw: [ICRC16.PropertyShared]) : Order.Order {

        //sort by key
    let a = Array.sort<ICRC16.PropertyShared>(araw, func(a,b){
      Text.compare(a.name,b.name);
    });
    let b = Array.sort<ICRC16.PropertyShared>(braw, func(a,b){
      Text.compare(a.name,b.name);
    });
    
    for(i in Iter.range(0, a.size()-1)){
      switch(Text.compare(a[i].name,b[i].name)){
        case(#equal){};
        case(#less) return #less;
        case(#greater) return #greater;
      };
      switch(dataItemCompare(a[i].value,b[i].value)){
        case(#equal){};
        case(#less) return #less;
        case(#greater) return #greater;
      };
      switch(Bool.compare(a[i].immutable,b[i].immutable)){
        case(#equal){};
        case(#less) return #less;
        case(#greater) return #greater;
      };
    };
    if(a.size() > b.size())
      return #greater;
    if(a.size() < b.size())
      return #less;
    return #equal;
  };

  public func ICRC16OptionCompare(a: ?DataItem, b: ?DataItem) : Order.Order {
    switch(a,b){
      case(?a, ?b) return dataItemCompare(a,b);
      case(?a, null) return #greater;
      case(null, ?b) return #less;
      case(null, null) return #equal;
    };
  };

  public func floatArrayCompare(a: [Float], b: [Float]) : Order.Order {
    for(i in Iter.range(0, a.size()-1)){
      switch(Float.compare(a[i],b[i])){
        case(#equal){};
        case(#less) return #less;
        case(#greater) return #greater;
      };
    };
    if(a.size() > b.size())
      return #greater;
    if(a.size() < b.size())
      return #less;
    return #equal;
  };

  public func intArrayCompare(a: [Int], b: [Int]) : Order.Order {
    for(i in Iter.range(0, a.size()-1)){
      switch(Int.compare(a[i],b[i])){
        case(#equal){};
        case(#less) return #less;
        case(#greater) return #greater;
      };
    };
    if(a.size() > b.size())
      return #greater;
    if(a.size() < b.size())
      return #less;
    return #equal;
  };  

  public func natArrayCompare(a: [Nat], b: [Nat]) : Order.Order {
    for(i in Iter.range(0, a.size()-1)){
      switch(Nat.compare(a[i],b[i])){
        case(#equal){};
        case(#less) return #less;
        case(#greater) return #greater;
      };
    };
    if(a.size() > b.size())
      return #greater;
    if(a.size() < b.size())
      return #less;
    return #equal;
  };

  public func nat8ArrayCompare(a: [Nat8], b: [Nat8]) : Order.Order {
    for(i in Iter.range(0, a.size()-1)){
      switch(Nat8.compare(a[i],b[i])){
        case(#equal){};
        case(#less) return #less;
        case(#greater) return #greater;
      };
    };
    if(a.size() > b.size())
      return #greater;
    if(a.size() < b.size())
      return #less;
    return #equal;
  };

  public func dataItemCompare(a: DataItem, b: DataItem) : Order.Order {
    switch (a, b) {
        case (#Array(a), #Array(b)) return ICRC16ArrayCompare(a,b);
        case (#Array(_), _) return #less;
        case (_, #Array(_)) return #greater;
        
        case (#Blob(a), #Blob(b)) return Blob.compare(a,b);
        case (#Blob(_), _) return #less;
        case (_, #Blob(_)) return #greater;
        
        case (#Bool(a), #Bool(b)) return Bool.compare(a,b);
        case (#Bool(_), _) return #less;
        case (_, #Bool(_)) return #greater;
        
        case (#Bytes(a), #Bytes(b)) return Blob.compare(Blob.fromArray(a),Blob.fromArray(b));
        case (#Bytes(_), _) return #less;
        case (_, #Bytes(_)) return #greater;
        
        case (#Class(a), #Class(b)) return  ICRC16ClassCompare(a,b);
        case (#Class(_), _) return #less;
        case (_, #Class(_)) return #greater;
        
        case (#Float(a), #Float(b)) return Float.compare(a,b);
        case (#Float(_), _) return #less;
        case (_, #Float(_)) return #greater;
        
        case (#Floats(a), #Floats(b)) return floatArrayCompare(a,b);
        case (#Floats(_), _) return #less;
        case (_, #Floats(_)) return #greater;
        
        case (#Int(a), #Int(b)) return Int.compare(a,b);
        case (#Int(_), _) return #less;
        case (_, #Int(_)) return #greater;
        
        case (#Int16(a), #Int16(b)) return  Int16.compare(a,b);
        case (#Int16(_), _) return #less;
        case (_, #Int16(_)) return #greater;
        
        case (#Int32(a), #Int32(b)) return Int32.compare(a,b);
        case (#Int32(_), _) return #less;
        case (_, #Int32(_)) return #greater;
        
        case (#Int64(a), #Int64(b)) return Int64.compare(a,b);
        case (#Int64(_), _) return #less;
        case (_, #Int64(_)) return #greater;
        
        case (#Int8(a), #Int8(b)) return Int8.compare(a,b);
        case (#Int8(_), _) return #less;
        case (_, #Int8(_)) return #greater;
        
        case (#Ints(a), #Ints(b)) return intArrayCompare(a,b);
        case (#Ints(_), _) return #less;
        case (_, #Ints(_)) return #greater;
        
        case (#Map(a), #Map(b)) return ICRC16MapCompare(a,b);
        case (#Map(_), _) return #less;
        case (_, #Map(_)) return #greater;
        
        case (#Nat(a), #Nat(b)) return  Nat.compare(a,b);
        case (#Nat(_), _) return #less;
        case (_, #Nat(_)) return #greater;
        
        case (#Nat16(a), #Nat16(b)) return Nat16.compare(a,b);
        case (#Nat16(_), _) return #less;
        case (_, #Nat16(_)) return #greater;
        
        case (#Nat32(a), #Nat32(b)) return  Nat32.compare(a,b);
        case (#Nat32(_), _) return #less;
        case (_, #Nat32(_)) return #greater;
        
        case (#Nat64(a), #Nat64(b)) return  Nat64.compare(a,b);
        case (#Nat64(_), _) return #less;
        case (_, #Nat64(_)) return #greater;
        
        case (#Nat8(a), #Nat8(b)) return  Nat8.compare(a,b);
        case (#Nat8(_), _) return #less;
        case (_, #Nat8(_)) return #greater;
        
        case (#Nats(a), #Nats(b)) return natArrayCompare(a,b);
        case (#Nats(_), _) return #less;
        case (_, #Nats(_)) return #greater;
        
        case (#Option(a), #Option(b)) return  ICRC16OptionCompare(a,b);
        case (#Option(_), _) return #less;
        case (_, #Option(_)) return #greater;
        
        case (#Principal(a), #Principal(b)) return  Principal.compare(a,b);
        case (#Principal(_), _) return #less;
        case (_, #Principal(_)) return #greater;
        
        case (#Set(a), #Set(b)) return  ICRC16SetCompare(a,b);
        case (#Set(_), _) return #less;
        case (_, #Set(_)) return #greater;
        
        case (#Text(a), #Text(b)) return  Text.compare(a,b);
        case (#Text(_), _) return #less;
        case (_, #Text(_)) return #greater;
        
        case (#ValueMap(a), #ValueMap(b)) return #equal;
        case (#ValueMap(_), _) return #less;
        case (_, #ValueMap(_)) return #greater;
    }
  };


  /// `account_hash32`
  ///
  /// Produces a 32-bit hash of an `Account` for efficient storage or lookups.
  ///
  /// Parameters:
  /// - `a`: The `Account` to hash.
  ///
  /// Returns:
  /// - `Nat32`: A 32-bit hash value representing the account.
  public func account_hash32(a : Account) : Nat32{
    var accumulator = Map.phash.0(a.owner);
    switch(a.subaccount){
      case(null){
        accumulator +%= Map.bhash.0(nullBlob);
      };
      case(?val){
        accumulator +%= Map.bhash.0(val);
      };
    };
    return accumulator;
  };

  let nullBlob  : Blob = "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00";

  /// `account_eq`
  ///
  /// Compares two `Account` instances for equality.
  ///
  /// Parameters:
  /// - `a`: First `Account` to compare.
  /// - `b`: Second `Account` to compare.
  ///
  /// Returns:
  /// - `Bool`: True if accounts are equal, False otherwise.
  public func account_eq(a : Account, b : Account) : Bool{
    
    if(a.owner != b.owner) return false;
    switch(a.subaccount, b.subaccount){
      case(null, null){};
      case(?vala, ?valb){
        if(vala != valb) return false;
      };
      case(null,?val){
        if(not(nullBlob == val)){
          return false;
        }
      };
      case(?val,null){
        if(not(nullBlob == val)){
          return false;
        }
      };
    };
    return true;
  };

  /// `account_compare`
  ///
  /// Orders two `Account` instances.
  ///
  /// Parameters:
  /// - `a`: First `Account` to compare.
  /// - `b`: Second `Account` to compare.
  ///
  /// Returns:
  /// - `Order.Order`: An ordering indication relative to the accounts.
  public func account_compare(a : Account, b : Account) : Order.Order {
    if(a.owner == b.owner){
      switch(a.subaccount, b.subaccount){
        case(null, null) return #equal;
        case(?vala, ?valb) return Blob.compare(vala,valb);
        case(null, ?valb){
          if(valb == nullBlob) return #equal;
         return #less;
        };
        case(?vala, null){
          if(vala == nullBlob) return #equal;
          return #greater;
        }
      };
    } else return Principal.compare(a.owner, b.owner);
  };

  public let ahash = (account_hash32, account_eq);

  public let listItemEq = func(a: ListItem, b:ListItem) : Bool {
    switch(a, b){
      case(#Account(a), #Account(b)) {
        return account_eq(a,b);
      };
      case(#Identity(a), #Identity(b)) {
        return Principal.equal(a,b);
      };
      case(#DataItem(a), #DataItem(b)) {
        return ICRC16.eqShared(a,b);
      };
      case(#List(a), #List(b)) {
        return Text.equal(a,b);
      };
      //todo: is an accunt with a null subaccount equal to an identity?
      case(_, _) {
        return false;
      };
    };
  };



  public let listItemCompare = func(a: ListItem, b:ListItem) : Order.Order {
    switch(a, b){
      case(#Account(a), #Account(b)) {
        return account_compare(a,b);
      };
      case(#Account(_), _) return #less;
      case(_, #Account(_)) return #greater;
      case(#DataItem(a), #DataItem(b)) {
        return dataItemCompare(a,b);
      };
      case(#DataItem(_), _) return #less;
      case(_, #DataItem(_)) return #greater;
      case(#Identity(a), #Identity(b)) {
        return Principal.compare(a,b);
      };
      case(#Identity(_), _) return #less;
      case(_, #Identity(_)) return #greater;
      case(#List(a), #List(b)) {
        return Text.compare(a,b);
      };
    };
  };

  public func listItemHash32(a : ListItem) : Nat32{

    switch(a){
      case(#Account(a)) {
        return account_hash32(a);
      };
      case(#Identity(a)) {
        return Map.phash.0(a);
      };
      case(#DataItem(a)) {
        return ICRC16.hashShared(a);
      };
      case(#List(a)) {
        return Map.thash.0(a);
      };
    };
    
  };

  public let listItemHash = (listItemHash32, listItemEq);

  ///MARK: Core
    /// Stats contains general statistics about the ledger and approvals in the system.
  public type Stats = {
    /// Shared ledger info with configurations.
    namespaceStoreCount : Nat;
    memberIndexCount : Nat;
    permissionsIndexCount : Nat;
    //fee : Fee;

    txWindow : Nat;

    defaultTake : Nat;
    maxTake : Nat;
    permittedDrift : Nat;
    owner: Principal;
  };


  /// Environment defines the context in which the token ledger operates.
  public type Environment = {
    /// Reference to the ICRC-1 ledger interface.
    advanced : ?{
      ICRC85 : ICRC85Options;
    };
    addRecord: ?(<system>(Value, ?Value) -> Nat);
    icrc10_register_supported_standards : (({
        name: Text;
        url : Text;
    }) -> Bool);
  };



  /// InitArgs represents the initialization arguments for setting up an ICRC1 token canister that includes ICRC4 standards.
  public type InitArgs = ?{
      existingNamespaces : ?[NamespaceRecordShared];
  };
  

  ///MARK: State

  /// State represents the entire state of the ledger, containing ledger configurations, approvals, and indices.
  public type State = {
    namespaceStore : BTree.BTree<Text, NamespaceRecord>;
    //upgrade these to btree later
    memberIndex : Map.Map<ListItem, Set.Set<List>>;
    permissionsIndex : Map.Map<ListItem, Set.Set<List>>;
    var owner : Principal;
    metadata: {
      var defaultTake: Nat;
      var maxTake: Nat;
      var permittedDrift: Nat;
      var txWindow: Nat;
    };
  };
};
// please do not import any types from your project outside migrations folder here
// it can lead to bugs when you change those types later, because migration types should not be changed
// you should also avoid importing these types anywhere in your project directly from here
// use MigrationTypes.Current property instead


import Blob "mo:base/Blob";
import Bool "mo:base/Bool";

import Principal "mo:base/Principal";

import Text "mo:base/Text";
import Nat "mo:base/Nat";

import MapLib "mo:map9/Map";
import SetLib "mo:map9/Set";
import VecLib "mo:vector";
import BTreeLib "mo:stableheapbtreemap/BTree";
import CertTree "mo:ic-certification/CertTree";

import ICRC16Lib "mo:candy/types";
import ICRC16ConversionLib "mo:candy/conversion";
import TT "mo:timer-tool";

import v0_1_0Types "../v000_001_000/types";

module {


  ///MARK: Modified types

  public type ManageListPropertyError = {
    #Unauthorized;
    #NotFound;
    #Exists;
    #IllegalAdmin;
    #TooManyRequests;
    #IllegalPermission;
    #Other : Text;
  };

  public type ManageResultError = {
    #Unauthorized;
    #TooManyRequests;
    #Other : Text;
  };

    public type ManageListMembershipResult = ?{
    #Ok : TransactionID;
    #Err : ManageListMembershipError;
  };



  //Mark: No Change

  public let ONE_DAY = v0_1_0Types.ONE_DAY; //NanoSeconds
  public let ONE_MINUTE = v0_1_0Types.ONE_MINUTE : Nat; //NanoSeconds

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
  public type Account = v0_1_0Types.Account;
  public type DataItem = v0_1_0Types.DataItem;
  public type Value = v0_1_0Types.Value;
  public type List = v0_1_0Types.List;
  public type ListRecord = v0_1_0Types.ListRecord;
  public type ListItem = v0_1_0Types.ListItem;
  public type Subaccount = v0_1_0Types.Subaccount;
  public type Permission = v0_1_0Types.Permission;
  public type ICRC16Map = v0_1_0Types.ICRC16Map;
  public type ICRC16MapItem = v0_1_0Types.ICRC16MapItem;
  public type ICRC85Options = v0_1_0Types.ICRC85Options;
  public type PermissionCollection = v0_1_0Types.PermissionCollection;
  public type PermissionList = v0_1_0Types.PermissionList;
  public type PermissionListItem = v0_1_0Types.PermissionListItem;
  public type NamespaceRecord = v0_1_0Types.NamespaceRecord;
  public type NamespaceRecordShared = v0_1_0Types.NamespaceRecordShared;
  public type Domain = v0_1_0Types.Domain;
  public type ManageListMembershipAction = v0_1_0Types.ManageListMembershipAction;
  public type ManageListMembershipRequestItem = v0_1_0Types.ManageListMembershipRequestItem;
  public type ManageListPropertyRequestAction = v0_1_0Types.ManageListPropertyRequestAction;
  public type ManageListPropertyRequestItem = v0_1_0Types.ManageListPropertyRequestItem;
  public type ManageListPropertyResponse = [ManageListPropertyResult];

  public type ManageListPropertyResult = ?{
    #Ok : TransactionID;
    #Err : ManageListPropertyError;
  };



  public type ManageRequest = v0_1_0Types.ManageRequest;

  public type ManageRequestItem = v0_1_0Types.ManageRequestItem;

  public type TransactionID = v0_1_0Types.TransactionID;

  public type ManageResult = ?{
    #Ok;
    #Err : ManageResultError;
  };

  public type AuthorizedRequestItem = v0_1_0Types.AuthorizedRequestItem;

  public type ManageResponse = [ManageResult];

  public type ManageListMembershipRequest = v0_1_0Types.ManageListMembershipRequest;

  public type ManageListPropertyRequest = v0_1_0Types.ManageListPropertyRequest;  



  public type ManageListMembershipResponse = [ManageListMembershipResult];



  public type ManageListMembershipError = {
    #Unauthorized;
    #NotFound;
    #TooManyRequests;
    #Exists;
    #Other : Text;
  };

  ///Mark: Interceptors

  public type CanChangeMembership = v0_1_0Types.CanChangeMembership;

  public type CanChangeProperty = v0_1_0Types.CanChangeProperty;

  ///MARK: Listeners

  public type MembershipChangeListener = v0_1_0Types.MembershipChangeListener;

  public type PropertyChangeListener = v0_1_0Types.PropertyChangeListener;

  ///MARK: Hashing and Equality

  public let domainEq = v0_1_0Types;

  public let domainHash32 = v0_1_0Types.domainHash32;

  public let domainHash = v0_1_0Types.domainHash;

  public let ICRC16ArrayCompare = v0_1_0Types.ICRC16ArrayCompare;

  public let ICRC16MapCompare = v0_1_0Types.ICRC16MapCompare;

  public let ICRC16ValueMapCompare = v0_1_0Types.ICRC16ValueMapCompare;

  public let ICRC16SetCompare = v0_1_0Types.ICRC16SetCompare;

  public let ICRC16ClassCompare= v0_1_0Types.ICRC16ClassCompare;

  public let ICRC16OptionCompare = v0_1_0Types.ICRC16OptionCompare;

  public let floatArrayCompare = v0_1_0Types.floatArrayCompare;

  public let intArrayCompare = v0_1_0Types.intArrayCompare;  

  public let natArrayCompare = v0_1_0Types.natArrayCompare;

  public let nat8ArrayCompare = v0_1_0Types.nat8ArrayCompare;

  public let dataItemCompare = v0_1_0Types.dataItemCompare;


  /// `account_hash32`
  ///
  /// Produces a 32-bit hash of an `Account` for efficient storage or lookups.
  ///
  /// Parameters:
  /// - `a`: The `Account` to hash.
  ///
  /// Returns:
  /// - `Nat32`: A 32-bit hash value representing the account.
  public let  account_hash32 = v0_1_0Types.account_hash32;

  public let nullBlob  : Blob = "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00";

  public let account_eq = v0_1_0Types.account_eq;
  public let account_compare = v0_1_0Types.account_compare;

  public let ahash = v0_1_0Types.ahash;

  public let listItemEq = v0_1_0Types.listItemEq;
  public let listItemCompare = v0_1_0Types.listItemCompare;

  public let listItemHash32 = v0_1_0Types.listItemHash32;

  public let listItemHash = v0_1_0Types.listItemHash;

  ///MARK: Core
    /// Stats contains general statistics about the ledger and approvals in the system.
  public type Stats = {
    /// Shared ledger info with configurations.
    namespaceStoreCount : Nat;
    memberIndexCount : Nat;
    permissionsIndexCount : Nat;
    //fee : Fee;

    txWindow : Nat;
    cycleShareTimerID : ?Nat;

    defaultTake : Nat;
    maxTake : Nat;
    permittedDrift : Nat;
    owner: Principal;
    tt: TT.Stats;
  };


  /// Environment defines the context in which the token ledger operates.
  public type Environment = {
    /// Reference to the ICRC-1 ledger interface.
    advanced : ?{
      icrc85 : ICRC85Options;
      
    };
    tt : ?TT.TimerTool;
    updated_certification : ?((CertTree.Store) -> Bool); //called when a certification has been made
    get_certificate_store : ?(() -> CertTree.Store); //needed to pass certificate store to the class
    addRecord: ?(<system>(Value, ?Value) -> Nat);
    icrc10_register_supported_standards : (({
        name: Text;
        url : Text;
    }) -> Bool);
  };



  /// InitArgs represents the initialization arguments for setting up an ICRC75 token canister
  public type InitArgs = ?{
      existingNamespaces : ?[NamespaceRecordShared];
      certificateNonce : ?Nat;
      cycleShareTimerID : ?Nat;
  };
  

  ///MARK: State

  /// State represents the entire state of the ledger, containing ledger configurations, approvals, and indices.
  public type State = {
    //new members
    var certificateNonce: Nat;
    var cycleShareTimerID: ?Nat;
    //old members
    namespaceStore : BTree.BTree<Text, NamespaceRecord>;
    //upgrade these to btree later
    memberIndex : Map.Map<ListItem, Set.Set<List>>;
    permissionsIndex : Map.Map<ListItem, Set.Set<List>>;
    var owner : Principal;
    icrc85: {
      var nextCycleActionId: ?Nat;
      var lastActionReported: ?Nat;
      var activeActions: Nat;
    };
    metadata: {
      var defaultTake: Nat;
      var maxTake: Nat;
      var permittedDrift: Nat;
      var txWindow: Nat;

      //new members
      var maxQuery: Nat;
      var maxUpdate: Nat;

    };
    var tt : ?TT.State;
  };
};
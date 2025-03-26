// please do not import any types from your project outside migrations folder here
// it can lead to bugs when you change those types later, because migration types should not be changed
// you should also avoid importing these types anywhere in your project directly from here
// use MigrationTypes.Current property instead


import Blob "mo:base/Blob";
import Bool "mo:base/Bool";

import Principal "mo:base/Principal";

import Text "mo:base/Text";
import Nat "mo:base/Nat";

import SetLib "mo:map9/Set";
import VecLib "mo:vector";
import CertTree "mo:ic-certification/CertTree";
import TT "mo:timer-tool";

import v0_1_1Types "../v000_001_001/types";

module {

  public let Map = v0_1_1Types.Map;
  public let BTree = v0_1_1Types.BTree;
  public let Set = v0_1_1Types.Set;
  public let Vector = v0_1_1Types.Vector;



  ///MARK: Modified types

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

  //Mark: No Change

  public let ONE_DAY = v0_1_1Types.ONE_DAY; //NanoSeconds
  public let ONE_MINUTE = v0_1_1Types.ONE_MINUTE : Nat; //NanoSeconds



  /// Set provides an interface to a set-like collection, storing unique elements.
  public type Identity = v0_1_1Types.Identity;
  public type Account = v0_1_1Types.Account;
  public type DataItem = v0_1_1Types.DataItem;
  public type Value = v0_1_1Types.Value;
  public type List = v0_1_1Types.List;
  public type ListRecord = v0_1_1Types.ListRecord;
  public type ListItem = v0_1_1Types.ListItem;
  public type Subaccount = v0_1_1Types.Subaccount;
  public type Permission = v0_1_1Types.Permission;
  public type ICRC16 = v0_1_1Types.DataItem;
  public type ICRC16Map = v0_1_1Types.ICRC16Map;
  public type ICRC16MapItem = v0_1_1Types.ICRC16MapItem;
  public type ICRC85Options = v0_1_1Types.ICRC85Options;
  public type PermissionCollection = v0_1_1Types.PermissionCollection;
  public type PermissionList = v0_1_1Types.PermissionList;
  public type PermissionListItem = v0_1_1Types.PermissionListItem;
  public type Domain = v0_1_1Types.Domain;
  public type DataItemMap = [(Text, DataItem)];
  public type DataItemMapItem = (Text, DataItem);

  public type ManageListPropertyResponse = [ManageListPropertyResult];

  public type ManageListPropertyResult = ?{
    #Ok : TransactionID;
    #Err : ManageListPropertyError;
  };



  public type ManageRequest = v0_1_1Types.ManageRequest;

  public type ManageRequestItem = v0_1_1Types.ManageRequestItem;

  public type TransactionID = v0_1_1Types.TransactionID;

  public type ManageResult = ?{
    #Ok;
    #Err : ManageResultError;
  };

  public type AuthorizedRequestItem = v0_1_1Types.AuthorizedRequestItem;

  public type ManageResponse = [ManageResult];

  public type ManageListMembershipRequest = v0_1_1Types.ManageListMembershipRequest;

   public type ManageListPropertyRequestItem = {
    list : List;
    memo : ?Blob;
    from_subaccount: ?Subaccount;
    created_at_time : ?Nat;
    action : ManageListPropertyRequestAction;
  };

  public type ManageListPropertyRequest = [ManageListPropertyRequestItem]; 



  public type ManageListMembershipResponse = [ManageListMembershipResult];



  public type ManageListMembershipError = {
    #Unauthorized;
    #NotFound;
    #TooManyRequests;
    #Exists;
    #Other : Text;
  };

  public type ManageListPropertyError = v0_1_1Types.ManageListPropertyError;

  public type ManageResultError = v0_1_1Types.ManageResultError;

  public type ManageListMembershipResult = v0_1_1Types.ManageListMembershipResult;
  ///Mark: Interceptors

  public type CanChangeMembership = v0_1_1Types.CanChangeMembership;

  public type CanChangeProperty = v0_1_1Types.CanChangeProperty;

  ///MARK: Listeners

  

  public type PropertyChangeListener = <system>(ManageListPropertyRequestItem, trxid: Nat) -> ();
  ///MARK: Hashing and Equality

  public let domainEq = v0_1_1Types;

  public let domainHash32 = v0_1_1Types.domainHash32;

  public let domainHash = v0_1_1Types.domainHash;

  public let ICRC16ArrayCompare = v0_1_1Types.ICRC16ArrayCompare;

  public let ICRC16MapCompare = v0_1_1Types.ICRC16MapCompare;

  public let ICRC16ValueMapCompare = v0_1_1Types.ICRC16ValueMapCompare;

  public let ICRC16SetCompare = v0_1_1Types.ICRC16SetCompare;

  public let ICRC16ClassCompare= v0_1_1Types.ICRC16ClassCompare;

  public let ICRC16OptionCompare = v0_1_1Types.ICRC16OptionCompare;

  public let floatArrayCompare = v0_1_1Types.floatArrayCompare;

  public let intArrayCompare = v0_1_1Types.intArrayCompare;  

  public let natArrayCompare = v0_1_1Types.natArrayCompare;

  public let nat8ArrayCompare = v0_1_1Types.nat8ArrayCompare;

  public let dataItemCompare = v0_1_1Types.dataItemCompare;


  /// `account_hash32`
  ///
  /// Produces a 32-bit hash of an `Account` for efficient storage or lookups.
  ///
  /// Parameters:
  /// - `a`: The `Account` to hash.
  ///
  /// Returns:
  /// - `Nat32`: A 32-bit hash value representing the account.
  public let  account_hash32 = v0_1_1Types.account_hash32;

  public let nullBlob  : Blob = v0_1_1Types.nullBlob;

  public let account_eq = v0_1_1Types.account_eq;
  public let account_compare = v0_1_1Types.account_compare;

  public let ahash = v0_1_1Types.ahash;

  public let listItemEq = v0_1_1Types.listItemEq;
  public let listItemCompare = v0_1_1Types.listItemCompare;

  public let listItemHash32 = v0_1_1Types.listItemHash32;

  public let listItemHash = v0_1_1Types.listItemHash;

  ///MARK: Core
    /// Stats contains general statistics about the ledger and approvals in the system.
  public type Stats = v0_1_1Types.Stats;


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
  public type InitArgsOption = ?InitArgs;

  /// InitArgs represents the initialization arguments for setting up an ICRC75 token canister
  public type InitArgs = {
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
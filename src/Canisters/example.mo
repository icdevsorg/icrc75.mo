///This is a naieve implementation and shows the minimum possible implementation. It does not provide archiving and will not scale.

import Array "mo:base/Array";
import ExperimentalCycles "mo:base/ExperimentalCycles";
import Principal "mo:base/Principal";
import Text "mo:base/Text";
import Timer "mo:base/Timer";
import CertTree "mo:ic-certification/CertTree";
import Candid "mo:candy/candid";
import ClassPlus "mo:class-plus";
import D "mo:base/Debug";
import TT "mo:timer-tool";




import ICRC75 "..";
import Service "../service"

shared ({ caller = _originalCaller }) persistent actor class ICRC75List  (
    init_args75 : ?ICRC75.InitArgs
) = this{

  transient let Set = ICRC75.Set;
  transient let Vector = ICRC75.Vector;

  stable var _owner = _originalCaller;

  transient let initManager = ClassPlus.ClassPlusInitializationManager(_owner, Principal.fromActor(this), true);

    
    stable var icrc10 : ICRC75.Set.Set<(ICRC10Record)> = ICRC75.Set.empty();

    type ICRC10Record = {name:Text; url:Text};

    func icrc10Compare(a: ICRC10Record, b: ICRC10Record): {#less; #equal; #greater}{
      switch(Text.compare(a.name, b.name)){
        case(#equal) Text.compare(a.url, b.url);
        case(other) other;
      };
    };

    stable let fakeLedger = Vector.new<ICRC75.Value>(); //maintains insertion order

    private func fakeledgerAddRecord<system>(trx: ICRC75.Value, trxTop: ?ICRC75.Value) : Nat {

      let finalMap = switch(trxTop){
        case(?#Map(top)) {
          let combined = Array.append<(Text, ICRC75.Value)>(top, [("tx",trx)]);
          #Map(combined);
        };
        case(_) {
          #Map([("op",trx)]);
        };
      };
      Vector.add(fakeLedger, finalMap);
      Vector.size(fakeLedger) - 1;
    };

    stable var icrc75MigrationState : ICRC75.State = ICRC75.Migration.migration.initialState;

    // TimerTool state and initialization
    stable var ttMigrationState : TT.State = TT.initialState();

    transient let tt = TT.Init({
      org_icdevs_class_plus_manager = initManager;
      initialState = ttMigrationState;
      args = null;
      pullEnvironment = ?(func() : TT.Environment {
        {
          advanced = null;
          reportExecution = null;
          reportError = null;
          syncUnsafe = null;
          reportBatch = null;
        }
      });
      onInitialize = ?(func(newClass: TT.TimerTool) : async* () {
        D.print("TimerTool initialized");
        newClass.initialize<system>();
      });
      onStorageChange = func(state: TT.State) {
        ttMigrationState := state;
      };
    });

    stable let cert_store : CertTree.Store = CertTree.newStore();
    transient let ct = CertTree.Ops(cert_store);

    private func getCertStore() : CertTree.Store {
      
      return cert_store;
    };

    transient let icrc75 = ICRC75.Init({
      org_icdevs_class_plus_manager = initManager;
      initialState = icrc75MigrationState;
      args= init_args75;
      pullEnvironment = ?(func() : ICRC75.Environment{
        {
          advanced = null;
          org_icdevs_timer_tool = tt();
          updated_certification = null; //called when a certification has been made
          get_certificate_store = ?getCertStore; //needed to pass certificate store to the class
          addRecord = ?fakeledgerAddRecord;
          icrc10_register_supported_standards = func(a : ICRC10Record): Bool {
            ignore ICRC75.Set.add(icrc10, icrc10Compare, a);
            true;
          };
        }
      });
      onInitialize = ?(func(newClass: ICRC75.ICRC75) : async*(){
        D.print("ICRC75 initialized");
      });
      onStorageChange = func(state: ICRC75.State){
        icrc75MigrationState := state;
      }
    });



    ignore ICRC75.Set.add(icrc10, icrc10Compare, ({name ="ICRC-10"; url = "https://github.com/dfinity/ICRC/ICRCs/ICRC-10"}));


  

  public query func icrc75_get_stats() : async ICRC75.Stats {
    return icrc75().get_stats();
  };

  public query func get_cycle_balance() : async Nat {
    return ExperimentalCycles.balance();
  };

  public query func icrc10_supported_standards() : async [ICRC10Record] {
    return ICRC75.Set.toArray(icrc10);
  };

  // Deposit cycles into this canister.
  public shared func deposit_cycles() : async () {
      let amount = ExperimentalCycles.available();
      let accepted = ExperimentalCycles.accept<system>(amount);
      assert (accepted == amount);
  };

  public type DataItemMap = Service.DataItemMap;
  public type ManageRequest = Service.ManageRequest;
  public type ManageResult = Service.ManageResult;
  public type ManageListMembershipRequest = Service.ManageListMembershipRequest;
  public type ManageListMembershipRequestItem = Service.ManageListMembershipRequestItem;
  public type ManageListMembershipAction = Service.ManageListMembershipAction;
  public type ManageListPropertyRequest = Service.ManageListPropertyRequest;
  public type ManageListMembershipResponse = Service.ManageListMembershipResponse;
  public type ManageListPropertyRequestItem = Service.ManageListPropertyRequestItem;
  public type ManageListPropertyResponse = Service.ManageListPropertyResponse;
  public type AuthorizedRequestItem = Service.AuthorizedRequestItem;
  public type PermissionList = Service.PermissionList;
  public type PermissionListItem = Service.PermissionListItem;
  public type ListRecord = Service.ListRecord;
  public type List = ICRC75.List;
  public type ListItem = ICRC75.ListItem;
  public type Permission = ICRC75.Permission;
  public type Identity = ICRC75.Identity;
  public type ManageResponse = Service.ManageResponse;


  public query(msg) func icrc75_metadata() : async DataItemMap {
    return icrc75().metadata();
  };

  public shared(msg) func icrc75_manage(request: ManageRequest) : async ManageResponse {
      return icrc75().updateProperties(msg.caller, request);
    };

  public shared(msg) func icrc75_manage_list_membership(request: ManageListMembershipRequest) : async ManageListMembershipResponse {
    return await* icrc75().manage_list_membership(msg.caller, request, null);
  };

  public shared(msg) func icrc75_manage_list_properties(request: ManageListPropertyRequest) : async ManageListPropertyResponse {
    return await* icrc75().manage_list_properties(msg.caller, request, null);
  };

  public query(msg) func icrc75_get_lists(name: ?Text, bMetadata: Bool, cursor: ?List, limit: ?Nat) : async [ListRecord] {
    return icrc75().get_lists(msg.caller, name, bMetadata, cursor, limit);
  };

  public query(msg) func icrc75_get_list_members_admin(list: List, cursor: ?ListItem, limit: ?Nat) : async [(ListItem, ?DataItemMap)] {
    return icrc75().get_list_members_admin(msg.caller, list, cursor, limit);
  };

  public query(msg) func icrc75_get_list_permissions_admin(list: List, filter: ?Permission, prev: ?PermissionListItem, take: ?Nat) : async PermissionList {
    return icrc75().get_list_permission_admin(msg.caller, list, filter, prev, take);
  };

  public query(msg) func icrc75_get_list_lists(list: List, cursor: ?List, limit: ?Nat) : async [List] {
    return icrc75().get_list_lists(msg.caller, list, cursor, limit);
  };

  public query(msg) func icrc75_member_of(listItem: ListItem, list: ?List, limit: ?Nat) : async [List] {
    return icrc75().member_of(msg.caller, listItem, list, limit);
  };

  public query(msg) func icrc75_is_member(requestItems: [AuthorizedRequestItem]) : async [Bool] {
    return icrc75().is_member(msg.caller, requestItems);
  };

  public shared(msg) func icrc75_request_token(listItem: ListItem, list: List, ttl: ?Nat) : async ICRC75.IdentityRequestResult {
    return icrc75().request_token<system>(msg.caller,listItem, list, ttl);
  };

  public query(msg) func icrc75_retrieve_token(token: ICRC75.IdentityToken) : async ICRC75.IdentityCertificate {
    return icrc75().retrieve_token(msg.caller, token);
  };

  public query(_msg) func getLedger() : async [ICRC75.Value] {
    return Vector.toArray(fakeLedger);
  };

  public query func icrc75_get_icrc85_stats() : async {
    activeActions: Nat;
    lastActionReported: ?Nat;
    nextCycleActionId: ?Nat;
  } {
    return icrc75().get_icrc85_stats();
  };
};

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




import ICRC75 "..";
import Service "../service"

shared ({ caller = _originalCaller }) actor class ICRC75List  (
    init_args75 : ?ICRC75.InitArgs
) = this{

  let Set = ICRC75.Set;
  let Vector = ICRC75.Vector;

  stable var _owner = _originalCaller;

  let initManager = ClassPlus.ClassPlusInitializationManager(_owner, Principal.fromActor(this), true);

    
    stable var icrc10 : Set.Set<(ICRC10Record)> = Set.new();

    type ICRC10Record = {name:Text; url:Text};

    func icrc10EQ(a: ICRC10Record, b: ICRC10Record): Bool{
      (a.name == b.name and a.url == b.url);
    };

    func icrc10Hash32(a: ICRC10Record) : Nat32 {
      var nameHash = Text.hash("icrc10");
      nameHash +%= Text.hash(a.name);
      nameHash +%= Text.hash("--");
      nameHash +%= Text.hash(a.url);
      nameHash;
    };

    let icrc10Hash = (icrc10Hash32, icrc10EQ);

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


    stable let cert_store : CertTree.Store = CertTree.newStore();
    let ct = CertTree.Ops(cert_store);

    private func getCertStore() : CertTree.Store {
      
      return cert_store;
    };

    let icrc75 = ICRC75.Init<system>({
      manager = initManager;
      initialState = icrc75MigrationState;
      args= init_args75;
      pullEnvironment = ?(func() : ICRC75.Environment{
        {
          advanced = null;
          tt= null;
          updated_certification = null; //called when a certification has been made
          get_certificate_store = ?getCertStore; //needed to pass certificate store to the class
          addRecord = ?fakeledgerAddRecord;
          icrc10_register_supported_standards = func(a : ICRC10Record): Bool {
            Set.add(icrc10, icrc10Hash, a);
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



    Set.add(icrc10, icrc10Hash, ({name ="ICRC-10"; url = "https://github.com/dfinity/ICRC/ICRCs/ICRC-10"}));


  

  public query func icrc75_get_stats() : async ICRC75.Stats {
    return icrc75().get_stats();
  };

  public query func get_cycle_balance() : async Nat {
    return ExperimentalCycles.balance();
  };

  public query func icrc10_supported_standards() : async [ICRC10Record] {
    return Set.toArray(icrc10);
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

  public shared(msg) func auto_init() : async () {
    icrc75().initTimer<system>();
    return;
  };

  public query(msg) func getLedger() : async [ICRC75.Value] {
    return Vector.toArray(fakeLedger);
  };

  ignore Timer.setTimer<system>(#nanoseconds(0), func() : async(){
    let thisActor : actor{
      auto_init : () -> async ();
    } = actor(Principal.toText(Principal.fromActor(this)));
    await thisActor.auto_init();
  });
};

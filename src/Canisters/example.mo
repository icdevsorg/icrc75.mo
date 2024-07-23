///This is a naieve implementation and shows the minimum possible implementation. It does not provide archiving and will not scale.

import Array "mo:base/Array";
import ExperimentalCycles "mo:base/ExperimentalCycles";
import Principal "mo:base/Principal";
import Text "mo:base/Text";

import ICRC75 "..";
import Service "../service"

shared ({ caller = _owner }) actor class Token  (
    init_args75 : ICRC75.InitArgs
) = this{

   let Set = ICRC75.Set;

    
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

    stable let fakeLedger = Set.new<ICRC75.Value>(); //maintains insertion order

    private func fakeledgerAddRecord<system>(trx: ICRC75.Value, trxTop: ?ICRC75.Value) : Nat {

      let finalMap = switch(trxTop){
        case(?#Map(top)) {
          let combined = Array.append<(Text, ICRC75.Value)>(top, [("op",trx)]);
          #Map(combined);
        };
        case(_) {
          #Map([("op",trx)]);
        };
      };
      ICRC75.Set.add(fakeLedger, (ICRC75.ICRC16.hashShared, ICRC75.ICRC16.eqShared), finalMap);
      ICRC75.Set.size(fakeLedger) - 1;
    };

    stable let icrc75_migration_state = ICRC75.init(ICRC75.initialState(), #v0_1_0(#id), init_args75, _owner);

    let #v0_1_0(#data(icrc75_state_current)) = icrc75_migration_state;

    private var _icrc75 : ?ICRC75.ICRC75 = null;


    private func get_icrc75_state() : ICRC75.CurrentState {
      return icrc75_state_current;
    };

    

    private func get_icrc75_environment() : ICRC75.Environment {
    {
      advanced = null;
      tt = null; // for recovery and safety you likely want to provide a timer tool instance here
      addRecord = ?fakeledgerAddRecord;
      icrc10_register_supported_standards = func(a : ICRC10Record): Bool {
        Set.add(icrc10, icrc10Hash, a);
        true;
      };
    };
  };

    func icrc75() : ICRC75.ICRC75 {
    switch(_icrc75){
      case(null){
        let initclass : ICRC75.ICRC75 = ICRC75.ICRC75(?icrc75_migration_state, Principal.fromActor(this), get_icrc75_environment());
        _icrc75 := ?initclass;
        initclass;
      };
      case(?val) val;
    };
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
  public type ManageListPropertiesRequest = Service.ManageListPropertiesRequest;
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


  public query(msg) func icrc_75_metadata() : async DataItemMap {
    return icrc75().metadata();
  };

  public shared(msg) func icrc_75_manage(request: ManageRequest) : async ManageResponse {
      return icrc75().updateProperties(msg.caller, request);
    };

  public shared(msg) func icrc_75_manage_list_membership(request: ManageListMembershipRequest) : async ManageListMembershipResponse {
    return await* icrc75().manage_list_membership(msg.caller, request, null);
  };

  public shared(msg) func manage_list_properties(request: ManageListPropertiesRequest) : async ManageListPropertyResponse {
    return await* icrc75().manage_list_properties(msg.caller, request, null);
  };

  public query(msg) func icrc_75_get_lists(name: ?Text, includeArchived: Bool, cursor: ?List, limit: ?Nat) : async [ListRecord] {
    return icrc75().get_lists(msg.caller, name, includeArchived, cursor, limit);
  };

  public query(msg) func icrc_75_get_list_members_admin(list: List, cursor: ?ListItem, limit: ?Nat) : async [ListItem] {
    return icrc75().get_list_members_admin(msg.caller, list, cursor, limit);
  };

  public query(msg) func icrc_75_get_list_permissions_admin(list: List, filter: ?Permission, prev: ?PermissionListItem, take: ?Nat) : async PermissionList {
    return icrc75().get_list_permission_admin(msg.caller, list, filter, prev, take);
  };

  public query(msg) func icrc_75_get_list_lists(list: List, cursor: ?List, limit: ?Nat) : async [List] {
    return icrc75().get_list_lists(msg.caller, list, cursor, limit);
  };

  public query(msg) func icrc_75_member_of(listItem: ListItem, list: ?List, limit: ?Nat) : async [List] {
    return icrc75().member_of(msg.caller, listItem, list, limit);
  };

  public query(msg) func icrc_75_is_member(requestItems: [AuthorizedRequestItem]) : async [Bool] {
    return icrc75().is_member(msg.caller, requestItems);
  };
};

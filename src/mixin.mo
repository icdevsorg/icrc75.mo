/////////
// ICRC75 Mixin - List Management Interface
//
// This mixin provides ICRC-75 list management functionality with automatic ICRC-85 OVS integration.
// It uses ClassPlus for proper async initialization.
//
// The mixin exposes `org_icdevs_icrc75_interface` which allows customization of all
// ICRC-75 endpoints through before/after hooks or full replacement.
//
// Usage:
// ```motoko
// import ICRC75Mixin "mo:icrc75-mo/mixin";
// import ICRC75 "mo:icrc75-mo";
// import Interface "mo:icrc75-mo/Interface";
// import ClassPlus "mo:class-plus";
// import Principal "mo:core/Principal";
//
// shared ({ caller = _owner }) persistent actor class MyCanister() = this {
//   transient let canisterId = Principal.fromActor(this);
//   transient let org_icdevs_class_plus_manager = ClassPlus.ClassPlusInitializationManager<system>(_owner, canisterId, true);
//
//   include ICRC75Mixin.mixin({
//     org_icdevs_class_plus_manager = org_icdevs_class_plus_manager;
//     args = ?icrc75Args;
//     pullEnvironment = ?getEnvironment;
//     onInitialize = null;
//   });
//
//   // Access class via icrc75()
//   // Customize via org_icdevs_icrc75_interface
// };
// ```
/////////

import ICRC75 ".";
import Interface "./Interface";
import Service "./service";
import List "mo:core/List";

mixin(
  config: ICRC75.MixinFunctionArgs
) {
  
  /// Stable state for ICRC-75 - persisted across upgrades
  stable var icrc75_migration_state = ICRC75.initialState();

  /// The ICRC-75 class instance getter
  transient let icrc75 = ICRC75.Init({
    org_icdevs_class_plus_manager = config.org_icdevs_class_plus_manager;
    initialState = icrc75_migration_state;
    args = config.args;
    pullEnvironment = config.pullEnvironment;
    onInitialize = config.onInitialize;
    onStorageChange = func(state: ICRC75.State) {
      icrc75_migration_state := state;
    };
  });

  /// The extensible interface for ICRC-75 endpoints
  /// Use this to add before/after hooks or replace implementations
  transient let org_icdevs_icrc75_interface : Interface.ICRC75Interface = Interface.defaultInterface(icrc75);

  //////////////////////////////////////////
  // QUERY ENDPOINTS
  //////////////////////////////////////////

  public query(msg) func icrc75_metadata() : async Service.DataItemMap {
    Interface.executeQuery<(), Service.DataItemMap>(
      { args = (); caller = ?msg.caller },
      org_icdevs_icrc75_interface.icrc75_metadata,
      org_icdevs_icrc75_interface.beforeMetadata,
      org_icdevs_icrc75_interface.afterMetadata
    );
  };

  public query(msg) func icrc75_get_lists(name: ?Text, includeArchived: Bool, cursor: ?ICRC75.List, limit: ?Nat) : async [Service.ListRecord] {
    Interface.executeQuery<Interface.GetListsArgs, [Service.ListRecord]>(
      { args = { name; includeArchived; cursor; limit }; caller = ?msg.caller },
      org_icdevs_icrc75_interface.icrc75_get_lists,
      org_icdevs_icrc75_interface.beforeGetLists,
      org_icdevs_icrc75_interface.afterGetLists
    );
  };

  public query(msg) func icrc75_get_list_members_admin(list: ICRC75.List, cursor: ?ICRC75.ListItem, limit: ?Nat) : async [(ICRC75.ListItem, ?Service.DataItemMap)] {
    Interface.executeQuery<Interface.GetListMembersAdminArgs, [(ICRC75.ListItem, ?Service.DataItemMap)]>(
      { args = { list; cursor; limit }; caller = ?msg.caller },
      org_icdevs_icrc75_interface.icrc75_get_list_members_admin,
      org_icdevs_icrc75_interface.beforeGetListMembersAdmin,
      org_icdevs_icrc75_interface.afterGetListMembersAdmin
    );
  };

  public query(msg) func icrc75_get_list_permissions_admin(list: ICRC75.List, filter: ?ICRC75.Permission, prev: ?Service.PermissionListItem, take: ?Nat) : async Service.PermissionList {
    Interface.executeQuery<Interface.GetListPermissionsAdminArgs, Service.PermissionList>(
      { args = { list; filter; prev; take }; caller = ?msg.caller },
      org_icdevs_icrc75_interface.icrc75_get_list_permissions_admin,
      org_icdevs_icrc75_interface.beforeGetListPermissionsAdmin,
      org_icdevs_icrc75_interface.afterGetListPermissionsAdmin
    );
  };

  public query(msg) func icrc75_get_list_lists(list: ICRC75.List, cursor: ?ICRC75.List, limit: ?Nat) : async [ICRC75.List] {
    Interface.executeQuery<Interface.GetListListsArgs, [ICRC75.List]>(
      { args = { list; cursor; limit }; caller = ?msg.caller },
      org_icdevs_icrc75_interface.icrc75_get_list_lists,
      org_icdevs_icrc75_interface.beforeGetListLists,
      org_icdevs_icrc75_interface.afterGetListLists
    );
  };

  public query(msg) func icrc75_member_of(listItem: ICRC75.ListItem, list: ?ICRC75.List, limit: ?Nat) : async [ICRC75.List] {
    Interface.executeQuery<Interface.MemberOfArgs, [ICRC75.List]>(
      { args = { listItem; list; limit }; caller = ?msg.caller },
      org_icdevs_icrc75_interface.icrc75_member_of,
      org_icdevs_icrc75_interface.beforeMemberOf,
      org_icdevs_icrc75_interface.afterMemberOf
    );
  };

  public query(msg) func icrc75_is_member(requestItems: [Service.AuthorizedRequestItem]) : async [Bool] {
    Interface.executeQuery<[Service.AuthorizedRequestItem], [Bool]>(
      { args = requestItems; caller = ?msg.caller },
      org_icdevs_icrc75_interface.icrc75_is_member,
      org_icdevs_icrc75_interface.beforeIsMember,
      org_icdevs_icrc75_interface.afterIsMember
    );
  };

  public query(msg) func icrc75_get_stats() : async ICRC75.Stats {
    Interface.executeQuery<(), ICRC75.Stats>(
      { args = (); caller = ?msg.caller },
      org_icdevs_icrc75_interface.icrc75_get_stats,
      org_icdevs_icrc75_interface.beforeGetStats,
      org_icdevs_icrc75_interface.afterGetStats
    );
  };

  public shared query func icrc75_get_icrc85_stats() : async ?{
    activeActions: Nat;
    lastActionReported: ?Nat;
    nextCycleActionId: ?Nat;
  } {
    ?icrc75().get_icrc85_stats();
  };

  //////////////////////////////////////////
  // UPDATE ENDPOINTS
  //////////////////////////////////////////

  public shared(msg) func icrc75_manage(request: Service.ManageRequest) : async Service.ManageResponse {
    let ctx : Interface.UpdateContext<Service.ManageRequest> = { args = request; caller = msg.caller };
    
    // Check before hooks
    for ((_, hook) in List.values(org_icdevs_icrc75_interface.beforeManage)) {
      switch(hook(ctx)) {
        case(?result) { return result };
        case(null) {};
      };
    };

    // Call class directly for system capability
    var result = icrc75().updateProperties<system>(msg.caller, request);

    // Apply after hooks
    for ((_, hook) in List.values(org_icdevs_icrc75_interface.afterManage)) {
      result := hook(ctx, result);
    };

    result;
  };

  public shared(msg) func icrc75_manage_list_membership(request: Service.ManageListMembershipRequest) : async Service.ManageListMembershipResponse {
    let ctx : Interface.UpdateContext<Interface.ManageListMembershipArgs> = {
      args = { request; canChange = config.canChangeMembership };
      caller = msg.caller;
    };
    
    // Check before hooks
    for ((_, hook) in List.values(org_icdevs_icrc75_interface.beforeManageListMembership)) {
      switch(hook(ctx)) {
        case(?result) { return result };
        case(null) {};
      };
    };
    
    // Call class directly for async operation
    var result = await* icrc75().manage_list_membership(msg.caller, request, config.canChangeMembership);
    
    // Apply after hooks
    for ((_, hook) in List.values(org_icdevs_icrc75_interface.afterManageListMembership)) {
      result := hook(ctx, result);
    };
    
    result;
  };

  public shared(msg) func icrc75_manage_list_properties(request: Service.ManageListPropertyRequest) : async Service.ManageListPropertyResponse {
    let ctx : Interface.UpdateContext<Interface.ManageListPropertyArgs> = {
      args = { request; canChange = config.canChangeProperty };
      caller = msg.caller;
    };
    
    // Check before hooks
    for ((_, hook) in List.values(org_icdevs_icrc75_interface.beforeManageListProperties)) {
      switch(hook(ctx)) {
        case(?result) { return result };
        case(null) {};
      };
    };
    
    // Call class directly for async operation
    var result = await* icrc75().manage_list_properties(msg.caller, request, config.canChangeProperty);
    
    // Apply after hooks
    for ((_, hook) in List.values(org_icdevs_icrc75_interface.afterManageListProperties)) {
      result := hook(ctx, result);
    };
    
    result;
  };
};

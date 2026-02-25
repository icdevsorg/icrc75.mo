/////////
// ICRC75 Interface - Extensible Hook Pattern
//
// This module provides a standardized interface for ICRC-75 endpoints that supports
// before/after hooks for customization without modifying the core library.
//
// The `org_icdevs_icrc75_interface` allows users to:
// - Override any endpoint implementation
// - Add before hooks that can short-circuit execution
// - Add after hooks that can transform results
//
// Usage in mixin:
// ```motoko
// transient let org_icdevs_icrc75_interface = Interface.defaultInterface(icrc75);
// ```
/////////

import List "mo:core/List";
import Principal "mo:core/Principal";
import Result "mo:base/Result";
import Debug "mo:base/Debug";

import ICRC75 ".";
import Service "./service";

module {

  //////////////////////////////////////////
  // TYPES
  //////////////////////////////////////////

  /// Query context - for query functions
  public type QueryContext<T> = {
    args: T;
    caller: ?Principal;
  };

  /// Before hook for queries (sync, no async*)
  public type QueryBeforeHook<T, R> = (QueryContext<T>) -> ?R;

  /// After hook for queries (sync)
  public type QueryAfterHook<T, R> = (QueryContext<T>, R) -> R;

  /// Update context - for update functions
  public type UpdateContext<T> = {
    args: T;
    caller: Principal;
  };

  /// Before hook for updates (sync - use sync hooks to avoid async generic issues)
  public type UpdateBeforeHook<T, R> = (UpdateContext<T>) -> ?R;

  /// After hook for updates (sync)
  public type UpdateAfterHook<T, R> = (UpdateContext<T>, R) -> R;

  // Type aliases for convenience
  public type DataItemMap = Service.DataItemMap;
  public type ManageRequest = Service.ManageRequest;
  public type ManageResponse = Service.ManageResponse;
  public type ManageListMembershipRequest = Service.ManageListMembershipRequest;
  public type ManageListMembershipResponse = Service.ManageListMembershipResponse;
  public type ManageListPropertyRequest = Service.ManageListPropertyRequest;
  public type ManageListPropertyResponse = Service.ManageListPropertyResponse;
  public type ListRecord = Service.ListRecord;
  public type List = ICRC75.List;
  public type ListItem = ICRC75.ListItem;
  public type Permission = ICRC75.Permission;
  public type PermissionList = Service.PermissionList;
  public type PermissionListItem = Service.PermissionListItem;
  public type AuthorizedRequestItem = Service.AuthorizedRequestItem;
  public type IdentityRequestResult = Service.IdentityRequestResult;
  public type IdentityToken = Service.IdentityToken;
  public type Witness = Service.Witness;
  public type IdentityCertificate = Service.IdentityCertificate;
  public type Stats = ICRC75.Stats;
  public type CanChangeMembership = ICRC75.CanChangeMembership;
  public type CanChangeProperty = ICRC75.CanChangeProperty;

  // Query args types
  public type GetListsArgs = {
    name: ?Text;
    includeArchived: Bool;
    cursor: ?List;
    limit: ?Nat;
  };

  public type GetListMembersAdminArgs = {
    list: List;
    cursor: ?ListItem;
    limit: ?Nat;
  };

  public type GetListPermissionsAdminArgs = {
    list: List;
    filter: ?Permission;
    prev: ?PermissionListItem;
    take: ?Nat;
  };

  public type GetListListsArgs = {
    list: List;
    cursor: ?List;
    limit: ?Nat;
  };

  public type MemberOfArgs = {
    listItem: ListItem;
    list: ?List;
    limit: ?Nat;
  };

  public type ManageListMembershipArgs = {
    request: ManageListMembershipRequest;
    canChange: CanChangeMembership;
  };

  public type ManageListPropertyArgs = {
    request: ManageListPropertyRequest;
    canChange: CanChangeProperty;
  };

  //////////////////////////////////////////
  // INTERFACE TYPE
  //////////////////////////////////////////

  /// The extensible ICRC75 interface
  public type ICRC75Interface = {
    // Query function implementations
    var icrc75_metadata : (QueryContext<()>) -> DataItemMap;
    var icrc75_get_lists : (QueryContext<GetListsArgs>) -> [ListRecord];
    var icrc75_get_list_members_admin : (QueryContext<GetListMembersAdminArgs>) -> [(ListItem, ?DataItemMap)];
    var icrc75_get_list_permissions_admin : (QueryContext<GetListPermissionsAdminArgs>) -> PermissionList;
    var icrc75_get_list_lists : (QueryContext<GetListListsArgs>) -> [List];
    var icrc75_member_of : (QueryContext<MemberOfArgs>) -> [List];
    var icrc75_is_member : (QueryContext<[AuthorizedRequestItem]>) -> [Bool];
    var icrc75_get_stats : (QueryContext<()>) -> Stats;

    // Update function implementations (sync - class methods return Star which is unwrapped by caller)
    var icrc75_manage : (UpdateContext<ManageRequest>) -> ManageResponse;
    var icrc75_manage_list_membership : (UpdateContext<ManageListMembershipArgs>) -> ManageListMembershipResponse;
    var icrc75_manage_list_properties : (UpdateContext<ManageListPropertyArgs>) -> ManageListPropertyResponse;

    // Query hooks
    var beforeMetadata : List.List<(Text, QueryBeforeHook<(), DataItemMap>)>;
    var afterMetadata : List.List<(Text, QueryAfterHook<(), DataItemMap>)>;
    var beforeGetLists : List.List<(Text, QueryBeforeHook<GetListsArgs, [ListRecord]>)>;
    var afterGetLists : List.List<(Text, QueryAfterHook<GetListsArgs, [ListRecord]>)>;
    var beforeGetListMembersAdmin : List.List<(Text, QueryBeforeHook<GetListMembersAdminArgs, [(ListItem, ?DataItemMap)]>)>;
    var afterGetListMembersAdmin : List.List<(Text, QueryAfterHook<GetListMembersAdminArgs, [(ListItem, ?DataItemMap)]>)>;
    var beforeGetListPermissionsAdmin : List.List<(Text, QueryBeforeHook<GetListPermissionsAdminArgs, PermissionList>)>;
    var afterGetListPermissionsAdmin : List.List<(Text, QueryAfterHook<GetListPermissionsAdminArgs, PermissionList>)>;
    var beforeGetListLists : List.List<(Text, QueryBeforeHook<GetListListsArgs, [List]>)>;
    var afterGetListLists : List.List<(Text, QueryAfterHook<GetListListsArgs, [List]>)>;
    var beforeMemberOf : List.List<(Text, QueryBeforeHook<MemberOfArgs, [List]>)>;
    var afterMemberOf : List.List<(Text, QueryAfterHook<MemberOfArgs, [List]>)>;
    var beforeIsMember : List.List<(Text, QueryBeforeHook<[AuthorizedRequestItem], [Bool]>)>;
    var afterIsMember : List.List<(Text, QueryAfterHook<[AuthorizedRequestItem], [Bool]>)>;
    var beforeGetStats : List.List<(Text, QueryBeforeHook<(), Stats>)>;
    var afterGetStats : List.List<(Text, QueryAfterHook<(), Stats>)>;

    // Update hooks
    var beforeManage : List.List<(Text, (UpdateContext<ManageRequest>) -> ?ManageResponse)>;
    var afterManage : List.List<(Text, (UpdateContext<ManageRequest>, ManageResponse) -> ManageResponse)>;
    var beforeManageListMembership : List.List<(Text, UpdateBeforeHook<ManageListMembershipArgs, ManageListMembershipResponse>)>;
    var afterManageListMembership : List.List<(Text, UpdateAfterHook<ManageListMembershipArgs, ManageListMembershipResponse>)>;
    var beforeManageListProperties : List.List<(Text, UpdateBeforeHook<ManageListPropertyArgs, ManageListPropertyResponse>)>;
    var afterManageListProperties : List.List<(Text, UpdateAfterHook<ManageListPropertyArgs, ManageListPropertyResponse>)>;
  };

  //////////////////////////////////////////
  // FACTORY
  //////////////////////////////////////////

  /// Create a default interface that delegates to the ICRC75 class instance
  public func defaultInterface(getInstance: () -> ICRC75.ICRC75) : ICRC75Interface {
    {
      // Query implementations - delegate to class
      var icrc75_metadata = func(_ctx: QueryContext<()>) : DataItemMap { 
        getInstance().metadata() 
      };
      
      var icrc75_get_lists = func(ctx: QueryContext<GetListsArgs>) : [ListRecord] { 
        let caller = switch(ctx.caller) {
          case(?c) c;
          case(null) Principal.fromText("2vxsx-fae"); // anonymous
        };
        getInstance().get_lists(caller, ctx.args.name, ctx.args.includeArchived, ctx.args.cursor, ctx.args.limit)
      };
      
      var icrc75_get_list_members_admin = func(ctx: QueryContext<GetListMembersAdminArgs>) : [(ListItem, ?DataItemMap)] {
        let caller = switch(ctx.caller) {
          case(?c) c;
          case(null) Principal.fromText("2vxsx-fae");
        };
        getInstance().get_list_members_admin(caller, ctx.args.list, ctx.args.cursor, ctx.args.limit)
      };
      
      var icrc75_get_list_permissions_admin = func(ctx: QueryContext<GetListPermissionsAdminArgs>) : PermissionList {
        let caller = switch(ctx.caller) {
          case(?c) c;
          case(null) Principal.fromText("2vxsx-fae");
        };
        getInstance().get_list_permission_admin(caller, ctx.args.list, ctx.args.filter, ctx.args.prev, ctx.args.take)
      };
      
      var icrc75_get_list_lists = func(ctx: QueryContext<GetListListsArgs>) : [List] {
        let caller = switch(ctx.caller) {
          case(?c) c;
          case(null) Principal.fromText("2vxsx-fae");
        };
        getInstance().get_list_lists(caller, ctx.args.list, ctx.args.cursor, ctx.args.limit)
      };
      
      var icrc75_member_of = func(ctx: QueryContext<MemberOfArgs>) : [List] {
        let caller = switch(ctx.caller) {
          case(?c) c;
          case(null) Principal.fromText("2vxsx-fae");
        };
        getInstance().member_of(caller, ctx.args.listItem, ctx.args.list, ctx.args.limit)
      };
      
      var icrc75_is_member = func(ctx: QueryContext<[AuthorizedRequestItem]>) : [Bool] {
        let caller = switch(ctx.caller) {
          case(?c) c;
          case(null) Principal.fromText("2vxsx-fae");
        };
        getInstance().is_member(caller, ctx.args)
      };
      
      var icrc75_get_stats = func(_ctx: QueryContext<()>) : Stats {
        getInstance().get_stats()
      };

      // Update implementations - these are stubs because system capability is needed
      // The mixin calls the class directly
      var icrc75_manage = func(_ctx: UpdateContext<ManageRequest>) : ManageResponse {
        Debug.trap("Use getInstance().updateProperties<system> directly")
      };
      
      // For async methods, we just provide a sync stub - the mixin calls the class directly
      var icrc75_manage_list_membership = func(_ctx: UpdateContext<ManageListMembershipArgs>) : ManageListMembershipResponse {
        Debug.trap("Use getInstance().manage_list_membership directly in async context")
      };
      
      var icrc75_manage_list_properties = func(_ctx: UpdateContext<ManageListPropertyArgs>) : ManageListPropertyResponse {
        Debug.trap("Use getInstance().manage_list_properties directly in async context")
      };

      // Initialize empty hook lists
      var beforeMetadata = List.empty<(Text, QueryBeforeHook<(), DataItemMap>)>();
      var afterMetadata = List.empty<(Text, QueryAfterHook<(), DataItemMap>)>();
      var beforeGetLists = List.empty<(Text, QueryBeforeHook<GetListsArgs, [ListRecord]>)>();
      var afterGetLists = List.empty<(Text, QueryAfterHook<GetListsArgs, [ListRecord]>)>();
      var beforeGetListMembersAdmin = List.empty<(Text, QueryBeforeHook<GetListMembersAdminArgs, [(ListItem, ?DataItemMap)]>)>();
      var afterGetListMembersAdmin = List.empty<(Text, QueryAfterHook<GetListMembersAdminArgs, [(ListItem, ?DataItemMap)]>)>();
      var beforeGetListPermissionsAdmin = List.empty<(Text, QueryBeforeHook<GetListPermissionsAdminArgs, PermissionList>)>();
      var afterGetListPermissionsAdmin = List.empty<(Text, QueryAfterHook<GetListPermissionsAdminArgs, PermissionList>)>();
      var beforeGetListLists = List.empty<(Text, QueryBeforeHook<GetListListsArgs, [List]>)>();
      var afterGetListLists = List.empty<(Text, QueryAfterHook<GetListListsArgs, [List]>)>();
      var beforeMemberOf = List.empty<(Text, QueryBeforeHook<MemberOfArgs, [List]>)>();
      var afterMemberOf = List.empty<(Text, QueryAfterHook<MemberOfArgs, [List]>)>();
      var beforeIsMember = List.empty<(Text, QueryBeforeHook<[AuthorizedRequestItem], [Bool]>)>();
      var afterIsMember = List.empty<(Text, QueryAfterHook<[AuthorizedRequestItem], [Bool]>)>();
      var beforeGetStats = List.empty<(Text, QueryBeforeHook<(), Stats>)>();
      var afterGetStats = List.empty<(Text, QueryAfterHook<(), Stats>)>();
      var beforeManage = List.empty<(Text, (UpdateContext<ManageRequest>) -> ?ManageResponse)>();
      var afterManage = List.empty<(Text, (UpdateContext<ManageRequest>, ManageResponse) -> ManageResponse)>();
      var beforeManageListMembership = List.empty<(Text, UpdateBeforeHook<ManageListMembershipArgs, ManageListMembershipResponse>)>();
      var afterManageListMembership = List.empty<(Text, UpdateAfterHook<ManageListMembershipArgs, ManageListMembershipResponse>)>();
      var beforeManageListProperties = List.empty<(Text, UpdateBeforeHook<ManageListPropertyArgs, ManageListPropertyResponse>)>();
      var afterManageListProperties = List.empty<(Text, UpdateAfterHook<ManageListPropertyArgs, ManageListPropertyResponse>)>();
    };
  };

  //////////////////////////////////////////
  // HOOK HELPERS
  //////////////////////////////////////////

  /// Add a before hook for manage_list_membership
  public func addBeforeManageListMembership(
    iface: ICRC75Interface,
    id: Text,
    hook: UpdateBeforeHook<ManageListMembershipArgs, ManageListMembershipResponse>
  ) {
    List.add(iface.beforeManageListMembership, (id, hook));
  };

  /// Remove a before hook for manage_list_membership
  public func removeBeforeManageListMembership(iface: ICRC75Interface, id: Text) {
    let filtered = List.filter<(Text, UpdateBeforeHook<ManageListMembershipArgs, ManageListMembershipResponse>)>(
      iface.beforeManageListMembership,
      func(item) { item.0 != id }
    );
    iface.beforeManageListMembership := filtered;
  };

  /// Add an after hook for manage_list_membership
  public func addAfterManageListMembership(
    iface: ICRC75Interface,
    id: Text,
    hook: UpdateAfterHook<ManageListMembershipArgs, ManageListMembershipResponse>
  ) {
    List.add(iface.afterManageListMembership, (id, hook));
  };

  /// Add a before hook for manage_list_properties
  public func addBeforeManageListProperties(
    iface: ICRC75Interface,
    id: Text,
    hook: UpdateBeforeHook<ManageListPropertyArgs, ManageListPropertyResponse>
  ) {
    List.add(iface.beforeManageListProperties, (id, hook));
  };

  /// Add an after hook for manage_list_properties
  public func addAfterManageListProperties(
    iface: ICRC75Interface,
    id: Text,
    hook: UpdateAfterHook<ManageListPropertyArgs, ManageListPropertyResponse>
  ) {
    List.add(iface.afterManageListProperties, (id, hook));
  };

  //////////////////////////////////////////
  // EXECUTION HELPERS
  //////////////////////////////////////////

  /// Execute query with hooks
  public func executeQuery<T, R>(
    ctx: QueryContext<T>,
    impl: (QueryContext<T>) -> R,
    beforeHooks: List.List<(Text, QueryBeforeHook<T, R>)>,
    afterHooks: List.List<(Text, QueryAfterHook<T, R>)>
  ) : R {
    // Check before hooks
    for ((_, hook) in List.values(beforeHooks)) {
      switch(hook(ctx)) {
        case(?result) { return result };
        case(null) {};
      };
    };

    // Execute main implementation
    var result = impl(ctx);

    // Apply after hooks
    for ((_, hook) in List.values(afterHooks)) {
      result := hook(ctx, result);
    };

    result;
  };

  /// Execute sync update with hooks
  public func executeUpdate<T, R>(
    ctx: UpdateContext<T>,
    impl: (UpdateContext<T>) -> R,
    beforeHooks: List.List<(Text, UpdateBeforeHook<T, R>)>,
    afterHooks: List.List<(Text, UpdateAfterHook<T, R>)>
  ) : R {
    // Check before hooks
    for ((_, hook) in List.values(beforeHooks)) {
      switch(hook(ctx)) {
        case(?result) { return result };
        case(null) {};
      };
    };

    // Execute main implementation
    var result = impl(ctx);

    // Apply after hooks
    for ((_, hook) in List.values(afterHooks)) {
      result := hook(ctx, result);
    };

    result;
  };
};

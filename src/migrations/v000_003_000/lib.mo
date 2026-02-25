import MigrationTypes "../types";
import v0_3_0 "types";
import v0_2_0 "../v000_002_000/types";

import Debug "mo:core/Debug";
import Text "mo:core/Text";
import Iter "mo:core/Iter";
import Runtime "mo:core/Runtime";

// Old libraries (for reading v0_2_0 state)
import OldMap "mo:map/Map";
import OldSet "mo:map/Set";
import BTree "mo:stableheapbtreemap/BTree";

// New libraries (for v0_3_0 state)
import Map "mo:core/Map";
import Set "mo:core/Set";

import OVS "mo:ovs-fixed";

module {

  public func upgrade(prev_migration_state: MigrationTypes.State, args: ?MigrationTypes.Args, caller: Principal): MigrationTypes.State {

    let oldState = switch (prev_migration_state) { 
      case (#v0_2_0(#data(state))) state; 
      case (#v0_0_0(_)) {
        // Fresh install - create default state
        return upgradeFromScratch(args, caller);
      };
      case (#v0_3_0(_)) {
        Runtime.trap("Already at v0_3_0");
      };
      case (_) Runtime.trap("Unexpected migration state") 
    };

    // Migrate namespaceStore - BTree contents use new Map/Set types
    let newNamespaceStore = BTree.init<Text, v0_3_0.NamespaceRecord>(null);

    for ((namespace, oldRecord) in BTree.entries(oldState.namespaceStore)) {
      // Migrate members: Map<ListItem, ?ICRC16Map> from mo:map to mo:core/Map
      let newMembers = Map.empty<v0_3_0.ListItem, ?v0_3_0.ICRC16Map>();
      for ((listItem, metadata) in OldMap.entries(oldRecord.members)) {
        Map.add(newMembers, v0_3_0.listItemCompare, listItem, metadata);
      };

      // Migrate permissions: PermissionCollection with Set<ListItem> fields
      let newRead = Set.empty<v0_3_0.ListItem>();
      for (item in OldSet.keys(oldRecord.permissions.read)) {
        Set.add(newRead, v0_3_0.listItemCompare, item);
      };

      let newWrite = Set.empty<v0_3_0.ListItem>();
      for (item in OldSet.keys(oldRecord.permissions.write)) {
        Set.add(newWrite, v0_3_0.listItemCompare, item);
      };

      let newAdmin = Set.empty<v0_3_0.ListItem>();
      for (item in OldSet.keys(oldRecord.permissions.admin)) {
        Set.add(newAdmin, v0_3_0.listItemCompare, item);
      };

      let newPermissions = Set.empty<v0_3_0.ListItem>();
      for (item in OldSet.keys(oldRecord.permissions.permissions)) {
        Set.add(newPermissions, v0_3_0.listItemCompare, item);
      };

      let newRecord : v0_3_0.NamespaceRecord = {
        namespace = oldRecord.namespace;
        permissions = {
          read = newRead;
          write = newWrite;
          admin = newAdmin;
          permissions = newPermissions;
        };
        members = newMembers;
        metadata = oldRecord.metadata;
      };

      ignore BTree.insert<Text, v0_3_0.NamespaceRecord>(newNamespaceStore, Text.compare, namespace, newRecord);
    };

    // Migrate memberIndex: Map<ListItem, Set<List>> from mo:map to mo:core/Map
    let newMemberIndex = Map.empty<v0_3_0.ListItem, Set.Set<v0_3_0.List>>();
    for ((listItem, oldSetOfLists) in OldMap.entries(oldState.memberIndex)) {
      let newSetOfLists = Set.empty<v0_3_0.List>();
      for (list in OldSet.keys(oldSetOfLists)) {
        Set.add(newSetOfLists, Text.compare, list);
      };
      Map.add(newMemberIndex, v0_3_0.listItemCompare, listItem, newSetOfLists);
    };

    // Migrate permissionsIndex: Map<ListItem, Set<List>> from mo:map to mo:core/Map
    let newPermissionsIndex = Map.empty<v0_3_0.ListItem, Set.Set<v0_3_0.List>>();
    for ((listItem, oldSetOfLists) in OldMap.entries(oldState.permissionsIndex)) {
      let newSetOfLists = Set.empty<v0_3_0.List>();
      for (list in OldSet.keys(oldSetOfLists)) {
        Set.add(newSetOfLists, Text.compare, list);
      };
      Map.add(newPermissionsIndex, v0_3_0.listItemCompare, listItem, newSetOfLists);
    };

    let state : v0_3_0.State = {
      var certificateNonce = oldState.certificateNonce;
      var cycleShareTimerID = oldState.cycleShareTimerID;
      namespaceStore = newNamespaceStore;
      memberIndex = newMemberIndex;
      var org_icdevs_ovs_fixed_state = OVS.initialState();
      permissionsIndex = newPermissionsIndex;
      var owner = oldState.owner;
      metadata = {
        var permittedDrift = oldState.metadata.permittedDrift;
        var maxTake = oldState.metadata.maxTake;
        var defaultTake = oldState.metadata.defaultTake;
        var txWindow = oldState.metadata.txWindow;
        var maxQuery = oldState.metadata.maxQuery;
        var maxUpdate = oldState.metadata.maxUpdate;
      };
    };

    return #v0_3_0(#data(state));
  };

  // Helper function for fresh installs
  func upgradeFromScratch(args: ?MigrationTypes.Args, caller: Principal): MigrationTypes.State {
    let state : v0_3_0.State = {
      var certificateNonce = 0;
      var cycleShareTimerID = null;
      namespaceStore = BTree.init<Text, v0_3_0.NamespaceRecord>(null);
      memberIndex = Map.empty<v0_3_0.ListItem, Set.Set<v0_3_0.List>>();
      permissionsIndex = Map.empty<v0_3_0.ListItem, Set.Set<v0_3_0.List>>();
      var owner = caller;
      var org_icdevs_ovs_fixed_state = OVS.initialState();
      metadata = {
        var defaultTake = 100;
        var maxTake = 10000;
        var permittedDrift = 60_000_000_000; // 1 minute in nanoseconds
        var txWindow = 86_400_000_000_000; // 24 hours in nanoseconds
        var maxQuery = 10000;
        var maxUpdate = 100;
      };
    };

    return #v0_3_0(#data(state));
  };

};

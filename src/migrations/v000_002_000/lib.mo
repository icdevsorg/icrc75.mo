import MigrationTypes "../types";
import v0_2_0 "types";

import D "mo:base/Debug";
import Text "mo:base/Text";


import Map "mo:map9/Map";
import Set "mo:map9/Set";

import BTree "mo:stableheapbtreemap/BTree";

module {

  public func upgrade(prev_migration_state: MigrationTypes.State, args: ?MigrationTypes.Args, caller: Principal): MigrationTypes.State {

    let oldState = switch (prev_migration_state) { case (#v0_1_1(#data(state))) state; case (_) D.trap("Unexpected migration state") };

    let newNamespaceStore = BTree.init<Text, v0_2_0.NamespaceRecord>(null);

    for(thisItem in BTree.entries(oldState.namespaceStore)) {

      let members = Map.new< v0_2_0.ListItem, ?v0_2_0.ICRC16Map>();
      
      for(thisMember in Set.keys<v0_2_0.ListItem>(thisItem.1.members)) {
        let memberKey = thisMember;
        ignore Map.add(members, v0_2_0.listItemHash, memberKey, null);
      };
     
      let newRecord : v0_2_0.NamespaceRecord = {
        namespace = thisItem.1.namespace;
        permissions = thisItem.1.permissions;
        members = members;
        metadata = thisItem.1.metadata;
      };

     ignore BTree.insert<Text, v0_2_0.NamespaceRecord>(newNamespaceStore, Text.compare, thisItem.0, newRecord);
    };

    let state : v0_2_0.State = {
      var certificateNonce = oldState.certificateNonce;
      var cycleShareTimerID = oldState.cycleShareTimerID;
      namespaceStore = newNamespaceStore;
      memberIndex = oldState.memberIndex;
      icrc85 = oldState.icrc85;
      permissionsIndex = oldState.permissionsIndex;
      var owner = oldState.owner;
      metadata = {
        var permittedDrift = oldState.metadata.permittedDrift;
        var maxTake = oldState.metadata.maxTake;
        var defaultTake = oldState.metadata.defaultTake;
        var txWindow = oldState.metadata.txWindow;
        var maxQuery = oldState.metadata.maxTake;
        var maxUpdate = oldState.metadata.maxUpdate; // this was changed from maxTake to maxUpdate
      };
      var tt = oldState.tt;
    };

    return #v0_2_0(#data(state));
  };

};
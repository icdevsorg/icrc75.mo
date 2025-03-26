import MigrationTypes "../types";
import v0_1_1 "types";

import D "mo:base/Debug";
import Text "mo:base/Text";


import Map "mo:map9/Map";
import Set "mo:map9/Set";

import BTree "mo:stableheapbtreemap/BTree";

module {

  public func upgrade(prev_migration_state: MigrationTypes.State, args: ?MigrationTypes.Args, caller: Principal): MigrationTypes.State {

    let oldState = switch (prev_migration_state) { case (#v0_1_0(#data(state))) state; case (_) D.trap("Unexpected migration state") };

    let state : v0_1_1.State = {
      var certificateNonce = 0;
      var cycleShareTimerID = null;
      namespaceStore = oldState.namespaceStore;
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
        var maxUpdate = 100;
      };
      var tt = oldState.tt;
    };

    return #v0_1_1(#data(state));
  };

};
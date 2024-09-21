import MigrationTypes "../types";
import v0_1_0 "types";

import D "mo:base/Debug";
import Text "mo:base/Text";


import Map "mo:map9/Map";
import Set "mo:map9/Set";

import BTree "mo:stableheapbtreemap/BTree";

module {

  public func upgrade(prevmigration_state: MigrationTypes.State, args: MigrationTypes.Args, caller: Principal): MigrationTypes.State {

    let (
        existingNamespaces,
        permittedDrift,
        maxTake,
        defaultTake,
        txWindow
     ) = switch(args){
      case(?args) {
        (switch(args.existingNamespaces){
          case(null) { [] };
          case(?existingNamespaces) existingNamespaces;
        },
        v0_1_0.ONE_MINUTE,
        200,
        200,
        v0_1_0.ONE_DAY
        )
      };
      case(null) {
        
        ([],
          v0_1_0.ONE_MINUTE,
          200,
          200,
          v0_1_0.ONE_DAY
        );
      };
    };

    type NamespaceRecord = v0_1_0.NamespaceRecord;
    type DataItem = v0_1_0.DataItem;
    type List = v0_1_0.List;
    type ListItem = v0_1_0.ListItem;
    type Identity = v0_1_0.Identity;
    type Permission = v0_1_0.Permission;
    type PermissionCollection = v0_1_0.PermissionCollection;
    type Domain = v0_1_0.Domain;

    let domainHash = v0_1_0.domainHash;
    let listItemHash = v0_1_0.listItemHash;

    let namespacesStore = BTree.init<Text, NamespaceRecord>(null);
    let memberIndex = Map.new<ListItem, Set.Set<List>>();
    let permissionsIndex = Map.new<ListItem, Set.Set<List>>();
    let domainIndex = Map.new<Domain, Set.Set<List>>();

    if(existingNamespaces.size() > 0 ){


      for(namespace in existingNamespaces.vals()) {
        let permissions : PermissionCollection = {
          read = Set.new<ListItem>();
          write = Set.new<ListItem>();
          admin = Set.new<ListItem>();
          permissions = Set.new<ListItem>();
        };

        for(thisPermission in namespace.permissions.vals()){
          switch(thisPermission.0){
            case(#Read) {
               Set.add(permissions.read, listItemHash, thisPermission.1);
            };
            case(#Write) {
               Set.add(permissions.write, listItemHash, thisPermission.1);
            };
            case(#Admin) {
               Set.add(permissions.admin, listItemHash, thisPermission.1);
            };
            case(#Permissions) {
               Set.add(permissions.permissions, listItemHash, thisPermission.1);
            };
          };
          let permissionIndexItem = switch(Map.get(permissionsIndex, listItemHash, thisPermission.1)){
            case(?permissionIndexItem) {
              permissionIndexItem;
            };
            case(null) {
              let list = Set.new<List>();
              ignore Map.put(permissionsIndex, listItemHash, thisPermission.1, list);
              list;
            };
          };
          Set.add(permissionIndexItem, Set.thash, namespace.namespace);
        };

        let members = Set.new<ListItem>();

        for (member in namespace.members.vals()) {
          Set.add(members, listItemHash, member);
          let memberIndexItem = switch(Map.get(memberIndex, listItemHash, member)){
            case(?memberIndexItem) {
              memberIndexItem;
            };
            case(null) {
              let list = Set.new<List>();
              ignore Map.put(memberIndex, listItemHash, member, list);
              list;
            };
          };
          Set.add(memberIndexItem, Set.thash, namespace.namespace);
        };

        let namespaceRecord : NamespaceRecord = {
          namespace = namespace.namespace;
          permissions = permissions;
          members = members;
          metadata = namespace.metadata;
        };

        ignore BTree.insert(namespacesStore, Text.compare, namespace.namespace, namespaceRecord);
      };
      
    };

    let state : v0_1_0.State = {
      namespaceStore = namespacesStore;
      domainIndex = domainIndex;
      memberIndex = memberIndex;
      icrc85 = {
        var nextCycleActionId = null;
        var lastActionReported = null;
        var activeActions = 0;
      };
      permissionsIndex = permissionsIndex;
      var owner = caller;
      metadata = {
        var permittedDrift = permittedDrift;
        var maxTake = maxTake;
        var defaultTake = defaultTake;
        var txWindow = txWindow;
      };
      var tt = null;
    };

    

    return #v0_1_0(#data(state));
  };

};
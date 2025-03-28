import List "mo:base/List";


module {
  public type Identity = Principal;

  public type TransactionID = Nat;

  public type Account = {
        owner : Principal;
        subaccount : ?Subaccount;
  };

  public type ListItem = {
    #Account : Account;
    #Identity : Identity;
    #DataItem : DataItem;
    #List : List;
  };

  public type PropertyShared = {name : Text; value : DataItem; immutable : Bool};

  public type DataItem = {
    #Int : Int;
    #Int8: Int8;
    #Int16: Int16;
    #Int32: Int32;
    #Int64: Int64;
    #Ints: [Int];
    #Nat : Nat;
    #Nat8 : Nat8;
    #Nat16 : Nat16;
    #Nat32 : Nat32;
    #Nat64 : Nat64;
    #Float : Float;
    #Text : Text;
    #Bool : Bool;
    #Blob : Blob;
    #Class : [PropertyShared];
    #Principal : Principal;
    #Option : ?DataItem;
    #Array :  [DataItem];
    #Nats: [Nat];
    #Floats: [Float]; 
    #Bytes : [Nat8];
    #ValueMap : [(DataItem, DataItem)];
    #Map : DataItemMap;
    #Set : [DataItem];
  };

  public type Value = {
    #Int : Int;
    #Nat : Nat;
    #Text : Text;
    #Blob : Blob;
    #Array :  [Value];
    #Map : [(Text, Value)];
  };

  public type DataItemMap = [(Text, DataItem)];

  public type List = Text;

  public type Subaccount = Blob;

  public type Permission = {
    #Admin;
    #Read;
    #Write;
    #Permissions;
  };

  public type AuthorizeRequestItem = (ListItem, [[List]]);

  public type AuthorizeResponse = [Bool];

  public type AuthorizeRequest = [AuthorizeRequestItem];

  public type IdentitiesResponse = [Identity];

  public type ListsResponse = [List];

  public type ManageListPropertyRequestAction = {
    #Create : {
      admin : ?ListItem;
      metadata : DataItemMap;
      members: [(ListItem, ?DataItemMap)];
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

  public type ManageListMembershipError = {
    #Unauthorized;
    #TooManyRequests;
    #NotFound;
    #Exists;
    #Other : Text;
  };

  public type ManageListMembershipResponse = [ManageListMembershipResult];

  public type ManageListMembershipResult = ?{
    #Ok : TransactionID;
    #Err : ManageListMembershipError;
  };

  public type ManageListPropertyError = {
     #Unauthorized;
    #NotFound;
    #TooManyRequests;
    #Exists;
    #IllegalAdmin;
    #IllegalPermission;
    #Other : Text;
  };

  public type ManageListPropertyResponse = [ManageListPropertyResult];

  public type ManageListPropertyResult = ?{
    #Ok : TransactionID;
    
    #Err : ManageListPropertyError;
  };

  public type ManageRequest = [ManageRequestItem];

  public type ManageRequestItem = {
    #UpdateDefaultTake : Nat;
    #UpdateMaxTake : Nat;
    #UpdatePermittedDrift : Nat;
    #UpdateTxWindow : Nat;
  };

  public type ManageResultError = {
    #Unauthorized;
    #TooManyRequests;
    #Other : Text;
  };

  public type ManageResponse = [ManageResult];

  public type ManageResult = ?{
    #Ok;
    #Err : ManageResultError;
  };

  public type IdentityRequestResult = {
    #Ok : IdentityToken;
    #Err : IdentityRequestError;
  };

  public type IdentityRequestError = {
    #NotFound;
    #NotAMember;
    #ExpirationError;
    #Other : Text;
  };

  public type IdentityToken = Value;
  
  /* {
    authority : Principal;
    namespace : Text;
    issued : Nat;
    expires : ?Nat;
    member : ListItem;
    nonce : Nat;
  }; */

  public type IdentityCertificate = {
    token : IdentityToken;
    witness : Blob;
    certificate : Blob;
  };

  public type Witness = {
    #empty;
    #pruned : Blob;
    #fork : (Witness, Witness);
    #labeled : (Blob, Witness);
    #leaf : Blob;
  };
  public type ManageListMembershipRequest = [ManageListMembershipRequestItem];

  public type ManageListMembershipRequestItem = {
    list : List;
    memo : ?Blob;
    from_subaccount: ?Subaccount;
    created_at_time : ?Nat;
    action : ManageListMembershipAction;
  };

  public type MapModifier = (Text, ?DataItem);

  public type ManageListMembershipAction = {
    #Add : (ListItem, ?DataItemMap);
    #Remove : ListItem;
    #Update : (ListItem, MapModifier);
  };

  public type ManageListPropertyRequest = [ManageListPropertyRequestItem];

  public type ManageListPropertyRequestItem = {
    list : List;
    memo : ?Blob;
    from_subaccount: ?Subaccount;
    created_at_time : ?Nat;
    action : ManageListPropertyRequestAction;
  };

  public type AuthorizedRequestItem = (ListItem, [[List]]);

  public type PermissionList = [PermissionListItem];

  public type PermissionListItem = (Permission, ListItem);

  public type ListRecord = {
    list : List;
    metadata :?DataItemMap;
  };

  public type Service = actor {
    icrc75_metadata: () -> async DataItemMap;
    icrc75_manage : (ManageRequest) -> async ManageResult;
    icrc75_manage_list_membership : (ManageListMembershipRequest) -> async ManageListMembershipResponse;
    icrc75_manage_list_properties : (ManageListPropertyRequest) -> async ManageListPropertyResponse;
    icrc75_get_lists : query (?Text, Bool, ?List, ?Nat) ->  async [ListRecord];
    icrc75_get_list_members_admin : query (List, ?ListItem, ?Nat) ->  async [(ListItem, ?DataItemMap)];
    icrc75_get_list_permissions_admin : query (List,  ?Permission, ?PermissionListItem, ?Nat) ->  async PermissionList;
    icrc75_get_list_lists : query (List, ?List, ?Nat) ->  async [List];
    icrc75_member_of : query(ListItem, ?List, ?Nat) ->  async[List];
    icrc75_is_member : query([AuthorizedRequestItem]) ->  async [Bool];
    icrc75_request_token : (ListItem, List, ?Nat) -> async IdentityRequestResult;
    icrc75_retrieve_token : (IdentityToken, Witness) -> async IdentityCertificate;
  };
};



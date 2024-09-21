
# ICRC-75 Minimal Membership Standard Implementation

This repository contains the implementation of the ICRC-75 standard, a minimal membership standard for the Internet Computer. The ICRC-75 standard enables the management of composable identity lists, facilitating secure and flexible group structures with various permissions.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Getting Started](#getting-started)
- [Usage](#usage)
- [API Reference](#api-reference)
- [Data Structures](#data-structures)
- [ICRC-75 Standard](#icrc-75-standard)
- [Contributing](#contributing)
- [License](#license)

## Overview

The ICRC-75 standard provides a framework for creating and managing identity lists on the Internet Computer. These lists can include identities, accounts, other lists, and unstructured data items, allowing for complex, hierarchical group structures. Permissions can be assigned to control access and modifications to these lists.

## Features

- **Identity Management**: Use principals to represent identities.
- **Composable Lists**: Create lists that can include other lists, identities, accounts, and data items.
- **Permission Control**: Assign and manage permissions for reading, writing, administrating, and modifying permissions of lists.
- **Data Migration**: Support for data migration across different state formats.
- **Event Listeners**: Register listeners for membership and property changes.
- **Efficient Storage**: Utilize BTree and other efficient data structures for storing lists and permissions.

## Getting Started

### Prerequisites

- [Dfinity SDK](https://sdk.dfinity.org/)
- [Motoko](https://sdk.dfinity.org/docs/language-guide/motoko.html) programming language

### Installation

1. Clone the repository:
   ```bash
   mops add icrc75-mo
   ```

## Usage

### Initializing the State

Initialize the state of the ICRC-75 system with:
```motoko
let initialState = ICRC75.initialState();
let currentState = #v0_1_0(#data(initialState));
```

### Managing Lists and Membership

Create a list:
```motoko
let createAction = #Create({
  admin = null;
  metadata = [];
  members = []
});
let request = {
  list = "exampleList";
  memo = null;
  created_at_time = null;
  from_subaccount = null;
  action = createAction
};
let result = ICRC75.manage_list_properties(caller, [request], null);
```

Add a member to a list:
```motoko
let addAction = #Add(#Identity(caller));
let request = {
  list = "exampleList";
  memo = null;
  created_at_time = null;
  from_subaccount = null;
  action = addAction
};
let result = ICRC75.manage_list_membership(caller, [request], null);
```

### Querying Lists and Membership

Get lists:
```motoko
let lists = ICRC75.get_lists(caller, null, false, null, null);
```

Check if an identity is a member of a list:
```motoko
let isMember = ICRC75.is_member(caller, [(#Identity(caller), [[]])]);
```

## API Reference

### Public Types

- `State`
- `CurrentState`
- `Environment`
- `InitArgs`
- `Value`
- `ICRC16Map`
- `DataItem`
- `List`
- `ListItem`
- `Identity`
- `Account`
- `Permission`
- `ManageRequest`
- `ManageResponse`
- `ManageListMembershipRequest`
- `ManageListPropertyRequest`
- `AuthorizedRequestItem`

### Public Functions

- `initialState() : State`
- `migrate(State, CurrentState, ?State, Principal) : CurrentState`
- `ICRC75(stored: ?State, canister: Principal, environment: Environment)`
- `get_state() : CurrentState`
- `metadata() : ICRC16Map`
- `registerMembershipChangeListener(namespace: Text, remote_func: MembershipChangeListener)`
- `registerPropertyChangeListener(namespace: Text, remote_func: PropertyChangeListener)`
- `updateProperties(caller: Principal, request: ManageRequest) : ManageResponse`
- `get_stats() : Stats`
- `accountToValue(acc: Account) : Value`
- `manage_list_membership(caller: Principal, request: ManageListMembershipRequest, canChange: CanChangeMembership) : async* ManageListMembershipResponse`
- `manage_list_properties(caller: Principal, request: ManageListPropertyRequest, canChange: CanChangeProperty) : async* ManageListPropertyResponse`
- `get_lists(caller: Principal, filter: ?Text, bMetadata: Bool, prev: ?List, take: ?Nat) : [ListRecord]`
- `findIdentityInList(principal: Principal, list: Text) : Bool`
- `get_list_members_admin(caller: Principal, namespace: Text, prev: ?ListItem, take: ?Nat) : [ListItem]`
- `get_list_permission_admin(caller: Principal, namespace: Text, filter: ?Permission, prev: ?PermissionListItem, take: ?Nat) : PermissionList`
- `get_list_lists(caller: Principal, namespace: List, prev: ?List, take: ?Nat) : [List]`
- `member_of(caller: Principal, listItem: ListItem, prev: ?List, take: ?Nat) : [List]`
- `is_member(caller: Principal, request: [AuthorizedRequestItem]) : [Bool]`
- `request_token<system>(caller: Principal, item: ListItem, list: List, exp: ?Nat)`
- `query retrieve_token(caller: Principal, token : IdentityToken ) : IdentityCertificate`

## Data Structures

### Identity

```motoko
type Identity = Principal;
```

### Account

```motoko
type Account = {
  owner : Principal;
  subaccount : ?Subaccount;
};
```

### DataItem

```motoko
type DataItem = ICRC16.CandyShared;
```

### List

```motoko
type List = Text;
```

### Permission

```motoko
type Permission = {
  #Admin;
  #Read;
  #Write;
  #Permissions;
};
```

## Token System Overview

The ICRC-75 implementation provides a token system that enables the attestation of membership within a specified identity list. This system issues and validates **IdentityTokens**, allowing users to prove their membership in a list, manage token expiration, and retrieve token details for verification purposes. The token system plays a crucial role in securely validating that an individual or entity belongs to a specific group or namespace.

### Token Request Workflow

1. **Requesting a Token**:  
   Users can request a token for a specific identity list by invoking the `request_token` function. This function checks the membership of the requesting principal within the specified list. If the requester is found to be a valid member, a token is generated.

2. **Expiration Management**:  
   Optionally, tokens can have an expiration time specified by the requester. However, the expiration time cannot exceed the maximum validity period set in the list's metadata (`icrc75:maxValidNS`). If no expiration time is provided, the token may remain valid indefinitely, depending on the list's configuration.

3. **Token Structure**:  
   A token includes several key-value pairs:
   - **`identity`**: The principal (or member) for whom the token is issued.
   - **`namespace`**: The identity list (or namespace) to which the token belongs.
   - **`issued`**: The timestamp when the token was issued.
   - **`authority`**: The canister issuing the token.
   - **`nonce`**: A unique value to prevent replay attacks.
   - **`expires`** (optional): The expiration time of the token, if applicable.

4. **Certification**:  
   If the environment supports certification, the token is certified using the canister's certification store. A certified token allows external parties to verify the integrity of the token using cryptographic techniques. The certification process ensures that the issued token is legitimate and has not been tampered with.

### Token Retrieval and Validation

1. **Token Retrieval**:  
   A previously issued token can be retrieved by invoking the `retrieve_token` function. This function verifies the integrity of the token by:
   - Checking whether the token has expired.
   - Validating the nonce against the stored certificate data.

2. **Certificate and Witness Verification**:  
   Upon retrieving the token, the function also generates a **witness** that can be used alongside the certificate to prove the validity of the token to third parties. This involves revealing the token’s inclusion in the certification tree and generating a cryptographic proof that external services or parties can validate.

3. **Token Integrity**:  
   The system ensures that the integrity of the token is maintained by performing checks on the nonce, authority, and membership status. If any part of the token is invalid or expired, appropriate errors are returned.

### Error Handling

- **NotFound**: Returned when the requested list does not exist.
- **NotAMember**: Returned when the requesting principal is not a member of the specified list.
- **ExpirationError**: Returned if the requested expiration time exceeds the maximum allowed for the list.
- **ExpiredToken**: Raised during token retrieval if the token has expired.

### Example Use Cases

- **Requesting a Token**:
   ```motoko
   let result = ICRC75.request_token(caller, #Identity(caller), "exampleList", ?3600);
   ```

- **Retrieving and Verifying a Token**:
   ```motoko
   let certificate = ICRC75.retrieve_token(caller, requestedToken);
   // Validate the certificate externally using the witness and certificate provided.
   ```

The token system allows for flexible and secure attestation of membership, enabling integration with external systems that require proof of membership in a decentralized manner.

## ICRC-75 Standard

For more details on the ICRC-75 standard, refer to the [ICRC-75 Standard Document](https://github.com/dfinity/ICRC/issues/75).


## OVS Default Behavior

This motoko class has a default OVS behavior that sends cycles to the developer to provide funding for maintenance and continued development. In accordance with the OVS specification and ICRC85, this behavior may be overridden by another OVS sharing heuristic or turned off. We encourage all users to implement some form of OVS sharing as it helps us provide quality software and support to the community.

Default behavior: 1 XDR per month for up to 10,000 actions;  1 additional XDR per month for each additional 10,000 actions. Max of 10 XDR per month per canister.

Default Beneficiary: ICDevs.org

Additional Behavior: Utilizes the timerTool by Pan Industrial: https://github.com/PanIndustrial-Org/timerTool

## Contributing

We welcome contributions to improve the ICRC-75 implementation. Please submit issues and pull requests via GitHub.

## License

This project is licensed under the MIT License.

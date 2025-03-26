Audit Log: Differences Between icrc75v1.md and icrc75v2.md
========================================================

This document provides a detailed log of the differences identified between the two versions of the ICRC-75 standard documentation:

1. Data Representations
-----------------------
- In both versions, the definition of `Identity`, `Account`, and `List` remain similar.
- Difference in DataItem:
  - icrc75v1.md: ```candid
type DataItem = ICRC16;
```
  - icrc75.md: ```candid
type DataItem = ICRC16;
```
  However, in icrc75.md additional type definitions are provided:
    - `type Map = vec record {text; ICRC16};`
    - `type MapModifier = vec record {text, opt ICRC16};`
  These additions indicate an extension of data structures to handle metadata with maps and structures that can modify them easily.

4. Types for Managing Lists
-----------------------------
- The structure `ListItem` is defined in both documents. The icrc75.md version slightly modifies the syntax by including a missing comma in the variant declaration:
  - icrc75v1.md:
    ```candid
type ListItem = variant {
    Identity: Identity;
    List: List;
    Account: Account;
    DataItem: DataItem;
};
```
  - icrc75.md:
    ```candid
type ListItem = variant {
    Identity: Identity;
    List: List;
    Account: Account,
    DataItem: DataItem
};
```
  This correction clarifies the variant structure.

- For `ManageListPropertyRequestAction`:
  - In icrc75v1.md, the Metadata action is declared as:
    ```candid
    Metadata: {
      key = text;
      value = opt Value
    };
    ```
  - In icrc75.md, it is changed to:
    ```candid
    Metadata: MapModifier;
    ```
  Reflecting an updated approach in handling metadata modifications.

5. Function Definitions for List Management
---------------------------------------------
- In the icrc75v1.md version, the `icrc_75_manage_list_membership` function includes only `Add` and `Remove` actions:
  ```candid
  action: variant { 
    Add: ListItem; 
    Remove: ListItem
  }
  ```
- In icrc75.md, an additional `Update` variant is added, along with an option to pass metadata:
  ```candid
  action: variant { 
    Add: record {ListItem, opt Map};  // List item and optional Metadata
    Remove: ListItem;
    Update: record {ListItem, MapModifier}
  }
  ```
  This represents an enhancement to support updates to existing list items with associated metadata modifications.

6. Function Definitions for Query Functions
---------------------------------------------
- The signature details for functions such as `icrc_75_get_list_members_admin` exhibit minor changes. In icrc75.md, the return type now wraps results in a record with `opt Metadata` where applicable, providing a way for administrators to get to the metadata.

7. Identity Tokens
------------------
- The definition of `IdentityToken` shows notable differences:
  - icrc75v1.md:
    ```candid
type IdentityToken = Value;
    ```
  - icrc75.md:
    ```candid
type IdentityToken = DataItem; // #Map([{certificateItems}]);
    ```
  This update aligns the IdentityToken type with the newly defined DataItem type in the updated document, ensuring consistency with other extended data structures.

8. Additional Clarifications and Corrections
--------------------------------------------
- Throughout the new document (icrc75.md), minor typographical corrections and clarifications have been made (e.g., adding missing commas, reordering explanations for clarity).
- Additional type definitions and metadata handling constructs (Map and MapModifier) are introduced in the icrc75.md version to support more complex data manipulation scenarios.

Conclusion
----------
All changes have been captured and documented above. The differences primarily reflect an effort to improve clarity, support richer metadata, and facilitate updates to list items through the introduction of an Update variant. These modifications enhance the standard's robustness and flexibility in managing decentralized lists.

End of Audit Log.
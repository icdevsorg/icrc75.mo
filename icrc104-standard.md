## ICRC-104: Rule-Based Membership Manager Standard

| ICRC | Title                     | Author                                    | Discussions                                                         | Status | Type            | Category               | Created    |
|:----:|:-------------------------|:------------------------------------------|:--------------------------------------------------------------------|:------:|:----------------|:-----------------------|:----------:|
| 104   | Rule-Based Membership Manager | [Austin Fatheree](https://github.com/skilesare) | [ICRC-104 Discussion](https://github.com/dfinity/ICRC/issues/104) | Draft  | Standards Track | Membership Management | 2024-05-15 |

### Overview

**ICRC-104: Rule-Based Membership Manager Standard** establishes a generic protocol for managing and manipulating memberships within lists defined by the **ICRC-75 Minimal Membership Standard**. This standard allows developers to create scalable and adaptable applications by applying customizable rule sets to membership lists, enabling operations such as role rotation, house sorting, and other membership-driven functionalities.

### Objectives

- **Modularity**: Ensure the standard is modular and can be integrated with existing ICRC-75 canisters without dependency.
- **Flexibility**: Allow developers to define and apply diverse rule sets without strict schema enforcement.
- **Interoperability**: Facilitate seamless interaction between different canisters implementing this standard.
- **Scalability**: Support operations on large membership lists efficiently.

### Data Representations

#### Core Entities

- **RuleSetNamespace**: A unique identifier for a set of rules, allowing multiple rule sets to coexist without conflict.

  ```candid
  type RuleSetNamespace = Text;
  ```

- **ICRC75Change**: Represents changes applied to a membership list after rule evaluation.

  ```candid
  type ICRC75Change = record {
      icrc75Canister: principal;
      list: text;
      changes: vec ChangeDetail;
  };
  
  type ChangeDetail = variant {
      AddedMember: ListItem;    // Member added to the list
      RemovedMember: ListItem;  // Member removed from the list
      AddedPermission: record { Role; ListItem };    // Permission added
      RemovedPermission: record { Role; ListItem };  // Permission removed
      RreateList: List;        // New list created
      DeleteList: List;        // List deleted
      ChangeListName: record { oldName: List; newName: List }; // List renamed
      UpdateMetadata: record { path: Text; value: ?ICRC16 }; // Metadata updated
  };
  ```


### Function Definitions

#### Core Methods

- **icrc104_apply_rules**

  Applies a set of rules from a specified namespace to a target membership list. This function evaluates the rules and performs necessary membership modifications based on the rule set. It returns the transactions that were performed. If the local **ICRC-104** canister does not keep a transaction log, it should refer to the **ICRC-75** transactions. If neither the **ICRC-104** canister nor the **ICRC-75** canister keeps a transaction log, specific changes can be returned in the `ICRC75Changes` variant.

  ```candid
  type List = text;

  type ListItem = variant {
      Identity: Identity;
      List: List;
      Account: Account
      DataItem: DataItem
  };

  type DataItem = ICRC16;
  
  type DataItemMap = vec {
    record {text; ICRC16};
  };

  type ApplyError = variant {
      Unauthorized;
      RuleSetNotFound;
      InvalidRuleSetFormat: text;
      ExecutionFailed: text;
  };
  
  type ApplyResult = variant {
      Ok: variant {
          RemoteTrx: record {
              metadata: DataItemMap;
              transactions: vec nat;
          };
          LocalTrx: record {
              metadata: DataItemMap;
              transactions: vec nat;
          };
          ICRC75Changes: record {
              metadata: DataItemMap;
              changes: vec ICRC75Change;
          };
      };
      Err: ApplyError;
  };
  
  service : {
      // Core Methods
      icrc104_apply_rules: (record {
          icrc75Canister: principal;
          target_list: List;                     // The list to apply rules on
          members: vec ListItem;                // Optional identity triggering the rule application
          rule_namespace: RuleSetNamespace;     // Namespace identifying the rule set to apply
          metadata: opt Map;                     // Optional metadata associated with the operation
      }) -> (ApplyResult);
  
      icrc104_simulate_rule: (
        Principal, //simulate as if called by a different principal
        record {
          icrc75Canister: principal;
          target_list: List;                     // The list to apply rules on
          identity: opt Identity;                // Optional identity triggering the rule application
          rule_namespace: RuleSetNamespace;     // Namespace identifying the rule set to apply
          metadata: opt Map;                     // Optional metadata associated with the operation
      }) -> variant {
        #Ok : record {
          metadata: ICRC16;
          changes: vec ICRC75Change;
        };
        #Err: ApplyError
      };
  };
  ```


### Metadata Handling

The `metadata` field allows for the inclusion of additional data related to the rule application or membership changes. This data is treated as opaque by the standard, providing developers the flexibility to include certified data or trusted information as required by their specific application context. Metadata schemas are not prescribed by the standard, granting developers the autonomy to define schemas that best fit their needs. The same applies to the return metadata value.

Metadata fields use ICRC16 Value fields to return metadata.

While **ICRC-104** does not prescribe specific metadata schemas, it is recommended to follow the guidelines below to ensure consistency and interoperability:

- **Certified Data**: When including certified data, use standardized encoding (e.g., JSON Web Tokens or canister-signed certificates) and include cryptographic signatures to verify authenticity.
  
- **Inter-Canister Trust**: Establish trusted relationships between canisters through shared principals or mutual authentication mechanisms to validate metadata sources.
  
- **Schema Flexibility**: Allow metadata to be extensible by using key-value pairs with namespaced keys, preventing collisions and ensuring clarity.

### Block Schema

To ensure traceability and auditability, all operations are logged immutably to an **ICRC-3** transaction log using the **ICRC-75** block schema. Below is the specific schema for rule-based membership management actions.

#### Rule Application Action Block

1. **`btype` field**: Must be set to `"104ruleApplication"`
2. **`tx` field**:
   - `icrc75_canister: principal` – Identifies the ICRC-75 canister to use for the service
   - `target_list: Text` – Identifier of the target list affected
   - `rule_namespace: Text` – Namespace of the rule set applied
   - `changes: ICRC75Change` – Details of members added or removed
   - `triggered_by: opt Principal` – Identity that triggered the rule application (if any)
   - `metadata?: Value | ICRC-61` – Metadata used for the transaction or pointer to external metadata

```candid
type RuleApplicationBlock = record {
    btype: Text; // "104ruleApplication"
    ts: Nat; //time of record
    tx: record {
        icrc75_canister: principal;
        target_list: Text;
        rule_namespace: Text;
        changes: ICRC75Change;
        triggered_by: opt Principal;
        metadata: opt Value | ICRC61;
    };
};
```

### Security Considerations

- **Authorization Enforcement**: Canister developers are responsible for strictly enforcing permissions to ensure only authorized entities can define, update, or remove rule sets.
  
- **Immutable Logging**: Utilize **ICRC-75**'s block schema to immutably log all rule applications and membership changes, ensuring a tamper-proof audit trail.
  
- **Metadata Validation**: While metadata is treated as opaque, it is recommended to implement validation checks to prevent the inclusion of malicious or oversized data.
  
- **Namespace Isolation**: Ensure that rule sets within different namespaces do not interfere with each other, maintaining isolation and preventing cross-namespace rule conflicts.

### Extensibility

**ICRC-104** is designed to be extensible, allowing future enhancements and additional rule types without disrupting existing implementations. New rule variants can be introduced as needed, catering to evolving membership management requirements across different applications.

Additionally, interoperability with other ICRC standards, such as **ICRC-10**, can be achieved by referencing these standards within metadata or leveraging shared functionalities. This ensures comprehensive integration capabilities and fosters a cohesive ICRC ecosystem.

### Dependence on other ICRC Standards

- **Interoperability with ICRC-10**: 

The result MUST include the following response at the `icrc10_supported_standards` endpoint `{name="ICRC-104"; url="https://github.com/dfinity/ICRCs/ICRC-104"}.

- **Interoperability with ICRC-3**: 

A ICRC-104 canister MAY implement an ICRC-3 ledger

### Conclusion

The **ICRC-104: Rule-Based Membership Manager Standard** offers a comprehensive and flexible framework for managing memberships through customizable rules. By abstracting the core functionalities of applications like **Role Rotator** and **House Sorter**, this standard empowers developers to create a wide range of membership-driven applications with ease and consistency. Its alignment with the modularity principles of **ICRC-75** ensures seamless integration and interoperability within the ICRC ecosystem.

Developers are encouraged to adhere to this standard to maximize interoperability and leverage the full potential of the ICRC framework. Future iterations may expand upon this standard to incorporate additional functionalities and integrations with other ICRC specifications.
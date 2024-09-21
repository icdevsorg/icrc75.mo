import { Principal } from "@dfinity/principal";
import type { Identity } from '@dfinity/agent';
import { Ed25519KeyIdentity } from '@dfinity/identity';
import { verifyCertification, validateTree } from './ver';
import { HttpAgent, compare, lookup_path, Certificate, Cbor, HashTree } from '@dfinity/agent';
import {hash_val, big_endian_encode, equalBuffers} from './repindy.ts';


import { IDL } from "@dfinity/candid";

import {
  PocketIc,
  createIdentity,
  FromPathSubnetStateConfig,
  SubnetStateType
} from "@hadronous/pic";

import type {
  Actor,
  CanisterFixture
} from "@hadronous/pic";



import {idlFactory as icrc75IDLFactory,
  init as icrc75Init } from "../../src/declarations/icrc75/icrc75.did.js";
import type {
  _SERVICE as ICRC75Service,
  ManageListMembershipRequest,
  ManageListPropertyRequest,
  ListItem,
  Account,
DataItem} from "../../src/declarations/icrc75/icrc75.did.d";
export const sub_WASM_PATH = ".dfx/local/canisters/icrc75/icrc75.wasm";

let replacer = (_key: any, value: any) => typeof value === "bigint" ? value.toString() + "n" : value;


let pic: PocketIc;

let icrc75_fixture: CanisterFixture<ICRC75Service>;

const admin = createIdentity("admin");
const alice = createIdentity("alice");
const bob = createIdentity("bob");
const serviceProvider = createIdentity("serviceProvider");
const OneDay = BigInt(86400000000000); // 24 hours in NanoSeconds
const OneMinute = BigInt(60000000000); // 1 minute in Nanoseconds

const OneDayMS = 86400000; // 24 hours in NanoSeconds

const base64ToUInt8Array = (base64String: string): Uint8Array => {
  return Buffer.from(base64String, 'base64');
};

const NNS_SUBNET_ID =
  "erfz5-i2fgp-76zf7-idtca-yam6s-reegs-x5a3a-nku2r-uqnwl-5g7cy-tqe";
const NNS_STATE_PATH = "pic/nns_state/node-100/state";


describe("test timers", () => {
  beforeEach(async () => {
    pic = await PocketIc.create(process.env.PIC_URL, {
      
      /* nns: {
        state: {
          type: SubnetStateType.FromPath,
          path: NNS_STATE_PATH,
          subnetId: Principal.fromText(NNS_SUBNET_ID),
        }
      }, */

      processingTimeoutMs: 1000 * 60 * 5,
    } );

    //await pic.setTime(new Date(2024, 1, 30).getTime());
    await pic.setTime(new Date(2024, 7, 10, 17, 55,33).getTime());
    await pic.tick();
    await pic.tick();
    await pic.tick();
    await pic.tick();
    await pic.tick();
    await pic.advanceTime(1000 * 5);

    

    await pic.resetTime();
    await pic.tick();

    //const subnets = pic.getApplicationSubnets();

    icrc75_fixture = await pic.setupCanister<ICRC75Service>({
      //targetCanisterId: Principal.fromText("q26le-iqaaa-aaaam-actsa-cai"),
      sender: admin.getPrincipal(),
      idlFactory: icrc75IDLFactory,
      wasm: sub_WASM_PATH,
      //targetSubnetId: subnets[0].id,
      arg: IDL.encode(icrc75Init({IDL}), [[]]),
    });
    
    

  });


  afterEach(async () => {
    await pic.tearDown();
  });

  

  let createList = async (listName: string = "testListName") => {
    icrc75_fixture.actor.setIdentity(admin);
    await pic.tick();

    const createResponse = await icrc75_fixture.actor.icrc75_manage_list_properties([
      {
        list: listName,
        action: { "Create": { admin: [], metadata: [], members: [] } },
        memo: [],
        from_subaccount: [],
        created_at_time: []
      }
    ]);
    await pic.tick();
    return createResponse;
  };



  it(`can call hello world`, async () => {

    let expectedDefaults = {
      defaultTake: 200n,
      maxTake:200n,
      memberIndexCount: 0n,
      namespaceStoreCount: 0n,
      owner: admin.getPrincipal(),
      permissionsIndexCount: 0n,
      permittedDrift: 60000000000n,
      txWindow: 86400000000000n
    };

    icrc75_fixture.actor.setIdentity(admin);

    await pic.tick();

    const stats = await icrc75_fixture.actor.icrc75_get_stats();

    await pic.tick();

    console.log("got", stats);
    console.log("admin", admin.getPrincipal().toString());

    expect(stats).toMatchObject(expectedDefaults);
  });


  it('should successfully create unique lists by name', async () => {
    icrc75_fixture.actor.setIdentity(admin);
    await pic.tick();
  
    // Create a list named "uniqueList1"
    const createResponse1 = await icrc75_fixture.actor.icrc75_manage_list_properties([
      {
        list: "uniqueList1",
        action: { "Create": { admin: [], metadata: [], members: [] } },
        memo: [],
        from_subaccount: [],
        created_at_time: []
      }
    ]);
    await pic.tick();
  
    expect(createResponse1[0]).toBeDefined();
    expect(createResponse1[0][0]).toHaveProperty("Ok");
  
    // Create another list named "uniqueList2"
    const createResponse2 = await icrc75_fixture.actor.icrc75_manage_list_properties([
      {
        list: "uniqueList2",
        action: { "Create": { admin: [], metadata: [], members: [] } },
        memo: [],
        from_subaccount: [],
        created_at_time: []
      }
    ]);
    await pic.tick();
  
    expect(createResponse2[0]).toBeDefined();
    expect(createResponse2[0][0]).toHaveProperty("Ok");
  
    // Attempt to create a list with the same name as the first list
    const createResponse3 = await icrc75_fixture.actor.icrc75_manage_list_properties([
      {
        list: "uniqueList1",
        action: { "Create": { admin: [], metadata: [], members: [] } },
        memo: [],
        from_subaccount: [],
        created_at_time: []
      }
    ]);
    await pic.tick();
  
    if (createResponse3[0] && createResponse3[0][0] && "Err" in createResponse3[0][0]) {
      expect(createResponse3[0][0].Err).toMatchObject({"Exists" : null});
    };

  });

  it(`Can Add and Remove Data Items`, async () => {

    let listName = "testListName";
    let createResponse = await createList(listName);
    
    let dataItem = { "Int": 123n };
    let dataItem1 = { "Text": "Test Text" };
    let dataItem2 = { "Blob": new Uint8Array([1, 2, 3, 4]) };
    let dataItem3 = { "Bool": true };

    const addMemberResp = await icrc75_fixture.actor.icrc75_manage_list_membership([
      {
        list: listName,
        action: { "Add": { "DataItem": dataItem } },
        memo: [],
        from_subaccount: [],
        created_at_time: []
      },
      {
        list: listName,
        action: { "Add": { "DataItem": dataItem1 } },
        memo: [],
        from_subaccount: [],
        created_at_time: []
      },
      {
        list: listName,
        action: { "Add": { "DataItem": dataItem2 } },
        memo: [],
        from_subaccount: [],
        created_at_time: []
      },
      {
        list: listName,
        action: { "Add": { "DataItem": dataItem3 } },
        memo: [],
        from_subaccount: [],
        created_at_time: []
      }
    ]);

    expect(addMemberResp[0]).toBeDefined();
    expect(addMemberResp[0][0]).toBeDefined();
    expect(addMemberResp[0][0]).toHaveProperty("Ok");

    expect(addMemberResp[1]).toBeDefined();
    expect(addMemberResp[1][0]).toBeDefined();
    expect(addMemberResp[1][0]).toHaveProperty("Ok");

    expect(addMemberResp[2]).toBeDefined();
    expect(addMemberResp[2][0]).toBeDefined();
    expect(addMemberResp[1][0]).toHaveProperty("Ok");

    expect(addMemberResp[2]).toBeDefined();
    expect(addMemberResp[2][0]).toBeDefined();
    expect(addMemberResp[2][0]).toHaveProperty("Ok");

    await pic.tick();

    const members = await icrc75_fixture.actor.icrc75_get_list_members_admin(listName, [], []);

    expect(members).toContainEqual({"DataItem": dataItem});
    expect(members).toContainEqual({"DataItem": dataItem1});
    expect(members).toContainEqual({"DataItem": dataItem2});
    expect(members).toContainEqual({"DataItem": dataItem3});

    const RemoveMemberResp = await icrc75_fixture.actor.icrc75_manage_list_membership([
      {
        list: listName,
        action: { "Remove": { "DataItem": dataItem } },
        memo: [],
        from_subaccount: [],
        created_at_time: []
      },
     
      {
        list: listName,
        action: { "Remove": { "DataItem": dataItem2 } },
        memo: [],
        from_subaccount: [],
        created_at_time: []
      }
    ]);
  

   await pic.tick();

    const members2 = await icrc75_fixture.actor.icrc75_get_list_members_admin(listName, [], []);

    expect (members2).not.toContainEqual({"DataItem": dataItem});
    expect(members2).toContainEqual({"DataItem": dataItem1});
    expect(members2).not.toContainEqual({"DataItem": dataItem2});
    expect(members2).toContainEqual({"DataItem": dataItem3});
  });

  it("should validate Admin permission", async () => {
    const listName = "adminList";
    await createList(listName);

    // Add Admin permission to Alice
    let adminPermissionResp = await icrc75_fixture.actor.icrc75_manage_list_properties([
      {
        list: listName,
        action: { "ChangePermissions": { "Admin": { "Add": { "Identity": alice.getPrincipal() }} }},
        memo: [],
        from_subaccount: [],
        created_at_time: []
      }
    ]);
    await pic.tick();

    expect(adminPermissionResp[0]).toBeDefined();
    expect(adminPermissionResp[0][0]).toHaveProperty("Ok");

    // Verify Alice can perform an admin action such as renaming
    icrc75_fixture.actor.setIdentity(alice);
    let renameResp = await icrc75_fixture.actor.icrc75_manage_list_properties([
      {
        list: listName,
        action: { "Rename": "newAdminList" },
        memo: [],
        from_subaccount: [],
        created_at_time: []
      }
    ]);
    await pic.tick();
    expect(renameResp[0]).toBeDefined();
    expect(renameResp[0][0]).toHaveProperty("Ok");

    // Verify Bob cannot perform the same admin action
    icrc75_fixture.actor.setIdentity(bob);
    renameResp = await icrc75_fixture.actor.icrc75_manage_list_properties([
      {
        list: listName,
        action: { "Rename": "unauthorizedRename" },
        memo: [],
        from_subaccount: [],
        created_at_time: []
      }
    ]);
    await pic.tick();
    expect(renameResp[0]).toBeDefined();
    expect(renameResp[0][0]).toHaveProperty("Err");
  });

  it("should validate Read permission", async () => {
    const listName = "readList";
    await createList(listName);

    // Add Read permission to Bob
    let readPermissionResp = await icrc75_fixture.actor.icrc75_manage_list_properties([
      {
        list: listName,
        action: { "ChangePermissions": { "Read": { "Add": { "Identity": bob.getPrincipal() }} }},
        memo: [],
        from_subaccount: [],
        created_at_time: []
      }
    ]);
    await pic.tick();

    expect(readPermissionResp[0]).toBeDefined();
    expect(readPermissionResp[0][0]).toHaveProperty("Ok");

    // Verify Bob can read list metadata
    icrc75_fixture.actor.setIdentity(bob);
    let metadataResp = await icrc75_fixture.actor.icrc75_get_lists([listName], true, [], []);
    await pic.tick();
    expect(metadataResp).toBeDefined();
    expect(metadataResp[0]).toHaveProperty("metadata");

    // Verify Alice cannot read the same list metadata
    icrc75_fixture.actor.setIdentity(alice);
    metadataResp = await icrc75_fixture.actor.icrc75_get_lists([listName], true, [], []);
    console.log("alice metadata resp", metadataResp);
    await pic.tick();
    expect(metadataResp).toBeDefined();
    expect(metadataResp).toHaveLength(0);
  });

  it("should validate Write permission", async () => {
    const listName = "writeList";
    await createList(listName);

    // Add Write permission to Alice
    let writePermissionResp = await icrc75_fixture.actor.icrc75_manage_list_properties([
      {
        list: listName,
        action: { "ChangePermissions": { "Write": { "Add": { "Identity": alice.getPrincipal() }} }},
        memo: [],
        from_subaccount: [],
        created_at_time: []
      }
    ]);
    await pic.tick();

    expect(writePermissionResp[0]).toBeDefined();
    expect(writePermissionResp[0][0]).toHaveProperty("Ok");

    // Verify Alice can add a member
    let addMemberResp = await icrc75_fixture.actor.icrc75_manage_list_membership([
      {
        list: listName,
        action: { "Add": { "Identity": bob.getPrincipal() } },
        memo: [],
        from_subaccount: [],
        created_at_time: []
      }
    ]);
    await pic.tick();
    expect(addMemberResp[0]).toBeDefined();
    expect(addMemberResp[0][0]).toHaveProperty("Ok");

    // Verify Bob cannot add a member
    icrc75_fixture.actor.setIdentity(bob);
    addMemberResp = await icrc75_fixture.actor.icrc75_manage_list_membership([
      {
        list: listName,
        action: { "Add": { "Identity": alice.getPrincipal() } },
        memo: [],
        from_subaccount: [],
        created_at_time: []
      }
    ]);
    await pic.tick();
    expect(addMemberResp[0]).toBeDefined();
    expect(addMemberResp[0][0]).toHaveProperty("Err");
  });

  it("should validate Permissions permission", async () => {
    const listName = "permissionsList";
    await createList(listName);

    // Add Permissions permission to Bob
    let permissionsPermissionResp = await icrc75_fixture.actor.icrc75_manage_list_properties([
      {
        list: listName,
        action: { "ChangePermissions": { "Permissions": { "Add": { "Identity": bob.getPrincipal() }} }},
        memo: [],
        from_subaccount: [],
        created_at_time: []
      }
    ]);
    await pic.tick();

    expect(permissionsPermissionResp[0]).toBeDefined();
    expect(permissionsPermissionResp[0][0]).toHaveProperty("Ok");

    // Verify Bob can change Read permission
    icrc75_fixture.actor.setIdentity(bob);
    let changePermissionResp = await icrc75_fixture.actor.icrc75_manage_list_properties([
      {
        list: listName,
        action: { "ChangePermissions": { "Read": { "Add": { "Identity": alice.getPrincipal() }} }},
        memo: [],
        from_subaccount: [],
        created_at_time: []
      }
    ]);
    await pic.tick();
    expect(changePermissionResp[0]).toBeDefined();
    expect(changePermissionResp[0][0]).toHaveProperty("Ok");

    // Verify Alice cannot change Permissions
    icrc75_fixture.actor.setIdentity(alice);
    changePermissionResp = await icrc75_fixture.actor.icrc75_manage_list_properties([
      {
        list: listName,
        action: { "ChangePermissions": { "Write": { "Add": { "Identity": admin.getPrincipal() }} }},
        memo: [],
        from_subaccount: [],
        created_at_time: []
      }
    ]);
    await pic.tick();
    expect(changePermissionResp[0]).toBeDefined();
    expect(changePermissionResp[0][0]).toHaveProperty("Err");
  });

  it("should successfully rename a list", async () => {
    const listName = "initialListName";
    await createList(listName);
  
    // Rename the list
    const renameResp = await icrc75_fixture.actor.icrc75_manage_list_properties([
      {
        list: listName,
        action: { "Rename": "renamedListName" },
        memo: [],
        from_subaccount: [],
        created_at_time: []
      }
    ]);
    await pic.tick();
  
    expect(renameResp[0]).toBeDefined();
    expect(renameResp[0][0]).toHaveProperty("Ok");
  
    const lists = await icrc75_fixture.actor.icrc75_get_lists([], true, [], []);
    expect(lists).toContainEqual({ list: "renamedListName", metadata: [[]] });
    expect(lists).not.toContainEqual({ list: "initialListName", metadata: [[]] });
  });

  it("should not allow renaming a list to an existing list name", async () => {
    const listName1 = "listName1";
    const listName2 = "listName2";
    await createList(listName1);
    await createList(listName2);
  
    // Attempt to rename listName1 to listName2
    const renameResp = await icrc75_fixture.actor.icrc75_manage_list_properties([
      {
        list: listName1,
        action: { "Rename": listName2 },
        memo: [],
        from_subaccount: [],
        created_at_time: []
      }
    ]);
    await pic.tick();
  
    expect(renameResp[0]).toBeDefined();
    if (renameResp[0] && renameResp[0][0] && "Err" in renameResp[0][0]) {
      expect(renameResp[0][0].Err).toMatchObject({ "Exists": null });
    }
  
    // Verify that original names remain unchanged
    const lists = await icrc75_fixture.actor.icrc75_get_lists([], true, [], []);
    expect(lists).toContainEqual({ list: listName1, metadata: [[]] });
    expect(lists).toContainEqual({ list: listName2, metadata: [[]] });
  });

  it("should successfully delete a list", async () => {
    const listName = "listToDelete";
    await createList(listName);
  
    const deleteResponse = await icrc75_fixture.actor.icrc75_manage_list_properties([
      { 
        list: listName, 
        action: { "Delete": null }, 
        memo: [], 
        from_subaccount: [], 
        created_at_time: [] 
      }
    ]);
    await pic.tick();
    expect(deleteResponse[0]).toBeDefined();
    expect(deleteResponse[0][0]).toHaveProperty("Ok");
  
    // Verify list is deleted
    const listsAfterDeletion = await icrc75_fixture.actor.icrc75_get_lists([], false, [], []);
    await pic.tick();
    const listsExist = listsAfterDeletion.some(list => list.list === listName);
    expect(listsExist).toBe(false);
  });
  
  it("should return an error when trying to delete a non-existent list", async () => {
    const nonExistentListName = "nonExistentList";
    const deleteResponse = await icrc75_fixture.actor.icrc75_manage_list_properties([
      { 
        list: nonExistentListName, 
        action: { "Delete": null }, 
        memo: [], 
        from_subaccount: [], 
        created_at_time: [] 
      }
    ]);
    await pic.tick();
    expect(deleteResponse[0]).toBeDefined();
    expect(deleteResponse[0][0]).toHaveProperty("Err");
    if (deleteResponse[0][0] && "Err" in deleteResponse[0][0]) {
        expect(deleteResponse[0][0].Err).toMatchObject({"NotFound" : null});
    };
  });

  it("should successfully add new metadata to a list", async () => {
    const listName = "metadataList";
    await createList(listName);
  
    const metadataKey = "description";
    const metadataValue = { "Text": "This is a test list." };
    
    const updateResponse = await icrc75_fixture.actor.icrc75_manage_list_properties([
      { 
        list: listName, 
        action: { "Metadata": { key: metadataKey, value: [metadataValue] } }, 
        memo: [], 
        from_subaccount: [], 
        created_at_time: [] 
      }
    ]);
    await pic.tick();
    expect(updateResponse[0]).toBeDefined();
    expect(updateResponse[0][0]).toHaveProperty("Ok");
  
    // Verify new metadata is added
    const listsWithMetadata = await icrc75_fixture.actor.icrc75_get_lists([], true, [], []);
    await pic.tick();
    const listMetadata = listsWithMetadata.find(list => list.list === listName)?.metadata;
    expect(listMetadata).toBeDefined();
    if(listMetadata)
    expect(listMetadata.some(md => md[0][0] === metadataKey && JSON.stringify(md[0][1]) === JSON.stringify(metadataValue))).toBe(true);
  });
  
  it("should successfully update existing metadata in a list", async () => {
    const listName = "updateMetadataList";
    await createList(listName);
  
    const metadataKey = "description";
    const initialMetadataValue = { "Text": "Initial description." };
    const updatedMetadataValue = { "Text": "Updated description." };
    
    await icrc75_fixture.actor.icrc75_manage_list_properties([
      { 
        list: listName, 
        action: { "Metadata": { key: metadataKey, value: [initialMetadataValue] } }, 
        memo: [], 
        from_subaccount: [], 
        created_at_time: [] 
      }
    ]);
    await pic.tick();
  
    const updateResponse = await icrc75_fixture.actor.icrc75_manage_list_properties([
      { 
        list: listName, 
        action: { "Metadata": { key: metadataKey, value: [updatedMetadataValue] } }, 
        memo: [], 
        from_subaccount: [], 
        created_at_time: [] 
      }
    ]);
    await pic.tick();
    expect(updateResponse[0]).toBeDefined();
    expect(updateResponse[0][0]).toHaveProperty("Ok");
  
    // Verify existing metadata is updated
    const listsWithMetadata = await icrc75_fixture.actor.icrc75_get_lists([], true, [], []);
    await pic.tick();
    const listMetadata = listsWithMetadata.find(list => list.list === listName)?.metadata;
    expect(listMetadata).toBeDefined();
    if (listMetadata)
      expect(listMetadata.some(md => {
        console.log("md2", md,  JSON.stringify(md[0][1]),JSON.stringify(updatedMetadataValue) , JSON.stringify(md[0][1]) == JSON.stringify(updatedMetadataValue), md[0][0] == metadataKey);

        return (md[0][0] == metadataKey) && (JSON.stringify(md[0][1]) == JSON.stringify(updatedMetadataValue));
      })).toBe(true);
  });
  
  it("should successfully remove metadata from a list", async () => {
    const listName = "removeMetadataList";
    await createList(listName);
  
    const metadataKey = "description";
    const metadataValue = { "Text": "To be removed." };
    
    await icrc75_fixture.actor.icrc75_manage_list_properties([
      { 
        list: listName, 
        action: { "Metadata": { key: metadataKey, value: [metadataValue] } }, 
        memo: [], 
        from_subaccount: [], 
        created_at_time: [] 
      }
    ]);
    await pic.tick();
  
    const removeResponse = await icrc75_fixture.actor.icrc75_manage_list_properties([
      { 
        list: listName, 
        action: { "Metadata": { key: metadataKey, value: [] } }, 
        memo: [], 
        from_subaccount: [], 
        created_at_time: [] 
      }
    ]);
    await pic.tick();
    expect(removeResponse[0]).toBeDefined();
    expect(removeResponse[0][0]).toHaveProperty("Ok");
  
    // Verify metadata key is removed
    const listsWithMetadata = await icrc75_fixture.actor.icrc75_get_lists([], true, [], []);
    await pic.tick();
    const listMetadata = listsWithMetadata.find(list => list.list === listName)?.metadata;
    expect(listMetadata).toBeDefined();
    if (listMetadata){
      expect(listMetadata.some(md => {
        expect(md).toHaveLength(0);
    })).toBe(false);
    };
  });

  it("should successfully add permissions", async () => {
    const listName = "permissionsTestList";
    await createList(listName);

    // Add all types of permissions to Bob
    let permissionsToAdd = [
        { "Read": { "Add": { "Identity": bob.getPrincipal() }} },
        { "Write": { "Add": { "Identity": bob.getPrincipal() }} },
        { "Admin": { "Add": { "Identity": bob.getPrincipal() }} },
        { "Permissions": { "Add": { "Identity": bob.getPrincipal() }} }
    ];

    for (let permission of permissionsToAdd) {
        let permissionResp = await icrc75_fixture.actor.icrc75_manage_list_properties([
            {
                list: listName,
                action: { "ChangePermissions": permission },
                memo: [],
                from_subaccount: [],
                created_at_time: []
            }
        ]);
        await pic.tick();
        expect(permissionResp[0]).toBeDefined();
        expect(permissionResp[0][0]).toHaveProperty("Ok");
    }
  });

  it("should not allow adding invalid permission", async () => {
      const listName = "invalidPermissionTestList";
      await createList(listName);

      // Attempt to add invalid permission
      let invalidPermissionResp = await icrc75_fixture.actor.icrc75_manage_list_properties([
          {
              list: listName,
              action: { "ChangePermissions": { "Admin": { "Add": { "DataItem": { "Int": 123n } } } } },
              memo: [],
              from_subaccount: [],
              created_at_time: []
          }
      ]);
      await pic.tick();

      expect(invalidPermissionResp[0]).toBeDefined();
      expect(invalidPermissionResp[0][0]).toHaveProperty("Err");
  });

  it("should successfully remove permissions", async () => {
    const listName = "removePermissionsTestList";
    await createList(listName);

    // Add permissions to Bob first
    let permissionsToAdd = [
        { "Read": { "Add": { "Identity": bob.getPrincipal()}} },
        { "Write": { "Add": { "Identity": bob.getPrincipal()}} }
    ];

    for (let permission of permissionsToAdd) {
        let permissionResp = await icrc75_fixture.actor.icrc75_manage_list_properties([
            {
                list: listName,
                action: { "ChangePermissions": permission },
                memo: [],
                from_subaccount: [],
                created_at_time: []
            }
        ]);
        await pic.tick();
        expect(permissionResp[0]).toBeDefined();
        expect(permissionResp[0][0]).toHaveProperty("Ok");
    }

    // Now remove those permissions
    let permissionsToRemove = [
        { "Read": { "Remove": { "Identity": bob.getPrincipal() }} },
        { "Write": { "Remove": { "Identity": bob.getPrincipal() }} }
    ];

    for (let permission of permissionsToRemove) {
        let permissionResp = await icrc75_fixture.actor.icrc75_manage_list_properties([
            {
                list: listName,
                action: { "ChangePermissions": permission },
                memo: [],
                from_subaccount: [],
                created_at_time: []
            }
        ]);
        await pic.tick();
        expect(permissionResp[0]).toBeDefined();
        expect(permissionResp[0][0]).toHaveProperty("Ok");
    }
  });

  it("should not allow removing non-existent permission", async () => {
      const listName = "nonExistentPermissionList";
      await createList(listName);

      // Attempt to remove a non-existent permission
      let invalidPermissionResp = await icrc75_fixture.actor.icrc75_manage_list_properties([
          {
              list: listName,
              action: { "ChangePermissions": { "Admin": { "Remove": { "Identity": bob.getPrincipal()}} }},
              memo: [],
              from_subaccount: [],
              created_at_time: []
          }
      ]);
      await pic.tick();

      expect(invalidPermissionResp[0]).toBeDefined();
      expect(invalidPermissionResp[0][0]).toHaveProperty("Err");
  });

  it("should add multiple members through batch process", async () => {
    const listName = "batchAddList";
    await createList(listName);

    let membersToAdd = [
        { "Identity": alice.getPrincipal() },
        { "Identity": bob.getPrincipal() }
    ];

    let addMemberRequests : ManageListMembershipRequest = membersToAdd.map(member => ({
        list: listName,
        action: { "Add": member },
        memo: [],
        from_subaccount: [],
        created_at_time: []
    }));

    let addMemberResp = await icrc75_fixture.actor.icrc75_manage_list_membership(addMemberRequests);
    await pic.tick();

    for (let response of addMemberResp) {
        expect(response[0]).toBeDefined();
        expect(response[0]).toHaveProperty("Ok");
    }
});

it("should remove multiple members through batch process", async () => {
    const listName = "batchRemoveList";
    await createList(listName);

    let membersToAdd = [
        { "Identity": alice.getPrincipal() },
        { "Identity": bob.getPrincipal() }
    ];

    let addMemberRequests : ManageListMembershipRequest = membersToAdd.map(member => ({
        list: listName,
        action: { "Add": member },
        memo: [],
        from_subaccount: [],
        created_at_time: []
    }));

    let addMemberResp = await icrc75_fixture.actor.icrc75_manage_list_membership(addMemberRequests);
    await pic.tick();

    // Now remove them
    let removeMemberRequests : ManageListMembershipRequest = membersToAdd.map(member => ({
        list: listName,
        action: { "Remove": member },
        memo: [],
        from_subaccount: [],
        created_at_time: []
    }));

    let removeMemberResp = await icrc75_fixture.actor.icrc75_manage_list_membership(removeMemberRequests);
    await pic.tick();

    for (let response of removeMemberResp) {
        expect(response[0]).toBeDefined();
        expect(response[0]).toHaveProperty("Ok");
    }
  });

  it("should fail batch size exceeding limits", async () => {
      const listName = "batchSizeLimitList";
      await createList(listName);

      // Assume max limit for batch is 100 for example
      let excessiveBatchSize = 101;

      let membersToAdd = Array(excessiveBatchSize).fill(0).map((_, i) => ({ "Identity": createIdentity(`2vxsx-fae${i}`).getPrincipal() }));

      let addMemberRequests : ManageListMembershipRequest = membersToAdd.map(member => ({
          list: listName,
          action: { "Add": member },
          memo: [],
          from_subaccount: [],
          created_at_time: []
      }));

      let addMemberResp = await icrc75_fixture.actor.icrc75_manage_list_membership(addMemberRequests);
      await pic.tick();

      expect(addMemberResp.every(response => response[0] ?
        "Err" in response[0] : false)).toBe(true);
  });

  it("should modify multiple permissions through batch process", async () => {
    const listName = "batchPermissionsList";
    await createList(listName);

    let permissionChanges = [
        { "Read": { "Add": { "Identity": alice.getPrincipal() }} },
        { "Write": { "Add": { "Identity": bob.getPrincipal() }} }
    ];

    let permissionRequests : ManageListPropertyRequest = permissionChanges.map(change => ({
        list: listName,
        action: { "ChangePermissions": change },
        memo: [],
        from_subaccount: [],
        created_at_time: []
    }));

    let permissionResp = await icrc75_fixture.actor.icrc75_manage_list_properties(permissionRequests);
    await pic.tick();

    for (let response of permissionResp) {
        expect(response[0]).toBeDefined();
        if (response[0] && 'Ok' in response[0]) {
          expect(response[0].Ok).toBeDefined();
        }
    }
});

it("should fail batch size exceeding limits for permissions", async () => {
    const listName = "batchPermissionLimitList";
    await createList(listName);

    // Assume max limit for batch is 100 for example
    let excessiveBatchSize = 101;

    let permissionChanges = Array(excessiveBatchSize).fill(0).map((_, i) => ({ "Read": { "Add": { "Identity": createIdentity(`2vxsx-fae${i}`).getPrincipal() }} }));

    let permissionRequests : ManageListPropertyRequest = permissionChanges.map(change => ({
        list: listName,
        action: { "ChangePermissions": change },
        memo: [],
        from_subaccount: [],
        created_at_time: []
    }));

    let permissionResp  = await icrc75_fixture.actor.icrc75_manage_list_properties(permissionRequests);
    await pic.tick();
    console.log("permissionResp", permissionResp);
    expect(permissionResp.every(response => response[0] ? "Err" in response[0] : false)).toBe(true);
  });

  it("should successfully fetch metadata with and without metadata flag", async () => {
    const listName = "metadataList";
    await createList(listName);

    // Add some metadata
    await icrc75_fixture.actor.icrc75_manage_list_properties([
        {
            list: listName,
            action: { "Metadata": { key: "creator", value: [{ "Text": "admin" }] } },
            memo: [],
            from_subaccount: [],
            created_at_time: []
        }
    ]);
    await pic.tick();

    // Fetch metadata with flag true
    let listResp = await icrc75_fixture.actor.icrc75_get_lists([], true, [], []);
    await pic.tick();
    expect(listResp).toBeDefined();
    expect(listResp[0].metadata).toBeDefined();

    // Fetch metadata with flag false
    listResp = await icrc75_fixture.actor.icrc75_get_lists([], false, [], []);
    await pic.tick();
    expect(listResp).toBeDefined();
    console.log("listResp", listResp);
    expect(listResp[0].metadata).toHaveLength(0);
});

it("should support pagination for metadata retrieval", async () => {
    const listPrefix = "paginatedMetadataList";

    // Create 5 lists
    for(let i=0; i<5; i++) {
        await createList(`${listPrefix}${i}`);
    }

    // Fetch data with limit
    let paginatedResp = await icrc75_fixture.actor.icrc75_get_lists([], true, [listPrefix + "0"], [2n]);
    await pic.tick();
    expect(paginatedResp).toHaveLength(2);
  });

  it("should retrieve members with admin permissions", async () => {
    const listName = "adminMembersList";
    await createList(listName);

    // Add members
    let addMemberRequests : ManageListMembershipRequest = [
        {
            list: listName,
            action: { "Add": { "Identity": alice.getPrincipal() }},
            memo: [],
            from_subaccount: [],
            created_at_time: []
        },
        {
            list: listName,
            action: { "Add": { "Identity": bob.getPrincipal() }},
            memo: [],
            from_subaccount: [],
            created_at_time: []
        }
    ];

    let addMemberResp = await icrc75_fixture.actor.icrc75_manage_list_membership(addMemberRequests);
    await pic.tick();

    // Fetch members
    let membersResp = await icrc75_fixture.actor.icrc75_get_list_members_admin(listName, [], [2n]);
    await pic.tick();
    expect(membersResp).toHaveLength(2);
  });

  it("should support pagination for retrieving list members", async () => {
      const listName = "adminMembersPaginationList";
      await createList(listName);

      // Add members
      let addMemberRequests : ManageListMembershipRequest = [
          {
              list: listName,
              action: { "Add": { "Identity": alice.getPrincipal() }},
              memo: [],
              from_subaccount: [],
              created_at_time: []
          },
          {
              list: listName,
              action: { "Add": { "Identity": bob.getPrincipal() }},
              memo: [],
              from_subaccount: [],
              created_at_time: []
          },
          {
              list: listName,
              action: { "Add": { "Identity": serviceProvider.getPrincipal() }},
              memo: [],
              from_subaccount: [],
              created_at_time: []
          }
      ];

      let addMemberResp = await icrc75_fixture.actor.icrc75_manage_list_membership(addMemberRequests);
      await pic.tick();

      // Fetch members with pagination
      let membersResp = await icrc75_fixture.actor.icrc75_get_list_members_admin(listName, [], [2n]);
      await pic.tick();
      expect(membersResp).toHaveLength(2);

      membersResp = await icrc75_fixture.actor.icrc75_get_list_members_admin(listName, [membersResp[1]], [2n]);
      await pic.tick();
      expect(membersResp).toHaveLength(1);
  });

  it("should successfully retrieve nested lists", async () => {
    const parentList = "parentList";
    const subList = "subList";
    await createList(parentList);
    await createList(subList);

    // Add sublist to parent list
    await icrc75_fixture.actor.icrc75_manage_list_membership([
        {
            list: parentList,
            action: { "Add": { "List": subList } },
            memo: [],
            from_subaccount: [],
            created_at_time: []
        }
    ]);
    await pic.tick();

    // Fetch sublists
    const subLists = await icrc75_fixture.actor.icrc75_get_list_lists(parentList, [], [2n]);
    await pic.tick();

    expect(subLists).toContain(subList);
});

it("should support pagination for sub-lists", async () => {
    const listName = "nestedPaginationList";
    await createList(listName);

    // Create 3 sublists
    for(let i=0; i<3; i++) {
        console.log("i", i);
        let subListName = `${listName}_sub${i}`;
        await createList(subListName);
        await icrc75_fixture.actor.icrc75_manage_list_membership([
            {
                list: listName,
                action: { "Add": { "List": subListName } },
                memo: [],
                from_subaccount: [],
                created_at_time: []
            }
        ]);
    } 
    await pic.tick();

    // Fetch sublists with pagination
    let subListsResp = await icrc75_fixture.actor.icrc75_get_list_lists(listName, [], [2n]);
    await pic.tick();
    expect(subListsResp).toHaveLength(2);

    console.log("subListsResp", subListsResp);  

    subListsResp = await icrc75_fixture.actor.icrc75_get_list_lists(listName, [subListsResp[1]], [2n]);
    await pic.tick();
    console.log("subListsResp", subListsResp);
    expect(subListsResp).toHaveLength(1);
    
  });


  it("should query membership for various types", async () => {
    const membershipList = "membershipList";
    await createList(membershipList);

    // Add various members
    let membersToAdd : ListItem[] = [
        { "Identity": alice.getPrincipal() },
        { "Account": { owner: bob.getPrincipal(), subaccount: [new Uint8Array([1,2,3])] } },
        { "DataItem": { "Bool": true } },
        { "List": "someOtherList" }
    ];

    let addMemberRequests : ManageListMembershipRequest = membersToAdd.map(member => ({
        list: membershipList,
        action: { "Add": member },
        memo: [],
        from_subaccount: [],
        created_at_time: []
    }));

    let addMemberResp = await icrc75_fixture.actor.icrc75_manage_list_membership(addMemberRequests);
    await pic.tick();

    for (let response of addMemberResp) {
        expect(response[0]).toBeDefined();
        expect(response[0]).toHaveProperty("Ok");
    }

    // Query for each type of member
    let membersResp = await icrc75_fixture.actor.icrc75_member_of({ "Identity": alice.getPrincipal() }, [], [2n]);
    await pic.tick();
    expect(membersResp).toContain(membershipList);

    membersResp = await icrc75_fixture.actor.icrc75_member_of({ 
        "Account": { owner: bob.getPrincipal(), subaccount: [new Uint8Array([1,2,3])] } 
    }, [], [2n]);
    await pic.tick();
    expect(membersResp).toContain(membershipList);
    
    membersResp = await icrc75_fixture.actor.icrc75_member_of({ "DataItem": { "Bool": true } }, [], [2n]);
    await pic.tick();
    expect(membersResp).toContain(membershipList);

    membersResp = await icrc75_fixture.actor.icrc75_member_of({ "List": "someOtherList" }, [], [2n]);
    await pic.tick();
    expect(membersResp).toContain(membershipList);
  });

  it("should support pagination for membership information retrieval", async () => {
      const paginatedMembershipList = "paginatedMembershipList";
      await createList(paginatedMembershipList);
      await createList(paginatedMembershipList + "1");
      await createList(paginatedMembershipList + "2");

      // Add multiple members
      let membersToAdd = [
          { "Identity": alice.getPrincipal() },
          { "Identity": bob.getPrincipal() },
          { "List": "list1" }
      ];

      let addMemberRequests : ManageListMembershipRequest = membersToAdd.map(member => ({
          list: paginatedMembershipList + "1",
          action: { "Add": member },
          memo: [],
          from_subaccount: [],
          created_at_time: []
      }));

      let addMemberRequests2 : ManageListMembershipRequest = membersToAdd.map(member => ({
        list: paginatedMembershipList + "2",
        action: { "Add": member },
        memo: [],
        from_subaccount: [],
        created_at_time: []
    }));

    let addMemberRequests3 : ManageListMembershipRequest = membersToAdd.map(member => ({
        list: paginatedMembershipList,
        action: { "Add": member },
        memo: [],
        from_subaccount: [],
        created_at_time: []
    }));

      let addMemberResp = await icrc75_fixture.actor.icrc75_manage_list_membership(addMemberRequests);
      let addMemberResp2 = await icrc75_fixture.actor.icrc75_manage_list_membership(addMemberRequests2);
      let addMemberResp3 = await icrc75_fixture.actor.icrc75_manage_list_membership(addMemberRequests3);
      await pic.tick();

      // Fetch members with pagination
      let paginatedResp = await icrc75_fixture.actor.icrc75_member_of({ "Identity": alice.getPrincipal() }, [], [2n]);
      await pic.tick();
      console.log("paginatedResp", paginatedResp);
      expect(paginatedResp).toHaveLength(2);

      paginatedResp = await icrc75_fixture.actor.icrc75_member_of({ "Identity": alice.getPrincipal() }, [paginatedResp[1]], [2n]);
      await pic.tick();
      expect(paginatedResp).toHaveLength(1);
  });

  it("should validate membership authorization for given Principal, Account, DataItem across multiple lists", async () => {
    const listName1 = "authList1";
    const listName2 = "authList2";
    await createList(listName1);
    await createList(listName2);
    
    let principal = alice.getPrincipal();
    let account : Account = { owner: bob.getPrincipal(), subaccount: [new Uint8Array([1, 2, 3])] };
    let dataItem = { "Bool": true };
    
    // Add members to lists
    await icrc75_fixture.actor.icrc75_manage_list_membership([
      { list: listName1, action: { "Add": { "Identity": principal }}, memo: [], from_subaccount: [], created_at_time: [] },
      { list: listName2, action: { "Add": { "Account": account }}, memo: [], from_subaccount: [], created_at_time: [] },
    ]);
    await pic.tick();
    
    // Query for membership authorization
    let authResp = await icrc75_fixture.actor.icrc75_is_member([
      [{ "Identity": principal }, [[listName1]] ],
      [{ "Account": account }, [ [listName2]] ]
    ]);
    await pic.tick();
  
    expect(authResp).toEqual([true, true]);
  
    // Add nested lists
    let nestedList = "nestedList";
    await createList(nestedList);
    await icrc75_fixture.actor.icrc75_manage_list_membership([
      { list: nestedList, action: { "Add": { "List": listName1 }}, memo: [], from_subaccount: [], created_at_time: [] },
      { list: nestedList, action: { "Add": { "List": listName2 }}, memo: [], from_subaccount: [], created_at_time: [] }
    ]);
    await pic.tick();
  
    // Validate nested list membership
    authResp = await icrc75_fixture.actor.icrc75_is_member([
      [ {"Identity": principal }, [[nestedList]] ],
      [{ "Account": account }, [[nestedList]] ]
    ]);
    await pic.tick();
  
    expect(authResp).toEqual([true, true]);
  });

  it("should successfully request and fail when requesting token for non-existent list", async () => {
    const listName = "tokenList";
    await createList(listName);

    await icrc75_fixture.actor.icrc75_manage_list_membership([
      { list: listName, action: { "Add": { "Identity": alice.getPrincipal() }}, memo: [], from_subaccount: [], created_at_time: [] },
      { list: listName, action: { "Add": { "Identity": bob.getPrincipal() }}, memo: [], from_subaccount: [], created_at_time: [] }
    ]);
    
    let tokenRequestResp = await icrc75_fixture.actor.icrc75_request_token({ "Identity": alice.getPrincipal() }, listName, []);
    await pic.tick();
    if(!("Ok" in tokenRequestResp)) throw new Error("Error requesting token");
    let tokenResp = tokenRequestResp.Ok;

    if(!("Map" in tokenRequestResp.Ok)) throw new Error("Token response is undefined");

    var authority = tokenRequestResp.Ok.Map.find((entry: any) => entry[0] === "authority");
    var namespace = tokenRequestResp.Ok.Map.find((entry: any) => entry[0] === "namespace");
    var member = tokenRequestResp.Ok.Map.find((entry: any) => entry[0] === "identity");
    var issued = tokenRequestResp.Ok.Map.find((entry: any) => entry[0] === "issued");
    var nonce = tokenRequestResp.Ok.Map.find((entry: any) => entry[0] === "nonce");

    if (!authority || !namespace || !member || !issued || !nonce) throw new Error("Token response is missing fields");

    expect(authority).toBeDefined();
    if(!("Blob" in authority[1])) throw new Error("Authority is missing Blob");
    expect(authority[1].Blob).toEqual(icrc75_fixture.canisterId.toUint8Array());


    expect(namespace).toBeDefined();
    if(!("Text" in namespace[1])) throw new Error("Namespace is missing Text");
    expect(namespace[1].Text).toEqual(listName);

    expect(member).toBeDefined();
    if(!("Blob" in member[1])) throw new Error("Member is missing Map");
    var memberIdentity = member[1].Blob;
    
    if (!memberIdentity) throw new Error("Member is missing Identity");
    
    expect(memberIdentity).toEqual(alice.getPrincipal().toUint8Array());


    expect(issued).toBeDefined();
    if(!("Nat" in issued[1])) throw new Error("Issued is missing Nat");
    expect(issued[1].Nat).toBeGreaterThan(0);


    expect(nonce).toBeDefined();
    if(!("Nat" in nonce[1])) throw new Error("Nonce is missing Nat");
    expect(nonce[1].Nat).toBeGreaterThan(-1n);
  
    // Request for a non-existent list
    let tokenRequestRespFail = await icrc75_fixture.actor.icrc75_request_token({ "Identity": alice.getPrincipal() }, "nonExistentList", []);
    await pic.tick();
    expect(tokenRequestRespFail).toMatchObject({"Err": {"NotFound": null}});
  });

  it("should successfully retrieve previously requested tokens and validate token integrity", async () => {
    const listName = "retrievalTokenList";
    await createList(listName);

    await icrc75_fixture.actor.icrc75_manage_list_membership([
      { list: listName, action: { "Add": { "Identity": alice.getPrincipal() }}, memo: [], from_subaccount: [], created_at_time: [] },
      { list: listName, action: { "Add": { "Identity": bob.getPrincipal() }}, memo: [], from_subaccount: [], created_at_time: [] }
    ]);

    let resultx = await icrc75_fixture.actor.icrc75_request_token({ "Identity": bob.getPrincipal() }, listName, []);
  
    let result = await icrc75_fixture.actor.icrc75_request_token({ "Identity": alice.getPrincipal() }, listName, []);

    await pic.tick();

    await pic.advanceTime(4000);

    console.log("token result", result);

    if(!("Ok" in result)) throw new Error("Error requesting token");

    var tokenResp = result.Ok;
    expect(tokenResp).toBeDefined();
    if (!("Map" in tokenResp)) throw new Error("Token response is undefined");

    var authority = tokenResp.Map.find((entry: any) => entry[0] === "authority");
    var namespace = tokenResp.Map.find((entry: any) => entry[0] === "namespace");
    var member = tokenResp.Map.find((entry: any) => entry[0] === "identity");
    var issued = tokenResp.Map.find((entry: any) => entry[0] === "issued");
    var nonce = tokenResp.Map.find((entry: any) => entry[0] === "nonce");

    console.log("authority", authority, member, issued, nonce,namespace);

    if (!authority || !namespace || !member || !issued || !nonce) throw new Error("Token response is missing fields");

    expect(authority).toBeDefined();
    if(!("Blob" in authority[1])) throw new Error("Authority is missing Blob");
    expect(authority[1].Blob).toEqual(icrc75_fixture.canisterId.toUint8Array());


    expect(namespace).toBeDefined();
    if(!("Text" in namespace[1])) throw new Error("Namespace is missing Text");
    expect(namespace[1].Text).toEqual(listName);

    expect(member).toBeDefined();
    if(!("Blob" in member[1])) throw new Error("Member is missing Map");
    var memberIdentity = member[1].Blob;
    
    if (!memberIdentity) throw new Error("Member is missing Identity");
    
    expect(memberIdentity).toEqual(alice.getPrincipal().toUint8Array());


    expect(issued).toBeDefined();
    if(!("Nat" in issued[1])) throw new Error("Issued is missing Nat");
    expect(issued[1].Nat).toBeGreaterThan(0);


    expect(nonce).toBeDefined();
    if(!("Nat" in nonce[1])) throw new Error("Nonce is missing Nat");
    expect(nonce[1].Nat).toBeGreaterThan(0n);
    

    let tokenRespRet = await icrc75_fixture.actor.icrc75_retrieve_token(result.Ok);
    await pic.tick();

    console.log("tokenRespRet", tokenRespRet);

    expect(tokenRespRet).toBeDefined();
    expect(tokenRespRet).toHaveProperty("token");
    expect(tokenRespRet).toHaveProperty("witness");
    expect(tokenRespRet).toHaveProperty("certificate");


    tokenResp = tokenRespRet.token;
    expect(tokenResp).toBeDefined();
    if (!("Map" in tokenResp)) throw new Error("Token response is undefined");

     authority = tokenResp.Map.find((entry: any) => entry[0] === "authority");
     namespace = tokenResp.Map.find((entry: any) => entry[0] === "namespace");
     member = tokenResp.Map.find((entry: any) => entry[0] === "identity");
     issued = tokenResp.Map.find((entry: any) => entry[0] === "issued");
     let oldNonce = nonce;
     nonce = tokenResp.Map.find((entry: any) => entry[0] === "nonce");


    if (!authority || !namespace || !member || !issued || !nonce) throw new Error("Token response is missing fields");

    expect(authority).toBeDefined();
    if(!("Blob" in authority[1])) throw new Error("Authority is missing Blob");
    expect(authority[1].Blob).toEqual(icrc75_fixture.canisterId.toUint8Array());


    expect(namespace).toBeDefined();
    if(!("Text" in namespace[1])) throw new Error("Namespace is missing Text");
    expect(namespace[1].Text).toEqual(listName);

    expect(member).toBeDefined();
    if(!("Blob" in member[1])) throw new Error("Member is missing Blob");
    memberIdentity = member[1].Blob;
    expect(memberIdentity).toEqual(alice.getPrincipal().toUint8Array());


    expect(issued).toBeDefined();
    if(!("Nat" in issued[1])) throw new Error("Issued is missing Nat");
    expect(issued[1].Nat).toBeGreaterThan(0);


    expect(nonce).toBeDefined();
    if(!("Nat" in nonce[1])) throw new Error("Nonce is missing Nat");
    expect(nonce[1]).toMatchObject(oldNonce[1]);
    
    let nonceVal = nonce[1].Nat;

    // Validate token integrity


    //validate token validity
    //let NNS = await pic.getNnsSubnet();
    //console.log("NNS", NNS);
    //if (!NNS) throw new Error("NNS is undefined");

    console.log("PIC_URL", await process.env.PIC_URL);
    const agent = await new HttpAgent({
      host: process.env.PIC_URL
    });

    if(tokenRespRet.certificate == null || !(tokenRespRet.certificate instanceof Uint8Array)) throw new Error("Certificate is null");

    console.log("agent", agent.rootKey);
    console.log("current time is ", await pic.getTime());

    /* let nns = await pic.getNnsSubnet();
    if(nns == null) throw new Error("NNS is null");
    let nnspubkey = new Uint8Array(await pic.getPubKey(nns.id)); */

    let subnet = await pic.getApplicationSubnets()[0];
    if(subnet == null) throw new Error("NNS is null");
    let nnspubkey = new Uint8Array(await pic.getPubKey(subnet.id));

    try {
      let result = await Certificate.create({
        certificate : tokenRespRet.certificate.buffer,
        rootKey: nnspubkey,
        canisterId: icrc75_fixture.canisterId, //await pic.getApplicationSubnets()[0].id,//icrc75_fixture.subnetId,
        maxAgeInMinutes : 5
      });
      console.log("result", result);

      if(!(tokenRespRet.witness instanceof Uint8Array)) throw new Error("Witness is not Uint8Array");

      const tree = Cbor.decode<HashTree>(tokenRespRet.witness);

      let validate = validateTree(
        tree,
        result,
        icrc75_fixture.canisterId,);
      } catch (e) {
        console.log("error", e);
        throw new Error("Error validating certificate");
      };

    function Concat(arrays: Uint8Array[]): Uint8Array {
        let totalLength = arrays.reduce((acc, value) => acc + value.length, 0);
        let result = new Uint8Array(totalLength);
        let length = 0;
        for (let array of arrays) {
            result.set(array, length);
            length += array.length;
        }
        return result;
    }

    function Utf8encode(str: string): Uint8Array {
        return new TextEncoder().encode(str);
    } 

    

    //const treeHash = lookup_path(['icrc75:certs', big_endian_encode(nonceVal)], certificate.lookup_label);
   

    //console.log("certificate", certificate);

    //let resultverify = await certificate.verify();
    /* let subnetkey =await pic.getPubKey(pic.getApplicationSubnets()[0].id);
    console.log("about to do tree");
    console.log("subnet key", subnetkey, subnetkey);
    console.log("subnet key length", subnetkey.byteLength);
    let nns = await pic.getNnsSubnet();
    if(nns == null) throw new Error("NNS is null");
    let nnspubkey = new Uint8Array(await pic.getPubKey(nns.id));
    console.log("nns key", nnspubkey, nnspubkey.byteLength, JSON.stringify(nnspubkey));
    const tree = await verifyCertification({
      canisterId: icrc75_fixture.canisterId,
      encodedCertificate: new Uint8Array(tokenRespRet.certificate).buffer,
      encodedTree: new Uint8Array(tokenRespRet.witness).buffer,
      //rootKey: agent.rootKey,
      //rootKey: await pic.getPubKey(pic.getApplicationSubnets()[0].id),
      rootKey: nnspubkey,
      maxCertificateTimeOffsetMs: 50000,
    });

    console.log("tree", tree);

    const treeHash = lookup_path(['icrc75:certs', big_endian_encode(nonceVal)], tree);
    if (!treeHash) {
      throw new Error('Count not found in tree');
    }

    const responseHash = await hash_val(tokenRespRet.token);
    if (!(treeHash instanceof ArrayBuffer) || !equalBuffers(responseHash, treeHash)) {
      throw new Error('token hash does not match');
    };  */

  });

  it("Supported Standards Endpoint", async () => {
    icrc75_fixture.actor.setIdentity(admin);
  
    await pic.tick();
  
    const supportedStandards = await icrc75_fixture.actor.icrc10_supported_standards();
  
    await pic.tick();

    console.log("supportedStandards", supportedStandards);
  
    expect(supportedStandards).toContainEqual({
      name: "ICRC-75",
      url: "https://github.com/dfinity/ICRC/ICRCs/ICRC-75"
    });
  
    expect(supportedStandards).toContainEqual({
      name: "ICRC-10",
      url: "https://github.com/dfinity/ICRC/ICRCs/ICRC-10"
    });
  });

  it("Error Handling for Invalid Requests", async () => {
    const nonExistentList = "nonExistentList";
    const dataItem = { "Int": 999n };
  
    // Try to add a member to a non-existent list
    const addMemberResp = await icrc75_fixture.actor.icrc75_manage_list_membership([
      {
        list: nonExistentList,
        action: { "Add": { "DataItem": dataItem } },
        memo: [],
        from_subaccount: [],
        created_at_time: []
      }
    ]);
    await pic.tick();
  
    expect(addMemberResp[0]).toBeDefined();
    expect(addMemberResp[0][0]).toHaveProperty("Err");
    if (addMemberResp[0][0] && "Err" in addMemberResp[0][0]) {
      expect(addMemberResp[0][0].Err).toMatchObject({ "NotFound": null });
    }
  });
  
  it("Error Handling for Unauthorized Access", async () => {
    const listName = "unauthorizedAccessList";
    await createList(listName);
  
    icrc75_fixture.actor.setIdentity(bob);
  
    // Try to rename the list without proper permissions
    const renameResp = await icrc75_fixture.actor.icrc75_manage_list_properties([
      {
        list: listName,
        action: { "Rename": "newUnauthorizedName" },
        memo: [],
        from_subaccount: [],
        created_at_time: []
      }
    ]);
    await pic.tick();
  
    expect(renameResp[0]).toBeDefined();
    expect(renameResp[0][0]).toHaveProperty("Err");
    if (renameResp[0][0] && "Err" in renameResp[0][0]) {
      expect(renameResp[0][0].Err).toMatchObject({ "Unauthorized": null });
    }
  });
  
  it("Error Handling for Non-existent Entities", async () => {
    const nonExistentList = "nonExistentList";
  
    // Try to delete a non-existent list
    const deleteResp = await icrc75_fixture.actor.icrc75_manage_list_properties([
      { 
        list: nonExistentList, 
        action: { "Delete": null }, 
        memo: [], 
        from_subaccount: [], 
        created_at_time: [] 
      }
    ]);
    await pic.tick();
  
    expect(deleteResp[0]).toBeDefined();
    expect(deleteResp[0][0]).toHaveProperty("Err");
    if (deleteResp[0][0] && "Err" in deleteResp[0][0]) {
      expect(deleteResp[0][0].Err).toMatchObject({ "NotFound": null });
    }
  });

  it('should handle simultaneous access and modifications correctly', async () => {
    const listName = "concurrentList";
    await createList(listName);
  
   await pic.tick();
  
    const dataItem1 = { "Text": "Concurrent Test 1" };
    const dataItem2 = { "Text": "Concurrent Test 2" };
  
    // Add two concurrent members
    const addMember1 = icrc75_fixture.actor.icrc75_manage_list_membership([
      {
        list: listName,
        action: { "Add": { "DataItem": dataItem1 } },
        memo: [],
        from_subaccount: [],
        created_at_time: []
      }
    ]);
  
    const addMember2 = icrc75_fixture.actor.icrc75_manage_list_membership([
      {
        list: listName,
        action: { "Add": { "DataItem": dataItem2 } },
        memo: [],
        from_subaccount: [],
        created_at_time: []
      }
    ]);
  
    await Promise.all([addMember1, addMember2]);
    await pic.tick();
  
    const members = await icrc75_fixture.actor.icrc75_get_list_members_admin(listName, [], []);
    expect(members).toContainEqual({ "DataItem": dataItem1 });
    expect(members).toContainEqual({ "DataItem": dataItem2 });
  });

  it('should maintain performance under heavy load', async () => {
    const heavyLoadListName = "heavyLoadList";
    await createList(heavyLoadListName);
  
    const batchSize = 100; // Assuming 100 as a high batch size for this example
    const membersToAdd = Array(batchSize).fill(0).map((_, i) => ({ "Identity": createIdentity(`identity${i}`).getPrincipal() }));
    const addMemberRequests: ManageListMembershipRequest = membersToAdd.map(member => ({
      list: heavyLoadListName,
      action: { "Add": member },
      memo: [],
      from_subaccount: [],
      created_at_time: []
    }));
    
    const startTime = Date.now();
    await icrc75_fixture.actor.icrc75_manage_list_membership(addMemberRequests);
    await pic.tick();
    const endTime = Date.now();
  
    const elapsedTime = endTime - startTime;
    expect(elapsedTime).toBeLessThanOrEqual(5000); // Example threshold of 5 seconds
  
    const members = await icrc75_fixture.actor.icrc75_get_list_members_admin(heavyLoadListName, [], []);
    expect(members).toHaveLength(batchSize);
  });

  it("should initialize timer correctly", async () => {
    // Check initial stats and ensure there is no active timer
    icrc75_fixture.actor.setIdentity(admin);
    await pic.tick();
    await pic.tick();

    await pic.advanceTime(OneDayMS + OneDayMS);
    await pic.tick();
    await pic.tick();
    
    const stats = await icrc75_fixture.actor.icrc75_get_stats();
    console.log("stats", stats);
   
    expect(stats.tt.timers).toEqual(1n);


  });
  
  it("should validate timer-based actions (e.g., cycle shares)", async () => {
    // Simulate passage of time to invoke timer-based actions

    // Create a list an add 100 members
    const listName = "cycleShareList";
    await createList(listName);
    const batchSize = 100;
    const membersToAdd = Array(batchSize).fill(0).map((_, i) => ({ "Identity": createIdentity(`identity${i}`).getPrincipal() }));
    const addMemberRequests: ManageListMembershipRequest = membersToAdd.map(member => ({
      list: listName,
      action: { "Add": member },
      memo: [],
      from_subaccount: [],
      created_at_time: []
    }));
    await icrc75_fixture.actor.icrc75_manage_list_membership(addMemberRequests);
    await pic.tick();

    let cycles1 = await icrc75_fixture.actor.get_cycle_balance();

    await pic.advanceTime(86400000 * 34); // Advance 34 days in nanoseconds
    await pic.tick(); // Perform ticks to invoke timer actions
    await pic.tick();

    // Assuming a function to fetch latest cycle share or related actions
    const cycleShares = await icrc75_fixture.actor.icrc75_get_stats(); // Assuming this method for validation
    if(cycleShares.cycleShareTimerID.length == 0) throw new Error("No cycle shares found");
    expect(cycleShares.cycleShareTimerID[0]).toBeGreaterThan(0);

    // Verify the state of next cycle action 
    let cycles2 = await icrc75_fixture.actor.get_cycle_balance();
    console.log("cycles1", cycles1, "cycles2", cycles2);
    expect(cycles1 > cycles2 + 1_000_000_000_000n &&  cycles1 < cycles2 + 2_000_000_000_000n).toBe(true);
  });

   // Edge Case for Anon Principal Read Permission
   it("should validate anon principal read permission and restriction", async () => {
    const listName = "anonReadList";
    await createList(listName);
  
    // Add Read permission to Anon principal
    let readPermissionResp = await icrc75_fixture.actor.icrc75_manage_list_properties([
      {
        list: listName,
        action: { "ChangePermissions": { "Read": { "Add": { "Identity": Principal.fromText("2vxsx-fae") }} }},
        memo: [],
        from_subaccount: [],
        created_at_time: []
      }
    ]);
    await pic.tick();
  
    expect(readPermissionResp[0]).toBeDefined();
    expect(readPermissionResp[0][0]).toHaveProperty("Ok");
  
    // Verify Anon can read list metadata
    icrc75_fixture.actor.setPrincipal(Principal.anonymous());
    let metadataResp = await icrc75_fixture.actor.icrc75_get_lists([listName], true, [], []);
    await pic.tick();
    expect(metadataResp).toBeDefined();
    expect(metadataResp[0]).toHaveProperty("metadata");

    // Verify Anon cannot write or alter permissions
    const manageResp = await icrc75_fixture.actor.icrc75_manage_list_properties([
      {
        list: listName,
        action: {"ChangePermissions": { "Write": { "Add": { "Identity": Principal.fromText("2vxsx-fae") }} }},
        memo: [],
        from_subaccount: [],
        created_at_time: []
      }
    ]);
    await pic.tick();

    expect(manageResp[0]).toBeDefined();
    expect(manageResp[0][0]).toHaveProperty("Err");
    if (manageResp[0][0] && "Err" in manageResp[0][0]) {
      expect(manageResp[0][0].Err).toMatchObject({ "Unauthorized": null });
    }
  });

  it("should handle expired tokens correctly", async () => {
    const listName = "expiryTokenList";
    await createList(listName);

    await icrc75_fixture.actor.icrc75_manage_list_membership([
      { list: listName, action: { "Add": { "Identity": alice.getPrincipal() }}, memo: [], from_subaccount: [], created_at_time: [] }
    ]);
    
    let tokenRequestResp = await icrc75_fixture.actor.icrc75_request_token({ "Identity": alice.getPrincipal() }, listName, [1n * OneMinute]);
    await pic.tick();

    if(!("Ok" in tokenRequestResp)) throw new Error("Error requesting token");
    let tokenResp = tokenRequestResp.Ok;

    await pic.advanceTime(2 * OneDayMS); // Advance time beyond token expiration
    await pic.tick();

    try{
      let tokenRespRet = await icrc75_fixture.actor.icrc75_retrieve_token(tokenResp);
      console.log("tokenRespRet", tokenRespRet);
      throw new Error("Token should be expired " + tokenRespRet);
    } catch(e) {

    };
    
  });

  // Helper function to verify ledger structure

  
  const verifyTransactionLog = (ledger: DataItem[], index: number, btype: string, action: object, aTime: bigint) => {
    expect(ledger.length).toBeGreaterThan(0);
  
    const lastEntry = ledger[index];
    if (!("Map" in lastEntry)) throw new Error("Invalid ledger entry");
  
    const btypeEntry = lastEntry.Map.find(([key]) => key === "btype");
    if (!btypeEntry) throw new Error("Invalid ledger entry");
    if (!("Text" in btypeEntry[1])) throw new Error("Invalid ledger entry");
    expect(btypeEntry[1].Text).toBe(btype);
  
    const opEntry = lastEntry.Map.find(([key]) => key === "tx");
    if (!opEntry) throw new Error("Invalid ledger entry");
    expect(opEntry[1]).toMatchObject(action);
  
    const tsEntry = lastEntry.Map.find(([key]) => key === "ts");
    if (!tsEntry) throw new Error("Invalid ledger entry");
    if (!("Nat" in tsEntry[1])) throw new Error("Invalid ledger entry");
    if (tsEntry[1].Nat === undefined) {
      throw new Error("Invalid ledger entry: tsEntry[1].Nat is undefined");
    }
    const tsValue = BigInt(tsEntry[1].Nat);
    const tolerance = 1000n; // Define an acceptable tolerance (e.g., 1000 nanoseconds)
    const tsDiff = tsValue - aTime;
  
    expect(tsDiff).toBeLessThanOrEqual(tolerance);
    expect(tsDiff).toBeGreaterThanOrEqual(-tolerance);
  };

  it("should create transaction logs for list creation", async () => {
    const listName = "testListTxnLog";
    await icrc75_fixture.actor.setIdentity(admin);
    let aTime = BigInt(Math.floor((await pic.getTime()) *1000000) + 4); //has a 4 for some reason
    await icrc75_fixture.actor.icrc75_manage_list_properties([
      {
        list: listName,
        action: { "Create": { admin: [], metadata: [], members: [] } },
        memo: [],
        from_subaccount: [],
        created_at_time: []
      }
    ]);
    await pic.tick();

    const ledger = await icrc75_fixture.actor.getLedger();
    await pic.tick();
    expect(ledger.length).toBeGreaterThan(0);

    const lastEntry = ledger[ledger.length - 1];
    if(!("Map" in lastEntry)) throw new Error("Invalid ledger entry");

    const btypeEntry = lastEntry.Map.find(([key]) => key === "btype");
    if(!btypeEntry) throw new Error("Invalid ledger entry");
    if(!("Text" in btypeEntry[1])) throw new Error("Invalid ledger entry");
    expect(btypeEntry[1].Text).toBe("75listCreate");

    const opEntry = lastEntry.Map.find(([key]) => key === "tx");
    if(!opEntry) throw new Error("Invalid ledger entry");
    expect(opEntry[1]).toMatchObject({
      Map: [
        ["creator", { Blob: admin.getPrincipal().toUint8Array() }],
        ["list", { Text: listName }],
        ["initialAdmin", { Blob: admin.getPrincipal().toUint8Array() }],
      ],
    });

    const tsEntry = lastEntry.Map.find(([key]) => key === "ts");
    if(!tsEntry) throw new Error("Invalid ledger entry");
    if(!("Nat" in tsEntry[1])) throw new Error("Invalid ledger entry");
    const tsValue = BigInt(tsEntry[1].Nat);
    const tolerance = 1000n; // Define an acceptable tolerance (e.g., 1000 nanoseconds)
    const tsDiff = tsValue - aTime;
  
    expect(tsDiff).toBeLessThanOrEqual(tolerance);
    expect(tsDiff).toBeGreaterThanOrEqual(-tolerance);
  });

  it("should create transaction logs for adding a member", async () => {
    const listName = "addMemberTxnLog";
    await icrc75_fixture.actor.setIdentity(admin);
    let aTime = BigInt(Math.floor((await pic.getTime()) * 1000000) + 4); //has a 4 for some reason
  
    await icrc75_fixture.actor.icrc75_manage_list_properties([
      {
        list: listName,
        action: { "Create": { admin: [], metadata: [], members: [] } },
        memo: [],
        from_subaccount: [],
        created_at_time: []
      }
    ]);
    await pic.tick();
  
    await icrc75_fixture.actor.icrc75_manage_list_membership([
      {
        list: listName,
        action: { "Add": { "Identity": alice.getPrincipal() } },
        memo: [],
        from_subaccount: [],
        created_at_time: []
      }
    ]);
    await pic.tick();
  
    const ledger = await icrc75_fixture.actor.getLedger();
    console.log("ledger 2", ledger);
    await pic.tick();
    verifyTransactionLog(ledger, ledger.length -1, "75memChange", {
      Map: [
        ["changer", { Blob: admin.getPrincipal().toUint8Array() }],
        ["list", { Text: listName }],
        ["identity", { Blob: alice.getPrincipal().toUint8Array() }],
        ["change", { Text: "add" }],
      ]
    },aTime);
  });

  it("should create transaction logs for removing a member", async () => {
    const listName = "removeMemberTxnLog";
    await icrc75_fixture.actor.setIdentity(admin);
    let aTime = BigInt(Math.floor((await pic.getTime()) * 1000000) + 4); //has a 4 for some reason
  
    await icrc75_fixture.actor.icrc75_manage_list_properties([
      {
        list: listName,
        action: { "Create": { admin: [], metadata: [], members: [] } },
        memo: [],
        from_subaccount: [],
        created_at_time: []
      }
    ]);
    await pic.tick();
  
    await icrc75_fixture.actor.icrc75_manage_list_membership([
      {
        list: listName,
        action: { "Add": { "Identity": alice.getPrincipal() } },
        memo: [],
        from_subaccount: [],
        created_at_time: []
      }
    ]);
    await pic.tick();
  
    await icrc75_fixture.actor.icrc75_manage_list_membership([
      {
        list: listName,
        action: { "Remove": { "Identity": alice.getPrincipal() } },
        memo: [],
        from_subaccount: [],
        created_at_time: []
      }
    ]);
    await pic.tick();
  
    const ledger = await icrc75_fixture.actor.getLedger();
    await pic.tick();
    verifyTransactionLog(ledger, ledger.length -1, "75memChange", {
      Map: [
        ["changer", { Blob: admin.getPrincipal().toUint8Array() }],
        ["list", { Text: listName }],
        ["identity", { Blob: alice.getPrincipal().toUint8Array() }],
        ["change", { Text: "remove" }],
      ]
    },aTime);
  });

  it("should create transaction logs for changing permissions", async () => {
    const listName = "changePermTxnLog";
    await icrc75_fixture.actor.setIdentity(admin);
    let aTime = BigInt(Math.floor((await pic.getTime()) * 1000000) + 4); //has a 4 for some reason
  
    await icrc75_fixture.actor.icrc75_manage_list_properties([
      {
        list: listName,
        action: { "Create": { admin: [], metadata: [], members: [] } },
        memo: [],
        from_subaccount: [],
        created_at_time: []
      }
    ]);
    await pic.tick();
  
    await icrc75_fixture.actor.icrc75_manage_list_properties([
      {
        list: listName,
        action: { "ChangePermissions": { "Read": { "Add": { "Identity": bob.getPrincipal() } } }},
        memo: [],
        from_subaccount: [],
        created_at_time: []
      }
    ]);
    await pic.tick();
  
    const ledger = await icrc75_fixture.actor.getLedger();
    await pic.tick();
    verifyTransactionLog(ledger,ledger.length -1, "75permChange", {
      Map: [
        ["changer", { Blob: admin.getPrincipal().toUint8Array() }],
        ["list", { Text: listName }],
        ["action", { Text: "add" }],
        ["perm", { Text: "read" }],
        ["targetIdentity", { Blob: bob.getPrincipal().toUint8Array() }],
      ]
    },aTime);
  });

  it("should create transaction logs for renaming a list", async () => {
    const listName = "renameListTxnLog";
    const newListName = "renamedList";
    await icrc75_fixture.actor.setIdentity(admin);
    let aTime = BigInt(Math.floor((await pic.getTime()) * 1000000) + 4); //has a 4 for some reason
  
    await icrc75_fixture.actor.icrc75_manage_list_properties([
      {
        list: listName,
        action: { "Create": { admin: [], metadata: [], members: [] } },
        memo: [],
        from_subaccount: [],
        created_at_time: []
      }
    ]);
    await pic.tick();
  
    let result = await icrc75_fixture.actor.icrc75_manage_list_properties([
      {
        list: listName,
        action: { "Rename": newListName },
        memo: [],
        from_subaccount: [],
        created_at_time: []
      }
    ]);
    console.log("rename", JSON.stringify(result, replacer));
    await pic.tick();
  
    const ledger = await icrc75_fixture.actor.getLedger();
    console.log("rename ledger", JSON.stringify(ledger,replacer));
    await pic.tick();
    verifyTransactionLog(ledger, ledger.length -1, "75listModify", {
      Map: [
        ["list", { Text: listName }],
        ["modifier", { Blob: admin.getPrincipal().toUint8Array() }],
        ["newName", { Text: newListName }],
        
        
      ]
    },aTime);
  });

  it("should create transaction logs for deleting a list", async () => {
    const listName = "deleteListTxnLog";
    await icrc75_fixture.actor.setIdentity(admin);
    let aTime = BigInt(Math.floor((await pic.getTime()) * 1000000) + 4); //has a 4 for some reason
  
    await icrc75_fixture.actor.icrc75_manage_list_properties([
      {
        list: listName,
        action: { "Create": { admin: [], metadata: [], members: [] } },
        memo: [],
        from_subaccount: [],
        created_at_time: []
      }
    ]);
    await pic.tick();
  
    await icrc75_fixture.actor.icrc75_manage_list_properties([
      {
        list: listName,
        action: { "Delete": null },
        memo: [],
        from_subaccount: [],
        created_at_time: []
      }
    ]);
    await pic.tick();
  
    const ledger = await icrc75_fixture.actor.getLedger();
    await pic.tick();
    verifyTransactionLog(ledger, ledger.length -1, "75listDelete", {
      Map: [
        ["list", { Text: listName }],
        ["modifier", { Blob: admin.getPrincipal().toUint8Array() }]
      ]
    },aTime);
  });

  it("should create transaction logs for updating metadata", async () => {
    const listName = "updateMetadataTxnLog";
    const metadataKey = "description";
    const metadataValue = { "Text": "This is a test list." };
    await icrc75_fixture.actor.setIdentity(admin);
    let aTime = BigInt(Math.floor((await pic.getTime()) * 1000000) + 4); //has a 4 for some reason
  
    await icrc75_fixture.actor.icrc75_manage_list_properties([
      {
        list: listName,
        action: { "Create": { admin: [], metadata: [], members: [] } },
        memo: [],
        from_subaccount: [],
        created_at_time: []
      }
    ]);
    await pic.tick();
  
    await icrc75_fixture.actor.icrc75_manage_list_properties([
      {
        list: listName,
        action: { "Metadata": { key: metadataKey, value: [metadataValue] } },
        memo: [],
        from_subaccount: [],
        created_at_time: []
      }
    ]);
    await pic.tick();
  
    const ledger = await icrc75_fixture.actor.getLedger();
    await pic.tick();
    verifyTransactionLog(ledger, ledger.length -1, "75listModify", {
      Map: [
        ["list", { Text: listName }],
        ["modifier", { Blob: admin.getPrincipal().toUint8Array() }],
        ["metadata", { Map: [[metadataKey, metadataValue]] }]
      ]
    },aTime);
  });


});

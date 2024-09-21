import Array "mo:base/Array";
import Blob "mo:base/Blob";
import D "mo:base/Debug";
import Int "mo:base/Int";
import Nat "mo:base/Nat";
import Nat64 "mo:base/Nat64";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Text "mo:base/Text";
import Time "mo:base/Time";

import Fake "./fake";

import Vec "mo:vector";
import Star "mo:star/star";

import {test; suite; skip} "mo:test/async";

import ActorSpec "./utils/ActorSpec";

import MigrationTypes = "../src/migrations/types";

import ICRC75 "../src/";
import T "../src/migrations/types";


let base_environment= {
  get_time = null;
  add_ledger_transaction = null;
  can_transfer = null;
  get_fee = null;
};

let Map = ICRC75.Map;
let Vector = ICRC75.Vector;


      let {
          assertTrue;
          assertFalse;
          assertAllTrue;
          describe;
          it;
          pending;
          run;
      } = ActorSpec;

      let canister = Principal.fromText("x4ocp-k7ot7-oiqws-rg7if-j4q2v-ewcel-2x6we-l2eqz-rfz3e-6di6e-jae");

      let user1 = Principal.fromText("prb4z-5pc7u-zdfqi-cgv7o-fdyqf-n6afm-xh6hz-v4bk4-kpg3y-rvgxf-iae");

      let user2 = Principal.fromText("ygyq4-mf2rf-qmcou-h24oc-qwqvv-gt6lp-ifvxd-zaw3i-celt7-blnoc-5ae");

      let user3 = Principal.fromText("p75el-ys2la-2xa6n-unek2-gtnwo-7zklx-25vdp-uepyz-qhdg7-pt2fi-bqe");
      

      let default_icrc75_args : ICRC75.InitArgs = null;

      var test_time : Int = Time.now();

      func get_icrc(args75 : ICRC75.InitArgs, env1 : ?ICRC75.Environment) : (ICRC75.ICRC75){
        

    let environment75 : ICRC75.Environment = switch(env1){
      case(null){
        {
          tt = null;
          addRecord = null;
          get_certificate_store = null;
          updated_certification = null;
          advanced = ?{
            icrc85 = {
              kill_switch= ?true;
              handler = null;
              period = null;
              tree = null;
              asset = null;
              platform = null;
              collector = null;
            };
          };
          icrc10_register_supported_standards = (func icrc10_register_supported_standards(x: {
              name: Text;
              url : Text;
          }): Bool{
            //todo: add ICRC10
            return true;
          });
        };
      };
      case(?val) val;
    };
      
    let icrc75Store = ICRC75.migrate(ICRC75.initialState(), #v0_1_0(#id), args75, canister);

    let icrc75 = ICRC75.ICRC75(?icrc75Store, canister, environment75);



    (icrc75);
  };

  /* 
  Example mock funcitons:
  let externalCanTransferBatchFalseSync = func <system>( notification: ICRC4.TransferBatchNotification) : Result.Result<( notification: ICRC4.TransferBatchNotification), ICRC4.TransferBatchResults> {

      
          return #err([?#Err(#GenericError({message = "always false"; error_code = 0}))]);
        
      // This mock externalCanTransfer function always returns false,
      // indicating the transfer should not proceed.
      
  };

  let externalCanTransferBatchFalseAsync = func <system>(notification: ICRC4.TransferBatchNotification) : async* Star.Star<( notification: ICRC4.TransferBatchNotification), ICRC4.TransferBatchResults> {
      // This mock externalCanTransfer function always returns false,
      // indicating the transfer should not proceed.
      let fake = await Fake.Fake();
      
      return #err(#awaited([?#Err(#GenericError({message = "always false"; error_code = 0}))]));
        
      
  };

  let externalCanTransfeBatchUpdateSync = func <system>(notification: ICRC4.TransferBatchNotification) : Result.Result<( notification: ICRC4.TransferBatchNotification), ICRC4.TransferBatchResults> {

      let transfers = Vec.new<ICRC4.TransferArgs>();
      for(thisItem in notification.transfers.vals()){
        Vec.add(transfers, thisItem);
      };
      Vec.add(transfers, {
        from_subaccount = null;
        amount = 2 * e8s;
        to = user3;
        fee = null;
        created_at_time = null;
        memo = null;
      });
      

      return #ok({notification with
        transfers = Vec.toArray(transfers);
      });
  };

  let externalCanTransferBatchUpdateAsync = func <system>( notification: ICRC4.TransferBatchNotification) : async* Star.Star<ICRC4.TransferBatchNotification, ICRC4.TransferBatchResults> {
      let fake = await Fake.Fake();
      let transfers = Vec.new<ICRC4.TransferArgs>();
      for(thisItem in notification.transfers.vals()){
        Vec.add(transfers, thisItem);
      };
      Vec.add(transfers, {
        from_subaccount = null;
        amount = 2 * e8s;
        to = user3;
        fee = null;
        created_at_time = null;
        memo = null;
      });
      

      return #awaited({notification with
        transfers = Vec.toArray(transfers);
      });
  };

  let externalCanTransferFalseSync = func <system>(trx: ICRC1.Value, trxtop: ?ICRC1.Value, notification: ICRC1.TransactionRequestNotification) : Result.Result<(trx: ICRC1.Value, trxtop: ?ICRC1.Value, notification: ICRC1.TransactionRequestNotification), Text> {

      switch(notification.kind){
        case(#transfer(val)){
          if(notification.amount == 2 * e8s) return #err("always false");
        };
        case(_){
          
        }
      };
      // This mock externalCanTransfer function always returns false,
      // indicating the transfer should not proceed.
      return #ok(trx, trxtop, notification);
  };

  let externalCanTransferFalseAsync = func <system>(trx: ICRC1.Value, trxtop: ?ICRC1.Value, notification: ICRC1.TransactionRequestNotification) : async* Star.Star<(trx: ICRC1.Value, trxtop: ?ICRC1.Value, notification: ICRC1.TransactionRequestNotification), Text> {
      // This mock externalCanTransfer function always returns false,
      // indicating the transfer should not proceed.
      let fake = await Fake.Fake();
      switch(notification.kind){
        case(#transfer(val)){
          if(notification.amount == 2 * e8s) return #err(#awaited("always false"));
        };
        case(_){
          
        }
      };
        return #awaited(trx, trxtop, notification);
  };

  let externalCanTransferUpdateSync = func <system>(trx: ICRC1.Value, trxtop: ?ICRC1.Value, notification: ICRC1.TransactionRequestNotification) : Result.Result<(trx: ICRC1.Value, trxtop: ?ICRC1.Value, notification: ICRC1.TransactionRequestNotification), Text> {
      let results = Vector.new<(Text,ICRC1.Value)>();
      switch(notification.kind){
        case(#transfer){};
        case(_){
          return #ok(trx,trxtop,notification);
        };
      };
      switch(trx){
        case(#Map(val)){
          for(thisItem in val.vals()){
            if(thisItem.0 == "amt"){
              Vector.add(results, ("amt", #Nat(2)));
            } else {
              Vector.add(results, thisItem);
            };
          }
        };
        case(_) return #err("not a map");
      };

      return #ok(#Map(Vector.toArray(results)), trxtop, {notification with
        amount = 2;
      });
  };

  let externalCanTransferUpdateAsync = func <system>(trx: ICRC1.Value, trxtop: ?ICRC1.Value, notification: ICRC1.TransactionRequestNotification) : async* Star.Star<(trx: ICRC1.Value, trxtop: ?ICRC1.Value, notification: ICRC1.TransactionRequestNotification), Text> {
      let fake = await Fake.Fake();
      switch(notification.kind){
        case(#transfer){};
        case(_){
          return #awaited(trx,trxtop,notification);
        };
      };
      let results = Vector.new<(Text,ICRC1.Value)>();
      switch(trx){
        case(#Map(val)){
          for(thisItem in val.vals()){
            if(thisItem.0 == "amt"){
              Vector.add(results, ("amt", #Nat(2)));
            } else {
              Vector.add(results, thisItem);
            };
          }
        };
        case(_) return #err(#awaited("not a map"))
      };

      return #awaited(#Map(Vector.toArray(results)), trxtop, {notification with
        amount = 2;
      });
  }; */


  await test(
      
      "icrc75_can create list",
      func () : async(){
        do {
            D.print("in test");
            let icrc75  = get_icrc(default_icrc75_args, null);

            let create_arg = [{
                  list = "test123";
                  memo = null;
                  from_subaccount = null;
                  created_at_time = null;
                  action = #Create({
                    admin = null;
                    metadata = [];
                    members = [];
                  })
              } ,{
                  list = "test123";
                  memo = null;
                  from_subaccount = null;
                  created_at_time = null;
                  action = #Create({
                    admin = null;
                    metadata = [];
                    members = [];
                  })
              },
              {
                  list = "test456";
                  memo = null;
                  from_subaccount = null;
                  created_at_time = null;
                  action = #Create({
                    admin = null;
                    metadata = [];
                    members = [];
                  })
              }
            ] : ICRC75.ManageListPropertyRequest;

            
            //Create two lists, one that should fail

            D.print("creating list");
            let createResult =  await* icrc75.manage_list_properties(
                canister,
                create_arg,
                null
            );

            D.print("createResult " # debug_show(createResult));

            assert(assertAllTrue([
              createResult[0] == ?#Ok(0),
              createResult[1] == ?#Err(#Exists),
              createResult[2] == ?#Ok(0),
              createResult.size() == 3,
            ]));

            let getLists = icrc75.get_lists(canister, null, false, null, null);

            D.print(debug_show("test getLists ",getLists));

            assert(assertAllTrue([


              getLists[0].list == "test123",
              getLists[1].list == "test456",
            ]));

            //add an identity to a list

            let addResult1 = await* icrc75.manage_list_membership(canister, [
              {
                list = "test123";
                memo = null;
                from_subaccount = null;
                created_at_time = null;
                action = #Add(#Identity(user1))
              },
              {
                list = "test123";
                memo = null;
                from_subaccount = null;
                created_at_time = null;
                action = #Add(#Identity(user1))
              },
              {
                list = "test123";
                memo = null;
                from_subaccount = null;
                created_at_time = null;
                action = #Add(#Identity(user2))
              }
              
            ], null);

            D.print(debug_show("test addResult1 ",getLists));

            assert(assertAllTrue([
              addResult1[0] == ?#Ok(0),
              addResult1[1] == ?#Err(#Exists),
              addResult1[2] == ?#Ok(0),
              addResult1.size() == 3,
            ]));

            //check that we can get the item

            let getMembers =  icrc75.get_list_members_admin(canister, "test123", null, null);

            assert(assertAllTrue([
              getMembers[0] == #Identity(user1),
              getMembers[1] == #Identity(user2),
              getMembers.size() == 2,
            ]));

            

            //check that member_of works

            let isMember1 =  icrc75.member_of(canister, #Identity(user1), null, null);

            D.print(debug_show("test isMember1 ",isMember1));


            assert(assertAllTrue([
              isMember1[0] == "test123",
              isMember1.size() == 1,
            ]));

            //add some list membership

            let addResult2 = await* icrc75.manage_list_membership(canister, [
              
          
              {
                list = "test456";
                memo = null;
                from_subaccount = null;
                created_at_time = null;
                action = #Add(#Identity(user3))
              }
              ,
              {
                list = "test123";
                memo = null;
                from_subaccount = null;
                created_at_time = null;
                action = #Add(#List("test456"))
              }
            ], null);

            assert(assertAllTrue([
              addResult2[0] == ?#Ok(0),
              addResult2[1] == ?#Ok(0),
              
              addResult2.size() == 2,
            ]));


            //test that list passes through for member of

            let isMember2 =  icrc75.member_of(canister, #Identity(user3), null, null);

            D.print(debug_show("test isMember2 ",isMember2));


            assert(assertAllTrue([
              isMember2[1] == "test123",
              isMember2[0] == "test456",
              isMember2.size() == 2,
            ]));

            //test that is_member works

            let isMember3 =  icrc75.is_member(canister, [
              (#Identity(user3),
                [["test123"],["test456"]]), // A and B - true
              (#Identity(user1),
                [["test123"]]),// A - true
              (#Identity(user2),
                [["test456"]]),// B - false
              (#Identity(user2),
                [["test123","test456"]]), // A or B - true
                
                
                ]);

            D.print(debug_show("test isMember3 ",isMember3));


            assert(assertAllTrue([
              isMember3[0] == true,
              isMember3[1] == true,
              isMember3[2] == false,
              isMember3[3] == true,
              isMember3.size() == 4,
            ]));


        };

      });


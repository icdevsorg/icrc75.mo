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

import ActorSpec "./utils/ActorSpec";

import MigrationTypes = "../src/migrations/types";

import ICRC75 "../src/";
import T "../src/migrations/types";

module {

  let base_environment= {
    get_time = null;
    add_ledger_transaction = null;
    can_transfer = null;
    get_fee = null;
  };

  let Map = ICRC75.Map;
  let Vector = ICRC75.Vector;


    public func test() : async ActorSpec.Group {
        D.print("in test");

        let {
            assertTrue;
            assertFalse;
            assertAllTrue;
            describe;
            it;
            skip;
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
                advanced = null;
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
           
          let icrc75Store = ICRC75.init(ICRC75.initialState(), #v0_1_0(#id), args75, canister);

          let icrc75 = ICRC75.ICRC75(?icrc75Store, user1, environment75);



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


        return describe(
            "ICRC75 List Implementation Tests",
            [
                /* it(
                    "icrc4_transfer creates multipletransfers",
                    do {
                        let (icrc1, icrc4)  = get_icrc(default_token_args, null, default_icrc4_args, null);

                        let mint_args = {
                            to = user1;
                            amount = 200 * e8s;
                            memo = null;
                            created_at_time = null;
                        };

                        D.print("minting");
                        ignore await* icrc1.mint_tokens(
                            canister.owner,
                            mint_args
                        );

                        let batchArgs = [{
                            from_subaccount = user1.subaccount;
                            amount = 1 * e8s;
                            to = user2;
                            fee = null;
                            memo = null;
                            created_at_time = null;
                          },
                          {
                            from_subaccount = user1.subaccount;
                            amount = 1 * e8s;
                            to = user2;
                            fee = null;
                            memo = null;
                            created_at_time = null;
                          },
                          {
                            from_subaccount = user1.subaccount;
                            amount = 1 * e8s;
                            to = user2;
                            fee = null;
                            memo = null;
                            created_at_time = null;
                          }];

                        let result = await* icrc4.transfer_batch_tokens(user1.owner, batchArgs, null, null);

                        D.print("result_test_batch was " # debug_show(result));
                        
                        let #trappable(result_array) = result;

                        let ?#Ok(result1) = result_array[0];

                        let ?#Ok(result2) = result_array[1];

                        let ?#Ok(result3) = result_array[2];

                        
                        assertAllTrue([
                          result1 == 1,
                          result2 == 2,
                          result3 == 3,
                        ]);
                    },
                ), */
                
            ],
        );
    };

};

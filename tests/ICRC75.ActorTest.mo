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
        

        let default_icrc75_args : ICRC4.InitArgs = {
            max_transfers = ?5;
            max_balances = ?5;
            fee = ?#Fixed(base_fee);
        };

        var test_time : Int = Time.now();

        func get_icrc(args1 : ICRC1.InitArgs, env1 : ?ICRC1.Environment, args4 : ICRC4.InitArgs, env4: ?{
          get_fee : ?ICRC4.GetFee}) : (ICRC1.ICRC1, ICRC4.ICRC4){
          

          let environment1 : ICRC1.Environment = switch(env1){
            case(null){
              {
                get_time = ?(func () : Int {test_time});
                add_ledger_transaction = null;
                get_fee = null;
                can_transfer = null;
                can_transfer_async = null;
              };
            };
            case(?val) val;
          };
           
          let token = ICRC1.init(ICRC1.initialState(), #v0_1_0(#id),?args1, canister.owner);

          let icrc1 = ICRC1.ICRC1(?token, canister.owner, environment1);

          let environment2 : ICRC4.Environment = switch(env4){
            case(null){
              {
                icrc1 = icrc1;
                get_fee = null;
              };
            };
            case(?val) {
              {val with icrc1 = icrc1}
            };
          };

          let app = ICRC4.init(ICRC4.initialState(), #v0_1_0(#id),?args4, canister.owner);

          let icrc4 = ICRC4.ICRC4(?app, canister.owner, environment2);


          (icrc1, icrc4);
        };

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
        };


        return describe(
            "ICRC4 Transfer Batch Implementation Tests",
            [
                it(
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
                ),
                it(
                    "Single transfer failure within a batch does not fail the entire batch",
                    do {
                        let (icrc1, icrc4) = get_icrc(default_token_args, null, default_icrc4_args, null);

                        // Mint enough tokens to user1 for successful transfers
                        ignore await* icrc1.mint_tokens(canister.owner, { to = user1; amount = 300 * e8s; memo = null; created_at_time = null; });

                        let batchArgs = [
                                { from_subaccount = user1.subaccount; 
                                to = user2; 
                                amount = 100 * e8s; 
                                fee = null;
                                memo = null;
                                created_at_time = null; }, // Success
                                { from_subaccount = user1.subaccount; 
                                to = user3; 
                                amount = 250 * e8s; 
                                fee = null;
                                memo = null;
                                created_at_time = null; }, // Fail
                                { from_subaccount = user1.subaccount; 
                                to = user2; 
                                amount = 50 * e8s; 
                                fee = null;
                                memo = null;
                                created_at_time = null; },  // Success
                            ];

                        let result = await* icrc4.transfer_batch_tokens(user1.owner, batchArgs, null, null);
                        let #trappable(result_array) = result;

                        let ?#Ok(success1) = result_array[0];
                        let ?#Err(insufficientFundsError) = result_array[1];
                        let ?#Ok(success2) = result_array[2];

                        assertAllTrue([
                            success1 == 1,
                            switch (insufficientFundsError) { case (#InsufficientFunds(_)) true; case _ false; },
                            success2 == 2,
                        ]);
                    },
                ),
                it(
                  "Transfer with incorrect fee data returns `BadFee` error",
                  do {
                      let (icrc1, icrc4) = get_icrc(default_token_args, null, default_icrc4_args, null);

                      // Mint enough tokens to user1 for successful transfers (excluding fee error)
                      ignore await* icrc1.mint_tokens(canister.owner, { to = user1; amount = 300 * e8s; memo = null; created_at_time = null; });

                      let incorrect_fee = 1 * e8s; // Less than base_fee, should cause BadFee error
                      let batchArgs = [
                              { from_subaccount = user1.subaccount;
                               to = user2; 
                               amount = 100 * e8s; 
                               fee = ?incorrect_fee;
                               memo = null;
                                created_at_time = null },
                          ];
                          

                      let result = await* icrc4.transfer_batch_tokens(user1.owner, batchArgs, null, null);
                      let #trappable(result_array) = result;

                      let ?#Err(badFeeError) = result_array[0];
                      
                      switch (badFeeError) {
                        case (#BadFee(_)) assertTrue(true);
                        case _ assertTrue(false);
                      };
                  },
                ),
                it(
                  "Transfers from multiple subaccounts are processed correctly",
                  do {
                      let (icrc1, icrc4)  = get_icrc(default_token_args, null, default_icrc4_args, null);

                      

                      let subaccount1 = ?Blob.fromArray([0, 0, 0, 0, 0, 0, 0, 0, 
                                                        0, 0, 0, 0, 0, 0, 0, 0,
                                                        0, 0, 0, 0, 0, 0, 0, 0,
                                                        0, 0, 0, 0, 0, 0, 0, 1]);
                      let subaccount2 = ?Blob.fromArray([0, 0, 0, 0, 0, 0, 0, 0, 
                                                        0, 0, 0, 0, 0, 0, 0, 0,
                                                        0, 0, 0, 0, 0, 0, 0, 0,
                                                        0, 0, 0, 0, 0, 0, 0, 2]);

                      // Mint enough tokens to user1 for multiple subaccounts
                      ignore await* icrc1.mint_tokens(canister.owner, { to = {user1 with subaccount = subaccount1}; amount = 200 * e8s; memo = null; created_at_time = null; });
                      ignore await* icrc1.mint_tokens(canister.owner, { to = {user1 with subaccount = subaccount2}; amount = 200 * e8s; memo = null; created_at_time = null; });

                      let batchArgs = [
                              { from_subaccount = subaccount1; 
                              to = user2; 
                              amount = 50 * e8s; 
                              fee = null;
                              memo = null;
                              created_at_time = null; },
                              { from_subaccount = subaccount2; 
                              to = user3; 
                              amount = 100 * e8s; 
                              fee = null;
                              memo = null;
                              created_at_time = null; }
                          ];

                      let result = await* icrc4.transfer_batch_tokens(user1.owner, batchArgs, null, null);
                      D.print("result subaccounts " # debug_show(result));
                      let #trappable(result_array) = result;

                      let ?#Ok(tx_index1) = result_array[0];
                      let ?#Ok(tx_index2) = result_array[1];

                      let localtrx = icrc1.get_local_transactions();

                      

                      assertAllTrue([
                          tx_index1 == 2,
                          tx_index2 == 3,
                          Vec.get(localtrx,2).kind == "TRANSFER",
                          Vec.get(localtrx,2).transfer == ?{amount = 50 * e8s},
                          Vec.get(localtrx,2).transfer == ?{to = user2},
                          Vec.get(localtrx,3).kind == "TRANSFER",
                          Vec.get(localtrx,3).transfer == ?{amount = 100 * e8s},
                          Vec.get(localtrx,3).transfer == ?{to = user3},
                      ]);
                  },
              ),
              it(
                "Batch transfer with a transaction size exceeding the maximum batch size returns an error",
                do {
                    let (icrc1, icrc4)  = get_icrc(default_token_args, null, default_icrc4_args, null);

                    // Using a direct manipulation to set max_transfers lower for this test case
                    ignore icrc4.update_ledger_info([#MaxTransfers(1)]);

                    ignore await* icrc1.mint_tokens(canister.owner, { to = user1; amount = 200 * e8s; memo = null; created_at_time = null; });

                    let batchArgs = [
                            { from_subaccount = user1.subaccount; 
                            to = user2; 
                            amount = 10 * e8s; 
                            fee = null;
                            memo = null;
                            created_at_time = null; },
                            { from_subaccount = user1.subaccount; 
                            to = user3; 
                            amount = 10 * e8s; 
                            fee = null;
                            memo = null;
                            created_at_time = null; },
                        ];

                    let result = await* icrc4.transfer_batch_tokens(user1.owner, batchArgs, null, null);
                    D.print("too many " # debug_show(result));
                    switch (result) {
                        case (#trappable(err)){
                            switch (err[0]) {
                                case (?#Err(#TooManyRequests(err))) {
                                    assertTrue(err.limit==1);
                                };
                                case _ {
                                    assertTrue(false); // Unexpected error type
                                };
                            };
                        };
                        case _ {
                            assertTrue(false); // Was expecting an error, but didn't get one
                        };
                    };
                    },
                ),    
                      it(
                        "Transfer with the created_at_time set in the future returns `CreatedInFuture` error",
                        do {
                            let (icrc1, icrc4)  = get_icrc(default_token_args, null, default_icrc4_args, null);

                            ignore await* icrc1.mint_tokens(canister.owner, { to = user1; amount = 200 * e8s; memo = null; created_at_time = null; });

                            let future_time = Nat64.add(Nat64.fromNat(Int.abs(Time.now())), 60_000_000_001); // 1 nano second more than default permitted drift

                            let batchArgs = [
                                    { from_subaccount = user1.subaccount; 
                                    to = user2; 
                                    amount = 1 * e8s; 
                                    fee = null;
                                    memo = null;
                                    created_at_time = ?future_time; },
                                ];

                            let result = await* icrc4.transfer_batch_tokens(user1.owner, batchArgs, null, null);

                            D.print("in the future " # debug_show(result));

                            let #trappable(result_err) = result;
                            

                            switch (result_err[0]) {
                                case (?#Err(#CreatedInFuture(_))) {
                                    assertTrue(true);
                                };
                                case _ {
                                    assertTrue(false); // An error was expected but did not occur
                                };
                            };
                        },
                    ),
                    it(
                      "Transfer with the created_at_time set too far in the past returns `TooOld` error",
                      do {
                          let (icrc1, icrc4)  = get_icrc(default_token_args, null, default_icrc4_args, null);

                          ignore await* icrc1.mint_tokens(canister.owner, { to = user1; amount = 200 * e8s; memo = null; created_at_time = null; });

                          let past_time = Nat64.sub(Nat64.fromNat(Int.abs(Time.now())), 60_000_000_001 + 86_400_000_000_000); // 2 seconds behind

                          let batchArgs = [
                                  { from_subaccount = user1.subaccount; 
                                  to = user2; 
                                  amount = 1 * e8s; 
                                  fee = null;
                                  memo = null;
                                  created_at_time = ?past_time },
                              ];

                          let result = await* icrc4.transfer_batch_tokens(user1.owner, batchArgs, null, null);

                          D.print("in the past " # debug_show(result));
                          let #trappable(result_err) = result;

                          switch (result_err[0]) {
                              case (?#Err(#TooOld)) {
                                  assertTrue(true);
                              };
                              case _ {
                                  assertTrue(false); // An error was expected but did not occur
                              };
                          };
                      },
                  ),
                  it(
                  "Transfer with identical `created_at_time` and `memo` results in `Duplicate` error",
                  do {

                      //todo: The standards working group needs to revisit deduplication for batch.

                      let (icrc1, icrc4)  = get_icrc(default_token_args, null, default_icrc4_args, null);

                      ignore await* icrc1.mint_tokens(canister.owner, { to = user1; amount = 200 * e8s; memo = null; created_at_time = null; });

                      let created_at_time = Nat64.fromNat(Int.abs(Time.now()));
                      let memo = "deduplication_test";

                      let batchArgs = [
                              { from_subaccount = user1.subaccount; 
                              to = user2; 
                              amount = 1 * e8s; 
                              fee = null;
                              memo = ?Text.encodeUtf8(memo);
                              created_at_time = ?created_at_time; },
                              { from_subaccount = user1.subaccount; 
                              to = user2; 
                              amount = 1 * e8s; 
                              fee = null;
                              memo = ?Text.encodeUtf8(memo);
                              created_at_time = ?created_at_time; },
                          ];

                      // Do the first transfer
                      let resulta =  await* icrc4.transfer_batch_tokens(user1.owner, batchArgs, null, null);

                      D.print("result deduplicate a" # debug_show(resulta));

                      // Attempt the second transfer with the same created_at_time and memo to trigger duplicate
                      let result = await* icrc4.transfer_batch_tokens(user1.owner, batchArgs, null, null);

                      D.print("result deduplicate " # debug_show(result));

                      let #trappable(result_array1) = resulta;
                      let #trappable(result_array2) = result;

                      let dupe = switch (result_array1[0]) {
                          case (?#Ok(val)) {
                              
                              val;
                          };
                          case _ {
                              //todo: fix once deduplication has been solved
                              
                              99999;
                          };
                      };

                      switch (result_array1[1]) {
                          case (?#Err(#Duplicate(err))) {
                              ignore assertTrue(err.duplicate_of == dupe);
                          };
                          case _ {
                              //todo: fix once deduplication has been solved
                              ignore assertTrue(false); // an dupe was expected 
                          };
                      };
                      switch (result_array2[0]) {
                          case (?#Err(#Duplicate(err))) {
                              ignore assertTrue(err.duplicate_of == dupe);
                          };
                          case _ {
                              //todo: fix once deduplication has been solved
                              ignore assertTrue(false); // an dupe was expected 
                          };
                      };
                      switch (result_array2[1]) {
                          case (?#Err(#Duplicate(err))) {
                              assertTrue(err.duplicate_of == dupe);
                          };
                          case _ {
                              //todo: fix once deduplication has been solved
                              assertTrue(false); // an dupe was expected 
                          };
                      };
                  },
              ),

              it(
                  "ICRC4 fee overrides the fee for the ICRC1 ledger",
                  do {
                      D.print("in fee override ");
                      // Prepare the ledger and its environment
                      let default_environment = base_environment;
                      let icrc1_fee = 10000;
                      let icrc4_fee = 5000;
                      let icrc1_token_args = {
                          default_token_args with fee = ?#Fixed(icrc1_fee);
                      };
                      let icrc4_init_args = {
                          default_icrc4_args with fee = ?#Fixed(icrc4_fee);
                      };
                      let (icrc1, icrc4) = get_icrc(icrc1_token_args, ?default_environment, icrc4_init_args, null);

                      ignore await* icrc1.mint_tokens(canister.owner, { to = user1; amount = 200 * e8s; memo = null; created_at_time = null; });

                      // Make a transfer batch request that uses the ICRC-4 fee override
                      let batchArgs = [
                              { from_subaccount = user1.subaccount; to = user2; amount = 100 * e8s; fee = null;
                              memo = null;
                          created_at_time = null; },
                          ];

                      D.print("trying batch ");

                      // Attempt the batch transfer
                      let result = await* icrc4.transfer_batch_tokens(user1.owner, batchArgs, null, null);

                      D.print("fee override " # debug_show(result));

                      // Assess the fee used for the transfer
                      let #trappable(result_array) = result;
                      let ?#Ok(actual_fee_used) = result_array[0];
                      
                      let localtrx = icrc1.get_local_transactions();

                      let fee_used = Vec.get(localtrx, actual_fee_used).transfer;

                      D.print("fee used " # debug_show(fee_used));

                      assertTrue(fee_used == ?{fee = ?icrc4_fee});
                  },
                ),
                it(
                    "Environment function for Fees works",
                    do {
                        D.print("in env fee");
                        // Setup custom environment to provide a dynamic fee
                        let dynamic_fee = 7000; // An example dynamic fee
                      
                        let default_icrc4_env = {
                            get_fee : ?ICRC4.GetFee = ?(func(state : ICRC4.CurrentState, env: ICRC4.Environment, batcharg: ICRC4.TransferBatchNotification, trxargs: ICRC1.TransferArgs) : Nat {
                                return dynamic_fee;
                            });
                        };
                        let custom_icrc4_args = {
                            default_icrc4_args with fee = ?#Environment;
                        };

                        let (icrc1, icrc4) = get_icrc(default_token_args, null, custom_icrc4_args, ?default_icrc4_env);

                        ignore await* icrc1.mint_tokens(canister.owner, { to = user1; amount = 200 * e8s; memo = null; created_at_time = null; });

                        // Prepare transfer batch request
                        let batchArgs = [
                                { 
                                    from_subaccount = user1.subaccount;
                                    to = user2;
                                    amount = 100 * e8s;
                                    fee = null;
                                    memo = null;
                                    created_at_time = null;
                                },
                            ];

                        // Attempt the batch transfer
                        let result = await* icrc4.transfer_batch_tokens(user1.owner, batchArgs, null, null);

                        D.print("environment fee " # debug_show(result));

                        // Assess the fee used for the transfer
                        let #trappable(result_array) = result;
                        let ?#Ok(actual_fee_used) = result_array[0];
                        
                        let localtrx = icrc1.get_local_transactions();

                        let fee_used = Vec.get(localtrx, actual_fee_used).transfer;

                        D.print("fee used " # debug_show(fee_used));

                        assertTrue(fee_used == ?{fee = ?dynamic_fee});
                    },
                ),
                it(
                    "Global icrc1:fee is used when icrc4:batch_fee is unspecified",
                    do {
                        // Prepare ICRC-1 and ICRC-4 ledgers without specifying icrc4:batch_fee
                        let default_environment = base_environment;
                        let default_icrc1_fee = 10000; // Global ICRC-1 fee
                        let icrc1_token_args = {
                            default_token_args with fee = ?#Fixed(default_icrc1_fee);
                        };

                        let (icrc1, icrc4) = get_icrc(icrc1_token_args, ?default_environment, {default_icrc4_args with fee = ?#ICRC1}, null);

                        ignore await* icrc1.mint_tokens(canister.owner, { to = user1; amount = 200 * e8s; memo = null; created_at_time = null; });

                        // Prepare transfer batch request
                        let batchArgs = [
                                {
                                    from_subaccount = user1.subaccount;
                                    to = user2;
                                    amount = 100 * e8s;
                                    fee = null; // Fee not specified, expect to use ICRC-1 fee
                                    memo = null;
                                    created_at_time = null;
                                },
                            ];

                        // Attempt the batch transfer
                        let result = await* icrc4.transfer_batch_tokens(user1.owner, batchArgs, null, null);

                        // Assess whether the expected global ICRC-1 fee was used
                        let #trappable(result_array) = result;
                        let ?#Ok(actual_fee_used) = result_array[0];
                        
                        let localtrx = icrc1.get_local_transactions();

                        let fee_used = Vec.get(localtrx, actual_fee_used).transfer;

                        D.print("fee used icrc1" # debug_show(fee_used));

                        assertTrue(fee_used == ?{fee = ?default_icrc1_fee});
                    },
                ),
              it(
                "Query balances of multiple accounts successfully",
                do {
                    let (icrc1, icrc4) = get_icrc(default_token_args, null, default_icrc4_args, null);

                    // Mint tokens to users for balance checks
                    ignore await* icrc1.mint_tokens(canister.owner, { to = user1; amount = 100 * e8s; memo = null; created_at_time = null; });
                    ignore await* icrc1.mint_tokens(canister.owner, { to = user2; amount = 50 * e8s; memo = null; created_at_time = null; });

                    let queryArgs = {
                        accounts = [user1, user2, user3];
                    };

                    let balances = icrc4.balance_of_batch(queryArgs);

                    // User3 has no tokens minted, so balance should be 0
                    let expectedBalances = [100 * e8s,  50 * e8s, 0];

                    let balancesMatch = Array.equal<Nat>(balances, expectedBalances, Nat.equal);

                    assertTrue(balancesMatch);
                },
            ),
            it(
                "Query balance exceeding maximum batch size results in error",
                do {
                    let (icrc1, icrc4) = get_icrc(default_token_args, null, default_icrc4_args, null);

                    // Using a direct manipulation to set max_transfers lower for this test case
                    ignore icrc4.update_ledger_info([#MaxBalances(1)]);

                    // Mint tokens to users for balance checks
                    ignore await* icrc1.mint_tokens(canister.owner, { to = user1; amount = 100 * e8s; memo = null; created_at_time = null; });
                    ignore await* icrc1.mint_tokens(canister.owner, { to = user2; amount = 50 * e8s; memo = null; created_at_time = null; });

                    let queryArgs = {
                        accounts = [user1, user2, user3];
                    };

                    let #err(result) = icrc4.balance_of_batch_tokens(queryArgs);

                   

                    assertTrue(Text.startsWith(result, #text("too many requests.")));
                },
            ),
            it("External sync can_transfer_batch invalidates a transaction",
              do {
                  
                  let (icrc1, icrc4) = get_icrc(default_token_args, null, default_icrc4_args, null);

                  let tx_amount = 1000*e8s;

                  let mint =  await* icrc1.mint_tokens(canister.owner,
                  { to = user1; amount = tx_amount; memo = null; created_at_time = null; });

                  let batchArgs = [
                          { from_subaccount = user1.subaccount; to = user2; amount = 1 * e8s; fee = null;
                          memo = null;
                          created_at_time = null; },
                          { from_subaccount = user1.subaccount; to = user3; amount = 1 * e8s; fee = null;
                          memo = null;
                          created_at_time = null; },
                      ];

                  let result = await* icrc4.transfer_batch_tokens(user1.owner, batchArgs, null, ?#Sync(externalCanTransferBatchFalseSync));

              

                  D.print("reject sync " # debug_show(result));

                  let #err(#trappable(list)) = result;

                  let ?#Err(#GenericError(res)) = list[0];

                  assertTrue(res.message == "always false");
              }),
              it("External async can_transfer_batch invalidates a transaction",
              do {
                  
                  let (icrc1, icrc4) = get_icrc(default_token_args, null, default_icrc4_args, null);

                  let tx_amount = 1000*e8s;

                  let mint =  await* icrc1.mint_tokens(canister.owner,
                  { to = user1; amount = tx_amount; memo = null; created_at_time = null; });
                  
                  let batchArgs = [
                          { from_subaccount = user1.subaccount; to = user2; amount = 1 * e8s; fee = null;
                          memo = null;
                          created_at_time = null; },
                          { from_subaccount = user1.subaccount; to = user3; amount = 1 * e8s; fee = null;
                          memo = null;
                          created_at_time = null; },
                      ];

                  let result = await* icrc4.transfer_batch_tokens(user1.owner, batchArgs, null, ?#Async(externalCanTransferBatchFalseAsync));

                  D.print("reject async " # debug_show(result));

                  let #err(#awaited(list)) = result;
                  let ?#Err(#GenericError(res)) = list[0];

                  assertTrue(res.message == "always false");
              }),
              it("External sync can_transfer_batch updates a transaction",
              do {
                  
                  let (icrc1, icrc4) = get_icrc(default_token_args, null, default_icrc4_args, null);

                  let tx_amount = 1000*e8s;

                  let mint =  await* icrc1.mint_tokens(canister.owner, { to = user1; amount = tx_amount; memo = null; created_at_time = null; });
                  
                  let batchArgs = [
                          { from_subaccount = user1.subaccount; to = user2; amount = 1 * e8s; fee = null;
                          memo = null;
                          created_at_time = null; },
                          { from_subaccount = user1.subaccount; to = user3; amount = 2 * e8s; fee = null;
                          memo = null;
                          created_at_time = null; },
                      ];

                  let result = await* icrc4.transfer_batch_tokens(user1.owner, batchArgs, null, ?#Sync(externalCanTransfeBatchUpdateSync));

              

                  D.print("update sync " # debug_show(result));

                  let #trappable(res) = result;
                  let ledger = Vector.toArray(icrc1.get_local_transactions());
                  let ?trn = ledger[1].transfer;

                    assertAllTrue([
                    res[0] == ?#Ok(1),
                    res[1] == ?#Ok(2),
                    res[2] == ?#Ok(3),
                    ledger[2].transfer == ?{amount = 2 * e8s; to = user3}
                  ]);
              }),
              it("External async can_transfer_batch updates a transaction",
              do {
                  
                  let (icrc1, icrc4) = get_icrc(default_token_args, null, default_icrc4_args, null);

                  let tx_amount = 1000*e8s;

                  let mint =  await* icrc1.mint_tokens( canister.owner, { to = user1; amount = tx_amount; memo = null; created_at_time = null; },);
                  
                  let batchArgs = [
                          { from_subaccount = user1.subaccount; to = user2; amount = 1 * e8s; fee = null;
                          memo = null;
                          created_at_time = null; },
                          { from_subaccount = user1.subaccount; to = user3; amount = 2 * e8s; fee = null;
                          memo = null;
                          created_at_time = null; },
                      ];

                  let result = await* icrc4.transfer_batch_tokens(user1.owner, batchArgs, null, ?#Async(externalCanTransferBatchUpdateAsync));

              

                  D.print("update async " # debug_show(result));

                  let #awaited(res) = result;
                  let ledger = Vector.toArray(icrc1.get_local_transactions());
                  let ?trn = ledger[1].transfer;

                  assertAllTrue([
                    res[0] == ?#Ok(1),
                    res[1] == ?#Ok(2),
                    res[2] == ?#Ok(3),
                    ledger[2].transfer == ?{amount = 2 * e8s; to = user3}
                  ]);
              }),
              it("External sync can_transfer invalidates a transaction",
                do {
                    
                    let (icrc1, icrc4) = get_icrc(default_token_args, null, default_icrc4_args, null);
                    let tx_amount = 1000*e8s;

                    let mint =  await* icrc1.mint_tokens(canister.owner,
                    { to = user1; amount = tx_amount; memo = null; created_at_time = null; });

                    let batchArgs = [
                            { from_subaccount = user1.subaccount; to = user2; amount = 1 * e8s; fee = null;
                            memo = null;
                            created_at_time = null; },
                            { from_subaccount = user1.subaccount; to = user3; amount = 2 * e8s; fee = null;
                            memo = null;
                            created_at_time = null; },
                        ];

                    let result = await* icrc4.transfer_batch_tokens(user1.owner, batchArgs, ?#Sync(externalCanTransferFalseSync), null);

                    D.print("reject sync single " # debug_show(result));

                    let #trappable(res) = result;
                    let ledger = Vector.toArray(icrc1.get_local_transactions());
                    let ?trn = ledger[1].transfer;

                      assertAllTrue([
                      res[0] == ?#Ok(1),
                      res[1] == ?#Err(#GenericError({error_code=6453; message="always false"})),
                      Array.size(ledger) == 2
                    ]);
                }),
                it("External async can_transfer invalidates a transaction",
                do {
                    
                     let (icrc1, icrc4) = get_icrc(default_token_args, null, default_icrc4_args, null);
                    let tx_amount = 1000*e8s;

                    let mint =  await* icrc1.mint_tokens(canister.owner,
                    { to = user1; amount = tx_amount; memo = null; created_at_time = null; });

                    let batchArgs = [
                            { from_subaccount = user1.subaccount; to = user2; amount = 1 * e8s; fee = null;
                            memo = null;
                            created_at_time = null; },
                            { from_subaccount = user1.subaccount; to = user3; amount = 2 * e8s; fee = null;
                            memo = null;
                            created_at_time = null; },
                        ];

                  let result = await* icrc4.transfer_batch_tokens(user1.owner, batchArgs, ?#Async(externalCanTransferFalseAsync), null);

              
                    
                    // First transfer
                   D.print("reject async single " # debug_show(result));

                    let #awaited(res) = result;
                    let ledger = Vector.toArray(icrc1.get_local_transactions());
                    let ?trn = ledger[1].transfer;

                      assertAllTrue([
                      res[0] == ?#Ok(1),
                      res[1] == ?#Err(#GenericError({error_code=6453; message="always false"})),
                      Array.size(ledger) == 2
                    ]);
                }),
                it("External sync can_transfer updates a transaction",
                do {
                    
                     let (icrc1, icrc4) = get_icrc(default_token_args, null, default_icrc4_args, null);
                    let tx_amount = 1000*e8s;

                    let mint =  await* icrc1.mint_tokens(canister.owner, { to = user1; amount = tx_amount; memo = null; created_at_time = null; });

                    let batchArgs =[
                            { from_subaccount = user1.subaccount; to = user2; amount = 1 * e8s; fee = null;
                            memo = null;
                            created_at_time = null; },
                            { from_subaccount = user1.subaccount; to = user3; amount = 2 * e8s; fee = null;
                            memo = null;
                            created_at_time = null; },
                        ];

                  let result = await* icrc4.transfer_batch_tokens(user1.owner, batchArgs, ?#Sync(externalCanTransferUpdateSync), null);

                    let #trappable(res) = result;
                    let ledger = Vector.toArray(icrc1.get_local_transactions());
                    let ?trn = ledger[1].transfer;
                    let ?trn2 = ledger[1].transfer;

                    assertAllTrue([
                      trn.amount == 2,
                      trn2.amount == 2
                    ]);
                }),
                it("External async can_transfer updates a transaction",
                do {
                    
                   let (icrc1, icrc4) = get_icrc(default_token_args, null, default_icrc4_args, null);
                    let tx_amount = 1000*e8s;

                    let mint =  await* icrc1.mint_tokens( canister.owner, { to = user1; amount = tx_amount; memo = null; created_at_time = null; },);

                    let batchArgs = [
                            { from_subaccount = user1.subaccount; to = user2; amount = 1 * e8s; fee = null;
                            memo = null;
                            created_at_time = null; },
                            { from_subaccount = user1.subaccount; to = user3; amount = 2 * e8s; fee = null;
                            memo = null;
                            created_at_time = null; },
                        ];

                    let result = await* icrc4.transfer_batch_tokens(user1.owner, batchArgs, ?#Async(externalCanTransferUpdateAsync), null);

                
                    
                    let #awaited(res) = result;
                    let ledger = Vector.toArray(icrc1.get_local_transactions());
                    let ?trn = ledger[1].transfer;
                    let ?trn2 = ledger[1].transfer;

                    assertAllTrue([
                      trn.amount == 2,
                      trn2.amount == 2
                    ]);
                }),
                it(
                  "Can listen to notifications of each item by adding a listener at the ICRC-1 level",
                  do {
                      let (icrc1, icrc4) = get_icrc(default_token_args, null, default_icrc4_args, null);

                      let mint_args = { to = user1; amount = 100 * e8s; memo = null; created_at_time = null; };
                      ignore await* icrc1.mint_tokens(canister.owner, mint_args);

                      let batchArgs = [
                              { from_subaccount = user1.subaccount; to = user2; amount = 10 * e8s; fee = null;
                              memo = null;
                              created_at_time = null; },
                               { from_subaccount = user1.subaccount; to = user3; amount = 10 * e8s; fee = null;
                              memo = null;
                              created_at_time = null; },
                              { from_subaccount = user1.subaccount; to = user2; amount = 4 * e8s; fee = null;
                              memo = null;
                              created_at_time = null; },
                          ];

                      var listener_called = false;

                      icrc4.register_transfer_batch_listener("test_listener", func <system>(notification: ICRC4.TransferBatchNotification, results: ICRC4.TransferBatchResults) {
                          listener_called := true;
                      });

                      var trx_called = 0;
                      icrc1.register_token_transferred_listener("test_listener", func <system>(tx: ICRC1.Transaction, tx_id: Nat) {
                          trx_called += 1;
                      });

                      ignore await* icrc4.transfer_batch(user1.owner, batchArgs);

                      assertAllTrue([listener_called, trx_called == 3]);
                  }),
                  it(
                  "test invalid memo",
                  do {
                      let (icrc1, icrc4) = get_icrc(default_token_args, null, default_icrc4_args, null);

                      let mint_args = { to = user1; amount = 100 * e8s; memo = null; created_at_time = null; };
                      ignore await* icrc1.mint_tokens(canister.owner, mint_args);

                      ignore icrc1.update_ledger_info([#MaxMemo(16)]);

                      let batchArgs = [
                              { from_subaccount = user1.subaccount; to = user2; amount = 10 * e8s; fee = null;
                              memo = ?Blob.fromArray([0,0,0,0,0,0,0,1,
                                                  0,0,0,0,0,0,0,1,
                                                  0,0,0,0,0,0,0,3,
                                                  0,0,0,0,0,0,0,1,
                                                  0,0,0,0,0,0,0,4,]);
                              created_at_time = null; },
                              { from_subaccount = user1.subaccount; to = user3; amount = 10 * e8s; fee = null;
                              memo = ?Blob.fromArray([0,0,0,0,0,0,0,1,
                                                  0,0,0,0,0,0,0,1,
                                                  0,0,0,0,0,0,0,3,
                                                  0,0,0,0,0,0,0,1,
                                                  0,0,0,0,0,0,0,4,]);
                              created_at_time = null; },
                              { from_subaccount = user1.subaccount; to = user2; amount = 4 * e8s; fee = null;
                              memo = ?Blob.fromArray([0,0,0,0,0,0,0,1,
                                                  0,0,0,0,0,0,0,1,
                                                  0,0,0,0,0,0,0,3,
                                                  0,0,0,0,0,0,0,1,
                                                  0,0,0,0,0,0,0,4,]);
                              created_at_time = null; },
                          ];

                      

                      let result = await* icrc4.transfer_batch(user1.owner, batchArgs);

                       // First transfer
                      D.print("reject memo " # debug_show(result));

                      let ?#Err(#GenericError(err)) = result[0];

                      assertAllTrue([err.error_code == 4]);
                  }),
            ],
        );
    };

};

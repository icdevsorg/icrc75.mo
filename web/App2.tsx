import './App.css';
import * as React from 'react';
import { useState, useEffect } from 'react';

import { Principal } from '@dfinity/principal';
import { AuthClient } from '@dfinity/auth-client';
import type  {} from './plug.d.ts';

import motokoLogo from './assets/motoko_moving.png';
import motokoShadowLogo from './assets/motoko_shadow.png';
import reactLogo from './assets/bob.png';
import viteLogo from './assets/vite.svg';

import {
  Container,
  Typography,
  Box,
  Link,
  Button,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  TextField,
  CircularProgress,
  IconButton,
} from '@mui/material';
import EditIcon from '@mui/icons-material/Edit';

import { idlFactory as icrc75Factory, createActor as createICRC75, canisterId as icrc75CanisterId } from '../src/declarations/icrc75';
import { _SERVICE as icrc75Service } from '../src/declarations/icrc75/icrc75.did.js';

import { idlFactory as nnsLedgerFactory, createActor as createNNSLedger } from '../src/declarations/nns-ledger';
import { _SERVICE as nnsLedgerService, Account as NNSAccount, ApproveArgs } from '../src/declarations/nns-ledger/nns-ledger.did.js';

import { idlFactory as pullerFactory, createActor as createPuller } from '../src/declarations/puller';
import { _SERVICE as pullerService, Account as PullerAccount } from '../src/declarations/puller/puller.did.js';

import CreateList from './components/ListManagement/CreateList';
import ListViewer from './components/ListViewer';

function App() {
  // State Management
  const [authClient, setAuthClient] = useState<AuthClient | null>(null);
  const [isConnected, setIsConnected] = useState<string>("none");
  const [loading, setLoading] = useState<boolean>(false);
  const [icrc75Actor, setIcrc75Actor] = useState<icrc75Service | null>(null);
  const [icrc75Reader, setIcrc75Reader] = useState<icrc75Service | null>(null);
  const [yourPrincipal, setYourPrincipal] = useState<Principal>(Principal.anonymous());
  const [reloadMyListsFlag, setReloadMyListFlag] = useState<boolean>(false);

  // Canister ID Management
  const [currentCanisterId, setCurrentCanisterId] = useState<string>(icrc75CanisterId.toString());
  const [openDialog, setOpenDialog] = useState<boolean>(false);
  const [newCanisterId, setNewCanisterId] = useState<string>("");
  const [canisterIdError, setCanisterIdError] = useState<string>("");

  // Join Tester State
  const [joinDialogOpen, setJoinDialogOpen] = useState<boolean>(false);
  const [icpAmount, setIcpAmount] = useState<string>("0.1");
  const [joinLoading, setJoinLoading] = useState<boolean>(false);
  const [joinStatus, setJoinStatus] = useState<string>("");
  const [nnsLedgerActor, setNnsLedgerActor] = useState<nnsLedgerService | null>(null);
  const [pullerActor, setPullerActor] = useState<pullerService | null>(null);

  // Constants
  const PULLER_CANISTER_ID = "w5kli-7qaaa-aaaae-qajwa-cai";
  const NNS_LEDGER_CANISTER_ID = "ryjl3-tyaaa-aaaaa-aaaba-cai";

  // Host Environment Setup
  let hostEnv = "https://ic0.app";
  let port = "";

  let pageURL = new URL(window.location.href);

  if (pageURL.host.includes("127.0.0.1") || pageURL.host.includes("localhost")) {
    console.log("Localhost detected");
    port = "8080";
    hostEnv = `http://127.0.0.1:${port}`;
  }

  // Utility Function (As in Original Code)
  function bigintToFloatString(bigintValue: bigint, decimals = 8) {
    const stringValue = bigintValue.toString();

    if (decimals === 0) {
      return stringValue.replace(/\B(?=(\d{3})+(?!\d))/g, ',');
    }

    const paddedStringValue = stringValue.padStart(decimals + 1, '0');
    const beforeDecimal = paddedStringValue.slice(0, -decimals);
    const afterDecimal = paddedStringValue.slice(-decimals);
    const result = `${beforeDecimal}.${afterDecimal}`.replace(/\.?0+$/, '');

    const parts = result.split('.');
    parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ',');

    return parts.join('.');
  }

  // Connection Check
  const checkConnection = async () => {
    try {
      const connected = await window.ic.plug.isConnected();
      if (connected) {
        await handleLogin();
      }
    } catch (error) {
      console.error("Error checking connection status:", error);
    }
  };

  // Initial Setup
  useEffect(() => {
    console.log("Component mounted, setting up canister reader...");
    setUpCanisterReader(currentCanisterId);
    setUpAuthClient();
  }, [currentCanisterId]); // Re-run when currentCanisterId changes

  useEffect(() => {
    if (isConnected !== "none") {
      fetchPrincipal();
      setUpActors(currentCanisterId);
    }
    console.log("isConnected", isConnected);
  }, [isConnected, currentCanisterId]);

  // Function to Setup Canister Reader
  const setUpCanisterReader = (canisterId: string) => {
    try {
      const readerActor = createICRC75(canisterId, { agentOptions: { host: hostEnv } });
      setIcrc75Reader(readerActor);
      console.log(`Reader actor set up with canister ID: ${canisterId}`);
    } catch (error) {
      console.error("Failed to set up reader actor:", error);
    }
  };

  // Function to Setup Auth Client
  const setUpAuthClient = async () => {
    setAuthClient(await AuthClient.create());
  };

  // Function to Fetch Principal
  const fetchPrincipal = async () => {
    if (isConnected === "plug") {
      if (!(await window.ic.plug.agent)) return;
      setYourPrincipal(await window.ic.plug.agent.getPrincipal());
    } else if (isConnected === "ii" && authClient !== null) {
      setYourPrincipal(await authClient.getIdentity().getPrincipal());
    }
  };

  // Function to Get Principal from Agent
  const getPrincipalFromAgent = async () => {
    if (isConnected === "plug") {
      if (!(await window.ic.plug.agent)) return Principal.anonymous();
      return await window.ic.plug.agent.getPrincipal();
    } else if (isConnected === "ii" && authClient !== null) {
      return await authClient.getIdentity().getPrincipal();
    }
    return Principal.anonymous();
  };

  // Logout Handler
  const handleLogout = async () => {
    setLoading(true);
    try {
      await window.ic.plug.disconnect();
      setIsConnected("none");
      setIcrc75Actor(null);
      setIcrc75Reader(null);
      setYourPrincipal(Principal.anonymous());
    } catch (error) {
      console.error('Logout failed:', error);
    } finally {
      setLoading(false);
    }
  };

  // Login Handler for Plug
  const handleLogin = async () => {
    setLoading(true);
    try {
      const connected = await window.ic.plug.isConnected();
      let useHost = hostEnv;
      if (port.length > 0) {
        useHost = `http://127.0.0.1:${port}`;
      }
      if (!connected) {
        let pubkey = await window.ic.plug.requestConnect({
          whitelist: [currentCanisterId, NNS_LEDGER_CANISTER_ID, PULLER_CANISTER_ID],
          host: useHost,
          onConnectionUpdate: async () => {
            console.log("Connection updated", await window.ic.plug.isConnected());
            await setIsConnected("plug");
          },
        });
        console.log("Connected with pubkey:", pubkey);
        await setIsConnected("plug");
      } else {
        setIsConnected("plug");
      }
    } catch (error) {
      console.error('Login failed:', error);
      setIsConnected("none");
    } finally {
      setLoading(false);
    }
  };

  // Login Handler for Internet Identity
  const handleLoginII = async () => {
    setLoading(true);
    if (!authClient) return;
    try {
      await authClient.login({
        identityProvider:
          process.env.DFX_NETWORK === "ic"
            ? "https://identity.ic0.app/#authorize"
            : `http://qhbym-qaaaa-aaaaa-aaafq-cai.localhost:8080/`,
        onSuccess: async () => {
          await setIsConnected("ii");
        },
      });
    } catch (error) {
      console.error('Login failed:', error);
      setIsConnected("none");
    } finally {
      setLoading(false);
    }
  };

  // Function to Setup Actors
  const setUpActors = async (canisterId: string) => {
    if (isConnected === "none") return;

    try {
      if (isConnected === "plug") {
        const actor = await window.ic.plug.createActor({
          canisterId: canisterId,
          interfaceFactory: icrc75Factory,
        });
        setIcrc75Actor(actor);

        // Set up NNS Ledger actor
        const nnsActor = await window.ic.plug.createActor({
          canisterId: NNS_LEDGER_CANISTER_ID,
          interfaceFactory: nnsLedgerFactory,
        });
        setNnsLedgerActor(nnsActor);

        // Set up Puller actor
        const pullerActorInstance = await window.ic.plug.createActor({
          canisterId: PULLER_CANISTER_ID,
          interfaceFactory: pullerFactory,
        });
        setPullerActor(pullerActorInstance);

      } else if (isConnected === "ii" && authClient !== null) {
        const identity = authClient.getIdentity();
        const agentOptions = { host: hostEnv, identity };
        
        const actor = createICRC75(canisterId, { agentOptions });
        setIcrc75Actor(actor);

        const nnsActor = createNNSLedger(NNS_LEDGER_CANISTER_ID, { agentOptions });
        setNnsLedgerActor(nnsActor);

        const pullerActorInstance = createPuller(PULLER_CANISTER_ID, { agentOptions });
        setPullerActor(pullerActorInstance);
      }
      console.log(`Actors set up with canister ID: ${canisterId}`);
    } catch (error) {
      console.error("Failed to set up actors:", error);
    }
  };

  // Function to Fetch Lists (Trigger Reload)
  const fetchLists = async () => {
    setReloadMyListFlag(prev => !prev);
  };

  // Copyright Component
  function Copyright() {
    return (
      <Typography
        variant="body2"
        align="center"
        sx={{
          color: 'text.secondary',
        }}
      >
        {'Copyright © '}
        <Link color="inherit" href="https://icdevs.org/">
          ICDevs.org
        </Link>{' '}
        {new Date().getFullYear()}.
      </Typography>
    );
  };

  // Functions to Handle Dialog
  const handleOpenDialog = () => {
    setNewCanisterId("");
    setCanisterIdError("");
    setOpenDialog(true);
  };

  const handleCloseDialog = () => {
    setOpenDialog(false);
  };

  // Join Tester Functions
  const handleOpenJoinDialog = () => {
    // Check if user is connected first
    if (isConnected === "none") {
      alert("Please connect your wallet first before joining the alpha test.");
      return;
    }
    
    setJoinStatus("");
    setJoinDialogOpen(true);
  };

  const handleCloseJoinDialog = () => {
    setJoinDialogOpen(false);
  };

  const handleJoinTest = async () => {
    // Double-check authentication
    if (isConnected === "none") {
      setJoinStatus("Please connect your wallet first");
      return;
    }

    if (!nnsLedgerActor || !pullerActor) {
      setJoinStatus("Actors not initialized. Please try reconnecting your wallet.");
      return;
    }

    setJoinLoading(true);
    setJoinStatus("Starting join process...");

    try {
      // Convert ICP to e8s (multiply by 10^8)
      const icpAmountFloat = parseFloat(icpAmount);
      if (isNaN(icpAmountFloat) || icpAmountFloat <= 0) {
        setJoinStatus("Please enter a valid ICP amount");
        setJoinLoading(false);
        return;
      }

      const e8sAmount = BigInt(Math.floor(icpAmountFloat * 100_000_000));
      setJoinStatus(`Approving ${icpAmount} ICP (${e8sAmount.toString()} e8s)...`);

      // Get user's account - ensure we have a valid principal
      const userPrincipal = await getPrincipalFromAgent();
      if (!userPrincipal || userPrincipal.isAnonymous()) {
        setJoinStatus("Authentication failed. Please reconnect your wallet.");
        setJoinLoading(false);
        return;
      }

      const userAccount: NNSAccount = {
        owner: userPrincipal,
        subaccount: [],
      };

      const spenderAccount: NNSAccount = {
        owner: Principal.fromText(PULLER_CANISTER_ID),
        subaccount: [],
      };

      // Approve the puller canister to spend ICP - this is an authenticated call
      const approveArgs: ApproveArgs = {
        spender: spenderAccount,
        amount: e8sAmount + 10000n, // Add small buffer for fee
        fee: [],
        memo: [],
        from_subaccount: [],
        created_at_time: [],
        expected_allowance: [],
        expires_at: [],
      };

      setJoinStatus("Requesting approval from NNS Ledger...");
      const approveResult = await nnsLedgerActor.icrc2_approve(approveArgs);

      if ('Err' in approveResult) {
        const errorMsg = (() => {
          const err = approveResult.Err;
          if ('BadFee' in err) return `Bad fee. Expected: ${err.BadFee.expected_fee}`;
          if ('InsufficientFunds' in err) return `Insufficient funds. Balance: ${err.InsufficientFunds.balance}`;
          if ('AllowanceChanged' in err) return `Allowance changed. Current: ${err.AllowanceChanged.current_allowance}`;
          if ('Expired' in err) return 'Request expired';
          if ('TooOld' in err) return 'Request too old';
          if ('CreatedInFuture' in err) return 'Request created in future';
          if ('Duplicate' in err) return `Duplicate request. Original: ${err.Duplicate.duplicate_of}`;
          if ('TemporarilyUnavailable' in err) return 'Service temporarily unavailable';
          if ('GenericError' in err) return `Error ${err.GenericError.error_code}: ${err.GenericError.message}`;
          return 'Unknown error';
        })();
        setJoinStatus(`Approval failed: ${errorMsg}`);
        setJoinLoading(false);
        return;
      }

      setJoinStatus(`Approval successful! Block index: ${approveResult.Ok}. Now calling join function...`);

      // Call the join function - this is also an authenticated call
      const pullerAccount: PullerAccount = {
        owner: userPrincipal,
        subaccount: [],
      };

      const joinResult = await pullerActor.join(pullerAccount, e8sAmount);

      if ('Err' in joinResult) {
        setJoinStatus(`Join failed: ${joinResult.Err}`);
      } else {
        setJoinStatus(`🎉 Join successful! Transaction block index: ${joinResult.Ok.toString()}. You should appear on the alpha tester list within a minute!`);
        
        // Show confirmation dialog after 1 second delay
        setTimeout(() => {
          setJoinStatus("success_confirmed");
        }, 1000);
      }

    } catch (error) {
      console.error("Join test failed:", error);
      let errorMessage = "Unknown error occurred";
      
      if (error instanceof Error) {
        errorMessage = error.message;
      } else if (typeof error === 'string') {
        errorMessage = error;
      } else if (error && typeof error === 'object') {
        errorMessage = JSON.stringify(error);
      }
      
      // Check for common authentication errors
      if (errorMessage.includes('Unauthorized') || errorMessage.includes('Anonymous')) {
        errorMessage = "Authentication required. Please reconnect your wallet and try again.";
      }
      
      setJoinStatus(`Error: ${errorMessage}`);
    } finally {
      setJoinLoading(false);
    }
  };

  

  const handleChangeCanisterId = async () => {
    // Basic Validation
    try {
      const parsedPrincipal = Principal.fromText(newCanisterId);
      if (!parsedPrincipal) {
        setCanisterIdError("Invalid Canister ID format.");
        return;
      }
      // Optionally, add more validation like checking if the canister exists
      setCurrentCanisterId(newCanisterId);
      setOpenDialog(false);
    } catch (error) {
      console.error("Invalid Canister ID:", error);
      setCanisterIdError("Invalid Canister ID format.");
    }
  };

  // Content Rendering
  return (
    <Container maxWidth="md">
      <Box sx={{ my: 4, textAlign: 'left' }}>
        <Typography variant="h4" component="h1" sx={{ mb: 2 }}>
          ICRC-75 List Manager
        </Typography>
        <Box sx={{ display: 'flex',  mb: 2 }}>
          <Typography variant="h5" component="h2" >
            Current Canister: {currentCanisterId}
          </Typography>
          <IconButton aria-label="edit canister id" onClick={handleOpenDialog}>
            <EditIcon />
          </IconButton>
        </Box>

        <Box sx={{ display: 'flex',  mb: 2 }}>
          <Button 
            onClick={(e) => setCurrentCanisterId("nn7ao-eiaaa-aaaap-akjoq-cai")} 
            color="secondary">
              Load ICRC75 Demo
          </Button>
          <Button onClick={(e) => setCurrentCanisterId("wujau-jyaaa-aaaae-qajxq-cai")} 
            color="secondary">
              Load Whitelist Demo 1
          </Button>
          <Button onClick={(e) => setCurrentCanisterId("e3rbx-iyaaa-aaaac-ah2bq-cai")} 
            color="secondary">
              Load Whitelist Demo 2
          </Button>
        </Box>
        <Box sx={{ display: 'flex',  mb: 2 }}>
          <Typography variant="body1" sx={{ mt: 1 }}>
            To Test the White List Demo, you can{' '}
            <Button 
              variant="contained" 
              color="primary" 
              size="small"
              onClick={handleOpenJoinDialog}
              sx={{ 
                opacity: isConnected === "none" ? 0.7 : 1,
                cursor: isConnected === "none" ? "not-allowed" : "pointer"
              }}
            >
              {isConnected === "none" ? "Connect Wallet to Join" : "Join Alpha Test"}
            </Button>
            {' '}to approve ICP to the puller canister. Within a minute or so you will be on the alpha tester list and your alpha contribution will be recorded.
            {isConnected === "none" && (
              <Typography variant="caption" display="block" sx={{ color: 'text.secondary', mt: 1 }}>
                Please connect your wallet using the login buttons below to participate in the alpha test.
              </Typography>
            )}
          </Typography>
        </Box>

        {/* Canister ID Change Dialog */}
        <Dialog open={openDialog} onClose={handleCloseDialog}>
          <DialogTitle>Change Canister ID</DialogTitle>
          <DialogContent>
            <TextField
              autoFocus
              margin="dense"
              label="New Canister ID"
              type="text"
              fullWidth
              variant="outlined"
              value={newCanisterId}
              onChange={(e) => setNewCanisterId(e.target.value)}
              error={!!canisterIdError}
              helperText={canisterIdError}
            />
          </DialogContent>
          <DialogActions>
            <Button onClick={handleCloseDialog} color="secondary">
              Cancel
            </Button>
            <Button onClick={handleChangeCanisterId} color="primary">
              Change
            </Button>
          </DialogActions>
        </Dialog>

        {/* Join Alpha Test Dialog */}
        <Dialog open={joinDialogOpen} onClose={handleCloseJoinDialog} maxWidth="sm" fullWidth>
          <DialogTitle>
            {joinStatus === "success_confirmed" ? "🎉 Welcome to the Alpha Test!" : "Join Alpha Test"}
          </DialogTitle>
          <DialogContent>
            {isConnected === "none" ? (
              <Box sx={{ mb: 2 }}>
                <Typography variant="body1" color="warning.main" sx={{ mb: 2 }}>
                  ⚠️ Please connect your wallet first to participate in the alpha test.
                </Typography>
                <Box sx={{ display: 'flex', gap: 2, justifyContent: 'center' }}>
                  <Button variant="contained" onClick={() => { handleCloseJoinDialog(); handleLogin(); }} disabled={loading}>
                    Connect with Plug
                  </Button>
                  <Button variant="contained" onClick={() => { handleCloseJoinDialog(); handleLoginII(); }} disabled={loading}>
                    Connect with Internet Identity
                  </Button>
                </Box>
              </Box>
            ) : joinStatus === "success_confirmed" ? (
              <Box sx={{ textAlign: 'center', py: 2 }}>
                <Typography variant="h6" sx={{ mb: 2, color: 'success.main' }}>
                  🎊 Congratulations! 🎊
                </Typography>
                <Typography variant="body1" sx={{ mb: 2 }}>
                  You have successfully joined the alpha test! Your contribution has been recorded and you should appear on the alpha tester list within a minute.
                </Typography>
                <Typography variant="body2" sx={{ color: 'text.secondary' }}>
                  Thank you for participating in our alpha test program!
                </Typography>
              </Box>
            ) : (
              <>
                <Typography variant="body1" sx={{ mb: 2 }}>
                  This will approve the specified amount of ICP to the puller canister and call the join function.
                </Typography>
                <Typography variant="body2" sx={{ mb: 2, color: 'text.secondary' }}>
                  Connected as: <strong>{yourPrincipal.toString()}</strong>
                </Typography>
                <TextField
                  autoFocus
                  margin="dense"
                  label="ICP Amount to Donate"
                  type="number"
                  fullWidth
                  variant="outlined"
                  value={icpAmount}
                  onChange={(e) => setIcpAmount(e.target.value)}
                  inputProps={{
                    step: "0.01",
                    min: "0.01",
                  }}
                  helperText="Amount will be converted to e8s (multiplied by 10^8)"
                />
                {joinStatus && joinStatus !== "success_confirmed" && (
                  <Box sx={{ mt: 2 }}>
                    <Typography 
                      variant="body2" 
                      color={
                        joinStatus.includes('Error') || joinStatus.includes('failed') 
                          ? 'error' 
                          : joinStatus.includes('successful') 
                            ? 'success.main'
                            : 'textSecondary'
                      }
                    >
                      {joinStatus}
                    </Typography>
                  </Box>
                )}
              </>
            )}
          </DialogContent>
          <DialogActions>
            {joinStatus === "success_confirmed" ? (
              <Button 
                onClick={() => {
                  setJoinStatus("");
                  handleCloseJoinDialog();
                }} 
                color="primary"
                variant="contained"
                sx={{ mx: 'auto' }}
              >
                Close
              </Button>
            ) : (
              <>
                <Button onClick={handleCloseJoinDialog} color="secondary" disabled={joinLoading}>
                  {isConnected === "none" ? "Close" : "Cancel"}
                </Button>
                {isConnected !== "none" && (
                  <Button 
                    onClick={handleJoinTest} 
                    color="primary" 
                    disabled={joinLoading || !nnsLedgerActor || !pullerActor}
                    startIcon={joinLoading ? <CircularProgress size={20} /> : null}
                  >
                    {joinLoading ? 'Processing...' : 'Join Test'}
                  </Button>
                )}
              </>
            )}
          </DialogActions>
        </Dialog>

        {/* Authentication and Main Content */}
        <div className="App">
          {isConnected === "none" ? (
            <Box sx={{ mb: 2 }}>
              <Button variant="contained" onClick={handleLogin} disabled={loading} sx={{ mr: 2 }}>
                Login with Plug
              </Button>
              <Button variant="contained" onClick={handleLoginII} disabled={loading}>
                Login with Internet Identity
              </Button>
            </Box>
          ) : (
            <Box sx={{ mb: 2 }}>
              <Button variant="outlined" onClick={handleLogout} disabled={loading}>
                Logout
              </Button>
              <Typography variant="body1" sx={{ mt: 1 }}>
                Your Principal: {yourPrincipal.toString()}
              </Typography>
              {icrc75Actor && (
                <CreateList actor={icrc75Actor} onListCreated={fetchLists} />
              )}
              {icrc75Actor && (
                <ListViewer
                  icrc75Reader={icrc75Actor}
                  title="Your Lists"
                  yourPrincipal={yourPrincipal}
                  onListChange={fetchLists}
                  reloadFlag={reloadMyListsFlag}
                  
                />
              )}
              
            </Box>
          )}
          {icrc75Reader && (
            <ListViewer
              yourPrincipal={Principal.anonymous()}
              icrc75Reader={icrc75Reader}
              title="Global Lists"
              onListChange={fetchLists}
              reloadFlag={reloadMyListsFlag}
            />
          )}
          <Box sx={{ mt: 4, textAlign: 'center' }}>
            <Typography className="read-the-docs">
              <span>Built by <a href="https://icdevs.org" target="_blank">ICDevs.org</a> using <a href="https://internetcomputer.org/docs/current/developer-docs/build/cdks/motoko-dfinity/motoko/" target="_blank">Motoko</a> with funding from the <a href="https://dfinity.org" target="_blank">DFINITY Foundation</a>.</span>
            </Typography>
          </Box>
        </div>
        <Copyright />
        <Box sx={{ mt: 4, textAlign: 'center' }}>
          <div>
            <a href="https://icdevs.org" target="_blank">
              <img src={viteLogo} className="logo vite" alt="Vite logo" />
            </a>

            <a
              href="https://internetcomputer.org/docs/current/developer-docs/build/cdks/motoko-dfinity/motoko/"
              target="_blank"
            >
              <span className="logo-stack">
                <img
                  src={motokoShadowLogo}
                  className="logo motoko-shadow"
                  alt="Motoko logo"
                />
                <img src={motokoLogo} className="logo motoko" alt="Motoko logo" />
              </span>
            </a>
          </div>
        </Box>
      </Box>
    </Container>
  );
}

export default App;
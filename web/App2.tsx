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
          whitelist: [currentCanisterId],
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
      } else if (isConnected === "ii" && authClient !== null) {
        const identity = authClient.getIdentity();
        const agentOptions = { host: hostEnv, identity };
        const actor = createICRC75(canisterId, { agentOptions });
        setIcrc75Actor(actor);
      }
      console.log(`Actor set up with canister ID: ${canisterId}`);
    } catch (error) {
      console.error("Failed to set up actor:", error);
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
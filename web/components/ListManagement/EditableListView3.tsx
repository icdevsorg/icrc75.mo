import React, { useEffect, useState } from 'react';
import { Principal } from '@dfinity/principal';
import {
  Typography,
  CircularProgress,
  Box,
  TextField,
  Button,
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableRow,
  Paper,
  TableContainer,
  IconButton,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Select,
  MenuItem,
  FormControl,
  InputLabel,
  DialogContentText,
} from '@mui/material';
import { Delete as DeleteIcon, Add as AddIcon } from '@mui/icons-material';
import { 
  _SERVICE as ICRC75Service, 
  PermissionList, 
  ListItem, 
  Value, 
  Permission, 
  PermissionListItem, 
  ManageListPropertyRequestAction,
  ManageListPropertyRequest,
  DataItemMap, 
  Subaccount, 
  DataItem, 
  ManageListMembershipRequest,
  ManageListMembershipRequestItem
} from '../../../src/declarations/icrc75/icrc75.did.js';
import { validateMetadata, validateValueAsString, dataItemStringify, dataItemReviver } from '../../utils';
import { on } from 'events';

interface EditableListViewProps {
  icrc75Reader: ICRC75Service;
  listName: string;
  metadata: DataItemMap | null;
  yourPrincipal: Principal; // Current user's principal
  onUpdateMetadata?: (metadata: DataItemMap) => void;
  onListsChange?: () => void;
}

const EditableListView: React.FC<EditableListViewProps> = ({
  icrc75Reader,
  listName,
  metadata,
  yourPrincipal,
  onUpdateMetadata,
  onListsChange
}) => {
  const [loading, setLoading] = useState<boolean>(true);
  const [error, setError] = useState<string>('');
  const [editMetadata, setEditMetadata] = useState<string>('');
  const [permissions, setPermissions] = useState<PermissionList | null>(null);
  const [members, setMembers] = useState<[ListItem, [] | [DataItemMap]][] | null>(null);
  
  // Member Management States
  const [openAddMember, setOpenAddMember] = useState<boolean>(false);
  const [newMemberPrincipal, setNewMemberPrincipal] = useState<string>('');
  const [newMemberSubaccount, setNewMemberSubaccount] = useState<string>('');
  const [newListName, setNewListName] = useState<string>('');
  const [newDataItemValue, setNewDataItemValue] = useState<string>('');
  const [newMemberType, setNewMemberType] = useState<'Identity' | 'Account' | 'List' | 'DataItem'>('Identity');
  
  const [addMemberError, setAddMemberError] = useState<string>('');
  
  // Add Permission Dialog States
  const [openAddPermission, setOpenAddPermission] = useState<boolean>(false);
  const [permissionTargetType, setPermissionTargetType] = useState<'Identity' | 'List'>('Identity');
  const [permissionTarget, setPermissionTarget] = useState<string>('');
  const [permissionType, setPermissionType] = useState<"Read" | "Write" | "Admin" | "Permissions">('Read');
  const [addPermissionError, setAddPermissionError] = useState<string>('');
  
  // Confirmation Dialog for Removing Member
  const [openConfirm, setOpenConfirm] = useState<boolean>(false);
  const [memberToRemove, setMemberToRemove] = useState<ListItem | null>(null);

  // Handle renaming the list
  const [renameListName, setRenameListName] = useState<string>(listName);
  const [renaming, setRenaming] = useState<boolean>(false);

  // Handle deleting the list
  const [openDeleteConfirm, setOpenDeleteConfirm] = useState<boolean>(false);
  const [deleting, setDeleting] = useState<boolean>(false);

  useEffect(() => {
    const fetchListDetails = async () => {
      setLoading(true);
      try {
        // Fetch permissions
        const foundPermissions: PermissionList = await icrc75Reader.icrc75_get_list_permissions_admin(
          listName,
          [], // No specific filters
          [],
          []
        );
        setPermissions(foundPermissions);

        // Fetch members
        const foundMembers = await icrc75Reader.icrc75_get_list_members_admin(
          listName,
          [], // No specific filters
          []
        );
        setMembers(foundMembers);

        // Initialize metadata
        const initialMetadata = metadata ? metadata : [];
        setEditMetadata(JSON.stringify(initialMetadata, dataItemStringify, 2));
      } catch (err) {
        console.error('Error fetching list details:', err);
        setError('Failed to fetch list details.');
      } finally {
        setLoading(false);
      }
    };

    fetchListDetails();
  }, [icrc75Reader, listName, metadata]);

  const handleMetadataChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setEditMetadata(e.target.value);
  };

  const handleSaveMetadata = async () => {
    try {
      let newMetadataString = editMetadata;
      const parsedMetadata: DataItemMap = validateMetadata(editMetadata, true);

      // Call the manage list properties API to update metadata
      let commandList: ManageListPropertyRequest = parsedMetadata.map(([key, value]) => ({
        list: listName,
        memo: [], // Optional: provide if needed
        from_subaccount: [], // Optional: provide if needed
        created_at_time: [], // Optional: provide if needed
        action: {
          Metadata: {
            key: key,
            value: [value], // Ensure value is an array containing a single DataItem object
          },
        },
      }));
     
      try {
        let result = await icrc75Reader.icrc75_manage_list_properties(commandList);
        if(result && result[0] && result[0][0] && "Ok" in result[0][0] && result[0][0].Ok){
          //alert('List metadata updated successfully! Transaction ID: ' + result[0][0].Ok.toString());
          setEditMetadata(newMetadataString);
        } else {
          alert('Error updating metadata: ' + JSON.stringify(result));
        };
      } catch (error) {
        console.error('Error updating metadata:', error);
        alert('Error updating metadata.');
      };

      // Refresh permissions and members after saving metadata
      if(onUpdateMetadata) onUpdateMetadata(parsedMetadata);
      // Optionally, show a success message (already handled above)
    } catch (err) {
      console.error('Error saving metadata:', err);
      setError('Failed to save metadata.');
      setLoading(false);
    }
  };

  // Handle adding a new member
  const handleAddMember = async () => {
    setAddMemberError('');
    try {
      let newListItem: ListItem;

      switch (newMemberType) {
        case 'Identity':
          if (!newMemberPrincipal) {
            setAddMemberError('Principal ID is required for Identity.');
            return;
          }
          newListItem = { 'Identity' : Principal.fromText(newMemberPrincipal) };
          break;
        case 'Account':
          if (!newMemberPrincipal) {
            setAddMemberError('Owner Principal ID is required for Account.');
            return;
          }
          // Convert subaccount hex string to Blob if provided
          const subaccountBlob : [Subaccount] | [] = newMemberSubaccount == ''
            ? [Uint8Array.from(Buffer.from(newMemberSubaccount, 'hex'))]
            : [];
          newListItem = {
            'Account': {
              owner: Principal.fromText(newMemberPrincipal),
              subaccount: subaccountBlob.length > 0 ? subaccountBlob : [],
            },
          };
          break;
        case 'List':
          if (!newListName) {
            setAddMemberError('List name is required for List.');
            return;
          }
          newListItem = { 'List': newListName };
          break;
        case 'DataItem':
          if (!newDataItemValue) {
            setAddMemberError('Value is required for DataItem.');
            return;
          }
          
          let valid = validateValueAsString(newDataItemValue, true);
          if (!valid) {
            setAddMemberError('Invalid DataItem value.');
            return;
          }
          newListItem = { 'DataItem': JSON.parse(newDataItemValue, dataItemReviver) };
          break;
        default:
          setAddMemberError('Unsupported member type.');
          return;
      }

      // Call the manage list membership API to add the new member
      const addMemberCommand : ManageListMembershipRequest = [{
        list: listName,
        memo: [], // Optional: provide if needed
        from_subaccount: [], // Optional: provide if needed
        created_at_time: [], // Optional: provide if needed
        action: {
          Add: [newListItem,[]],
        },
      }];

      await icrc75Reader.icrc75_manage_list_membership(addMemberCommand);

      // Refresh members after adding
      setLoading(true);
      const updatedMembers = await icrc75Reader.icrc75_get_list_members_admin(
        listName,
        [], // No specific filters
        []
      );
      setMembers(updatedMembers);
      setLoading(false);

      // Reset dialog fields
      setOpenAddMember(false);
      setNewMemberPrincipal('');
      setNewMemberSubaccount('');
      setNewListName('');
      setNewDataItemValue('');
    } catch (err) {
      setLoading(false);
      console.error('Error adding member:', err);
      setError('Failed to add member.');
    }
  };

  // Handle removing a member
  const handleRemoveMember = (member: ListItem) => {
    setMemberToRemove(member);
    setOpenConfirm(true);
  };

  const confirmRemoveMember = async () => {
    if (!memberToRemove) return;

    try {
      const removeMemberCommand : ManageListMembershipRequest = [{
        list: listName,
        memo: [], // Optional: provide if needed
        from_subaccount: [], // Optional: provide if needed
        created_at_time: [], // Optional: provide if needed
        action: {
          Remove: memberToRemove,
        },
      }];
      await icrc75Reader.icrc75_manage_list_membership(removeMemberCommand);

      // Refresh members after removal
      setLoading(true);
      const updatedMembers = await icrc75Reader.icrc75_get_list_members_admin(
        listName,
        [], // No specific filters
        []
      );
      setMembers(updatedMembers);
      setLoading(false);

      setOpenConfirm(false);
      setMemberToRemove(null);
    } catch (err) {
      setLoading(false);
      console.error('Error removing member:', err);
      setError('Failed to remove member.');
      setOpenConfirm(false);
    }
  };

  const cancelRemoveMember = () => {
    setOpenConfirm(false);
    setMemberToRemove(null);
  };

  // Handle adding a new permission
  const handleAddPermission = async () => {
    setAddPermissionError('');
    try {
      if (!permissionTarget) {
        setAddPermissionError('Target identifier is required.');
        return;
      }

      let listItem: ListItem;

      switch (permissionTargetType) {
        case 'Identity':
          listItem = { 'Identity': Principal.fromText(permissionTarget) };
          break;
        case 'List':
          listItem = { 'List': permissionTarget };
          break;
        default:
          setAddPermissionError('Unsupported target type.');
          return;
      }

      let changePermissionsAction: any;

      if (permissionType === "Read") {
        changePermissionsAction = {
          Read: {
            Add: listItem,
          },
        };
      } else if (permissionType === "Write") {
        changePermissionsAction = {
          Write: {
            Add: listItem,
          },
        };
      } else if (permissionType === "Admin") {
        changePermissionsAction = {
          Admin: {
            Add: listItem,
          },
        };
      } else if (permissionType === "Permissions") {
        changePermissionsAction = {
          Permissions: {
            Add: listItem,
          },
        };
      }

      // Call the manage list properties API to add permission
      const addPermissionCommand : ManageListPropertyRequest = [{
        list: listName,
        memo: [], // Optional: provide if needed
        from_subaccount: [], // Optional: provide if needed
        created_at_time: [], // Optional: provide if needed
        action: {
          ChangePermissions : changePermissionsAction,
        },
      }];

      await icrc75Reader.icrc75_manage_list_properties(addPermissionCommand);

      // Refresh permissions after adding
      setLoading(true);
      const updatedPermissions: PermissionList = await icrc75Reader.icrc75_get_list_permissions_admin(
        listName,
        [], // No specific filters
        [],
        []
      );
      setPermissions(updatedPermissions);
      setLoading(false);

      // Reset dialog fields
      setOpenAddPermission(false);
      setPermissionTarget('');
      setPermissionType('Read');
    } catch (err) {
      setLoading(false);
      console.error('Error adding permission:', err);
      setAddPermissionError('Failed to add permission.');
    }
  };

  // Handle adding a new permission
  const handleRemovePermission = async (listItem, permission) => {
    
    try {


      let changePermissionsAction: any;

      if ("Read" in permission) {
        changePermissionsAction = {
          Read: {
            Remove: listItem,
          },
        };
      } else if ("Write" in permission) {
        changePermissionsAction = {
          Write: {
            Remove: listItem,
          },
        };
      } else if ("Admin" in permission) {
        changePermissionsAction = {
          Admin: {
            Remove: listItem,
          },
        };
      } else if ("Permissions" in permission) {
        changePermissionsAction = {
          Permissions: {
            Remove: listItem,
          },
        };
      }

      // Call the manage list properties API to add permission
      const removePermissionCommand : ManageListPropertyRequest = [{
        list: listName,
        memo: [], // Optional: provide if needed
        from_subaccount: [], // Optional: provide if needed
        created_at_time: [], // Optional: provide if needed
        action: {
          ChangePermissions : changePermissionsAction,
        },
      }];

      await icrc75Reader.icrc75_manage_list_properties(removePermissionCommand);

      // Refresh permissions after adding
      setLoading(true);
      const updatedPermissions: PermissionList = await icrc75Reader.icrc75_get_list_permissions_admin(
        listName,
        [], // No specific filters
        [],
        []
      );
      setPermissions(updatedPermissions);
      setLoading(false);

    } catch (err) {
      setLoading(false);
      console.error('Error adding permission:', err);
      setAddPermissionError('Failed to add permission.');
    }
  };

  // Handle permission change for a member
  const handlePermissionChange = async (member: ListItem, newPermission: string) => {
    try {
      let permissionChange: any = {};

      switch (newPermission) {
        case "Admin":
          permissionChange = { Admin: { Add: member } };
          break;
        case "Write":
          permissionChange = { Write: { Add: member } };
          break;
        case "Read":
          permissionChange = { Read: { Add: member } };
          break;
        case "Permissions":
          permissionChange = { Permissions: { Add: member } };
          break;
        default:
          setError('Unsupported permission type.');
          return;
      }

      const changePermissionCommand : ManageListPropertyRequest = [{
        list: listName,
        memo: [], // Optional: provide if needed
        from_subaccount: [], // Optional: provide if needed
        created_at_time: [], // Optional: provide if needed
        action: {
          ChangePermissions: permissionChange,
        },
      }];
      
      await icrc75Reader.icrc75_manage_list_properties(changePermissionCommand);

      // Refresh permissions after change
      setLoading(true);
      const updatedPermissions: PermissionList = await icrc75Reader.icrc75_get_list_permissions_admin(
        listName,
        [], // No specific filters
        [],
        []
      );
      setPermissions(updatedPermissions);
      setLoading(false);
    } catch (err) {
      setLoading(false);
      console.error('Error changing permissions:', err);
      setError('Failed to change permissions.');
    }
  };

  // Handle renaming the list
  const handleRenameList = async () => {
    if (renameListName.trim() === "") {
      setError("List name cannot be empty.");
      return;
    }

    if (renameListName === listName) {
      setError("New list name is the same as the current name.");
      return;
    }

    try {
      setRenaming(true);
      const commandList: ManageListPropertyRequest = [
        {
          list: listName,
          memo: [], // Optional: provide if needed
          from_subaccount: [], // Optional: provide if needed
          created_at_time: [], // Optional: provide if needed
          action: {
            Rename: renameListName,
          },
        },
      ];

      const result = await icrc75Reader.icrc75_manage_list_properties(commandList);
      if (result && result[0] && result[0][0] && "Ok" in result[0][0] && result[0][0].Ok) {
        //('List renamed successfully! Transaction ID: ' + result[0][0].Ok.toString());
        // Optionally, update the current component's state or notify the parent
        if(onListsChange) onListsChange();
      } else {
        alert('Error renaming list: ' + JSON.stringify(result));
      }
    } catch (err) {
      console.error('Error renaming list:', err);
      setError('Failed to rename list.');
    } finally {
      setRenaming(false);
    }
  };

  // Handle deleting the list
  const handleDeleteList = async () => {
    try {
      setDeleting(true);
      const commandList: ManageListPropertyRequest = [
        {
          list: listName,
          memo: [], // Optional: provide if needed
          from_subaccount: [], // Optional: provide if needed
          created_at_time: [], // Optional: provide if needed
          action: {
            Delete: null, // Delete action doesn't require additional data
          },
        },
      ];

      const result = await icrc75Reader.icrc75_manage_list_properties(commandList);
      if (result && result[0] && result[0][0] && "Ok" in result[0][0] && result[0][0].Ok) {
        //alert('List deleted successfully! Transaction ID: ' + result[0][0].Ok.toString());
        if(onListsChange) onListsChange();
        // Optionally, redirect the user or update the parent component
      } else {
        alert('Error deleting list: ' + JSON.stringify(result));
      }
    } catch (err) {
      console.error('Error deleting list:', err);
      setError('Failed to delete list.');
    } finally {
      setDeleting(false);
      setOpenDeleteConfirm(false);
    }
  };

  if (loading) {
    return (
      <Box sx={{ display: 'flex', justifyContent: 'center', mt: 2 }}>
        <CircularProgress size={24} />
      </Box>
    );
  }

  if (error) {
    return (
      <Typography color="error">{error}</Typography>
    );
  }

  return (
    <Box>
      <Typography variant="h6">Editable List Details</Typography>
      
      {/* Metadata Editing */}
      <Box sx={{ mt: 2 }}>
        <Typography variant="subtitle1">Metadata:</Typography>
        <TextField
          multiline
          fullWidth
          minRows={4}
          value={editMetadata}
          onChange={handleMetadataChange}
          variant="outlined"
          placeholder="Edit metadata as JSON"
        />
        <Box sx={{ mt: 2 }}>
          <Button variant="contained" color="primary" onClick={handleSaveMetadata}>
            Save Metadata
          </Button>
        </Box>
      </Box>

      {/* Rename List */}
      <Box sx={{ mt: 4 }}>
        <Typography variant="subtitle1">Rename List:</Typography>
        <Box sx={{ display: 'flex', alignItems: 'center', mt: 1 }}>
          <TextField
            label="New List Name"
            variant="outlined"
            value={renameListName}
            onChange={(e) => setRenameListName(e.target.value)}
            sx={{ mr: 2, flexGrow: 1 }}
          />
          <Button 
            variant="contained" 
            color="secondary" 
            onClick={handleRenameList} 
            disabled={renaming}
          >
            {renaming ? 'Renaming...' : 'Rename'}
          </Button>
        </Box>
      </Box>

      {/* Delete List */}
      <Box sx={{ mt: 2 }}>
        <Typography variant="subtitle1">Delete List:</Typography>
        <Box sx={{ mt: 1 }}>
          <Button 
            variant="outlined" 
            color="error" 
            startIcon={<DeleteIcon />} 
            onClick={() => setOpenDeleteConfirm(true)}
            disabled={deleting}
          >
            {deleting ? 'Deleting...' : 'Delete List'}
          </Button>
        </Box>
      </Box>

      {/* Members Management */}
      <Box sx={{ mt: 4 }}>
        <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <Typography variant="subtitle1">Members:</Typography>
          <Button
            variant="outlined"
            startIcon={<AddIcon />}
            onClick={() => setOpenAddMember(true)}
          >
            Add Member
          </Button>
        </Box>
        <TableContainer component={Paper} sx={{ mt: 2 }}>
          <Table aria-label="members table">
            <TableHead>
              <TableRow>
                <TableCell><strong>Type</strong></TableCell>
                <TableCell><strong>Identifier</strong></TableCell>
                <TableCell><strong>Metadata</strong></TableCell>
                <TableCell><strong>Actions</strong></TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {members && members.length > 0 ? (
                members.map((member, index) => {
                  const identifier =
                    'Identity' in member[0]
                      ? member[0]['Identity'].toString()
                      : 'Account' in member[0]
                      ? `${member[0]['Account'].owner.toString()}.${member[0]['Account'].subaccount[0] ? Buffer.from(member[0]['Account'].subaccount[0]).toString('hex') : 'No Subaccount'}`
                      : 'List' in member[0]
                      ? member[0]['List']
                      : 'DataItem' in member[0]
                      ? JSON.stringify(member[0]['DataItem'], dataItemStringify, 2)
                      : 'Unknown';

                    const memberMetadata = member[1] && member[1].length > 0 ? JSON.stringify(member[1][0], dataItemStringify, 2) : null;

                  return (
                    <TableRow key={index}>
                      <TableCell>
                        {'Identity' in member[0]
                          ? 'Identity'
                          : 'Account' in member[0]
                          ? 'Account'
                          : 'List' in member[0]
                          ? 'List'
                          : 'DataItem' in member[0]
                          ? 'DataItem'
                          : 'Unknown'}
                      </TableCell>
                      <TableCell>{identifier}</TableCell>
                      <TableCell>{memberMetadata}</TableCell>
                      <TableCell>
                        <IconButton
                          aria-label="delete"
                          color="secondary"
                          onClick={() => handleRemoveMember(member[0])}
                        >
                          <DeleteIcon />
                        </IconButton>
                      </TableCell>
                    </TableRow>
                  );
                })
              ) : (
                <TableRow>
                  <TableCell colSpan={3} align="center">
                    No members found.
                  </TableCell>
                </TableRow>
              )}
            </TableBody>
          </Table>
        </TableContainer>
      </Box>

      {/* Permissions Management */}
      <Box sx={{ mt: 4 }}>
        <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <Typography variant="subtitle1">Permissions:</Typography>
          <Button
            variant="outlined"
            startIcon={<AddIcon />}
            onClick={() => setOpenAddPermission(true)}
          >
            Add Permission
          </Button>
        </Box>
        <TableContainer component={Paper} sx={{ mt: 2 }}>
          <Table aria-label="permissions table">
            <TableHead>
              <TableRow>
                <TableCell><strong>Type</strong></TableCell>
                <TableCell><strong>Identifier</strong></TableCell>
                <TableCell><strong>Permission</strong></TableCell>
                <TableCell><strong>Actions</strong></TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {permissions && permissions.length > 0 ? (
                permissions.map(([permission, listItem], index) => {
                  const target =
                    'Identity' in listItem
                      ? listItem['Identity'].toString()
                      : 'List' in listItem
                      ? listItem['List']
                      : 'Account' in listItem
                      ? `${listItem['Account'].owner.toString()}.${listItem['Account'].subaccount[0] ? Buffer.from(listItem['Account'].subaccount[0]).toString('hex') : 'No Subaccount'}`
                      : 'DataItem' in listItem
                      ? JSON.stringify(listItem['DataItem'], dataItemStringify, 2)
                      : 'Unknown';

                  return (
                    <TableRow key={index}>
                      <TableCell>
                        {'Identity' in listItem
                          ? 'Identity'
                          : 'List' in listItem
                          ? 'List'
                          : 'Account' in listItem
                          ? 'Account'
                          : 'DataItem' in listItem
                          ? 'DataItem'
                          : 'Unknown'}
                      </TableCell>
                      <TableCell>{target}</TableCell>
                      <TableCell>{('Admin' in permission )? "Admin" : ('Write' in permission ? "Write" : ('Read' in permission ? 'Read' : 'Permissions'))}</TableCell>
                      <TableCell>
                        
                         <IconButton
                          aria-label="delete"
                          color="secondary"
                          onClick={() => handleRemovePermission(listItem, permission)}
                        >
                          <DeleteIcon />
                        </IconButton>
                      </TableCell>
                    </TableRow>
                  );
                })
              ) : (
                <TableRow>
                  <TableCell colSpan={4} align="center">
                    No permissions found.
                  </TableCell>
                </TableRow>
              )}
            </TableBody>
          </Table>
        </TableContainer>
      </Box>

      {/* Add Member Dialog */}
      <Dialog open={openAddMember} onClose={() => setOpenAddMember(false)} maxWidth="sm" fullWidth>
        <DialogTitle>Add New Member</DialogTitle>
        <DialogContent>
          <DialogContentText>
            Select the type of member you want to add and provide the necessary details.
          </DialogContentText>
          <FormControl fullWidth sx={{ mt: 2 }}>
            <InputLabel id="member-type-label">Member Type</InputLabel>
            <Select
              labelId="member-type-label"
              value={newMemberType}
              onChange={(e) => setNewMemberType(e.target.value as 'Identity' | 'Account' | 'List' | 'DataItem')}
              label="Member Type"
            >
              <MenuItem value="Identity">Identity</MenuItem>
              <MenuItem value="Account">Account</MenuItem>
              <MenuItem value="List">List</MenuItem>
              <MenuItem value="DataItem">DataItem</MenuItem>
            </Select>
          </FormControl>

          {/* Conditionally render input fields based on member type */}
          {newMemberType === 'Identity' && (
            <TextField
              margin="dense"
              label="Principal ID"
              type="text"
              fullWidth
              variant="standard"
              value={newMemberPrincipal}
              onChange={(e) => setNewMemberPrincipal(e.target.value)}
              sx={{ mt: 2 }}
            />
          )}

          {newMemberType === 'Account' && (
            <>
              <TextField
                margin="dense"
                label="Owner Principal ID"
                type="text"
                fullWidth
                variant="standard"
                value={newMemberPrincipal}
                onChange={(e) => setNewMemberPrincipal(e.target.value)}
                sx={{ mt: 2 }}
              />
              <TextField
                margin="dense"
                label="Subaccount (Hexadecimal)"
                type="text"
                fullWidth
                variant="standard"
                value={newMemberSubaccount}
                onChange={(e) => setNewMemberSubaccount(e.target.value)}
                sx={{ mt: 2 }}
                helperText="Optional: Provide in hexadecimal format"
              />
            </>
          )}

          {newMemberType === 'List' && (
            <TextField
              margin="dense"
              label="List Name"
              type="text"
              fullWidth
              variant="standard"
              value={newListName}
              onChange={(e) => setNewListName(e.target.value)}
              sx={{ mt: 2 }}
            />
          )}

          {newMemberType === 'DataItem' && (
            <>
              <TextField
                multiline
                minRows={4}
                margin="dense"
                label="DataItem Value"
                type="text"
                fullWidth
                variant="standard"
                value={newDataItemValue}
                onChange={(e) => setNewDataItemValue(e.target.value)}
                sx={{ mt: 2 }}
              />
            </>
          )}

          {addMemberError && (
            <Typography color="error" sx={{ mt: 2 }}>
              {addMemberError}
            </Typography>
          )}
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setOpenAddMember(false)}>Cancel</Button>
          <Button onClick={handleAddMember} variant="contained" color="primary">
            Add
          </Button>
        </DialogActions>
      </Dialog>

      {/* Add Permission Dialog */}
      <Dialog open={openAddPermission} onClose={() => setOpenAddPermission(false)} maxWidth="sm" fullWidth>
        <DialogTitle>Add New Permission</DialogTitle>
        <DialogContent>
          <DialogContentText>
            Assign a permission to an identity or a list. Select the target type and provide the identifier.
          </DialogContentText>
          <FormControl fullWidth sx={{ mt: 2 }}>
            <InputLabel id="permission-target-type-label">Target Type</InputLabel>
            <Select
              labelId="permission-target-type-label"
              value={permissionTargetType}
              onChange={(e) => setPermissionTargetType(e.target.value as 'Identity' | 'List')}
              label="Target Type"
            >
              <MenuItem value="Identity">Identity</MenuItem>
              <MenuItem value="List">List</MenuItem>
            </Select>
          </FormControl>

          <TextField
            margin="dense"
            label="Identifier"
            type="text"
            fullWidth
            variant="standard"
            value={permissionTarget}
            onChange={(e) => setPermissionTarget(e.target.value)}
            sx={{ mt: 2 }}
            helperText={permissionTargetType === 'Identity' ? 'Enter Principal ID' : 'Enter List Name'}
          />

          <FormControl fullWidth sx={{ mt: 2 }}>
            <InputLabel id="permission-type-label">Permission Type</InputLabel>
            <Select
              labelId="permission-type-label"
              value={permissionType}
              onChange={(e) => setPermissionType(e.target.value as "Read" | "Write" | "Admin" | "Permissions")}
              label="Permission Type"
            >
              <MenuItem value="Admin">Admin</MenuItem>
              <MenuItem value="Write">Write</MenuItem>
              <MenuItem value="Read">Read</MenuItem>
              <MenuItem value="Permissions">Permissions</MenuItem>
            </Select>
          </FormControl>

          {addPermissionError && (
            <Typography color="error" sx={{ mt: 2 }}>
              {addPermissionError}
            </Typography>
          )}
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setOpenAddPermission(false)}>Cancel</Button>
          <Button onClick={handleAddPermission} variant="contained" color="primary">
            Add Permission
          </Button>
        </DialogActions>
      </Dialog>

      {/* Confirmation Dialog for Removing Member */}
      <Dialog
        open={openConfirm}
        onClose={cancelRemoveMember}
        aria-labelledby="confirm-dialog-title"
        aria-describedby="confirm-dialog-description"
      >
        <DialogTitle id="confirm-dialog-title">Confirm Member Removal</DialogTitle>
        <DialogContent>
          <DialogContentText id="confirm-dialog-description">
            Are you sure you want to remove{' '}
            {memberToRemove
              ? memberToRemove['Identity']
                ? `Identity: ${memberToRemove['Identity']}`
                : memberToRemove['Account']
                ? `Account Owner: ${memberToRemove['Account'].owner.toString()}${memberToRemove['Account'].subaccount ? `, Subaccount: ${Buffer.from(memberToRemove['Account'].subaccount).toString('hex')}` : ''}`
                : memberToRemove['List']
                ? `List: ${memberToRemove['List']}`
                : memberToRemove['DataItem']
                ? `DataItem: ${JSON.stringify(memberToRemove['DataItem'], dataItemStringify, 2)}`
                : 'this member'
              : ''}
            ?
          </DialogContentText>
        </DialogContent>
        <DialogActions>
          <Button onClick={cancelRemoveMember}>Cancel</Button>
          <Button onClick={confirmRemoveMember} color="secondary" variant="contained" autoFocus>
            Remove
          </Button>
        </DialogActions>
      </Dialog>

      
    </Box>
  );
};

export default EditableListView;
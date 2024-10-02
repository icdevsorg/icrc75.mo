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
  DataItem 
} from '../../../src/declarations/icrc75/icrc75.did.js';
import { validateMetadata, validateValueAsString, dataItemReviver, dataItemStringify } from '../../utils.js';

interface EditableListViewProps {
  icrc75Reader: ICRC75Service;
  listName: string;
  metadata: DataItemMap | null;
  yourPrincipal: Principal; // Current user's principal
}

const EditableListView: React.FC<EditableListViewProps> = ({
  icrc75Reader,
  listName,
  metadata,
  yourPrincipal,
}) => {
  const [loading, setLoading] = useState<boolean>(true);
  const [error, setError] = useState<string>('');
  const [editMetadata, setEditMetadata] = useState<string>('');
  const [permissions, setPermissions] = useState<PermissionList | null>(null);
  const [members, setMembers] = useState<ListItem[] | null>(null);
  const [metadataMap, setMetadataMap] = useState<{ key: string; value: any }[]>([]);
  const [openAddMember, setOpenAddMember] = useState<boolean>(false);
  const [newMemberPrincipal, setNewMemberPrincipal] = useState<string>('');
  const [newMemberPermission, setNewMemberPermission] = useState<string>("Read");

  const [addMemberError, setAddMemberError] = useState<string>('');

  const [newMemberType, setNewMemberType] = useState<'Identity' | 'Account' | 'List' | 'DataItem'>('Identity');
  
  // Common fields
  
  // Account specific
  const [newMemberSubaccount, setNewMemberSubaccount] = useState<string>('');
  
  // List specific
  const [newListName, setNewListName] = useState<string>('');
  
  // DataItem specific
  const [newDataItemValue, setNewDataItemValue] = useState<string>('');

  // Handle renaming the list
  const [renameListName, setRenameListName] = useState<string>(listName);
  const [renaming, setRenaming] = useState<boolean>(false);

  // Handle deleting the list
  const [openDeleteConfirm, setOpenDeleteConfirm] = useState<boolean>(false);
  const [deleting, setDeleting] = useState<boolean>(false);

  // Confirmation Dialog for Removing Member
  const [openConfirm, setOpenConfirm] = useState<boolean>(false);
  const [memberToRemove, setMemberToRemove] = useState<ListItem | null>(null);

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
        const foundMembers: ListItem[] = await icrc75Reader.icrc75_get_list_members_admin(
          listName,
          [], // No specific filters
          []
        );
        setMembers(foundMembers);

        // Initialize metadata
        const initialMetadata = metadata ? metadata : { 'Map': [] };
        const map = initialMetadata['Map'] as Array<{ key: string; value: any }>;
        setMetadataMap(map);
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
      const parsedMetadata: DataItemMap = validateMetadata(editMetadata, true);

      // Call the manage list properties API to update metadata
      let commandList: ManageListPropertyRequest = parsedMetadata.map(([key, value]) => {

        return {
          list: listName,
          memo: [], // Optional: provide if needed
          from_subaccount: [], // Optional: provide if needed
          created_at_time: [], // Optional: provide if needed
          action: {
            Metadata: {
              key: key,
              value: [value], // Ensure value is an array containing a single DataItem__1 object
            },
          },
        };
      });
     
      try{
        let result = await icrc75Reader.icrc75_manage_list_properties(commandList);
        if(result && result[0] && result[0][0] && "Ok" in result[0][0] && result[0][0].Ok){
          //alert('List metadata updated successfully! Transaction ID: ' + result[0][0].Ok.toString());
        } else {
          alert('Error updating metadata: ' + JSON.stringify(result));
        };
      } catch (error) {
        console.error('Error updating metadata:', error);
        setError('Failed to update metadata.');
      };

      // Refresh permissions and members after saving metadata
      setLoading(true);
      const updatedPermissions: PermissionList = await icrc75Reader.icrc75_get_list_permissions_admin(
        listName,
        [], // No specific filters
        [],
        []
      );
      setPermissions(updatedPermissions);

      const updatedMembers: ListItem[] = await icrc75Reader.icrc75_get_list_members_admin(
        listName,
        [], // No specific filters
        []
      );
      setMembers(updatedMembers);
      setLoading(false);

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
          const subaccountBlob : [Subaccount] | [] = newMemberSubaccount
            ? [Uint8Array.from(Buffer.from(newMemberSubaccount, 'hex'))]
            : [];
          newListItem = {
            'Account': {
              owner: Principal.fromText(newMemberPrincipal),
              subaccount: subaccountBlob,
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
          newListItem = { 'DataItem': JSON.parse(newDataItemValue) };
          break;
        default:
          setAddMemberError('Unsupported member type.');
          return;
      }

      // Call the manage list membership API to add the new member
      await icrc75Reader.icrc75_manage_list_membership([
        {
          list: listName,
          memo: [], // Optional: provide if needed
          from_subaccount: [], // Optional: provide if needed
          created_at_time: [], // Optional: provide if needed
          action: {
            Add: newListItem,
          },
        },
      ]);

      if(newMemberType === "Identity" || newMemberType === "List"){  

        let newPermission : any = { Read : {  Add: {Identity: Principal.fromText(newMemberPrincipal)} } };
        if("Admin" === newMemberPermission){
          newPermission = { Admin : {  Add: {Identity: Principal.fromText(newMemberPrincipal)} } };
        } else if("Write" === newMemberPermission){ 
          newPermission = { Write : {  Add: {Identity: Principal.fromText(newMemberPrincipal)} } };
        } else if("Permissions" === newMemberPermission){
          newPermission = { Permissions : {  Add: {Identity: Principal.fromText(newMemberPrincipal)} } };
        } else if("Read" === newMemberPermission){
          newPermission = { Read : {  Add: {Identity: Principal.fromText(newMemberPrincipal)} } };
        };

        await icrc75Reader.icrc75_manage_list_properties([
          {
            list: listName,
            memo: [], // Optional: provide if needed
            from_subaccount: [], // Optional: provide if needed
            created_at_time: [], // Optional: provide if needed
            action: {
              ChangePermissions:  newPermission,
            },
          },
        ]);
      };

      // Refresh members after adding
      setLoading(true);
      const updatedMembers: ListItem[] = await icrc75Reader.icrc75_get_list_members_admin(
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
      console.error('Error adding member:', err);
      setError('Failed to add member.');
    }
  };

  // Handle removing a member
  const handleRemoveMember = async (member: ListItem) => {
    setMemberToRemove(member);
    setOpenConfirm(true);
  };

  const confirmRemoveMember = async () => {
    if (!memberToRemove) return;

    try {
      await icrc75Reader.icrc75_manage_list_membership([
        {
          list: listName,
          memo: [], // Optional: provide if needed
          from_subaccount: [], // Optional: provide if needed
          created_at_time: [], // Optional: provide if needed
          action: {
            Remove: memberToRemove,
          },
        },
      ]);

      // Refresh members after removal
      setLoading(true);
      const updatedMembers: ListItem[] = await icrc75Reader.icrc75_get_list_members_admin(
        listName,
        [], // No specific filters
        []
      );
      setMembers(updatedMembers);
      setLoading(false);

      setOpenConfirm(false);
      setMemberToRemove(null);
    } catch (err) {
      console.error('Error removing member:', err);
      setError('Failed to remove member.');
      setOpenConfirm(false);
    }
  };

  const cancelRemoveMember = () => {
    setOpenConfirm(false);
    setMemberToRemove(null);
  };

  // Handle permission change for a member
  const handlePermissionChange = async (member: ListItem, newPermission: string) => {
    try {
      // Call the manage list properties API to change permissions
      let foundPermission : any =  { Admin : {
        Add: member,
      } };
      
      if( newPermission === "Admin"){
        foundPermission = { Admin : {
          Add: member,
        } };
      } else if(newPermission === "Write"){
        foundPermission = { Write : {
          Add: member,
        } };
      } else if(newPermission === "Read" ){
        foundPermission = { Read : {
          Add: member,
        } };
      } else if( newPermission === "Permissions" ){  
        foundPermission = { Permissions : {
          Add: member,
        } };
      };

      await icrc75Reader.icrc75_manage_list_properties([
        {
          list: listName,
          memo: [], // Optional: provide if needed
          from_subaccount: [], // Optional: provide if needed
          created_at_time: [], // Optional: provide if needed
          action: {
            ChangePermissions: foundPermission
          },
        },
      ]);

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
      console.error('Error changing member permissions:', err);
      setError('Failed to change member permissions.');
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
        //alert('List renamed successfully! Transaction ID: ' + result[0][0].Ok.toString());
        // Optionally, update the current component's state or notify the parent
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
                <TableCell><strong>Permission</strong></TableCell>
                <TableCell><strong>Actions</strong></TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {members && members.length > 0 ? (
                members.map((member, index) => {
                  let permission: string = "Read"; // Default permission
                  permissions?.forEach(([perm, listItem]) => {
                    if (listItem['Identity']?.toText() === member['Identity']?.toText()) {
                      if('Admin' in perm){
                        permission = "Admin";
                      } else if('Write' in perm){
                        permission = "Write";
                      }
                      else if('Read' in perm){
                        permission = "Read";
                      }
                      else if('Permissions' in perm){
                        permission = "Permissions";
                      };
                    }
                  });
                  return (
                    <TableRow key={index}>
                      <TableCell>
                        {member['Identity']
                          ? 'Identity'
                          : member['Account']
                          ? 'Account'
                          : member['List']
                          ? 'List'
                          : member['DataItem']
                          ? 'DataItem'
                          : 'Unknown'}
                      </TableCell>
                      <TableCell>
                        {('Identity' in member && member['Identity'])
                          ? member['Identity'].toText() 
                          : ('Account' in member && member['Account'])
                          ? `${member['Account'].owner.toText()}${member['Account'].subaccount && member['Account'].subaccount[0] ? `, Subaccount: ${Buffer.from(member['Account'].subaccount[0]).toString('hex')}` : ''}`
                          : ('List' in member && member['List'])
                          ? member['List']
                          : ('DataItem' in member && member['DataItem'])
                          ? JSON.stringify(member['DataItem'], dataItemStringify, 2)
                          : 'N/A'}
                      </TableCell>
                      <TableCell>
                        <FormControl variant="standard" fullWidth>
                          <InputLabel id={`permission-select-label-${index}`}>Permission</InputLabel>
                          <Select
                            labelId={`permission-select-label-${index}`}
                            value={permission}
                            onChange={(e) => handlePermissionChange(member, e.target.value as string)}
                          >
                            <MenuItem value="Admin">Admin</MenuItem>
                            <MenuItem value="Write">Write</MenuItem>
                            <MenuItem value="Read">Read</MenuItem>
                            <MenuItem value="Permissions">Permissions</MenuItem>
                          </Select>
                        </FormControl>
                      </TableCell>
                      <TableCell>
                        <IconButton
                          aria-label="delete"
                          color="secondary"
                          onClick={() => handleRemoveMember(member)}
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
                    No members found.
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
                ? `Identity: ${memberToRemove['Identity'].toText()}`
                : memberToRemove['Account']
                ? `Account Owner: ${memberToRemove['Account'].owner.toText()}${memberToRemove['Account'].subaccount && memberToRemove['Account'].subaccount.length > 0 ? `, Subaccount: ${Buffer.from(memberToRemove['Account'].subaccount).toString('hex')}` : ''}`
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

      {/* Confirmation Dialog for Deleting List */}
      <Dialog
        open={openDeleteConfirm}
        onClose={() => setOpenDeleteConfirm(false)}
        aria-labelledby="delete-dialog-title"
        aria-describedby="delete-dialog-description"
      >
        <DialogTitle id="delete-dialog-title">Confirm List Deletion</DialogTitle>
        <DialogContent>
          <DialogContentText id="delete-dialog-description">
            Are you sure you want to delete the list "{listName}"? This action cannot be undone.
          </DialogContentText>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setOpenDeleteConfirm(false)}>Cancel</Button>
          <Button onClick={handleDeleteList} color="error" variant="contained" autoFocus>
            Delete
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
};

export default EditableListView;
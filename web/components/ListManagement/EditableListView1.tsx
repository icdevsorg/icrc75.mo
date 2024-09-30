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
  FormGroup,
  FormControlLabel,
  Checkbox,
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
} from '../../../src/declarations/icrc75/icrc75.did.js';
import { validateMetadata, validateValueAsString, dataItemStringify } from '../../utils.js';

// Define an interface to associate members with their permissions
interface MemberWithPermissions {
  member: ListItem;
  permissions: Permission[];
}

interface EditableListViewProps {
  icrc75Reader: ICRC75Service;
  listName: string;
  metadata: DataItemMap | null;
  yourPrincipal: Principal; // Current user's principal
  onItemUpdated?: () => void;
}

const EditableListView: React.FC<EditableListViewProps> = ({
  icrc75Reader,
  listName,
  metadata,
  yourPrincipal,
  onItemUpdated
}) => {
  // State variables
  const [loading, setLoading] = useState<boolean>(true);
  const [error, setError] = useState<string>('');
  const [editMetadata, setEditMetadata] = useState<string>(JSON.stringify(metadata, dataItemStringify, 2));
  const [permissions, setPermissions] = useState<PermissionList | null>(null);
  const [members, setMembers] = useState<ListItem[] | null>(null);
  const [metadataMap, setMetadataMap] = useState<{ key: string; value: any }[]>([]);
  
  // State for managing members with their permissions
  const [membersWithPermissions, setMembersWithPermissions] = useState<MemberWithPermissions[] | null>(null);
  
  // States for Add Member Dialog
  const [openAddMember, setOpenAddMember] = useState<boolean>(false);
  const [newMemberPrincipal, setNewMemberPrincipal] = useState<string>('');
  const [newMemberPermission, setNewMemberPermission] = useState<string>('Read');
  const [addMemberError, setAddMemberError] = useState<string>('');
  const [newMemberType, setNewMemberType] = useState<'Identity' | 'Account' | 'List' | 'DataItem'>('Identity');
  
  // Additional states for specific member types
  const [newMemberSubaccount, setNewMemberSubaccount] = useState<string>('');
  const [newListName, setNewListName] = useState<string>('');
  const [newDataItemValue, setNewDataItemValue] = useState<string>('');

  // States for Confirmation Dialog when removing a member
  const [openConfirm, setOpenConfirm] = useState<boolean>(false);
  const [memberToRemove, setMemberToRemove] = useState<MemberWithPermissions | null>(null);

  // Helper function to determine if two ListItems are the same member
  const isSameMember = (listItem: ListItem, member: ListItem): boolean => {
    if ('Identity' in listItem && 'Identity' in member) {
      return listItem['Identity'].toText() === member['Identity'].toText();
    }
    if ('Account' in listItem && 'Account' in member) {
      const sub1 = listItem['Account'].subaccount.length > 0 && listItem['Account'].subaccount[0] ? Buffer.from(listItem['Account'].subaccount[0]).toString('hex') : '';
      const sub2 = member['Account'].subaccount.length > 0 && member['Account'].subaccount[0] ? Buffer.from(member['Account'].subaccount[0]).toString('hex') : '';
      return listItem['Account'].owner.toText() === member['Account'].owner.toText() &&
        sub1 === sub2;
    }
    if ('List' in listItem && 'List' in member) {
      return listItem['List'] === member['List'];
    }
    if ('DataItem' in listItem && 'DataItem' in member) {
      return JSON.stringify(listItem['DataItem']) === JSON.stringify(member['DataItem']);
    }
    return false;
  };

  // Fetch list details on component mount or when dependencies change
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
        console.log("metadata", metadata);
        const initialMetadata = metadata ? metadata : [];
       
        setEditMetadata(JSON.stringify(initialMetadata, dataItemStringify, 2));

        // Map permissions to members
        const membersWithPer: MemberWithPermissions[] = foundMembers.map((member) => {
          const perms = foundPermissions
            .filter(([perm, listItem]) => isSameMember(listItem, member))
            .map(([perm, _]) => perm);
          return { member, permissions: perms };
        });

        setMembersWithPermissions(membersWithPer);
      } catch (err) {
        console.error('Error fetching list details:', err);
        setError('Failed to fetch list details.');
      } finally {
        setLoading(false);
      }
    };

    fetchListDetails();
  }, [icrc75Reader, listName, metadata]);

  // Handle changes in metadata input
  const handleMetadataChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setEditMetadata(e.target.value);
  };

  // Save updated metadata
  const handleSaveMetadata = async () => {
    try {
      const parsedMetadata: DataItemMap = validateMetadata(editMetadata, true);

      // Prepare the ManageListPropertyRequest based on the parsed metadata
      let commandList: ManageListPropertyRequest = parsedMetadata.map(([key, value]) => {
        return {
          list: listName,
          memo: [], // Optional: provide if needed
          from_subaccount: [], // Optional: provide if needed
          created_at_time: [], // Optional: provide if needed
          action: {
            Metadata: {
              key: key,
              value: [value], // Ensure value is an array containing a single DataItem
            },
          },
        };
      });
     
      try {
        let result = await icrc75Reader.icrc75_manage_list_properties(commandList);
        if (
          result &&
          result[0] &&
          result[0][0] &&
          'Ok' in result[0][0] &&
          result[0][0].Ok
        ) {
          alert('List metadata updated successfully! Transaction ID: ' + result[0][0].Ok.toString());
        } else {
          alert('Error updating metadata: ' + JSON.stringify(result));
        };
      } catch (error) {
        console.error('Error updating metadata:', error);
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

      // Remap to membersWithPermissions
      const updatedMembersWithPer: MemberWithPermissions[] = updatedMembers.map((member) => {
        const perms = updatedPermissions
          .filter(([perm, listItem]) => isSameMember(listItem, member))
          .map(([perm, _]) => perm);
        return { member, permissions: perms };
      });

      setMembersWithPermissions(updatedMembersWithPer);
      setLoading(false);

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

      // Determine the type of member being added and construct the ListItem accordingly
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
          const subaccountBuffer = newMemberSubaccount ? Buffer.from(newMemberSubaccount, 'hex') : new Uint8Array();
          const subaccountBlob: [Subaccount] | [] = newMemberSubaccount
            ? [subaccountBuffer]
            : [];
          newListItem = {
            'Account': {
              owner: Principal.fromText(newMemberPrincipal),
              subaccount: subaccountBlob as [Subaccount], // Adjust type accordingly
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

      // Assign permissions to the new member
      // Split multiple permissions if separated by commas
      const selectedPermissions = newMemberPermission.split(',').map(p => p.trim()) as string[];
      const permissionActions : ManageListPropertyRequest = selectedPermissions.map(permission => {

        let foundPermission : any =  { Admin : {
          Add: newListItem,
        } };
        
        if( permission == "Admin"){
          foundPermission = { Admin : {
            Add: newListItem,
          } };
        } else if(permission == "Write"){
          foundPermission = { Write : {
            Add: newListItem,
          } };
        } else if(permission == "Read" ){
          foundPermission = { Read : {
            Add: newListItem,
          } };
        } else if( permission == "Permissions" ){  
          foundPermission = { Permissions : {
            Add: newListItem,
          } };
        };

        return {
          list: listName,
          memo: [], // Optional: provide if needed
          from_subaccount: [], // Optional: provide if needed
          created_at_time: [], // Optional: provide if needed
          action: {
            ChangePermissions: foundPermission,
          }
        }
      });

      // Execute all permission additions
      await  icrc75Reader.icrc75_manage_list_properties(permissionActions);

      // Refresh members after adding
      setLoading(true);
      const updatedMembers: ListItem[] = await icrc75Reader.icrc75_get_list_members_admin(
        listName,
        [], // No specific filters
        []
      );

      // Fetch updated permissions
      const updatedPermissions: PermissionList = await icrc75Reader.icrc75_get_list_permissions_admin(
        listName,
        [], // No specific filters
        [],
        []
      );

      // Map to membersWithPermissions
      const updatedMembersWithPer: MemberWithPermissions[] = updatedMembers.map((member) => {
        const perms = updatedPermissions
          .filter(([perm, listItem]) => isSameMember(listItem, member))
          .map(([perm, _]) => perm);
        return { member, permissions: perms };
      });

      setMembersWithPermissions(updatedMembersWithPer);
      setLoading(false);

      // Reset dialog fields
      setOpenAddMember(false);
      setNewMemberPrincipal('');
      setNewMemberSubaccount('');
      setNewListName('');
      setNewDataItemValue('');
      setNewMemberPermission('Read');
    } catch (err) {
      console.error('Error adding member:', err);
      setError('Failed to add member.');
    }
  };

  // Handle removing a member via confirmation dialog
  const confirmRemoveMember = async () => {
    if (!memberToRemove) return;

    try {
      // Remove the member from the list
      await icrc75Reader.icrc75_manage_list_membership([
        {
          list: listName,
          memo: [], // Optional: provide if needed
          from_subaccount: [], // Optional: provide if needed
          created_at_time: [], // Optional: provide if needed
          action: {
            Remove: memberToRemove.member,
          },
        },
      ]);

      // Remove all permissions associated with the member
      const permissionTypes: string[] = ['Admin', 'Write', 'Read', 'Permissions'];
      const permissionActions : ManageListPropertyRequest = permissionTypes.map(permission => {
        let foundPermission : any =  { Admin : {
          Remove: memberToRemove.member,
        } };
        
        if( permission == "Admin"){
          foundPermission = { Admin : {
            Remove: memberToRemove.member,
          } };
        } else if(permission == "Write"){
          foundPermission = { Write : {
            Remove: memberToRemove.member,
          } };
        } else if(permission == "Read" ){
          foundPermission = { Read : {
            Remove: memberToRemove.member,
          } };
        } else if( permission == "Permissions" ){  
          foundPermission = { Permissions : {
            Remove: memberToRemove.member,
          } };
        };

        return {
          list: listName,
          memo: [], // Optional: provide if needed
          from_subaccount: [], // Optional: provide if needed
          created_at_time: [], // Optional: provide if needed
          action: {
            ChangePermissions: foundPermission,
          }
        }
      });

      await Promise.all(
        permissionActions.map(action => icrc75Reader.icrc75_manage_list_properties(permissionActions))
      );

      // Refresh members after removal
      setLoading(true);
      const updatedMembers: ListItem[] = await icrc75Reader.icrc75_get_list_members_admin(
        listName,
        [], // No specific filters
        []
      );

      // Fetch updated permissions
      const updatedPermissions: PermissionList = await icrc75Reader.icrc75_get_list_permissions_admin(
        listName,
        [], // No specific filters
        [],
        []
      );

      // Map to membersWithPermissions
      const updatedMembersWithPer: MemberWithPermissions[] = updatedMembers.map((member) => {
        const perms = updatedPermissions
          .filter(([perm, listItem]) => isSameMember(listItem, member))
          .map(([perm, _]) => perm);
        return { member, permissions: perms };
      });

      setMembersWithPermissions(updatedMembersWithPer);
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

  // Handle permission change for a member (add/remove specific permission)
  const handlePermissionChange = async (member: ListItem, permission: string, isChecked: boolean) => {
    try {
      if (isChecked) {
        let foundPermission : any =  { Admin : {
          Add: member,
        } };
        
        if( permission == "Admin"){
          foundPermission = { Admin : {
            Add: member,
          } };
        } else if(permission == "Write"){
          foundPermission = { Write : {
            Add: member,
          } };
        } else if(permission == "Read" ){
          foundPermission = { Read : {
            Add: member,
          } };
        } else if( permission == "Permissions" ){  
          foundPermission = { Permissions : {
            Add: member,
          } };
        };
        // Add permission
        await icrc75Reader.icrc75_manage_list_properties([
          {
            list: listName,
            memo: [], // Optional: provide if needed
            from_subaccount: [], // Optional: provide if needed
            created_at_time: [], // Optional: provide if needed
            action: {
              ChangePermissions: foundPermission,
            },
          },
        ]);
      } else {
        // Remove permission
        let foundPermission : any =  { Admin : {
          Add: member,
        } };
        
        if( permission == "Admin"){
          foundPermission = { Admin : {
            Remove: member,
          } };
        } else if(permission == "Write"){
          foundPermission = { Write : {
            Remove: member,
          } };
        } else if(permission == "Read" ){
          foundPermission = { Read : {
            Remove: member,
          } };
        } else if( permission == "Permissions" ){  
          foundPermission = { Permissions : {
            Remove: member,
          } };
        };
        await icrc75Reader.icrc75_manage_list_properties([
          {
            list: listName,
            memo: [], // Optional: provide if needed
            from_subaccount: [], // Optional: provide if needed
            created_at_time: [], // Optional: provide if needed
            action: {
              ChangePermissions: foundPermission,
            },
          },
        ]);
      }
      
      // Refresh permissions
      const updatedPermissions: PermissionList = await icrc75Reader.icrc75_get_list_permissions_admin(
        listName,
        [], // No filters
        [],
        []
      );

      // Update membersWithPermissions
      const updatedMembersWithPer: MemberWithPermissions[] = membersWithPermissions?.map(mwp => {
        if (isSameMember(mwp.member, member)) {
          const updatedPerms = updatedPermissions
            .filter(([perm, listItem]) => isSameMember(listItem, mwp.member))
            .map(([perm, _]) => perm);
          return { ...mwp, permissions: updatedPerms };
        }
        return mwp;
      }) || [];

      setMembersWithPermissions(updatedMembersWithPer);
    } catch (err) {
      console.error('Error updating permission:', err);
      setError('Failed to update permission.');
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
                <TableCell><strong>Permissions</strong></TableCell>
                <TableCell><strong>Actions</strong></TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {membersWithPermissions && membersWithPermissions.length > 0 ? (
                membersWithPermissions.map((mwp, index) => (
                  <TableRow key={index}>
                    <TableCell>
                      {mwp.member['Identity']
                        ? 'Identity'
                        : mwp.member['Account']
                        ? 'Account'
                        : mwp.member['List']
                        ? 'List'
                        : mwp.member['DataItem']
                        ? 'DataItem'
                        : 'Unknown'}
                    </TableCell>
                    <TableCell>
                      {mwp.member['Identity']
                        ? mwp.member['Identity'].toText()
                        : mwp.member['Account']
                        ? `${mwp.member['Account'].owner.toText()}${mwp.member['Account'].subaccount ? '.' + Buffer.from(mwp.member['Account'].subaccount).toString('hex') : ''}`
                        : mwp.member['List']
                        ? mwp.member['List']
                        : mwp.member['DataItem'] ?
                        <TextField
                          value={(JSON.stringify(mwp.member['DataItem'], dataItemStringify, 2))}
                          slotProps={{
                            input: {
                              readOnly: true,
                            },
                          }}
                          multiline
                          minRows={4}
                        />
                        : 'N/A'}
                    </TableCell>
                    <TableCell>
                      <FormGroup row>
                        <FormControlLabel
                          control={
                            <Checkbox
                              checked={mwp.permissions.some(permission => "Admin" in permission)}
                              onChange={(e) => handlePermissionChange(mwp.member, 'Admin', e.target.checked)}
                            />
                          }
                          label="Admin"
                        />
                        <FormControlLabel
                          control={
                            <Checkbox
                              checked={mwp.permissions.some(permission => "Write" in permission)}
                              onChange={(e) => handlePermissionChange(mwp.member, 'Write', e.target.checked)}
                            />
                          }
                          label="Write"
                        />
                        <FormControlLabel
                          control={
                            <Checkbox
                              checked={mwp.permissions.some(permission => "Read" in permission)}
                              onChange={(e) => handlePermissionChange(mwp.member, 'Read', e.target.checked)}
                            />
                          }
                          label="Read"
                        />
                        <FormControlLabel
                          control={
                            <Checkbox
                              checked={mwp.permissions.some(permission => "Permissions" in permission)}
                              onChange={(e) => handlePermissionChange(mwp.member, 'Permissions', e.target.checked)}
                            />
                          }
                          label="Permissions"
                        />
                      </FormGroup>
                    </TableCell>
                    <TableCell>
                      <IconButton
                        aria-label="delete"
                        color="secondary"
                        onClick={() => { setMemberToRemove(mwp); setOpenConfirm(true); }}
                      >
                        <DeleteIcon />
                      </IconButton>
                    </TableCell>
                  </TableRow>
                ))
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
              ? memberToRemove.member['Identity']
                ? `Identity: ${memberToRemove.member['Identity']}`
                : memberToRemove.member['Account']
                ? `Account Owner: ${memberToRemove.member['Account'].owner.toText()}${memberToRemove.member['Account'].subaccount ? `, Subaccount: ${Buffer.from(memberToRemove.member['Account'].subaccount).toString('hex')}` : ''}`
                : memberToRemove.member['List']
                ? `List: ${memberToRemove.member['List']}`
                : memberToRemove.member['DataItem']
                ? `DataItem: ${
                    typeof memberToRemove.member['DataItem'] === 'string'
                      ? memberToRemove.member['DataItem']
                      : memberToRemove.member['DataItem'] instanceof Uint8Array
                      ? Buffer.from(memberToRemove.member['DataItem']).toString('hex')
                      : 'Complex DataItem'
                  }`
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
import React, { useEffect, useState } from 'react';
import {
  Typography,
  CircularProgress,
  Box,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Paper,
} from '@mui/material';
import { 
  _SERVICE as ICRC75Service, 
  PermissionList, 
  ListItem, 
  Value, 
  PermissionListItem,
  Permission,
  DataItemMap 
} from '../../../src/declarations/icrc75/icrc75.did.js';
import { dataItemStringify } from '../../utils';

// Define an interface to associate members with their permissions
interface MemberWithPermissions {
  member: ListItem;
  permissions: Permission[];
}

interface ReadOnlyListViewProps {
  icrc75Reader: ICRC75Service;
  listName: string;
  metadata: DataItemMap | null;
}

const ReadOnlyListView: React.FC<ReadOnlyListViewProps> = ({
  icrc75Reader,
  listName,
  metadata,
}) => {
  // State variables
  const [loading, setLoading] = useState<boolean>(true);
  const [error, setError] = useState<string>('');
  const [permissions, setPermissions] = useState<PermissionList | null>(null);
  const [members, setMembers] = useState<ListItem[] | null>(null);
  const [metadataMap, setMetadataMap] = useState<DataItemMap | null>([]);
  
  // State for members with their permissions
  const [membersWithPermissions, setMembersWithPermissions] = useState<MemberWithPermissions[] | null>(null);

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
        const initialMetadata : DataItemMap = metadata ? metadata : [];
       
        setMetadataMap(initialMetadata);

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
      <Typography variant="h6">List Details</Typography>
      {/* Metadata Display */}
      <Box sx={{ mt: 2 }}>
        <Typography variant="subtitle1">Metadata:</Typography>
        <pre>{metadata ? JSON.stringify(metadataMap, dataItemStringify, 2) : 'No Metadata'}</pre>
      </Box>

      {/* Members Display */}
      <Box sx={{ mt: 4 }}>
        <Typography variant="subtitle1">Members:</Typography>
        <TableContainer component={Paper} sx={{ mt: 2 }}>
          <Table aria-label="members table">
            <TableHead>
              <TableRow>
                <TableCell><strong>Type</strong></TableCell>
                <TableCell><strong>Identifier</strong></TableCell>
                <TableCell><strong>Permissions</strong></TableCell>
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
                        : mwp.member['DataItem']
                        ? JSON.stringify(mwp.member['DataItem'], dataItemStringify, 2)
                        : 'N/A'}
                    </TableCell>
                    <TableCell>
                      {mwp.permissions.length > 0 ? mwp.permissions.join(', ') : 'No Permissions'}
                    </TableCell>
                  </TableRow>
                ))
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
    </Box>
  );
};

export default ReadOnlyListView;
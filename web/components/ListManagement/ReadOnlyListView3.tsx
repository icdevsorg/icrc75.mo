import React, { useEffect, useState } from 'react';
import {
  Typography,
  CircularProgress,
  Box,
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableRow,
  Paper,
  TableContainer,
} from '@mui/material';
import { _SERVICE as ICRC75Service, PermissionList, ListItem, Value, DataItemMap } from '../../../src/declarations/icrc75/icrc75.did.js';
import { dataItemStringify } from '../../utils';

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
  const [loading, setLoading] = useState<boolean>(true);
  const [error, setError] = useState<string>('');
  const [permissions, setPermissions] = useState<PermissionList | null>(null);
  const [members, setMembers] = useState<[ListItem, [] | [DataItemMap]][] | null>(null);
  const [metadataMap, setMetadataMap] = useState<{ key: string; value: any }[]>([]);

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
        const initialMetadata = metadata ? metadata : { '#Map': [] };
        const map = initialMetadata['#Map'] as Array<{ key: string; value: any }>;
        setMetadataMap(map);
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
        <pre>{metadata ? JSON.stringify(metadataMap, null, 2) : 'No Metadata'}</pre>
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
                <TableCell><strong>Metadata</strong></TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {members && members.length > 0 ? (
                members.map((member, index) => {
                  const identifier =
                    'Identity' in member[0]
                      ? member[0]['Identity'].toString()
                      : 'Account' in member[0]
                      ? `${member[0]['Account'].owner.toString()}.${member[0]['Account'].subaccount[0] ? Buffer.from(member[0]['Account'].subaccount[0]).toString('hex') : ''}`
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
                    </TableRow>
                  );
                })
              ) : (
                <TableRow>
                  <TableCell colSpan={2} align="center">
                    No members found.
                  </TableCell>
                </TableRow>
              )}
            </TableBody>
          </Table>
        </TableContainer>
      </Box>

      {/* Permissions Display */}
      <Box sx={{ mt: 4 }}>
        <Typography variant="subtitle1">Permissions:</Typography>
        <TableContainer component={Paper} sx={{ mt: 2 }}>
          <Table aria-label="permissions table">
            <TableHead>
              <TableRow>
                <TableCell><strong>Type</strong></TableCell>
                <TableCell><strong>Identifier</strong></TableCell>
                <TableCell><strong>Permission</strong></TableCell>
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
                      ? `${listItem['Account'].owner.toString()}.${listItem['Account'].subaccount[0] ? Buffer.from(listItem['Account'].subaccount[0]).toString('hex') : ''}`
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
                    </TableRow>
                  );
                })
              ) : (
                <TableRow>
                  <TableCell colSpan={3} align="center">
                    No permissions found.
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
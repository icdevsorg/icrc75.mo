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
import { _SERVICE as ICRC75Service, PermissionList, ListItem, Value, Permission, DataItemMap } from '../../../src/declarations/icrc75/icrc75.did.js';

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
  const [members, setMembers] = useState<ListItem[] | null>(null);
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
        const foundMembers: ListItem[] = await icrc75Reader.icrc75_get_list_members_admin(
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
                <TableCell><strong>Principal</strong></TableCell>
                <TableCell><strong>Permission</strong></TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {members && members.length > 0 ? (
                members.map((member, index) => {
                  let permission: string = "Unknown"; // Default permission
                  permissions?.forEach(([perm, listItem]) => {
                    if (listItem['#Identity'] === member['#Identity']) {
                      if("Read" in perm){
                        permission = "Read";
                      } else if("Write" in perm){
                        permission = "Write";
                      } else if("Admin" in perm){
                        permission = "Admin";
                      } else if("Permissions" in perm){
                        permission = "Permissions";
                      };
                    };
                  });
                  return (
                    <TableRow key={index}>
                      <TableCell>{member['#Identity'] || member['#Account'] || 'N/A'}</TableCell>
                      <TableCell>{permission}</TableCell>
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
    </Box>
  );
};

export default ReadOnlyListView;
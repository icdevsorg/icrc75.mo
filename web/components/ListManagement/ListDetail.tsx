import React, { useEffect, useState } from 'react';
import {Principal} from '@dfinity/principal';
import {
  Typography,
  CircularProgress,
  Box,
} from '@mui/material';
import { _SERVICE as ICRC75Service, ListRecord, PermissionListItem, Value, DataItemMap, ListItem } from '../../../src/declarations/icrc75/icrc75.did.js';
import EditableListView from './EditableListView3'; // Create this component
import ReadOnlyListView from './ReadOnlyListView3'; // Ensure the correct path to the component

interface ListDetailProps {
  icrc75Reader: ICRC75Service;
  listName: string;
  metadata: DataItemMap | null;
  yourPrincipal: Principal;
  onMetadataChange?: (listName: string, metadata: DataItemMap) => void;
}

const ListDetail: React.FC<ListDetailProps> = ({
  icrc75Reader,
  listName,
  metadata,
  yourPrincipal,
  onMetadataChange
}) => {
  const [loading, setLoading] = useState<boolean>(true);
  const [error, setError] = useState<string>('');
  const [permissions, setPermissions] = useState<PermissionListItem[]>([]);
  const [isAdminOrWrite, setIsAdminOrWrite] = useState<boolean>(false);

  useEffect(() => {
    const fetchPermissions = async () => {
      setLoading(true);
      try {
        // Fetch permissions for the current user on the selected list
        // Assuming a method icrc75_get_list_permissions_admin exists

        const permissionList: PermissionListItem[] = await icrc75Reader.icrc75_get_list_permissions_admin(
          listName,
          [], // You can filter specific permissions if needed
          [], 
          []
        );

        setPermissions(permissionList);

        // Determine if the current user has Admin or Write permissions
        const userPermissions = permissionList.filter(
          ([permission, listItem]) => {
            if (listItem['Identity']) {
              return listItem['Identity'].toString() === yourPrincipal.toString();
            }
            return false;
          }
        ).map(([permission, _]) => permission);

        const hasAdmin = userPermissions.some(permission => "Admin" in permission);
        const hasWrite = userPermissions.some(permission => "Write" in permission);

        setIsAdminOrWrite(hasAdmin || hasWrite);



      } catch (err) {
        console.error("Error fetching permissions:", err);
        setError('Failed to fetch permissions.');
      } finally {
        setLoading(false);
      }
    };

    fetchPermissions();
  }, [icrc75Reader, listName, yourPrincipal]);

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

  const updateMetadata = (metadata: DataItemMap) => {
    if (onMetadataChange) {
      onMetadataChange(listName, metadata);
    }
  };

  return (
    <Box>
      {isAdminOrWrite ? (
        <EditableListView icrc75Reader={icrc75Reader} yourPrincipal={yourPrincipal} listName={listName} metadata={metadata} onUpdateMetadata={updateMetadata} />
      ) : (
        <ReadOnlyListView icrc75Reader={icrc75Reader} listName={listName} metadata={metadata} />
      )}
    </Box>
  );
};

export default ListDetail;
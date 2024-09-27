import React, { useEffect, useState } from 'react';
import {Principal} from '@dfinity/principal';
import {
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Paper,
  CircularProgress,
  Pagination,
  Box,
  Typography,
  TextField, 
  Button,
  IconButton,
  Collapse,


} from '@mui/material';
import {
  KeyboardArrowDown as KeyboardArrowDownIcon,
  KeyboardArrowUp as KeyboardArrowUpIcon,
} from '@mui/icons-material';
import { _SERVICE as ICRC75Service, ListRecord, DataItemMap } from '../../src/declarations/icrc75/icrc75.did.js'; 
import useGlobalList from './hooks/useGlobalList';
import ListDetail from './ListManagement/ListDetail';
import * as utils from '../utils'; // Add this line to import utils


interface ListViewerProps {
  icrc75Reader: ICRC75Service;
  yourPrincipal: Principal; // Pass the current user's principal
  title?: string;
  reloadFlag : boolean; // Toggle the state to trigger a re-fetch in ListViewer
  onListChange: () => void;
}

const ListViewer: React.FC<ListViewerProps> = ({
  icrc75Reader,
  yourPrincipal,
  title = 'Lists', 
  reloadFlag = false,
  onListChange
}) => {
  
  
  

  // Pagination state
  const [itemsPerPage, setItemsPerPage] = useState<number>(10);
  const [filter, setFilter] = useState<string>(''); // Filter text
  const [currentPage, setCurrentPage] = useState<number>(1);
  const [totalPages, setTotalPages] = useState<number>(1);
  const [prevTokens, setPrevTokens] = useState<string[]>([]);
  const [currentPrev, setCurrentPrev] = useState<string | undefined>(undefined);
  const { data, loading, error,} = useGlobalList(icrc75Reader, filter, itemsPerPage, currentPage, reloadFlag);
  const [openRows, setOpenRows] = useState<{ [key: string]: boolean }>({});


  const handlePageChange = (event: React.ChangeEvent<unknown>, value: number) => {
    setCurrentPage(value);
  };

  const handleSearchChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    setFilter(event.target.value);
  };

  const updateMetadata = (listName: string, metadata: DataItemMap) => {
    // Update the metadata for the list
    onListChange();
  };

  const handleSearch = () => {
    setCurrentPage(1);
    setPrevTokens([]);
  };

  const handleToggleRow = (listName: string) => {
    setOpenRows((prev) => ({
      ...prev,
      [listName]: !prev[listName],
    }));
  };

  return (
    <Box sx={{ mt: 4 }}>
      <Typography variant="h5" gutterBottom>
        {title  || 'Lists'}
      </Typography>
      <Box sx={{ display: 'flex', mb: 2 }}>
        <TextField
          label="Search Lists"
          variant="outlined"
          value={filter}
          onChange={handleSearchChange}
          size="small"
          fullWidth
        />
        <Button variant="contained" color="primary" onClick={handleSearch} sx={{ ml: 2 }}>
          Search
        </Button>
      </Box>
      {loading ? (
        <Box sx={{ display: 'flex', justifyContent: 'center', mt: 4 }}>
          <CircularProgress />
        </Box>
      ) : error ? (
        <Typography color="error">{error}</Typography>
      ) : (
        <>
          <TableContainer component={Paper}>
            <Table aria-label="lists table">
              <TableHead>
                <TableRow>
                  <TableCell><strong>Expand</strong></TableCell>
                  <TableCell><strong>List Name</strong></TableCell>
                  <TableCell><strong>Metadata</strong></TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
               
                  {data && data.length > 0 ? (
                    data.map((list) => (
                      <React.Fragment key={list.list}>
                      <TableRow>
                        <TableCell>
                          <IconButton
                            aria-label="expand row"
                            size="small"
                            onClick={() => handleToggleRow(list.list)}
                          >
                            {openRows[list.list] ? <KeyboardArrowUpIcon /> : <KeyboardArrowDownIcon />}
                          </IconButton>
                        </TableCell>
                        <TableCell component="th" scope="row">
                          {list.list}
                        </TableCell>
                        <TableCell>
                          {list.metadata ? (
                          <TextField
                            value={JSON.stringify(list.metadata[0], utils.dataItemStringify, 2)}
                            multiline
                            rows={4}
                            variant="outlined"
                            slotProps={{
                              input: {
                                readOnly: true,
                                style: { overflow: 'auto' },
                              },
                            }}
                            fullWidth
                          />
                          ) : (
                          'No Metadata'
                          )}
                        </TableCell>
                      </TableRow>
                      <TableRow>
                        <TableCell style={{ paddingBottom: 0, paddingTop: 0 }} colSpan={3}>
                          <Collapse in={openRows[list.list]} timeout="auto" unmountOnExit>
                            <Box margin={1}>
                              <ListDetail 
                                icrc75Reader={icrc75Reader}
                                listName={list.list}
                                yourPrincipal={yourPrincipal}
                                onMetadataChange={updateMetadata}
                                metadata={list.metadata && list.metadata[0] ? list.metadata[0] : null}
                              />
                            </Box>
                          </Collapse>
                        </TableCell>
                      </TableRow>
                    </React.Fragment>
                    ))
                  )
                  : (
                    <TableRow>
                      <TableCell colSpan={2} align="center">
                        No lists found.
                      </TableCell>
                    </TableRow>
                  )}
              
              </TableBody>
            </Table>
          </TableContainer>
          <Box sx={{ display: 'flex', justifyContent: 'center', mt: 2 }}>
            <Pagination
              count={totalPages}
              page={currentPage}
              onChange={handlePageChange}
              color="primary"
              showFirstButton
              showLastButton
            />
          </Box>
        </>
      )}
    </Box>
  );
};

export default ListViewer;
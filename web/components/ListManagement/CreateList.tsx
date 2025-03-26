import React, { useState } from 'react';
import { validateMetadata } from '../../utils';
import { _SERVICE as ICRC75Service } from '../../../src/declarations/icrc75/icrc75.did';
import { TextField, Accordion, AccordionSummary, AccordionDetails, Typography, Button } from '@mui/material';
import ExpandMoreIcon from '@mui/icons-material/ExpandMore';

interface Props {
  actor: ICRC75Service;
  onListCreated?: () => void;
}

const CreateList: React.FC<Props> = ({ actor, onListCreated }) => {
  const [listName, setListName] = useState('');
  const [metadata, setMetadata] = useState('');
  const [loading, setLoading] = useState(false);

  const handleCreate = async () => {
    setLoading(true);
    let testMetadata = metadata;
    if (metadata === '') {
      testMetadata = '[]';
    }
    try {
      const metadataMap = validateMetadata(testMetadata, true);
      try {
        let result = await actor.icrc75_manage_list_properties([
          {
            list: listName,
            memo: [],
            from_subaccount: [],
            created_at_time: [],
            action: { Create: { admin: [], metadata: metadataMap, members: [] } },
          },
        ]);

        if (result && result[0] && result[0][0] && 'Ok' in result[0][0] && result[0][0].Ok) {
          //alert('List created successfully!' + result[0][0].Ok.toString());
        } else {
          alert('Error creating list: ' + JSON.stringify(result));
        }
      } catch (error) {
        console.error('Error creating list:', error);
      }
      // Reset form fields and notify parent
      setListName('');
      setMetadata('');

      if (onListCreated) {
        onListCreated();
      }
    } catch (error) {
      console.error('Error creating list:', error);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div>
      <Accordion>
        <AccordionSummary expandIcon={<ExpandMoreIcon />}>
          <Typography>Create a New List</Typography>
        </AccordionSummary>
        <AccordionDetails>
          <div>
            <TextField
              fullWidth
              label="List Name"
              value={listName}
              onChange={(e) => setListName(e.target.value)}
              variant="outlined"
              margin="normal"
            />

            <TextField
              multiline
              fullWidth
              minRows={4}
              value={metadata}
              onChange={(e) => setMetadata(e.target.value)}
              variant="outlined"
              placeholder="Edit metadata as JSON"
              margin="normal"
            />

            <Button
              variant="contained"
              color="primary"
              onClick={handleCreate}
              disabled={loading}
              style={{ marginTop: '16px' }}
            >
              {loading ? 'Creating...' : 'Create List'}
            </Button>
          </div>
        </AccordionDetails>
      </Accordion>
    </div>
  );
};

export default CreateList;

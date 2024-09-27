import React, { useState } from 'react';
import { _SERVICE as ICRC75Service } from '../../../src/declarations/icrc75/icrc75.did';

interface Props {
  actor: ICRC75Service;
}

const RenameList: React.FC<Props> = ({ actor }) => {
  const [oldName, setOldName] = useState('');
  const [newName, setNewName] = useState('');
  const [loading, setLoading] = useState(false);

  const handleRename = async () => {
    setLoading(true);
    try {
      await actor.icrc75_manage_list_properties([
        {
          list: oldName,
          memo: [],
          from_subaccount: [],
          created_at_time: [],
          action: { Rename: newName },
        },
      ]);
      // Handle success
    } catch (error) {
      console.error('Error renaming list:', error);
      // Handle error
    } finally {
      setLoading(false);
    }
  };

  return (
    <div>
      <h3>Rename List</h3>
      <input
        type="text"
        value={oldName}
        onChange={(e) => setOldName(e.target.value)}
        placeholder="Current List Name"
      />
      <input
        type="text"
        value={newName}
        onChange={(e) => setNewName(e.target.value)}
        placeholder="New List Name"
      />
      <button onClick={handleRename} disabled={loading}>
        {loading ? 'Renaming...' : 'Rename List'}
      </button>
    </div>
  );
};

export default RenameList;
import { useState, useEffect } from 'react';
import { _SERVICE as ICRC75Service, ListRecord } from '../../../src/declarations/icrc75/icrc75.did.js'; // Adjust the import path as needed

const useGlobalList = (icrc75Reader : ICRC75Service, filter: string, itemsPerPage : null | number, currentPage : number, reloadFlag: boolean) => {
  const [data, setData] = useState<ListRecord[] | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const [totalPages, setTotalPages] = useState<number>(1);
  const [prevTokens, setPrevTokens] = useState<string[]>([]);
  const [currentPrev, setCurrentPrev] = useState<string | undefined>(undefined);

  useEffect(() => {

    const fetchLists = async () => {
      setLoading(true);
      setError(null);
  
      try {
        // Determine the 'prev' token based on the current page
        let prev: string | undefined = undefined;
        if (currentPage > 1) {
          prev = prevTokens[currentPage - 2];
        }
  
        // Fetch lists from the canister
        const response: ListRecord[] = await icrc75Reader.icrc75_get_lists(
          filter && filter.length > 0 ? [filter] : [],
          true, // bMetadata: fetch metadata
          prev && prev.length > 0 ? [prev] : [],
          itemsPerPage ? [BigInt(itemsPerPage)] : [],
        );
  
        setData(response);
  
        // Update prevTokens for pagination
        if (response.length === itemsPerPage) {
          const lastList = response[response.length - 1].list;
          setPrevTokens((prevArr) => {
            const newArr = [...prevArr];
            if (currentPage === prevArr.length + 1) {
              newArr.push(lastList);
            }
            return newArr;
          });
          setTotalPages(currentPage + 1); // Tentatively set total pages; adjust as needed
        } else {
          setTotalPages(currentPage);
        }
      } catch (err: any) {
        console.error('Error fetching lists:', err);
        setError('Failed to fetch lists. Please try again later.');
      } finally {
        setLoading(false);
      }
    };


    fetchLists();
  }, [icrc75Reader, filter, itemsPerPage, currentPage, reloadFlag]);

  return { data, loading, error };
};

export default useGlobalList;
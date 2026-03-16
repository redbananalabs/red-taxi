import {
    Popover, MenuItem, Select, FormControl, InputLabel,
    TextField, Box, Button, IconButton
  } from '@mui/material';
  import CloseIcon from '@mui/icons-material/Close';
  import AddIcon from '@mui/icons-material/Add';
  import RemoveIcon from '@mui/icons-material/Remove';
  import { useEffect } from 'react';
 
  const operators = ['contains', 'equals', 'starts with', 'ends with'];
  
  export default function TableFilterPopover({
    anchorEl,
    onClose,
    column,
    columns,
    filters,
    setFilters,
  }) {
    const open = Boolean(anchorEl);
    // useEffect(() => {
    //     if (open && filters.length === 0) {
    //       setFilters([
    //         {
    //           column: column?.value || '',
    //           operator: 'contains',
    //           value: '',
    //         },
    //       ]);
    //     }
    //   }, [open, filters.length]);

    useEffect(() => {
  if (open && filters.length === 0 && column?.value) {
    setFilters([
      {
        column: column.value,
        operator: 'contains',
        value: '',
      },
    ]);
  }
}, [open, filters.length, column?.value]);
  
    // const handleChange = (index, field, value) => {
    //   const updatedFilters = [...filters];
    //   updatedFilters[index][field] = value;
    //   setFilters(updatedFilters);
    // };
  
    // const handleAddFilter = () => {
    //   setFilters((prev) => [
    //     ...prev,
    //     {
    //       column: column?.value || '',
    //       operator: 'contains',
    //       value: '',
    //     },
    //   ]);
    // };
  
    // const handleRemoveFilter = (index) => {
    //   const updated = filters.filter((_, i) => i !== index);
    //   setFilters(updated);
    // };
  
    // const handleClear = () => {
    //   setFilters([]);
    // };

    const handleChange = (index, field, value) => {
  const updated = [...filters];
  updated[index][field] = value;
  setFilters(updated);
};

  const handleAddFilter = () => {
  setFilters(prev => [
    ...prev,
    {
      column: column?.value || '',
      operator: 'contains',
      value: '',
    },
  ]);
};

const handleRemoveFilter = (index) => {
  const updated = filters.filter((_, i) => i !== index);
  setFilters(updated);
};

const handleClear = () => {
  setFilters([]);
};
  
    return (
      <Popover
        open={open}
        anchorEl={anchorEl}
        onClose={onClose}
        anchorOrigin={{ vertical: 'bottom', horizontal: 'center' }}
        transformOrigin={{ vertical: 'top', horizontal: 'center' }}
      >
        <Box className="p-6 min-w-[26rem] light:bg-light dark:bg-coal-500 dark:text-gray-700 text-[#14151A]">
          {filters.map((filter, index) => (
            <Box key={index} className="flex gap-2 items-center mb-1">
              <IconButton size="small" onClick={() => handleRemoveFilter(index)}>
                <CloseIcon fontSize="small" className='text-[#14151A] dark:text-gray-700' />
              </IconButton>
 
              <FormControl fullWidth>
                <InputLabel className='form-label text-[#14151A] dark:text-gray-700'>Column</InputLabel>
                <Select
                  value={filter.column}
                  label="Column"
                  onChange={(e) => handleChange(index, 'column', e.target.value)}
                  className='text-[#14151A] dark:text-gray-700'
                 sx={{
      '@media (prefers-color-scheme: dark)': {
        color: '#9A9CAE',
        '& .MuiSelect-icon': {
        color: '#363843',
      },
        '& .MuiOutlinedInput-notchedOutline': {
          borderColor: '#363843',
        },
        
      },
    }}
                >
                  {columns.map((col) => (
                    <MenuItem key={col.value} value={col.value}>
                      {col.label}
                    </MenuItem>
                  ))}
                </Select>
              </FormControl>
  
              <FormControl fullWidth>
                <InputLabel className='form-label text-[#14151A] dark:text-gray-700'>Operator</InputLabel>
                <Select
                  value={filter.operator}
                  label="Operator"
                  onChange={(e) => handleChange(index, 'operator', e.target.value)}
                  className='text-[#14151A] dark:text-gray-700'
                  sx={{
      '@media (prefers-color-scheme: dark)': {
        color: '#9A9CAE',
        '& .MuiSelect-icon': {
        color: '#363843',
      },
        '& .MuiOutlinedInput-notchedOutline': {
          borderColor: '#363843',
        },
        
      },
    }}
                  
                >
                  {operators.map((op) => (
                    <MenuItem key={op} value={op} 
                    >{op}</MenuItem>
                  ))}
                </Select>
              </FormControl>
  
              <TextField
                fullWidth
                label="Filter value"
                value={filter.value}
                onChange={(e) => handleChange(index, 'value', e.target.value)}
                className='text-[#14151A] dark:text-gray-700 dark:focus:border-[#1B1C22]'
                sx={{
    // Dark mode override
    '@media (prefers-color-scheme: dark)': {
      '& .MuiInputBase-input': {
        color: '#9A9CAE',
      },
      '& .MuiInputLabel-root': {
        color: '#9A9CAE',
      },
      '& .MuiOutlinedInput-root': {
        '& fieldset': {
          borderColor: '#363843',
        },
        
      },
    }
  }}
              />
            </Box>
          ))}
  
          <Box className="flex justify-start gap-3 mt-2">
            <Button
              startIcon={<AddIcon />}
              onClick={handleAddFilter}
              className='text-[#7E57C2] font-medium'
            >
              ADD FILTER
            </Button>
            <Button
              startIcon={<RemoveIcon />}
              onClick={handleClear}
              className='text-[#7E57C2] font-medium'

            >
              CLEAR
            </Button>
          </Box>
        </Box>
      </Popover>
    );
  }
  
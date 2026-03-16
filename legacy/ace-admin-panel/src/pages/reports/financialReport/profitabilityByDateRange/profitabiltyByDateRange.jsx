/** @format */

import { Fragment, useEffect, useMemo, useState } from 'react';
import {
    Toolbar,
    ToolbarDescription,
    ToolbarHeading,
    ToolbarPageTitle,
} from '@/partials/toolbar';
import { KeenIcon } from '@/components';
import {
    Popover,
    PopoverContent,
    PopoverTrigger,
} from '@/components/ui/popover';
import { Calendar } from '@/components/ui/calendar';
import { addDays, format } from 'date-fns';
import { cn } from '@/lib/utils';
import {
    DataGrid,
    DataGridColumnHeader,
    
} from '@/components';
import { Input } from '@/components/ui/input';
import { useDispatch, useSelector } from 'react-redux';
import {
    refreshProfitabilityByDateRange,
    setProfitabilityByDateRange,
} from '../../../../slices/reportSlice';
import { Stats } from './StatsBlocks';

function ProfitabilityByDateRange() {
    const dispatch = useDispatch();
    const { profitabilityByDateRange } = useSelector((state) => state.reports);
    const [openDate, setOpenDate] = useState(false);
    const [date, setDate] = useState({
        from: new Date(),
        to: addDays(new Date(), 20),
    });
    const [tempRange, setTempRange] = useState(date);

    console.log(profitabilityByDateRange);
    useEffect(() => {
        if (openDate) {
            setTempRange({ from: null, to: null });
        }
    }, [openDate]);

    const handleDateSelect = (range) => {
        setTempRange(range);
        if (range?.from && range?.to) {
            setDate(range);
            setOpenDate(false);
        }
    };

    useEffect(() => {
        // Agar status, scope ya date change hota hai to API call karega
        dispatch(
            refreshProfitabilityByDateRange(
                format(new Date(date.from), "yyyy-MM-dd'T'00:00:00'Z'"),
                format(new Date(date.to), "yyyy-MM-dd'T'00:00:00'Z'")
            )
        );
    }, [date, dispatch]);

    const ColumnInputFilter = ({ column }) => {
        return (
            <Input
                placeholder='Filter...'
                value={column.getFilterValue() ?? ''}
                onChange={(event) => column.setFilterValue(event.target.value)}
                className='h-9 w-full max-w-40'
            />
        );
    };

    const columns = useMemo(() => {
        let baseColumns = [
            {
                accessorKey: 'accountPayouts',
                header: ({ column }) => (
                    <DataGridColumnHeader
                        title=<span className='font-bold'>Acc Payouts</span>
                        filter={<ColumnInputFilter column={column} />}
                        column={column}
                    />
                ),
                enableSorting: true,
                cell: ({ row }) => (
                    <span className={`font-medium ${row.original.color}`}>
                        {row.original.accountPayouts
                            ? `£${row.original.accountPayouts?.toFixed(2)}`
                            : '-'}
                    </span>
                ),
                meta: { headerClassName: 'min-w-[120px]' },
            },
            {
                accessorKey: 'totalAccountProfitNet',
                header: ({ column }) => (
                    <DataGridColumnHeader
                        title=<span className='font-bold'>Acc Profit (NET)</span>
                        filter={<ColumnInputFilter column={column} />}
                        column={column}
                    />
                ),
                enableSorting: true,
                cell: ({ row }) => (
                    <span className={`font-medium ${row.original.color}`}>
                        {row.original.totalAccountProfitNet ? `£${row.original.totalAccountProfitNet?.toFixed(2)}` : '-'}
                    </span>
                ),
                meta: { headerClassName: 'min-w-[120px]' },
            },
            {
                accessorKey: 'accountProfitMargin',
                header: ({ column }) => (
                    <DataGridColumnHeader
                        title=<span className='font-bold'>Acc Profit Margin %</span>
                        filter={<ColumnInputFilter column={column} />}
                        column={column}
                    />
                ),
                enableSorting: true,
                cell: ({ row }) => (
                    <span className={`font-medium ${row.original.color}`}>
                        {row.original.accountProfitMargin ? `${row.original.accountProfitMargin?.toFixed(2)}%` : '-'}
                    </span>
                ),
                meta: { headerClassName: 'min-w-[120px]' },
            },
            {
                accessorKey: 'totalCommsProfitGross',
                header: ({ column }) => (
                    <DataGridColumnHeader
                        title=<span className='font-bold'>Comms Profit (Gross)</span>
                        filter={<ColumnInputFilter column={column} />}
                        column={column}
                    />
                ),
                enableSorting: true,
                cell: ({ row }) => (
                    <span className={`font-medium ${row.original.color}`}>
                        {row.original?.totalCommsProfitGross ? `£${row.original?.totalCommsProfitGross?.toFixed(2)}` : "-"}
                    </span>
                ),
                meta: { headerClassName: 'min-w-[120px]' },
            },
            {
                accessorKey: 'totalCommsProfitNet',
                header: ({ column }) => (
                    <DataGridColumnHeader
                        title=<span className='font-bold'>Comms Profit (NET)</span>
                        filter={<ColumnInputFilter column={column} />}
                        column={column}
                    />
                ),
                enableSorting: true,
                cell: ({ row }) => (
                    <span className={`font-medium ${row.original.color}`}>
                        {row.original?.totalCommsProfitNet ? `£${row.original?.totalCommsProfitNet?.toFixed(2)}` : "-"}
                    </span>
                ),
                meta: { headerClassName: 'min-w-[120px]' },
            },
            {
                accessorKey: 'grossProfit',
                header: ({ column }) => (
                    <DataGridColumnHeader
                        title=<span className='font-bold'>Gross Profit</span>
                        filter={<ColumnInputFilter column={column} />}
                        column={column}
                    />
                ),
                enableSorting: true,
                cell: ({ row }) => (
                    <span className={`font-medium ${row.original.color}`}>
                        {row.original?.grossProfit ? `£${row.original?.grossProfit?.toFixed(2)}` : "-" }
                    </span>
                ),
                meta: { headerClassName: 'min-w-[120px]' },
            },
            {
                accessorKey: 'netProfit',
                header: ({ column }) => (
                    <DataGridColumnHeader
                        title=<span className='font-bold'>Net Profit</span>
                        filter={<ColumnInputFilter column={column} />}
                        column={column}
                    />
                ),
                enableSorting: true,
                cell: ({ row }) => (
                    <span className={`font-medium ${row.original.color}`}>
                        {row.original.netProfit ? `£${row.original.netProfit?.toFixed(2)}` : "-"}
                    </span>
                ),
                meta: { headerClassName: 'min-w-[200px]' },
            },
        ];

        return baseColumns;
    }, []);

    const handleRowSelection = (state) => {
        const selectedRowIds = Object.keys(state);
        if (selectedRowIds.length > 0) {
            alert(`Selected Drivers: ${selectedRowIds.join(', ')}`);
        }
    };

    useEffect(() => {
        return () => {
            dispatch(setProfitabilityByDateRange([])); // Clear table data
        };
    }, [dispatch]);
    return (
        <Fragment>
            <div className='pe-[1.875rem] ps-[1.875rem] ms-auto me-auto max-w-[1850px] w-full'>
                <Toolbar>
                    <ToolbarHeading>
                        <ToolbarPageTitle />
                        <ToolbarDescription>
                            Showing {profitabilityByDateRange?.length} Report(s){' '}
                        </ToolbarDescription>
                    </ToolbarHeading>
                </Toolbar>
            </div>
            <div className='pe-[1.875rem] ps-[1.875rem] ms-auto me-auto max-w-[1850px] w-full'>
                <div className='flex flex-col items-stretch gap-5 lg:gap-7.5'>
                    <div className='flex flex-wrap items-center gap-5 justify-between'>
                        <div className="flex flex-wrap justify-start items-center gap-4">
                            <Stats />
                        </div>
                        <div className='card card-grid min-w-full'>
                       
                            <div className='card-header flex-wrap gap-2'>
                                <div className='flex flex-wrap gap-2 lg:gap-5'>
                                    <div className='flex flex-wrap items-center gap-2.5'>
                                        <div className='flex flex-col'>
                                            <label className='form-label'>Date Range</label>
                                            <Popover
                                                open={openDate}
                                                onOpenChange={setOpenDate}
                                            >
                                                <PopoverTrigger asChild>
                                                    <button
                                                        id='date'
                                                        className={cn(
                                                            'btn btn-sm btn-light data-[state=open]:bg-light-active',
                                                            !date && 'text-gray-400'
                                                        )}
                                                        style={{ height: '40px' }}
                                                    >
                                                        <KeenIcon
                                                            icon='calendar'
                                                            className='me-0.5'
                                                        />
                                                        {date?.from ? (
                                                            date.to ? (
                                                                <>
                                                                    {format(date.from, 'LLL dd, y')} -{' '}
                                                                    {format(date.to, 'LLL dd, y')}
                                                                </>
                                                            ) : (
                                                                format(date.from, 'LLL dd, y')
                                                            )
                                                        ) : (
                                                            <span>Pick a date range</span>
                                                        )}
                                                    </button>
                                                </PopoverTrigger>
                                                <PopoverContent
                                                    className='w-auto p-0'
                                                    align='end'
                                                >
                                                    <Calendar
                                                        initialFocus
                                                        mode='range'
                                                        defaultMonth={date?.from}
                                                        selected={tempRange}
                                                        onSelect={handleDateSelect}
                                                        numberOfMonths={2}
                                                    />
                                                </PopoverContent>
                                            </Popover>
                                        </div>

                                       
                                    </div>
                                </div>
                            </div>
                            <div className='card-body'>
                                {profitabilityByDateRange.length ? (
                                    <>
                                        <DataGrid
                                            columns={columns}
                                            data={profitabilityByDateRange}
                                            rowSelection={true}
                                            onRowSelectionChange={handleRowSelection}
                                            pagination={{ size: 10 }}
                                            sorting={[{ id: 'date', desc: true }]}
                                            layout={{ card: true }}
                                        />
                                        
                                    </>
                                ) : (
                                    <div className='text-center py-10 text-gray-500'>
                                        No data found
                                    </div>
                                )}
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </Fragment>
    );
}

export { ProfitabilityByDateRange };

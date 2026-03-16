/** @format */

import { Fragment } from 'react';
import { toAbsoluteUrl } from '@/utils/Assets';
import { useSelector } from 'react-redux';
// import { KeenIcon } from '../../../../components';
const Stats = () => {
    const { profitabilityByDateRange } = useSelector((state) => state.reports);

    const items = [
        {
            icon: 'car',
            info: profitabilityByDateRange[0]?.accountSales || 0,
            desc: 'Account Sales',
            color: 'bg-danger',
        },
        {
            icon: 'briefcase',
            info: profitabilityByDateRange[0]?.cashProfitsGross || 0,
            desc: 'Cash Comms Gross',
            color: 'bg-primary',
        },
        {
            icon: 'underlining',
            info: profitabilityByDateRange[0]?.cashProfitsNet || 0,
            desc: 'Cash Comms Net',
            color: 'bg-purple-400',
        },
        {
            icon: 'users',
            info: profitabilityByDateRange[0]?.rankProfitsGross || 0,
            desc: 'Rank Comms Gross',
            color: 'bg-cyan-400',
        },
        {
            icon: 'map',
            info: profitabilityByDateRange[0]?.rankProfitsNet || 0,
            desc: 'Rank Comms Net',
            color: 'bg-success',
        },
        {
            icon: 'user',
            info:
                profitabilityByDateRange[0]?.totalCosts || 0,
            desc: 'Total Costs',
            color: 'bg-teal-400',
        },
        // {
        //     icon: 'user-tick',
        //     info:
        //         profitabilityByDateRange?.customerAquireCounts?.find((entry) => entry.periodWhen === 1) // ✅ Find the correct object
        //             ?.new || 0,
        //     desc: 'Week New Customer',
        //     color: 'bg-sky-400',
        // },
        // {
        //     icon: 'user-square',
        //     info:
        //         profitabilityByDateRange?.customerAquireCounts?.find((entry) => entry.periodWhen === 2) // ✅ Find the correct object
        //             ?.new || 0,
        //     desc: 'Month New Customer',
        //     color: 'bg-teal-400',
        // },
        // {
        //     icon: 'users',
        //     info:
        //         profitabilityByDateRange?.customerAquireCounts?.find((entry) => entry.periodWhen === 0) // ✅ Find the correct object
        //             ?.returning || 0,
        //     desc: 'Day Returning Customer',
        //     color: 'bg-success',
        // },
        // {
        //     icon: 'user-edit',
        //     info:
        //         profitabilityByDateRange?.customerAquireCounts?.find((entry) => entry.periodWhen === 1) // ✅ Find the correct object
        //             ?.returning || 0,
        //     desc: 'Week Returning Customer',
        //     color: 'bg-orange-400',
        // },
        // {
        //     icon: 'user',
        //     info:
        //         profitabilityByDateRange?.customerAquireCounts?.find((entry) => entry.periodWhen === 2) // ✅ Find the correct object
        //             ?.returning || 0,
        //     desc: 'Month Returning Customer',
        //     color: 'bg-cyan-400',
        // },
    ];
    const renderItem = (item, index) => {
        return (
            <div
                key={index}
                className={`card min-w-[12rem] flex-col justify-between gap-6 h-full bg-cover rtl:bg-[left_top_-1.7rem] bg-[right_top_-1.7rem] bg-no-repeat channel-stats-bg ${item?.color}`}
            >
                {/* <div className='w-7 mt-4 ms-5'>
                    <KeenIcon
                        icon={item.icon}
                        className="text-3xl font-bold text-white"
                    />
                </div> */}

                <div className='flex flex-col gap-1 pb-4 px-5'>
                    <span className='text-lg font-semibold text-white mt-4'>
                        {item.desc}
                    </span>
                    <span className='text-3xl font-bold text-white'>
                        £ {item.info?.toFixed(2)}
                    </span>
                </div>
            </div>
        );
    };
    return (
        <Fragment>
            <style>
                {`
          .channel-stats-bg {
            background-image: url('${toAbsoluteUrl('/media/images/2600x1600/bg-3.png')}');
          }
          .dark .channel-stats-bg {
            background-image: url('${toAbsoluteUrl('/media/images/2600x1600/bg-3-dark.png')}');
          }
        `}
            </style>

            {items.map((item, index) => {
                return renderItem(item, index);
            })}
        </Fragment>
    );
};
export { Stats };

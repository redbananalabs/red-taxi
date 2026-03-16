/** @format */

import { Fragment, useEffect, useMemo, useState } from "react";
import {
  Toolbar,
  ToolbarDescription,
  ToolbarHeading,
  ToolbarPageTitle,
} from "@/partials/toolbar";
import { KeenIcon } from "@/components";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
// import { Container } from '@/components/container';
import {
  Popover,
  PopoverContent,
  PopoverTrigger,
} from "@/components/ui/popover";
import { Calendar } from "@/components/ui/calendar";
import { format, subDays } from "date-fns";
import { cn } from "@/lib/utils";
import {
  DataGrid,
  DataGridColumnHeader,
  // useDataGrid,
  // DataGridRowSelectAll,
  // DataGridRowSelect,
} from "@/components";
import {
  Box,
  Collapse,
  IconButton,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Paper,
  TableSortLabel,
  TablePagination,
} from "@mui/material";
import { Input } from "@/components/ui/input";
import { useDispatch, useSelector } from "react-redux";
import { refreshAllAccounts } from "../../../../slices/accountSlice";
import {
  downloadInvoice,
  downloadInvoiceCSV,
  markInvoiceAsPaid,
  resendAccountInvoice,
} from "../../../../service/operations/billing&Payment";
import toast from "react-hot-toast";
import {
  refreshInvoiceHistory,
  setInvoiceHistory,
} from "../../../../slices/billingSlice";
import MoneyIcon from "@mui/icons-material/Money";
import {
  EmailOutlined,
  KeyboardArrowDown,
  KeyboardArrowUp,
} from "@mui/icons-material";
import DownloadOutlinedIcon from "@mui/icons-material/DownloadOutlined";
import DescriptionOutlinedIcon from "@mui/icons-material/DescriptionOutlined";
function RowNotPriced({
  row,
  handlePostButton,
  buttonLoading,
  setButtonLoading,
}) {
  const [open, setOpen] = useState(false);
  const ColumnInputFilter = ({ column }) => {
    return (
      <Input
        placeholder="Filter..."
        value={column.getFilterValue() ?? ""}
        onChange={(event) => column.setFilterValue(event.target.value)}
        className="h-9 w-full max-w-40"
      />
    );
  };
  const columns = useMemo(
    () => [
      {
        accessorKey: "jobNo",
        header: ({ column }) => (
          <DataGridColumnHeader
            title="#"
            filter={<ColumnInputFilter column={column} />}
            column={column}
          />
        ),
        enableSorting: true,
        cell: ({ row }) => (
          <span className={`p-2 rounded-md`}>{row.original.jobNo}</span>
        ),
        meta: { headerClassName: "w-20" },
      },
      {
        accessorKey: "date",
        header: ({ column }) => (
          <DataGridColumnHeader
            title="Date"
            filter={<ColumnInputFilter column={column} />}
            column={column}
          />
        ),
        enableSorting: true,
        cell: ({ row }) => (
          <span className={`p-2 rounded-md`}>
            {new Date(row?.original?.date).toLocaleDateString("en-GB") +
              " " +
              row.original.date?.split("T")[1]?.split(".")[0]?.slice(0, 5)}
          </span>
        ),
        meta: { headerClassName: "w-20" },
      },
      {
        accessorKey: "pickup",
        header: ({ column }) => (
          <DataGridColumnHeader
            title="Pickup"
            filter={<ColumnInputFilter column={column} />}
            column={column}
          />
        ),
        enableSorting: true,
        cell: ({ row }) => (
          <span className={`font-medium ${row.original.color}`}>
            {row.original.pickup}
          </span>
        ),
        meta: { headerClassName: "min-w-[120px]" },
      },
      {
        accessorKey: "destination",
        header: ({ column }) => (
          <DataGridColumnHeader
            title="Destination"
            filter={<ColumnInputFilter column={column} />}
            column={column}
          />
        ),
        enableSorting: true,
        cell: ({ row }) => (
          <span className={`font-medium ${row.original.color}`}>
            {row.original.destination}
          </span>
        ),
        meta: { headerClassName: "min-w-[120px]" },
      },
      {
        accessorKey: "passenger",
        header: ({ column }) => (
          <DataGridColumnHeader
            title="Passenger"
            filter={<ColumnInputFilter column={column} />}
            column={column}
          />
        ),
        enableSorting: true,
        cell: ({ row }) => (
          <span className={`font-medium ${row.original.color}`}>
            {row.original.passenger}
          </span>
        ),
        meta: { headerClassName: "min-w-[120px]" },
      },
      {
        accessorKey: "journey",
        header: ({ column }) => (
          <DataGridColumnHeader
            title="Price"
            filter={<ColumnInputFilter column={column} />}
            column={column}
          />
        ),
        enableSorting: true,
        cell: ({ row }) => (
          <span className={`font-medium ${row.original.color}`}>
            £{row.original.journey.toFixed(2)}
          </span>
        ),
        meta: { headerClassName: "min-w-[120px]" },
      },
      {
        accessorKey: "waiting",
        header: ({ column }) => (
          <DataGridColumnHeader
            title="Waiting"
            filter={<ColumnInputFilter column={column} />}
            column={column}
          />
        ),
        enableSorting: true,
        cell: ({ row }) => (
          <span className={`font-medium ${row.original.color}`}>
            £{row.original.waiting.toFixed(2)}
          </span>
        ),
        meta: { headerClassName: "min-w-[120px]" },
      },
      {
        accessorKey: "parking",
        header: ({ column }) => (
          <DataGridColumnHeader
            title="Parking"
            filter={<ColumnInputFilter column={column} />}
            column={column}
          />
        ),
        enableSorting: true,
        cell: ({ row }) => (
          <span className={`font-medium ${row.original.color}`}>
            £{row.original.parking.toFixed(2)}
          </span>
        ),
        meta: { headerClassName: "min-w-[120px]" },
      },
      {
        accessorKey: "total",
        header: ({ column }) => (
          <DataGridColumnHeader
            title="Total Ex"
            filter={<ColumnInputFilter column={column} />}
            column={column}
          />
        ),
        enableSorting: true,
        cell: ({ row }) => (
          <span className={`font-medium ${row.original.color}`}>
            £{row.original.total.toFixed(2)}
          </span>
        ),
        meta: { headerClassName: "min-w-[120px]" },
      },
      {
        accessorKey: "totalInc",
        header: ({ column }) => (
          <DataGridColumnHeader
            title="Total Inc"
            filter={<ColumnInputFilter column={column} />}
            column={column}
          />
        ),
        enableSorting: true,
        cell: ({ row }) => (
          <span className={`font-medium ${row.original.color}`}>
            £{row.original.totalInc.toFixed(2)}
          </span>
        ),
        meta: { headerClassName: "min-w-[120px]" },
      },
    ],
    []
  );
  const handleRowSelection = (state) => {
    const selectedRowIds = Object.keys(state);
    if (selectedRowIds.length > 0) {
      alert(`Selected Drivers: ${selectedRowIds.join(", ")}`);
    }
  };

  const downloadInvoiceClick = async (row) => {
    setButtonLoading({ rowId: row?.id, button: "downloadPdf" });
    try {
      const response = await downloadInvoice(row?.id);

      if (!response || response.size === 0) {
        console.error("Invalid or empty file received from API.");
        toast.error("Failed to download: Received an empty file.");
        return;
      }

      const blob = new Blob([response], { type: "application/pdf" });
      const link = document.createElement("a");
      link.href = URL.createObjectURL(blob);
      link.setAttribute("download", `invoice-${row.id}.pdf`);
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
    } catch (error) {
      console.error("Error handling invoice download:", error);
      toast.error("Error downloading invoice. Please try again.");
    } finally {
      setButtonLoading({ rowId: null, button: null });
    }
  };

  const downloadInvoiceCSVClick = async (row) => {
    setButtonLoading({ rowId: row?.id, button: "downloadCSV" });
    try {
      const response = await downloadInvoiceCSV(row?.id);

      if (!response || response.size === 0) {
        console.error("Invalid or empty file received from API.");
        toast.error("Failed to download: Received an empty file.");
        return;
      }

      const blob = new Blob([response], { type: "text/csv;charset=utf-8;" });
      const link = document.createElement("a");
      link.href = URL.createObjectURL(blob);
      link.setAttribute("download", `invoice-${row.id}.csv`);
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
    } catch (error) {
      console.error("Error handling invoice download:", error);
      toast.error("Error downloading invoice. Please try again.");
    } finally {
      setButtonLoading({ rowId: null, button: null });
    }
  };

  const handleResendButton = async (row) => {
    setButtonLoading({ rowId: row?.id, button: "resend" });
    try {
      const response = await resendAccountInvoice(row?.id);
      if (response?.status === "success") {
        toast.success("Account Invoice resent successfully");
      } else {
        toast.error(response.data.message);
      }
    } catch (error) {
      console.error("Failed to resend account invoice:", error);
      toast.error("Failed to resend account invoice");
    } finally {
      setButtonLoading({ rowId: null, button: null });
    }
  };

  return (
    <>
      {/* Main Table Row */}
      <TableRow
        className={`${row?.coa ? " bg-orange-500 hover:bg-orange-400" : "bg-white dark:bg-[#14151A] hover:bg-gray-100"} `}
      >
        <TableCell>
          <IconButton size="small" onClick={() => setOpen(!open)}>
            {open ? (
              <KeyboardArrowUp
                className={`${row?.coa ? "text-gray-800 dark:text-white" : "text-gray-800 dark:text-gray-700"}`}
              />
            ) : (
              <KeyboardArrowDown
                className={`${row?.coa ? "text-gray-800 dark:text-white" : "text-gray-800 dark:text-gray-700"}`}
              />
            )}
          </IconButton>
        </TableCell>
        <TableCell
          className={`${row?.coa ? "text-blue-600 dark:text-white" : "text-blue-500 dark:text-cyan-400"}  font-medium`}
        >
          {row.id}
        </TableCell>
        <TableCell
          className={`${row?.coa ? "dark:text-white" : "dark:text-gray-700"} text-gray-900`}
        >
          {row.accNumber}
        </TableCell>
        <TableCell
          className={`${row?.coa ? "dark:text-white" : "dark:text-gray-700"} text-gray-900`}
        >
          {row.date}
        </TableCell>
        <TableCell
          className={`${row?.coa ? "dark:text-white" : "dark:text-gray-700"} text-gray-900`}
        >
          £{row.net.toFixed(2)}
        </TableCell>
        <TableCell
          className={`${row?.coa ? "dark:text-white" : "dark:text-gray-700"} text-gray-900`}
        >
          £{row.vat.toFixed(2)}
        </TableCell>
        <TableCell
          className={`${row?.coa ? "dark:text-white" : "dark:text-gray-700"} text-gray-900 font-semibold`}
        >
          £{row.total.toFixed(2)}
        </TableCell>
        <TableCell>
          <IconButton
            size="small"
            onClick={() => downloadInvoiceClick(row)}
            disabled={
              buttonLoading.rowId === row?.id &&
              buttonLoading.button === "downloadPdf"
            }
          >
            <DownloadOutlinedIcon
              className={`${row?.coa ? `text-red-500 dark:text-red-900 ` : `text-red-500 dark:text-red-600`}`}
            />
          </IconButton>
        </TableCell>
        <TableCell>
          <IconButton
            size="small"
            onClick={() => downloadInvoiceCSVClick(row)}
            disabled={
              buttonLoading.rowId === row?.id &&
              buttonLoading.button === "downloadCSV"
            }
          >
            <DescriptionOutlinedIcon
              className={`${row?.coa ? `text-red-500 dark:text-red-900 ` : `text-red-500 dark:text-red-600`}`}
            />
          </IconButton>
        </TableCell>
        <TableCell>
          <IconButton
            size="small"
            onClick={() => handleResendButton(row)}
            disabled={
              buttonLoading.rowId === row?.id &&
              buttonLoading.button === "resend"
            }
          >
            <EmailOutlined
              className={`${
                row.paid ||
                (buttonLoading.rowId === row?.id &&
                  buttonLoading.button === "resend")
                  ? "text-gray-400 dark:text-gray-500" // Blur effect when disabled
                  : row?.coa
                    ? `text-blue-500 dark:text-white`
                    : `text-blue-500 dark:text-cyan-400`
              }`}
            />
          </IconButton>
        </TableCell>
        <TableCell
          className={`${row?.coa ? "dark:text-white" : "dark:text-gray-700"} text-gray-900 font-semibold`}
        >
          {row.paid ? "True" : "False"}
        </TableCell>
        <TableCell>
          <IconButton
            size="small"
            disabled={
              row.paid ||
              (buttonLoading.rowId === row?.id &&
                buttonLoading.button === "post")
            }
          >
            <MoneyIcon
              className={`${
                row.paid ||
                (buttonLoading.rowId === row?.id &&
                  buttonLoading.button === "post")
                  ? "text-gray-400 dark:text-gray-500" // Blur effect when disabled
                  : row?.coa
                    ? "text-green-600 dark:text-green-600"
                    : "text-green-500 dark:text-green-400"
              }`}
              onClick={() => {
                if (row.total === 0 && !row.paid) {
                  toast.error("Driver Price Should not be 0"); // Show error if price is 0
                } else {
                  handlePostButton(row); // Post the job if valid
                }
              }}
            />
          </IconButton>
        </TableCell>
      </TableRow>

      {/* Collapsible Booking Details Row */}
      <TableRow>
        <TableCell colSpan={16} style={{ paddingBottom: 0, paddingTop: 0 }}>
          <Collapse in={open} timeout="auto" unmountOnExit>
            <Box
              margin={1}
              className="border border-gray-300 dark:border-gray-600 rounded-md p-2 bg-gray-100 dark:bg-[#232427] text-gray-900 dark:text-gray-700"
            >
              <div
                className={`${row?.coa ? "text-blue-600 dark:text-white" : "text-blue-500 dark:text-cyan-400"}  font-medium text-lg`}
              >
                Invoice #: {row?.id}
              </div>
              <DataGrid
                columns={columns}
                data={row.items}
                rowSelection={true}
                onRowSelectionChange={handleRowSelection}
                pagination={{ size: 10 }}
                sorting={[{ id: "jobNo", desc: false }]}
                layout={{ card: true }}
              />
            </Box>
          </Collapse>
        </TableCell>
      </TableRow>
    </>
  );
}

function InvoiceHistory() {
  const dispatch = useDispatch();
  const { accounts } = useSelector((state) => state.account);
  const { invoiceHistory, loading } = useSelector((state) => state.billing);
  const [selectedAccount, setSelectedAccount] = useState(0);
  const [search, setSearch] = useState("");
  const [order, setOrder] = useState("desc"); // Sort order
  const [orderBy, setOrderBy] = useState("date"); // Default sorted column
  const [buttonLoading, setButtonLoading] = useState({
    rowId: null,
    button: null,
  });
  const [date, setDate] = useState({
    from: subDays(new Date(), 689),
    to: new Date(),
  });
  const [openDate, setOpenDate] = useState(false);
  const [tempRange, setTempRange] = useState(date);
  const [page, setPage] = useState(0);
  const [rowsPerPage, setRowsPerPage] = useState(10);

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

  const handleChangePage = (event, newPage) => {
    setPage(newPage);
  };

  const handleChangeRowsPerPage = (event) => {
    setRowsPerPage(parseInt(event.target.value, 10));
    setPage(0); // Reset to first page when rows per page changes
  };

  // console.log(invoiceHistory);

  const formattedBookings = (invoiceHistory || []).map((booking) => ({
    id: booking?.invoiceNumber,
    date: booking?.invoiceDate
      ? new Date(booking?.invoiceDate).toLocaleDateString("en-GB") +
        " " +
        booking?.invoiceDate?.split("T")[1]?.split(".")[0]?.slice(0, 5)
      : "-", // Ensure correct date format
    accNumber: booking?.accNo,
    net: booking?.net || 0,
    vat: booking?.vat || 0,
    total: booking?.total || 0,
    paid: booking?.paid || false,
    items: booking?.items || [],
  }));

  const filteredBookings = formattedBookings?.filter((booking) => {
    if (!search?.trim()) return true;

    const isMatch =
      String(booking?.accNumber)
        ?.toLowerCase()
        .includes(search?.toLowerCase()) ||
      String(booking?.id)?.toLowerCase().includes(search?.toLowerCase());

    return isMatch;
  });

  const handleSort = (property) => {
    const isAscending = orderBy === property && order === "asc";
    setOrder(isAscending ? "desc" : "asc");
    setOrderBy(property);
  };

  const sortedBookings = [...filteredBookings].sort((a, b) => {
    if (a.paid !== b.paid) {
      return a.paid ? 1 : -1; // unpaid (false) comes first
    }
    if (order === "asc") {
      return a[orderBy] > b[orderBy] ? 1 : -1;
    } else {
      return a[orderBy] < b[orderBy] ? 1 : -1;
    }
  });

  const handlePostButton = async (row) => {
    setButtonLoading({ rowId: row?.id, button: "post" });
    try {
      const response = await markInvoiceAsPaid(row?.id);
      if (response?.status === "success") {
        toast.success("Mark Invoice As Paid Successfully");
        handleSearch();
      } else {
        toast.error(response.data?.message);
      }
    } catch (error) {
      console.error("Failed to post job:", error);
      toast.error("Failed to post job");
    } finally {
      setButtonLoading({ rowId: null, button: null });
    }
  };

  const handleSearch = async () => {
    dispatch(
      refreshInvoiceHistory(
        format(new Date(date?.from), "yyyy-MM-dd"),
        format(new Date(date?.to), "yyyy-MM-dd"),
        selectedAccount
      )
    );
  };

  useEffect(() => {
    dispatch(setInvoiceHistory([]));
    dispatch(refreshAllAccounts());
  }, [dispatch]);

  return (
    <Fragment>
      <div className="pe-[1.875rem] ps-[1.875rem] ms-auto me-auto max-w-[1850px] w-full">
        <Toolbar>
          <ToolbarHeading>
            <ToolbarPageTitle />
            <ToolbarDescription>
              Showing {invoiceHistory?.length} Invoices{" "}
            </ToolbarDescription>
          </ToolbarHeading>
        </Toolbar>
      </div>
      <div className="pe-[1.875rem] ps-[1.875rem] ms-auto me-auto max-w-[1850px] w-full">
        <div className="flex flex-col items-stretch gap-5 lg:gap-7.5">
          <div className="flex flex-wrap items-center gap-5 justify-between">
            <div className="card card-grid min-w-full">
              <div className="card-header flex-wrap gap-2">
                <div className="flex flex-wrap gap-2 lg:gap-5">
                  <div className="flex">
                    <label
                      className="input input-sm hover:shadow-lg"
                      style={{ height: "40px", marginTop: "16px" }}
                    >
                      <KeenIcon icon="magnifier" />
                      <input
                        type="text"
                        placeholder="Search Invoice No."
                        value={search}
                        onChange={(e) => setSearch(e.target.value)}
                      />
                    </label>
                  </div>
                  <div className="flex flex-wrap items-center gap-2.5">
                    <div className="flex flex-col">
                      <label className="form-label">Date Range</label>
                      <Popover open={openDate} onOpenChange={setOpenDate}>
                        <PopoverTrigger asChild>
                          <button
                            id="date"
                            className={cn(
                              "btn btn-sm btn-light data-[state=open]:bg-light-active",
                              !date && "text-gray-400"
                            )}
                            style={{ height: "40px" }}
                          >
                            <KeenIcon icon="calendar" className="me-0.5" />
                            {date?.from ? (
                              date.to ? (
                                <>
                                  {format(date.from, "LLL dd, y")} -{" "}
                                  {format(date.to, "LLL dd, y")}
                                </>
                              ) : (
                                format(date.from, "LLL dd, y")
                              )
                            ) : (
                              <span>Pick a date range</span>
                            )}
                          </button>
                        </PopoverTrigger>
                        <PopoverContent className="w-auto p-0" align="end">
                          <Calendar
                            initialFocus
                            mode="range"
                            defaultMonth={date?.from}
                            selected={tempRange}
                            onSelect={handleDateSelect}
                            numberOfMonths={2}
                          />
                        </PopoverContent>
                      </Popover>
                    </div>

                    <div className="flex flex-col">
                      <label className="form-label">Accounts</label>
                      <Select
                        value={selectedAccount}
                        onValueChange={(value) => setSelectedAccount(value)}
                      >
                        <SelectTrigger
                          className="w-40 hover:shadow-lg"
                          size="sm"
                          style={{ height: "40px" }}
                        >
                          <SelectValue placeholder="Select" />
                        </SelectTrigger>
                        <SelectContent className="w-40">
                          <SelectItem value={0}>All</SelectItem>
                          {accounts?.length > 0 &&
                            accounts?.map((acc) => (
                              <>
                                <SelectItem value={acc?.accNo}>
                                  {acc?.accNo} - {acc?.businessName}
                                </SelectItem>
                              </>
                            ))}
                        </SelectContent>
                      </Select>
                    </div>

                    <button
                      className="btn btn-sm btn-outline btn-primary mt-4"
                      style={{ height: "40px" }}
                      onClick={handleSearch}
                      disabled={loading}
                    >
                      <KeenIcon icon="magnifier" />{" "}
                      {loading ? "Searching..." : "Search"}
                    </button>
                  </div>
                </div>
              </div>
              <div className="card-body">
                <div className="flex justify-start items-center gap-4 ml-4 mt-2 mb-2">
                  Available Invoices
                </div>
                {sortedBookings?.length > 0 ? (
                  <TableContainer
                    component={Paper}
                    className="shadow-none bg-white dark:bg-[#14151A] overflow-x-auto"
                  >
                    <Table className="text-[#14151A] dark:text-gray-100">
                      <TableHead
                        className="bg-gray-100 dark:bg-[#14151A]"
                        sx={{
                          "& .MuiTableCell-root": {
                            // borderBottom: '1px solid #464852',
                            fontWeight: "bold", // Ensures header text stands out
                          },
                        }}
                      >
                        <TableRow>
                          <TableCell className="w-8" />{" "}
                          {/* Empty Cell for Expand Button */}
                          <TableCell className="text-gray-900 dark:text-gray-700 border-e">
                            <TableSortLabel
                              active={orderBy === "id"}
                              direction={order}
                              onClick={() => handleSort("id")}
                              sx={{
                                "&:hover": { color: "#9A9CAE" }, // Change color on hover
                                "&.Mui-active": { color: "#9A9CAE" },
                                "&.Mui-active .MuiTableSortLabel-icon": {
                                  color: "#9A9CAE",
                                }, // Change to blue when active
                              }}
                            >
                              Invoice #
                            </TableSortLabel>
                          </TableCell>
                          <TableCell className="text-gray-900 dark:text-gray-700 border-e">
                            Acc No.
                          </TableCell>
                          <TableCell className="text-gray-900 dark:text-gray-700 border-e">
                            <TableSortLabel
                              active={orderBy === "date"}
                              direction={order}
                              onClick={() => handleSort("date")}
                              sx={{
                                "&:hover": { color: "#9A9CAE" }, // Change color on hover
                                "&.Mui-active": { color: "#9A9CAE" },
                                "&.Mui-active .MuiTableSortLabel-icon": {
                                  color: "#9A9CAE",
                                }, // Change to blue when active
                              }}
                            >
                              Date
                            </TableSortLabel>
                          </TableCell>
                          <TableCell className="text-gray-900 dark:text-gray-700 border-e">
                            NET
                          </TableCell>
                          <TableCell className="text-gray-900 dark:text-gray-700 border-e">
                            VAT
                          </TableCell>
                          <TableCell className="text-gray-900 dark:text-gray-700 border-e">
                            Total
                          </TableCell>
                          <TableCell className="text-gray-900 dark:text-gray-700 border-e">
                            Download
                          </TableCell>
                          <TableCell className="text-gray-900 dark:text-gray-700 border-e">
                            Download CSV
                          </TableCell>
                          <TableCell className="text-gray-900 dark:text-gray-700 border-e">
                            Resend
                          </TableCell>
                          <TableCell className="text-gray-900 dark:text-gray-700 border-e">
                            <TableSortLabel
                              active={orderBy === "paid"}
                              direction={order}
                              onClick={() => handleSort("paid")}
                              sx={{
                                "&:hover": { color: "#9A9CAE" }, // Change color on hover
                                "&.Mui-active": { color: "#9A9CAE" },
                                "&.Mui-active .MuiTableSortLabel-icon": {
                                  color: "#9A9CAE",
                                }, // Change to blue when active
                              }}
                            >
                              Paid
                            </TableSortLabel>
                          </TableCell>
                          <TableCell className="text-gray-900 dark:text-gray-700 border-e">
                            Mark Paid
                          </TableCell>
                        </TableRow>
                      </TableHead>

                      <TableBody
                        sx={{
                          "& .MuiTableCell-root": {
                            // borderBottom: '1px solid #464852',
                          },
                        }}
                      >
                        {sortedBookings
                          ?.slice(
                            page * rowsPerPage,
                            page * rowsPerPage + rowsPerPage
                          )
                          .map((row) => (
                            <>
                              <RowNotPriced
                                key={row.id}
                                row={row}
                                handlePostButton={handlePostButton}
                                buttonLoading={buttonLoading}
                                setButtonLoading={setButtonLoading}
                              />
                            </>
                          ))}
                      </TableBody>
                    </Table>
                    <TablePagination
                      component="div"
                      count={sortedBookings.length}
                      page={page}
                      onPageChange={handleChangePage}
                      rowsPerPage={rowsPerPage}
                      onRowsPerPageChange={handleChangeRowsPerPage}
                      rowsPerPageOptions={[5, 10, 25, 50]}
                      className="text-sm text-gray-900 dark:text-gray-700 px-4"
                      SelectProps={{
                        MenuProps: {
                          PaperProps: {
                            sx: {
                              "& .MuiMenuItem-root": {
                                fontSize: "0.875rem",
                                "&:hover": {
                                  backgroundColor: "transparent", // Tailwind's gray-100
                                  color: "#071437", // Tailwind's blue-800
                                },
                                "&.Mui-selected": {
                                  backgroundColor: "#F1F1F4", // selected bg
                                  color: "#071437", // selected text (blue-800)
                                },
                              },
                              // Dark mode styles (optional)
                              "@media (prefers-color-scheme: dark)": {
                                backgroundColor: "transparent", // dark gray bg
                                color: "#9A9CAE",
                                "& .MuiMenuItem-root": {
                                  "&:hover": {
                                    backgroundColor: "#374151", // hover dark gray
                                    color: "#9A9CAE",
                                  },
                                  "&.Mui-selected": {
                                    backgroundColor: "#0D0E12",
                                    color: "#9A9CAE",
                                  },
                                },
                              },
                            },
                          },
                        },
                      }}
                    />
                  </TableContainer>
                ) : (
                  <div className="text-start ml-4  text-yellow-600 dark:border dark:border-yellow-400 dark:opacity-50 dark:bg-transparent rounded-md bg-yellow-100 p-2 mr-4 mb-2">
                    ⚠️ No Data Available
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

export { InvoiceHistory };

/** @format */
import {
  Dialog,
  DialogBody,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { useFormik } from "formik";
import * as Yup from "yup";
// import clsx from 'clsx';
import { updateDriverExpirys } from "../../../../service/operations/driverApi";
import { useDispatch, useSelector } from "react-redux";
import {
  refreshAllDrivers,
  refreshAllDriversExpiry,
} from "../../../../slices/driverSlice";
import toast from "react-hot-toast";
import clsx from "clsx";
import { useEffect, useState } from "react";
import { formatMyDate } from "../../../../utils/Date";
function AddDriverExpiry({ open, onOpenChange }) {
  const dispatch = useDispatch();
  const { drivers } = useSelector((state) => state.driver);
  const [date, setDate] = useState(formatMyDate(new Date()));
  const addLocalSchema = Yup.object().shape({
    userId: Yup.number().required("Select a Driver"),
    docType: Yup.number().required("Document type is required"),
    expiryDate: Yup.date().required("Expiry date is required"),
  });

  const initialValues = {
    userId: 0,
    docType: 0,
    expiryDate: formatMyDate(new Date()),
  };

  const formik = useFormik({
    initialValues,
    validationSchema: addLocalSchema,
    onSubmit: async (values, { setSubmitting }) => {
      try {
        const payload = {
          userId: values.userId || 0,
          docType: values.docType || 0,
          expiryDate: values.expiryDate || date,
        };
        const response = await updateDriverExpirys(payload);
        if (response.status === "success") {
          console.log("Driver Expiry added successfully");
          toast.success("Driver Expiry added successfully");
          dispatch(refreshAllDriversExpiry());
          setSubmitting(false);
          onOpenChange(); // Reset Formik's submitting state
        } else {
          console.error("Failed to add driver expiry", response.error);
        }
      } catch (error) {
        console.error("Error adding driver expiry", error);
      }
    },
  });

  // ✅ Handle Date Change in Formik
  const handleDateTimeChange = (e) => {
    const dateTimeValue = e.target.value; // e.g., "2025-03-07T06:30"
    if (dateTimeValue) {
      // Convert to ISO string with seconds (required by API)
      const selectedDate = new Date(dateTimeValue);
      setDate(formatMyDate(selectedDate));
      formik.setFieldValue("expiryDate", formatMyDate(selectedDate));
    }
  };

  const formatDateForInput = (date) => {
    if (!date) return "";
    const d = new Date(date);
    const year = d.getFullYear();
    const month = String(d.getMonth() + 1).padStart(2, "0");
    const day = String(d.getDate()).padStart(2, "0");
    const hours = String(d.getHours()).padStart(2, "0");
    const minutes = String(d.getMinutes()).padStart(2, "0");
    return `${year}-${month}-${day}T${hours}:${minutes}`;
  };

  useEffect(() => {
    dispatch(refreshAllDrivers());
  }, [dispatch]);

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="max-w-[500px]">
        <DialogHeader className="border-0">
          <DialogTitle></DialogTitle>
          <DialogDescription></DialogDescription>
        </DialogHeader>
        <DialogBody className="flex flex-col items-center pt-0 pb-4">
          <h3 className="text-lg font-medium text-gray-900 text-center mb-3">
            Add Driver Expiry
          </h3>

          <form onSubmit={formik.handleSubmit} className="w-full">
            <div className="flex flex-col pb-2 w-full">
              <label className="form-label text-gray-900">Driver</label>
              <Select
                value={formik.values.userId}
                onValueChange={(value) =>
                  formik.setFieldValue("userId", Number(value))
                }
              >
                <SelectTrigger
                  className="w-full hover:shadow-lg"
                  size="sm"
                  style={{ height: "40px" }}
                >
                  <SelectValue placeholder="Select" />
                </SelectTrigger>
                <SelectContent className="w-36">
                  <SelectItem value={0}>All</SelectItem>
                  {drivers?.length > 0 &&
                    drivers?.map((driver) => (
                      <>
                        <SelectItem value={driver?.id}>
                          {driver?.id} - {driver?.fullName}
                        </SelectItem>
                      </>
                    ))}
                </SelectContent>
              </Select>
            </div>
            <div className="w-full flex justify-center items-center gap-2">
              <div className="flex flex-col gap-1 pb-2 w-[50%]">
                <label className="form-label text-gray-900">Expiry Date</label>
                {/* <Popover>
									<PopoverTrigger asChild>
										<button
											id='date'
											className={cn(
												'input data-[state=open]:border-primary',
												!date && 'text-muted-foreground'
											)}
											style={{ width: '13rem' }}
										>
											<KeenIcon
												icon='calendar'
												className='-ms-0.5'
											/>
											{date ? (
												format(date, 'LLL dd, y')
											) : (
												<span>Pick a date</span>
											)}
										</button>
									</PopoverTrigger>
									<PopoverContent
										className='w-auto p-0'
										align='start'
									>
										<Calendar
											initialFocus
											mode='single' // Single date selection
											defaultMonth={date}
											selected={date}
											onSelect={handleDateChange}
											numberOfMonths={1}
										/>
									</PopoverContent>
								</Popover> */}

                <label className="input">
                  <input
                    type="datetime-local"
                    placeholder="Enter Expiry Date"
                    autoComplete="off"
                    value={formatDateForInput(formik.values.expiryDate)}
                    onChange={handleDateTimeChange}
                    step="60"
                    className={clsx("form-control", {
                      "is-invalid":
                        formik.touched.expiryDate && formik.errors.expiryDate,
                    })}
                  />
                </label>

                {/* ✅ Show Formik Validation Error */}
                {formik.touched.expiryDate && formik.errors.expiryDate && (
                  <span role="alert" className="text-danger text-xs mt-1">
                    {formik.errors.expiryDate}
                  </span>
                )}
              </div>
              <div className="flex flex-col gap-1 pb-2 w-[50%]">
                <label className="form-label text-gray-900">
                  Document Type
                </label>
                <Select
                  value={formik.values.docType.toString()}
                  onValueChange={(value) =>
                    formik.setFieldValue("docType", Number(value))
                  }
                >
                  <SelectTrigger className="w-full">
                    <SelectValue placeholder="Select" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="0"> Insurance</SelectItem>
                    <SelectItem value="1">MOT</SelectItem>
                    <SelectItem value="2">DBS</SelectItem>
                    <SelectItem value="3">Vehicle Badge</SelectItem>
                    <SelectItem value="4">Driver License</SelectItem>
                    <SelectItem value="5">Safe Guarding</SelectItem>
                    <SelectItem value="6">FirstAidCert</SelectItem>
                    <SelectItem value="7">Driver Photo</SelectItem>
                  </SelectContent>
                </Select>
                {formik.touched.docType && formik.errors.docType && (
                  <span color="alert" className="text-danger text-xs mt-1">
                    {formik.errors.docType}
                  </span>
                )}
              </div>
            </div>

            <div className="flex justify-end mb-2 mt-2">
              <button className="btn btn-light" onClick={() => onOpenChange()}>
                Cancel
              </button>
              <button className="btn btn-success ml-2" type="submit">
                Submit
              </button>
            </div>
          </form>
        </DialogBody>
      </DialogContent>
    </Dialog>
  );
}

export { AddDriverExpiry };

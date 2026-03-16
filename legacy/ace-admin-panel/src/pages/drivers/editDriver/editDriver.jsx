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
import clsx from "clsx";
import { updateDriver } from "../../../service/operations/driverApi";
import { useDispatch, useSelector } from "react-redux";
import { refreshAllDrivers } from "../../../slices/driverSlice";
import toast from "react-hot-toast";
import { useRef } from "react";
function EditDriver({ open, onOpenChange }) {
  const dispatch = useDispatch();
  const { driver } = useSelector((state) => state.driver);
  const addLocalSchema = Yup.object().shape({
    cashCommisionRate: Yup.number()
      .typeError("Commission rate must be a number")
      .required("Commission rate is required")
      .min(0, "Commission rate cannot be less than 0")
      .max(100, "Commission rate cannot be more than 100"),
  });
  const colorInputRef = useRef(null);
  const initialValues = {
    RegistrationNo: driver?.regNo || "",
    fullName: driver?.fullName || "",
    email: driver?.email || "",
    phoneNumber: driver?.phoneNumber || "",
    vehicleMake: driver?.vehicleMake || "",
    vehicleModel: driver?.vehicleModel || "",
    vehicleColor: driver?.vehicleColour || "",
    role: driver?.role || 0,
    colorCode: driver?.colorRGB || "#000000",
    vehicleType: driver?.vehicleType || 0,
    cashCommisionRate: driver?.cashCommisionRate || 0,
    comms: driver?.comms || 0,
    showAllBookings: driver?.showAllBookings || false,
    nonAce: driver?.nonAce || false,
  };

  const formik = useFormik({
    initialValues,
    validationSchema: addLocalSchema,
    onSubmit: async (values, { setSubmitting }) => {
      try {
        const payload = {
          ...values,
          userId: driver?.id || 0,
        };
        const response = await updateDriver(payload);
        if (response.status === "success") {
          console.log("Driver updated successfully");
          toast.success("Driver updated successfully");
          dispatch(refreshAllDrivers());
          setSubmitting(false);
          onOpenChange(); // Reset Formik's submitting state
        } else {
          console.error("Failed to update driver", response.error);
        }
      } catch (error) {
        console.error("Error updating driver", error);
      }
    },
  });

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="max-w-[500px]">
        <DialogHeader className="border-0">
          <DialogTitle></DialogTitle>
          <DialogDescription></DialogDescription>
        </DialogHeader>
        <DialogBody className="flex flex-col items-center pt-0 pb-4">
          <h3 className="text-lg font-medium text-gray-900 text-center mb-3">
            Edit Driver #{driver?.id}
          </h3>

          <form onSubmit={formik.handleSubmit} className="w-full">
            <div className="w-full flex justify-center items-center gap-2">
              <div className="flex flex-col gap-1 pb-2 w-full">
                <label className="form-label text-gray-900">
                  Registration Number
                </label>
                <label className="input">
                  <input
                    placeholder="Enter registration Number"
                    autoComplete="off"
                    {...formik.getFieldProps("RegistrationNo")}
                    className={clsx("form-control", {
                      "is-invalid":
                        formik.touched.RegistrationNo &&
                        formik.errors.RegistrationNo,
                    })}
                  />
                </label>
                {formik.touched.RegistrationNo &&
                  formik.errors.RegistrationNo && (
                    <span role="alert" className="text-danger text-xs mt-1">
                      {formik.errors.RegistrationNo}
                    </span>
                  )}
              </div>
              <div className="flex flex-col gap-1 pb-2 w-full">
                <label className="form-label text-gray-900">Full Name</label>
                <label className="input">
                  <input
                    placeholder="Enter fullname"
                    autoComplete="off"
                    {...formik.getFieldProps("fullName")}
                    className={clsx("form-control", {
                      "is-invalid":
                        formik.touched.fullName && formik.errors.fullName,
                    })}
                  />
                </label>
                {formik.touched.fullName && formik.errors.fullName && (
                  <span role="alert" className="text-danger text-xs mt-1">
                    {formik.errors.fullName}
                  </span>
                )}
              </div>
            </div>

            <div className="w-full flex justify-center items-center gap-2">
              <div className="flex flex-col gap-1 pb-2 w-full">
                <label className="form-label text-gray-900">Email</label>
                <label className="input">
                  <input
                    placeholder="Enter email"
                    autoComplete="off"
                    {...formik.getFieldProps("email")}
                    className={clsx("form-control", {
                      "is-invalid": formik.touched.email && formik.errors.email,
                    })}
                  />
                </label>
                {formik.touched.email && formik.errors.email && (
                  <span role="alert" className="text-danger text-xs mt-1">
                    {formik.errors.email}
                  </span>
                )}
              </div>
              <div className="flex flex-col gap-1 pb-2 w-full">
                <label className="form-label text-gray-900">Phone Number</label>
                <label className="input">
                  <input
                    placeholder="Enter phone number"
                    autoComplete="off"
                    {...formik.getFieldProps("phoneNumber")}
                    className={clsx("form-control", {
                      "is-invalid":
                        formik.touched.phoneNumber && formik.errors.phoneNumber,
                    })}
                  />
                </label>

                {formik.touched.phoneNumber && formik.errors.phoneNumber && (
                  <span role="alert" className="text-danger text-xs mt-1">
                    {formik.errors.phoneNumber}
                  </span>
                )}
              </div>
            </div>

            <div className="w-full flex justify-center items-center gap-2">
              <div className="flex flex-col gap-1 pb-2 w-[50%]">
                <label className="form-label text-gray-900">Role</label>
                <Select
                  value={formik.values.role.toString()} // Ensure value is string
                  onValueChange={(value) =>
                    formik.setFieldValue("role", Number(value))
                  }
                >
                  <SelectTrigger className="w-full">
                    <SelectValue placeholder="Select" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="0">Choose Role</SelectItem>
                    <SelectItem value="1">Admin</SelectItem>
                    <SelectItem value="2">User</SelectItem>
                    <SelectItem value="3">Driver</SelectItem>
                    <SelectItem value="4">Account</SelectItem>
                  </SelectContent>
                </Select>
                {formik.touched.role && formik.errors.role && (
                  <span role="alert" className="text-danger text-xs mt-1">
                    {formik.errors.role}
                  </span>
                )}
              </div>
              <div className="flex flex-col gap-1 pb-2 w-[50%]">
                <label className="form-label text-gray-900">Color</label>
                <label className="input">
                  <input
                    ref={colorInputRef}
                    type="color"
                    value={
                      formik.values.colorCode?.length === 7
                        ? formik.values.colorCode
                        : formik.values.colorCode?.slice(0, 7)
                    }
                    onChange={(e) =>
                      formik.setFieldValue("colorCode", e.target.value)
                    }
                    className="w-10 h-10 rounded cursor-pointer border border-gray-400"
                  />

                  {/* Show HEX Color Code Input */}
                  <input
                    type="text"
                    value={formik.values.colorCode || ""}
                    onChange={(e) =>
                      formik.setFieldValue("colorCode", e.target.value)
                    }
                    className={clsx("form-control flex-grow", {
                      "is-invalid":
                        formik.touched.colorCode && formik.errors.colorCode,
                    })}
                    onClick={() => colorInputRef.current.click()}
                  />
                </label>
                {formik.touched.colorCode && formik.errors.colorCode && (
                  <span color="alert" className="text-danger text-xs mt-1">
                    {formik.errors.colorCode}
                  </span>
                )}
              </div>
            </div>

            <div className="w-full flex justify-center items-center gap-2">
              <div className="flex flex-col gap-1 pb-2 w-full">
                <label className="form-label text-gray-900">Vehicle Make</label>
                <label className="input">
                  <input
                    placeholder="Enter vehicle make"
                    autoComplete="off"
                    {...formik.getFieldProps("vehicleMake")}
                    className={clsx("form-control", {
                      "is-invalid":
                        formik.touched.vehicleMake && formik.errors.vehicleMake,
                    })}
                  />
                </label>
                {formik.touched.vehicleMake && formik.errors.vehicleMake && (
                  <span role="alert" className="text-danger text-xs mt-1">
                    {formik.errors.vehicleMake}
                  </span>
                )}
              </div>
              <div className="flex flex-col gap-1 pb-2 w-full">
                <label className="form-label text-gray-900">
                  Vehicle Model
                </label>
                <label className="input">
                  <input
                    placeholder="Enter vehicle model"
                    autoComplete="off"
                    {...formik.getFieldProps("vehicleModel")}
                    className={clsx("form-control", {
                      "is-invalid":
                        formik.touched.vehicleModel &&
                        formik.errors.vehicleModel,
                    })}
                  />
                </label>
                {formik.touched.vehicleModel && formik.errors.vehicleModel && (
                  <span role="alert" className="text-danger text-xs mt-1">
                    {formik.errors.vehicleModel}
                  </span>
                )}
              </div>
            </div>

            <div className="w-full flex justify-center items-center gap-2">
              <div className="flex flex-col gap-1 pb-2 w-[50%]">
                <label className="form-label text-gray-900">
                  Vehicle Color
                </label>
                <label className="input">
                  <input
                    placeholder="Enter vehicle color"
                    autoComplete="off"
                    {...formik.getFieldProps("vehicleColor")}
                    className={clsx("form-control", {
                      "is-invalid":
                        formik.touched.vehicleColor &&
                        formik.errors.vehicleColor,
                    })}
                  />
                </label>

                {formik.touched.vehicleColor && formik.errors.vehicleColor && (
                  <span role="alert" className="text-danger text-xs mt-1">
                    {formik.errors.vehicleColor}
                  </span>
                )}
              </div>
              <div className="flex flex-col gap-1 pb-2 w-[50%]">
                <label className="form-label text-gray-900">Vehicle Type</label>
                <Select
                  defaultValue="0"
                  value={formik.values.vehicleType.toString()}
                  onValueChange={(value) =>
                    formik.setFieldValue("vehicleType", Number(value))
                  }
                >
                  <SelectTrigger className="w-full">
                    <SelectValue placeholder="Select" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="0">Unknown</SelectItem>
                    <SelectItem value="1">Saloon</SelectItem>
                    <SelectItem value="2">Estate</SelectItem>
                    <SelectItem value="3">MPV</SelectItem>
                    <SelectItem value="4">MPVPlus</SelectItem>
                    <SelectItem value="5">SUV</SelectItem>
                  </SelectContent>
                </Select>
                {formik.touched.vehicleType && formik.errors.vehicleType && (
                  <span color="alert" className="text-danger text-xs mt-1">
                    {formik.errors.vehicleType}
                  </span>
                )}
              </div>
            </div>
            <div className="w-full flex justify-center items-center gap-2">
              <div className="flex flex-col gap-1 pb-2 w-[50%]">
                <label className="form-label text-gray-900">
                  Commission Rate
                </label>
                <label className="input">
                  <input
                    type="number"
                    placeholder="Enter commission rate"
                    autoComplete="off"
                    {...formik.getFieldProps("cashCommisionRate")}
                    className={clsx("form-control", {
                      "is-invalid":
                        formik.touched.cashCommisionRate &&
                        formik.errors.cashCommisionRate,
                    })}
                  />
                </label>

                {formik.touched.cashCommisionRate &&
                  formik.errors.cashCommisionRate && (
                    <span role="alert" className="text-danger text-xs mt-1">
                      {formik.errors.cashCommisionRate}
                    </span>
                  )}
              </div>
              <div className="flex flex-col gap-1 pb-2 w-[50%]">
                <label className="form-label text-gray-900">
                  Communication Method
                </label>
                <Select
                  value={formik.values.comms.toString()}
                  onValueChange={(value) =>
                    formik.setFieldValue("comms", Number(value))
                  }
                >
                  <SelectTrigger className="w-full">
                    <SelectValue placeholder="Select" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="0">None</SelectItem>
                    <SelectItem value="1">WhatsApp</SelectItem>
                    <SelectItem value="2">SMS</SelectItem>
                    <SelectItem value="3">Push</SelectItem>
                  </SelectContent>
                </Select>
                {formik.touched.comms && formik.errors.comms && (
                  <span color="alert" className="text-danger text-xs mt-1">
                    {formik.errors.comms}
                  </span>
                )}
              </div>
            </div>

            <div className="flex justify-start items-center gap-2">
              <div className="flex items-center gap-2">
                <label className="switch">
                  <span className="switch-label">Show All Bookings</span>
                  <input
                    type="checkbox"
                    name="showAllBookings"
                    checked={formik.values.showAllBookings}
                    onChange={(e) =>
                      formik.setFieldValue("showAllBookings", e.target.checked)
                    }
                  />
                </label>
                {formik.touched.showAllBookings &&
                  formik.errors.showAllBookings && (
                    <span role="alert" className="text-danger text-xs mt-1">
                      {formik.errors.showAllBookings}
                    </span>
                  )}
              </div>
              <div className="flex items-center gap-2">
                <label className="switch">
                  <span className="switch-label">Non Ace</span>
                  <input
                    type="checkbox"
                    name="nonAce"
                    checked={formik.values.nonAce}
                    onChange={(e) =>
                      formik.setFieldValue("nonAce", e.target.checked)
                    }
                  />
                </label>
                {formik.touched.nonAce && formik.errors.nonAce && (
                  <span role="alert" className="text-danger text-xs mt-1">
                    {formik.errors.nonAce}
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

export { EditDriver };

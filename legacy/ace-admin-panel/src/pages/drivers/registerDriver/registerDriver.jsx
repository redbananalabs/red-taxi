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
import { KeenIcon } from "@/components";
import { useFormik } from "formik";
import * as Yup from "yup";
import clsx from "clsx";
import { useRef, useState } from "react";
import { createDriver } from "../../../service/operations/driverApi";
import { useDispatch } from "react-redux";
import { refreshAllDrivers } from "../../../slices/driverSlice";
import toast from "react-hot-toast";
function RegisterDriver({ open, onOpenChange }) {
  const dispatch = useDispatch();
  const [showPassword, setShowPassword] = useState(false);
  const addLocalSchema = Yup.object().shape({
    username: Yup.string().required("User Name is required"),
    cashCommisionRate: Yup.number()
      .typeError("Commission rate must be a number")
      .required("Commission rate is required")
      .min(0, "Commission rate cannot be less than 0")
      .max(100, "Commission rate cannot be more than 100"),
  });
  const colorInputRef = useRef(null);

  const initialValues = {
    username: "",
    password: "",
    registrationNo: "",
    fullname: "",
    email: "",
    phoneNumberNumber: "",
    vehicleMake: "",
    vehicleModel: "",
    vehicleColor: "",
    role: 0,
    colorCode: "#000000",
    vehicleType: 0,
    comms: 0,
    cashCommisionRate: 0,
    showAllBookings: false,
  };

  const formik = useFormik({
    initialValues,
    validationSchema: addLocalSchema,
    onSubmit: async (values, { setSubmitting }) => {
      console.log("Submitted Values:", values);
      try {
        const response = await createDriver(values);
        if (response.status === "success") {
          dispatch(refreshAllDrivers());
          toast.success("Driver registered successfully");
          setSubmitting(false);
          onOpenChange(); // Reset Formik's submitting state
        } else {
          toast.error(response.data);
          console.error("Failed to register driver", response.data);
        }
      } catch (error) {
        console.error("Error registering driver", error);
      }
    },
  });

  const togglePassword = (event) => {
    event.preventDefault();
    setShowPassword(!showPassword);
  };
  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="max-w-[500px]">
        <DialogHeader className="border-0">
          <DialogTitle></DialogTitle>
          <DialogDescription></DialogDescription>
        </DialogHeader>
        <DialogBody className="flex flex-col items-center pt-0 pb-4">
          <h3 className="text-lg font-medium text-gray-900 text-center mb-3">
            Register Driver
          </h3>

          <form onSubmit={formik.handleSubmit} className="w-full">
            <div className="w-full flex justify-center items-center gap-2">
              <div className="flex flex-col gap-1 pb-2 w-[50%]">
                <label className="form-label text-gray-900">User Name</label>
                <label className="input">
                  <input
                    placeholder="Enter user name"
                    autoComplete="off"
                    {...formik.getFieldProps("username")}
                    className={clsx("form-control", {
                      "is-invalid":
                        formik.touched.username && formik.errors.username,
                    })}
                  />
                </label>
                {formik.touched.username && formik.errors.username && (
                  <span role="alert" className="text-danger text-xs mt-1">
                    {formik.errors.username}
                  </span>
                )}
              </div>
              <div className="flex flex-col gap-1 pb-2 w-[50%]">
                <label className="form-label text-gray-900">Password</label>
                <label className="input">
                  <input
                    type={showPassword ? "text" : "password"}
                    placeholder="Enter Password"
                    autoComplete="off"
                    {...formik.getFieldProps("password")}
                    className={clsx(
                      "form-control bg-transparent",
                      {
                        "is-invalid":
                          formik.touched.password && formik.errors.password,
                      },
                      {
                        "is-valid":
                          formik.touched.password && !formik.errors.password,
                      }
                    )}
                  />
                  <button className="btn btn-icon" onClick={togglePassword}>
                    <KeenIcon
                      icon="eye"
                      className={clsx("text-gray-500", {
                        hidden: showPassword,
                      })}
                    />
                    <KeenIcon
                      icon="eye-slash"
                      className={clsx("text-gray-500", {
                        hidden: !showPassword,
                      })}
                    />
                  </button>
                </label>
                {formik.touched.password && formik.errors.password && (
                  <span role="alert" className="text-danger text-xs mt-1">
                    {formik.errors.password}
                  </span>
                )}
              </div>
            </div>

            <div className="w-full flex justify-center items-center gap-2">
              <div className="flex flex-col gap-1 pb-2 w-full">
                <label className="form-label text-gray-900">
                  Registration Number
                </label>
                <label className="input">
                  <input
                    placeholder="Enter registration Number"
                    autoComplete="off"
                    {...formik.getFieldProps("registrationNo")}
                    className={clsx("form-control", {
                      "is-invalid":
                        formik.touched.registrationNo &&
                        formik.errors.registrationNo,
                    })}
                  />
                </label>
                {formik.touched.registrationNo &&
                  formik.errors.registrationNo && (
                    <span role="alert" className="text-danger text-xs mt-1">
                      {formik.errors.registrationNo}
                    </span>
                  )}
              </div>
              <div className="flex flex-col gap-1 pb-2 w-full">
                <label className="form-label text-gray-900">Full Name</label>
                <label className="input">
                  <input
                    placeholder="Enter fullname"
                    autoComplete="off"
                    {...formik.getFieldProps("fullname")}
                    className={clsx("form-control", {
                      "is-invalid":
                        formik.touched.fullname && formik.errors.fullname,
                    })}
                  />
                </label>
                {formik.touched.fullname && formik.errors.fullname && (
                  <span role="alert" className="text-danger text-xs mt-1">
                    {formik.errors.fullname}
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
                    placeholder="Enter phoneNumber"
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

export { RegisterDriver };

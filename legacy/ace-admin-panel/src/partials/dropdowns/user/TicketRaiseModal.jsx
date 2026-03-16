/** @format */
import {
  Dialog,
  DialogBody,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";

import { useFormik } from "formik";
import * as Yup from "yup";
import clsx from "clsx";
// import { useSelector } from "react-redux";
import toast from "react-hot-toast";
import { submitTicket } from "../../../service/operations/reportsApi";
import { useState } from "react";

function TicketRaiseModal({ open, onClose }) {
  //   const { user } = useSelector((state) => state.auth);
  //   const fullName = user?.fullName || "Guest User";
  //   const email = user?.email || "";
  const [preview, setPreview] = useState(null);
  const addLocalSchema = Yup.object().shape({
    // Changed from email to username
    subject: Yup.string().required("Subject is required"),
    message: Yup.string().required("Message is required"),
  });

  const initialValues = {
    subject: "",
    message: "",
    attachment: null,
  };

  const formik = useFormik({
    initialValues,
    validationSchema: addLocalSchema,
    onSubmit: async (values, { setSubmitting }) => {
      console.log("Submitted Values:", values);
      try {
        const formData = new FormData();
        formData.append("subject", values.subject);
        formData.append("message", values.message);

        // 🔥 Swagger-compatible behavior
        if (values.attachment) {
          formData.append("attachment", values.attachment);
        } else {
          formData.append("attachment", ""); // send empty value
        }

        const res = await submitTicket(formData);

        if (res.status === "success") {
          toast.success("Ticket sent successfully!");
          onClose();
        } else {
          toast.error(res.message || "Failed to send ticket");
        }
      } catch (error) {
        toast.error("Failed to send ticket.");
        console.error(error);
      } finally {
        setSubmitting(false);
      }
    },
  });

  return (
    <Dialog open={open} onOpenChange={onClose}>
      <DialogContent className="max-w-[500px]">
        <DialogHeader className="border-0">
          <DialogTitle></DialogTitle>
          <DialogDescription></DialogDescription>
        </DialogHeader>
        <DialogBody className="flex flex-col items-center pt-0 pb-4">
          <h3 className="text-lg font-medium text-gray-900 text-center mb-3">
            Submit Support or Feature Request
          </h3>

          <div className="flex justify-center items-start gap-4 w-full">
            <form onSubmit={formik.handleSubmit} className="w-full">
              <div className="flex flex-col gap-1 pb-2">
                <label className="form-label text-gray-900">Subject</label>
                <label className="input">
                  <input
                    placeholder="Enter subject"
                    autoComplete="off"
                    {...formik.getFieldProps("subject")}
                    className={clsx("form-control", {
                      "is-invalid":
                        formik.touched.subject && formik.errors.subject,
                    })}
                  />
                </label>
                {formik.touched.subject && formik.errors.subject && (
                  <span role="alert" className="text-danger text-xs mt-1">
                    {formik.errors.subject}
                  </span>
                )}
              </div>
              <div className="flex flex-col gap-1 pb-2">
                <label className="form-label text-gray-900">Message</label>
                <label className="">
                  <textarea
                    placeholder="Enter message"
                    rows={3}
                    autoComplete="off"
                    {...formik.getFieldProps("message")}
                    className={clsx(
                      "form-control textarea text-2sm text-gray-600 font-normal",
                      {
                        "is-invalid":
                          formik.touched.message && formik.errors.message,
                      }
                    )}
                  />
                </label>
                {formik.touched.message && formik.errors.message && (
                  <span role="alert" className="text-danger text-xs mt-1">
                    {formik.errors.message}
                  </span>
                )}
              </div>
              <div className="flex flex-col gap-1 pb-2">
                <label className="form-label text-gray-900">
                  Attachment (optional)
                </label>

                <div
                  className="border-2 border-dashed border-gray-400 bg-inherit rounded-md p-3 text-center cursor-pointer
               hover:border-blue-500 transition"
                  onDragOver={(e) => e.preventDefault()}
                  onDrop={(e) => {
                    e.preventDefault();
                    const f = e.dataTransfer.files[0];
                    if (!f) return;

                    formik.setFieldValue("attachment", f);
                    if (f.type.startsWith("image/")) {
                      setPreview(URL.createObjectURL(f));
                    } else {
                      setPreview(null);
                    }
                  }}
                >
                  {!formik.values.attachment ? (
                    <>
                      <p className="text-gray-600 text-sm font-medium">
                        Drag & Drop to Upload File
                      </p>
                      <p className="text-gray-500 text-xs my-1">OR</p>

                      <label className="btn btn-light btn-sm cursor-pointer">
                        Browse File
                        <input
                          type="file"
                          hidden
                          accept="image/*,.pdf,.doc,.docx"
                          onChange={(e) => {
                            const f = e.target.files[0];
                            if (!f) return;

                            formik.setFieldValue("attachment", f);
                            if (f.type.startsWith("image/")) {
                              setPreview(URL.createObjectURL(f));
                            } else {
                              setPreview(null);
                            }
                          }}
                        />
                      </label>
                    </>
                  ) : (
                    <div className="flex flex-col items-center">
                      {formik.values.attachment.type?.startsWith("image/") ? (
                        <img
                          src={preview}
                          alt="Preview"
                          className="w-[4.5rem] h-[4.5rem] object-cover rounded-md mb-2"
                        />
                      ) : (
                        <p className="text-gray-700 text-sm mb-2">
                          📄 {formik.values.attachment.name}
                        </p>
                      )}

                      <button
                        type="button"
                        className="btn btn-light btn-sm"
                        onClick={() => {
                          formik.setFieldValue("attachment", null);
                          setPreview(null);
                        }}
                      >
                        Remove File
                      </button>
                    </div>
                  )}
                </div>
              </div>

              <div className="flex justify-end mb-2 mt-2">
                <button className="btn btn-light" onClick={() => onClose()}>
                  Cancel
                </button>
                <button className="btn btn-primary ml-2" type="submit">
                  Send Ticket
                </button>
              </div>
            </form>
          </div>
        </DialogBody>
      </DialogContent>
    </Dialog>
  );
}

export default TicketRaiseModal;

/** @format */

import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { useDispatch, useSelector } from "react-redux"; // Import Redux hooks
import toast from "react-hot-toast";
import carlogo from "../../assets/logo.png"; // Ensure this path is correct
import { login } from "../../service/operations/authApi"; // Import login action

const LoginForm = () => {
	const [formData, setFormData] = useState({
		username: "",
		password: "",
	});

	const navigate = useNavigate();
	const dispatch = useDispatch();

	// Access loading and error state from Redux
	const { loading, error } = useSelector((state) => state.auth);

	// Handle input changes
	// Handle input changes with validation
	const handleChange = (e) => {
		const { name, value } = e.target;

		if (name === "username") {
			// ✅ Allow only numeric values, restrict length to 10
			if (!/^\d*$/.test(value)) {
				toast.error("Only numeric values (0-9) are allowed!");
				return;
			}
			if (value.length > 10) {
				toast.error("Account Number cannot exceed 10 digits!");
				return;
			}
		}

		setFormData({ ...formData, [name]: value });
	};

	// Handle form submission
	const handleSubmit = async (e) => {
		e.preventDefault();

		// Validation for empty fields
		if (!formData.username || !formData.password) {
			toast.error("All fields are required!");
			return;
		}

		// Dispatch the login action
		try {
			await dispatch(login(formData.username, formData.password, navigate));
		} catch (error) {
			toast.error("Login failed!");
		}
	};

	return (
		<div className="flex justify-center items-center min-h-screen bg-white from-white-500 to-white-800 px-4">
			<div className="w-full max-w-md bg-white shadow-lg rounded-lg overflow-hidden">
				<div className="p-6">
					{/* Logo Section */}
					<div className="flex justify-center mb-6">
						<img
							src={carlogo}
							alt="Car Logo"
							className="w-16 h-16"
						/>
					</div>

					<h2 className="text-2xl font-bold text-center text-red-700 mb-4">
						ACE TAXIS - ACCOUNT LOGIN
					</h2>

					{/* Display error message if login fails */}
					{error && (
						<p className="text-red-500 text-center mb-4">{error}</p>
					)}

					<form onSubmit={handleSubmit} className="space-y-4">
						<div>
							<label
								htmlFor="username"
								className="block text-gray-600 font-medium mb-1"
							>
								Account Number:
							</label>
							<input
								type="text"
								name="username"
								placeholder="Enter your account number"
								className="w-full p-3 bg-gray-100 border border-gray-300 rounded-lg focus:outline-none focus:ring"
								value={formData.username}
								onChange={handleChange}
								required
								pattern="\d*" // ✅ Allow only numbers on mobile keyboards
								maxLength="10" // ✅ Restrict max length to 10
							/>
						</div>

						<div>
							<label
								htmlFor="password"
								className="block text-gray-600 font-medium mb-1"
							>
								Password:
							</label>
							<input
								type="password"
								name="password"
								placeholder="Enter your password"
								className="w-full p-3 bg-gray-100 border border-gray-300 rounded-lg focus:outline-none focus:ring"
								value={formData.password}
								onChange={handleChange}
								required
							/>
						</div>

						{/* Disable button when loading */}
						<button
							type="submit"
							className="w-full bg-red-700 text-white py-3 rounded-lg font-bold hover:bg-red-800 transition duration-300"
							disabled={loading}
						>
							{loading ? "Logging in..." : "Login"}
						</button>
					</form>
				</div>
			</div>
		</div>
	);
};

export default LoginForm;

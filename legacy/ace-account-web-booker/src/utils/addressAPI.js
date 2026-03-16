/** @format */

import axios from "axios";
// import { sendLogs } from "./getLogs"; // Ensure this exists or replace with your logger

const BASE = import.meta.env.VITE_BASE_URL; // API base URL
const API_KEY = import.meta.env.VITE_GETADDRESS_KEY; // Address API key

// Helper to set headers
function setHeaders() {
  const accessToken = localStorage.getItem("authToken");
  return accessToken
    ? {
        accept: "*/*",
        Authorization: `Bearer ${accessToken}`,
        "Content-Type": "application/json",
      }
    : {};
}

// ✅ Fetch local POI (Point of Interest) suggestions
export async function getPoi(code) {
  const URL = `${BASE}/LocalPOI/GetPOI`; // ✅ Fixed URL format
  const config = { headers: setHeaders() }; // ✅ Added headers like other API calls
  const body = { searchTerm: code }; // ✅ Fixed variable syntax

  try {
    const response = await axios.post(URL, body, config);
    if (response.status >= 200 && response.status < 300) {
      return response.data; // ✅ Return fetched POI data
    } else {
      console.log("Unexpected response status:", response);
      return null;
    }
  } catch (err) {
    console.error("Error in getPoi request:", err);
    return null;
  }
}

// ✅ Fetch postcode suggestions
export async function getPostal(code) {
  const URL = `https://api.getaddress.io/v2/uk/${code}?api-key=${API_KEY}`;
  return await handleGetReq(URL);
}

// ✅ Fetch full address details
export async function getAddressDetails(id) {
  const URL = `https://api.getAddress.io/get/${id}?api-key=${API_KEY}`;
  try {
    const response = await axios.get(URL);
    const data = response.data;

    const cleanedAddress = data.formatted_address
      .filter((line) => line && line.trim())
      .join(", ");

    return {
      address: cleanedAddress,
      postcode: data.postcode || "No Postcode",
      latitude: data.latitude,
      longitude: data.longitude,
    };
  } catch (error) {
    console.error("Error fetching full address details:", error);
    return null;
  }
}

// ✅ Fetch address suggestions
// export async function getAddressSuggestions(location) {
//   const URL = `https://api.getAddress.io/autocomplete/${location}?api-key=${API_KEY}`;
//   try {
//     const autocompleteResponse = await axios.post(URL, {
//       location: { latitude: 51.0388, longitude: -2.2799 },
//     });

//     const suggestions = autocompleteResponse.data.suggestions;

//     return suggestions.map((suggestion) => ({
//       label: suggestion.address,
//       id: suggestion.id,
//       address: suggestion.address || "Unknown Address",
//     }));
//   } catch (error) {
//     console.error("Error fetching address suggestions:", error);
//     return [];
//   }
// }

export async function getAddressSuggestions(location) {
  const URL = `${BASE}/WeBooking/GetAdressSuggestions?search=${location}`;
  try {
    const autocompleteResponse = await axios.post(URL, {
      // location: { latitude: 51.0388, longitude: -2.2799 },
    });

    const suggestions = autocompleteResponse.data;

    console.log("Address Suggestions:", suggestions); // Debug log

    return Object.entries(suggestions).map(([fullAddress, id], index) => {
      // Extract postcode
      const postcodeMatch = fullAddress.match(
        /\b[A-Z]{1,2}\d{1,2}[A-Z]?\s*\d[A-Z]{2}\b/i
      );
      const postcode = postcodeMatch ? postcodeMatch[0].toUpperCase() : "";

      // Remove postcode from the address part
      let addressOnly = fullAddress;
      if (postcode) {
        addressOnly = fullAddress.replace(postcode, "").trim();
        addressOnly = addressOnly.replace(/,\s*$/, ""); // clean trailing commas
      }

      return {
        label: fullAddress, // ✅ full address shown in suggestions
        id: id || `no-id-${index}`,
        address: addressOnly || "Unknown Address",
        postcode: postcode,
      };
    });
  } catch (error) {
    console.error("Error fetching address suggestions:", error);
    return [];
  }
}

export async function getCombinedSuggestions(searchTerm) {
  try {
    // 🏎️ Step 1: Pehle getPoi() ka response lo
    const poiResults = await getPoi(searchTerm); // Local API Call

    // 🏎️ Step 2: Phir getAddressSuggestions() ka response lo
    const addressResults = await getAddressSuggestions(searchTerm); // External API Call

    // 🔀 Step 3: Dono results ko combine karo (Same Format me)
    const combinedResults = [];

    const cleanAddress = (addr) =>
      addr?.replace(/,\s*[A-Z]{1,2}\d[A-Z\d]?\s*\d[A-Z]{2}$/i, "").trim() ||
      "Unknown Address";

    // ✅ Pehle Local POI results daalo (GetAddress.io format me convert karke)
    if (poiResults) {
      poiResults.forEach((place) => {
		// clean address before setting them
        const cleanedAddress = cleanAddress(place.address);

        combinedResults.push({
          label: place.address, // ✅ GetAddress.io ke format me
          address: cleanedAddress,
          postcode: place.postcode || "N/A", // ✅ Agar postcode nahi hai toh "N/A" dikhaye
          source: "Local POI", // ✅ Yeh local API ka source hai
        });
      });
    }

    // ✅ Uske baad GetAddress.io results daalo (Same Format Maintain Rakho)
    if (addressResults) {
      addressResults.forEach((place) => {
        const cleanedAddress = cleanAddress(place.address);
        combinedResults.push({
          label: place.address, // ✅ GetAddress.io ka format same rakha
          address: cleanedAddress,
          postcode: place.postcode || "N/A",
          source: "GetAddress.io", // ✅ Yeh external API ka source hai
        });
      });
    }

    return combinedResults; // ✅ Final ordered results return
  } catch (error) {
    console.error("Error fetching combined suggestions:", error);
    return [];
  }
}

// ✅ Generic GET request handler
async function handleGetReq(URL) {
  try {
    const response = await axios.get(URL, { headers: setHeaders() });
    if (response.status >= 200 && response.status < 300) {
      return { ...response.data, status: "success" };
    } else {
      console.log("Unexpected response status:", response);
      return null;
    }
  } catch (err) {
    console.error("Error in GET request:", err);
    return {
      ...err.response,
      status: err.response?.status > 499 ? "error" : "fail",
      message: `${
        err.response?.status > 499 ? "server error" : "Failed"
      } while fetching the data`,
    };
  }
}

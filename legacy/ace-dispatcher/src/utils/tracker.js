/** @format */

import Tracker from '@openreplay/tracker';

const tracker = new Tracker({
	projectKey: import.meta.env.VITE_OPENREPLY_PROJECT_ID, // Replace with your real key
});

export default tracker;

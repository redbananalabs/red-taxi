/** @format */

export const MENU_SIDEBAR = [
	{
		title: 'Dashboards',
		icon: 'element-11',
		iconLightColor: 'text-red-400',
		iconDarkColor: 'text-red-400',
		roles: [1, 2, 3],
		path: '/',
		// children: [
		// 	{
		// 		title: 'Light Sidebar',
		// 		path: '/',
		// 	},
		// 	{
		// 		title: 'Dark Sidebar',
		// 		path: '/dark-sidebar',
		// 	},
		// ],
	},
	// Booking & Disptach
	{
		title: 'Booking & Dispatch',
		icon: 'chart-simple-3',
		iconLightColor: 'text-blue-300',
		iconDarkColor: 'text-blue-300',
		roles: [1, 2, 3],
		path: '/bookings/booking-dispatch',
	},
	{
		title: 'Tracking',
		icon: 'focus',
		iconLightColor: 'text-cyan-400',
		iconDarkColor: 'text-cyan-400',
		roles: [1, 2, 3],
		path: '/booking/driver-tracking',
	},
	{
		title: 'Availability',
		icon: 'chart-simple-3',
		iconLightColor: 'text-green-400',
		iconDarkColor: 'text-green-400',
		roles: [1, 2, 3],
		path: '/booking/availability',
	},
	{
		title: 'Availability Logs',
		icon: 'graph',
		iconLightColor: 'text-purple-400',
		iconDarkColor: 'text-purple-400',
		roles: [1, 2, 3],
		path: '/booking/availability-logs',
	},

	{
		title: 'Local POIs',
		icon: 'geolocation',
		iconLightColor: 'text-green-400',
		iconDarkColor: 'text-green-400',
		roles: [1, 2, 3],
		path: '/localPOIs/list-local-Poi',
	},
	{
		title: 'Bookings',
		icon: 'car',
		iconLightColor: 'text-orange-400',
		iconDarkColor: 'text-orange-400',
		roles: [1, 2, 3],
		children: [
			{
				title: 'Web Bookings',
				children: [
					{
						title: 'All Web Requests',
						path: '/bookings/web-booking',
						roles: [1, 2, 3],
					},
					{
						title: 'Amendment Requests',
						path: '/bookings/amend-booking',
						roles: [1, 2, 3],
					},
					{
						title: 'Accepted Requests',
						path: '/bookings/accept-booking',
						roles: [1, 2, 3],
					},
					{
						title: 'Rejected Requests',
						path: '/bookings/reject-booking',
						roles: [1, 2, 3],
					},
				],
			},
			{
				title: 'Global Search',
				path: '/bookings/global-search',
				roles: [1, 2, 3],
			},
			{
				title: 'Audit View',
				path: '/bookings/audit-view',
				roles: [1],
			},

			{
				title: 'Card Bookings',
				path: '/bookings/card-bookings',
				roles: [1],
			},
			{
				title: 'Cancel Range',
				path: '/bookings/cancelbyrange',
				roles: [1],
			},
			{
				title: 'Cancel Range Report',
				path: '/bookings/cancelbyrangereport',
				roles: [1],
			},

			// {
			// 	title: 'More',
			// 	collapse: true,
			// 	collapseTitle: 'Show less',
			// 	expandTitle: 'Show 3 more',
			// 	dropdownProps: {
			// 		placement: 'right-start',
			// 	},
			// 	children: [
			// 		{
			// 			title: 'Campaigns - Card',
			// 			path: '/public-profile/campaigns/card',
			// 		},
			// 		{
			// 			title: 'Campaigns - List',
			// 			path: '/public-profile/campaigns/list',
			// 		},
			// 		{
			// 			title: 'Empty',
			// 			path: '/public-profile/empty',
			// 		},
			// 	],
			// },
		],
	},
	{
		title: 'Accounts',
		icon: 'book-open',
		iconLightColor: 'text-blue-400',
		iconDarkColor: 'text-blue-400',
		roles: [1],
		path: '/accounts/list-account',
	},
	{
		title: 'Driver',
		icon: 'users',
		iconLightColor: 'text-cyan-400',
		iconDarkColor: 'text-cyan-400',
		roles: [1],
		children: [
			{ title: 'Driver List', path: '/drivers/list-driver', roles: [1] },
			{ title: `Expiry's`, path: '/drivers/expires', roles: [1] },
		],
	},

	{
		title: 'Tariffs',
		icon: 'simcard',
		iconLightColor: 'text-purple-400',
		iconDarkColor: 'text-purple-400',
		roles: [1],
		path: '/tariffs',
	},
	{
		title: 'Account Tariffs',
		icon: 'badge',
		iconLightColor: 'text-orange-400',
		iconDarkColor: 'text-orange-400',
		roles: [1],
		path: '/accountTariffs',
	},
	{
		title: 'Billing & Payments',
		icon: 'bitcoin',
		iconLightColor: 'text-yellow-400',
		iconDarkColor: 'text-yellow-400',
		roles: [1],
		children: [
			{
				title: 'Driver',
				roles: [1],
				children: [
					{
						title: 'Statement Processing',
						path: '/billing/driver/statement-processing',
						roles: [1],
					},
					{
						title: 'Statement History',
						path: '/billing/driver/statement-history',
						roles: [1],
					},
					// {
					// 	title: '2FA',
					// 	path: '/auth/2fa',
					// },
					// {
					// 	title: 'Check Email',
					// 	path: '/auth/check-email',
					// },
					// {
					// 	title: 'Reset Password',
					// 	children: [
					// 		{
					// 			title: 'Enter Email',
					// 			path: '/auth/reset-password/enter-email',
					// 		},
					// 		{
					// 			title: 'Check Email',
					// 			path: '/auth/reset-password/check-email',
					// 		},
					// 		{
					// 			title: 'Change Password',
					// 			path: '/auth/reset-password/change',
					// 		},
					// 		{
					// 			title: 'Password Changed',
					// 			path: '/auth/reset-password/changed',
					// 		},
					// 	],
					// },
				],
			},
			{
				title: 'Account',
				roles: [1],
				children: [
					{
						title: 'Invoice Processor',
						path: '/billing/account/invoice-processor',
						roles: [1],
					},
					{
						title: 'Invoice Processor (Grp)',
						path: '/billing/account/invoice-processor-grp',
						roles: [1],
					},
					{
						title: 'Invoice History',
						path: '/billing/account/invoice-history',
						roles: [1],
					},
					{
						title: 'Credit Invoice',
						path: '/billing/account/credit-invoice',
						roles: [1],
					},
					{
						title: 'Credit Journeys',
						path: '/billing/account/credit-journeys',
						roles: [1],
					},
					{
						title: 'Credit Notes',
						path: '/billing/account/credit-notes',
						roles: [1],
					},
					// {
					// 	title: 'Check Email',
					// 	path: '/auth/check-email',
					// },
					// {
					// 	title: 'Reset Password',
					// 	children: [
					// 		{
					// 			title: 'Enter Email',
					// 			path: '/auth/reset-password/enter-email',
					// 		},
					// 		{
					// 			title: 'Check Email',
					// 			path: '/auth/reset-password/check-email',
					// 		},
					// 		{
					// 			title: 'Change Password',
					// 			path: '/auth/reset-password/change',
					// 		},
					// 		{
					// 			title: 'Password Changed',
					// 			path: '/auth/reset-password/changed',
					// 		},
					// 	],
					// },
				],
			},
			{
				title: 'Vat Outputs',
				path: '/billing/vat-outputs',
				roles: [1],
			},
		],
	},
	{
		title: 'Reports',
		icon: 'ranking',
		iconLightColor: 'text-green-400',
		iconDarkColor: 'text-green-400',
		roles: [1, 2, 3],
		children: [
			{
				title: 'Driver Reports',
				roles: [1],
				children: [
					{
						title: 'Availability Report',
						roles: [1],
						path: '/booking/availability-report',
					},
					{
						title: 'Expenses Report',
						roles: [1],
						path: '/driver-expenses',
					},
					{
						title: 'Earning Report',
						roles: [1, 3],
						path: '/driver-earning-report',
					},
				],
			},
			{
				title: 'Bookings',
				roles: [1, 2, 3],
				children: [
					{
						title: 'Turndown History',
						path: '/bookings/turndown',
						roles: [1, 2, 3],
					},
					{
						title: 'Airport Runs',
						path: '/bookings/airport-runs',
						roles: [1, 2, 3],
					},
					{
						title: 'Duplicate Bookings',
						path: '/bookings/duplicate-bookings',
						roles: [1, 2, 3],
					},
					{
						title: 'Count By Scope',
						path: '/bookings/count-by-scope',
						roles: [1, 2, 3],
					},
					{
						title: 'Top Customer',
						path: '/bookings/top-customer',
						roles: [1],
					},
					{
						title: 'Pickups By Postcode',
						path: '/bookings/pickups-by-postcode',
						roles: [1, 2, 3],
					},

					{
						title: 'By Vehicle Type',
						path: '/bookings/by-vehicle-type',
						roles: [1, 2, 3],
					},
					{
						title: 'Average Duration',
						path: '/bookings/average-duration',
						roles: [1, 2, 3],
					},
					{
						title: 'Growth By Period',
						path: '/bookings/growth-by-period',
						roles: [1],
					},
				],
			},
			{
				title: 'Financial',
				roles: [1],
				children: [
					{
						title: 'Payouts By Month',
						path: '/financial/payouts-by-month',
						roles: [1],
					},
					{
						title: 'Revenue By Month',
						path: '/financial/revenue-by-month',
						roles: [1],
					},
					{
						title: 'Profitability On Invoice',
						path: '/financial/profitability-on-invoice',
						roles: [1],
					},
					{
						title: 'Total Profitability By Period',
						path: '/financial/total-profitability-by-period',
						roles: [1],
					},
					{
						title: 'Profitability By DateRange',
						path: '/financial/profitability-by-date-range',
						roles: [1],
					},
					{
						title: 'QR Code Adverts',
						path: '/financial/qr-code-adverts',
						roles: [1],
					},
				],
			},
		],
	},

	{
		title: 'Company Settings',
		icon: 'setting-3',
		iconLightColor: 'text-blue-400',
		iconDarkColor: 'text-blue-400',
		roles: [1],
		path: '/setting/company-settings',
	},

	{
		title: 'Message Settings',
		icon: 'social-media',
		iconLightColor: 'text-cyan-400',
		iconDarkColor: 'text-cyan-400',
		roles: [1],
		path: '/setting/msg-settings',
	},
	{
		title: 'Utilities',
		icon: 'abstract-26',
		iconLightColor: 'text-yellow-400',
		iconDarkColor: 'text-yellow-400',
		roles: [1],
		children: [
			{
				title: 'HVS Account Changes',
				path: '/utilities/hvs-account-changes',
				roles: [1],
			},
		],
	},
	// {
	// 	title: 'Settings',
	// 	icon: 'setting-2',
	// 	children: [
	// 		{
	// 			title: 'Company Settings',
	// 			path: '/setting/company-settings',
	// 		},
	// 		{
	// 			title: 'Message Settings',
	// 			path: '/setting/msg-settings',
	// 		},
	// 	],
	// },
];
export const MENU_MEGA = [
	{
		// title: 'Home',
		// path: '/',
	},
	{
		// title: 'Profiles',
		children: [
			{
				title: 'Profiles',
				children: [
					{
						children: [
							{
								title: 'Default',
								icon: 'badge',
								path: '/public-profile/profiles/default',
							},
							{
								title: 'Creator',
								icon: 'coffee',
								path: '/public-profile/profiles/creator',
							},
							{
								title: 'Company',
								icon: 'abstract-41',
								path: '/public-profile/profiles/company',
							},
							{
								title: 'NFT',
								icon: 'bitcoin',
								path: '/public-profile/profiles/nft',
							},
							{
								title: 'Blogger',
								icon: 'message-text',
								path: '/public-profile/profiles/blogger',
							},
							{
								title: 'CRM',
								icon: 'devices',
								path: '/public-profile/profiles/crm',
							},
							{
								title: 'Gamer',
								icon: 'ghost',
								path: '/public-profile/profiles/gamer',
							},
						],
					},
					{
						children: [
							{
								title: 'Feeds',
								icon: 'book',
								path: '/public-profile/profiles/feeds',
							},
							{
								title: 'Plain',
								icon: 'files',
								path: '/public-profile/profiles/plain',
							},
							{
								title: 'Modal',
								icon: 'mouse-square',
								path: '/public-profile/profiles/modal',
							},
							{
								title: 'Freelancer',
								icon: 'financial-schedule',
								path: '#',
								disabled: true,
							},
							{
								title: 'Developer',
								icon: 'technology-4',
								path: '#',
								disabled: true,
							},
							{
								title: 'Team',
								icon: 'users',
								path: '#',
								disabled: true,
							},
							{
								title: 'Events',
								icon: 'calendar-tick',
								path: '#',
								disabled: true,
							},
						],
					},
				],
			},
			{
				title: 'Other Pages',
				children: [
					{
						children: [
							{
								title: 'Projects - 3 Columns',
								icon: 'element-6',
								path: '/public-profile/projects/3-columns',
							},
							{
								title: 'Projects - 2 Columns',
								icon: 'element-4',
								path: '/public-profile/projects/2-columns',
							},
							{
								title: 'Works',
								icon: 'office-bag',
								path: '/public-profile/works',
							},
							{
								title: 'Teams',
								icon: 'people',
								path: '/public-profile/teams',
							},
							{
								title: 'Network',
								icon: 'icon',
								path: '/public-profile/network',
							},
							{
								title: 'Activity',
								icon: 'chart-line-up-2',
								path: '/public-profile/activity',
							},
							{
								title: 'Campaigns - Card',
								icon: 'element-11',
								path: '/public-profile/campaigns/card',
							},
						],
					},
					{
						children: [
							{
								title: 'Campaigns - List',
								icon: 'kanban',
								path: '/public-profile/campaigns/list',
							},
							{
								title: 'Empty',
								icon: 'file-sheet',
								path: '/public-profile/empty',
							},
							{
								title: 'Documents',
								icon: 'document',
								path: '#',
								disabled: true,
							},
							{
								title: 'Badges',
								icon: 'award',
								path: '#',
								disabled: true,
							},
							{
								title: 'Awards',
								icon: 'gift',
								path: '#',
								disabled: true,
							},
						],
					},
				],
			},
		],
	},
	{
		// title: 'My Account',
		children: [
			{
				title: 'General Pages',
				children: [
					{
						title: 'Integrations',
						icon: 'technology-2',
						path: '/account/integrations',
					},
					{
						title: 'Notifications',
						icon: 'notification-1',
						path: '/account/notifications',
					},
					{
						title: 'API Keys',
						icon: 'key',
						path: '/account/api-keys',
					},
					{
						title: 'Appearance',
						icon: 'eye',
						path: '/account/appearance',
					},
					{
						title: 'Invite a Friend',
						icon: 'user-tick',
						path: '/account/invite-a-friend',
					},
					{
						title: 'Activity',
						icon: 'support',
						path: '/account/activity',
					},
					{
						title: 'Brand',
						icon: 'verify',
						disabled: true,
					},
					{
						title: 'Get Paid',
						icon: 'euro',
						disabled: true,
					},
				],
			},
			{
				title: 'Other pages',
				children: [
					{
						title: 'Account Home',
						children: [
							{
								title: 'Get Started + ',
								path: '/account/home/get-started',
							},
							{
								title: 'User Profile',
								path: '/account/home/user-profile',
							},
							{
								title: 'Company Profile',
								path: '/account/home/company-profile',
							},
							{
								title: 'With Sidebar',
								path: '/account/home/settings-sidebar',
							},
							{
								title: 'Enterprise',
								path: '/account/home/settings-enterprise',
							},
							{
								title: 'Plain',
								path: '/account/home/settings-plain',
							},
							{
								title: 'Modal',
								path: '/account/home/settings-modal',
							},
						],
					},
					{
						title: 'Billing',
						children: [
							{
								title: 'Basic Billing',
								path: '/account/billing/basic',
							},
							{
								title: 'Enterprise',
								path: '/account/billing/enterprise',
							},
							{
								title: 'Plans',
								path: '/account/billing/plans',
							},
							{
								title: 'Billing History',
								path: '/account/billing/history',
							},
							{
								title: 'Tax Info',
								disabled: true,
							},
							{
								title: 'Invoices',
								disabled: true,
							},
							{
								title: 'Gateaways',
								disabled: true,
							},
						],
					},
					{
						title: 'Security',
						children: [
							{
								title: 'Get Started',
								path: '/account/security/get-started',
							},
							{
								title: 'Security Overview',
								path: '/account/security/overview',
							},
							{
								title: 'IP Addresses',
								path: '/account/security/allowed-ip-addresses',
							},
							{
								title: 'Privacy Settings',
								path: '/account/security/privacy-settings',
							},
							{
								title: 'Device Management',
								path: '/account/security/device-management',
							},
							{
								title: 'Backup & Recovery',
								path: '/account/security/backup-and-recovery',
							},
							{
								title: 'Current Sessions',
								path: '/account/security/current-sessions',
							},
							{
								title: 'Security Log',
								path: '/account/security/security-log',
							},
						],
					},
					{
						title: 'Members & Roles',
						children: [
							{
								title: 'Teams Starter',
								path: '/account/members/team-starter',
							},
							{
								title: 'Teams',
								path: '/account/members/teams',
							},
							{
								title: 'Team Info',
								path: '/account/members/team-info',
							},
							{
								title: 'Members Starter',
								path: '/account/members/members-starter',
							},
							{
								title: 'Team Members',
								path: '/account/members/team-members',
							},
							{
								title: 'Import Members',
								path: '/account/members/import-members',
							},
							{
								title: 'Roles',
								path: '/account/members/roles',
							},
							{
								title: 'Permissions - Toggler',
								path: '/account/members/permissions-toggle',
							},
							{
								title: 'Permissions - Check',
								path: '/account/members/permissions-check',
							},
						],
					},
					{
						title: 'Other Pages',
						children: [
							{
								title: 'Integrations',
								path: '/account/integrations',
							},
							{
								title: 'Notifications',
								path: '/account/notifications',
							},
							{
								title: 'API Keys',
								path: '/account/api-keys',
							},
							{
								title: 'Appearance',
								path: '/account/appearance',
							},
							{
								title: 'Invite a Friend',
								path: '/account/invite-a-friend',
							},
							{
								title: 'Activity',
								path: '/account/activity',
							},
						],
					},
				],
			},
		],
	},
	{
		// title: 'Network',
		children: [
			{
				title: 'General Pages',
				children: [
					{
						title: 'Get Started',
						icon: 'flag',
						path: '/network/get-started',
					},
					{
						title: 'Colleagues',
						icon: 'users',
						path: '#',
						disabled: true,
					},
					{
						title: 'Donators',
						icon: 'heart',
						path: '#',
						disabled: true,
					},
					{
						title: 'Leads',
						icon: 'abstract-21',
						path: '#',
						disabled: true,
					},
				],
			},
			{
				title: 'Other pages',
				children: [
					{
						title: 'User Cards',
						children: [
							{
								title: 'Mini Cards',
								path: '/network/user-cards/mini-cards',
							},
							{
								title: 'Team Members',
								path: '/network/user-cards/team-crew',
							},
							{
								title: 'Authors',
								path: '/network/user-cards/author',
							},
							{
								title: 'NFT Users',
								path: '/network/user-cards/nft',
							},
							{
								title: 'Social Users',
								path: '/network/user-cards/social',
							},
							{
								title: 'Gamers',
								path: '#',
								disabled: true,
							},
						],
					},
					{
						title: 'User Base',
						badge: 'Datatables',
						children: [
							{
								title: 'Team Crew',
								path: '/network/user-table/team-crew',
							},
							{
								title: 'App Roster',
								path: '/network/user-table/app-roster',
							},
							{
								title: 'Market Authors',
								path: '/network/user-table/market-authors',
							},
							{
								title: 'SaaS Users',
								path: '/network/user-table/saas-users',
							},
							{
								title: 'Store Clients',
								path: '/network/user-table/store-clients',
							},
							{
								title: 'Visitors',
								path: '/network/user-table/visitors',
							},
						],
					},
				],
			},
		],
	},
	{
		// title: 'Authentication',
		children: [
			{
				title: 'General pages',
				children: [
					{
						title: 'Classic Layout',
						children: [
							{
								title: 'Sign In',
								path: '/auth/login',
							},
							{
								title: 'Sign Up',
								path: '/auth/signup',
							},
							{
								title: '2FA',
								path: '/auth/2fa',
							},
							{
								title: 'Check Email',
								path: '/auth/check-email',
							},
							{
								title: 'Reset Password',
								children: [
									{
										title: 'Enter Email',
										path: '/auth/reset-password/enter-email',
									},
									{
										title: 'Check Email',
										path: '/auth/reset-password/check-email',
									},
									{
										title: 'Change Password',
										path: '/auth/reset-password/change',
									},
									{
										title: 'Password is Changed',
										path: '/auth/reset-password/changed',
									},
								],
							},
						],
					},
					// {
					// 	title: 'Branded Layout',
					// 	children: [
					// 		{
					// 			title: 'Sign In',
					// 			path: '/auth/login',
					// 		},
					// 		{
					// 			title: 'Sign Up',
					// 			path: '/auth/signup',
					// 		},
					// 		{
					// 			title: '2FA',
					// 			path: '/auth/2fa',
					// 		},
					// 		{
					// 			title: 'Check Email',
					// 			path: '/auth/check-email',
					// 		},
					// 		{
					// 			title: 'Reset Password',
					// 			children: [
					// 				{
					// 					title: 'Enter Email',
					// 					path: '/auth/reset-password/enter-email',
					// 				},
					// 				{
					// 					title: 'Check Email',
					// 					path: '/auth/reset-password/check-email',
					// 				},
					// 				{
					// 					title: 'Change Password',
					// 					path: '/auth/reset-password/change',
					// 				},
					// 				{
					// 					title: 'Password is Changed',
					// 					path: '/auth/reset-password/changed',
					// 				},
					// 			],
					// 		},
					// 	],
					// },
				],
			},
			{
				title: 'Other Pages',
				children: [
					{
						title: 'Welcome Message',
						icon: 'like-2',
						path: '/auth/welcome-message',
					},
					{
						title: 'Account Deactivated',
						icon: 'shield-cross',
						path: '/auth/account-deactivated',
					},
					{
						title: 'Error 404',
						icon: 'message-question',
						path: '/error/404',
					},
					{
						title: 'Error 500',
						icon: 'information',
						path: '/error/500',
					},
				],
			},
		],
	},
	{
		// title: 'Help',
		children: [
			{
				title: 'Getting Started',
				icon: 'coffee',
				path: 'https://keenthemes.com/metronic/tailwind/docs/getting-started/installation',
			},
			{
				title: 'Support Forum',
				icon: 'information',
				children: [
					{
						title: 'All Questions',
						icon: 'questionnaire-tablet',
						path: 'https://devs.keenthemes.com',
					},
					{
						title: 'Popular Questions',
						icon: 'star',
						path: 'https://devs.keenthemes.com/popular',
					},
					{
						title: 'Ask Question',
						icon: 'message-question',
						path: 'https://devs.keenthemes.com/question/create',
					},
				],
			},
			{
				title: 'Licenses & FAQ',
				tooltip: {
					title: 'Learn more about licenses',
					placement: 'right',
				},
				icon: 'subtitle',
				path: 'https://keenthemes.com/metronic/tailwind/docs/getting-started/license',
			},
			{
				title: 'Documentation',
				icon: 'questionnaire-tablet',
				path: 'https://keenthemes.com/metronic/tailwind/docs',
			},
			{
				separator: true,
			},
			{
				title: 'Contact Us',
				icon: 'share',
				path: 'https://keenthemes.com/contact',
			},
		],
	},
];
export const MENU_ROOT = [
	{
		title: 'Public Profile',
		icon: 'profile-circle',
		rootPath: '/public-profile/',
		path: 'public-profile/profiles/default',
		childrenIndex: 2,
	},
	{
		title: 'Account',
		icon: 'setting-2',
		rootPath: '/account/',
		path: '/',
		childrenIndex: 3,
	},
	{
		title: 'Network',
		icon: 'users',
		rootPath: '/network/',
		path: 'network/get-started',
		childrenIndex: 4,
	},
	{
		title: 'Authentication',
		icon: 'security-user',
		rootPath: '/authentication/',
		path: 'authentication/get-started',
		childrenIndex: 5,
	},
];

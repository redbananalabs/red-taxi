// `Link` component React Router se aata hai, jo SPA (Single Page Application) ke andar navigation ke liye use hota hai
import { Link } from 'react-router-dom';

// `KeenIcon` ek custom icon component hai jo icons render karne ke liye use hota hai
import { KeenIcon } from '@/components/keenicons';

// `toAbsoluteUrl` ek utility function hai jo relative URL ko absolute URL me convert karta hai
import { toAbsoluteUrl } from '@/utils';

// `useDemo1Layout` ek custom hook hai jo layout se related state aur functions provide karta hai
import { useDemo1Layout } from '../';

// HeaderLogo component define ho raha hai
const HeaderLogo = () => {
	// `useDemo1Layout` hook se layout ki state aur functions le rahe hain
	const {
		setMobileSidebarOpen, // Mobile sidebar open karne ke liye function
		setMobileMegaMenuOpen, // Mobile mega menu open karne ke liye function
		megaMenuEnabled, // Mega menu enabled hai ya nahi, yeh boolean value
	} = useDemo1Layout();

	// Function jo mobile sidebar ko open karega
	const handleSidebarOpen = () => {
		setMobileSidebarOpen(true);
	};

	// Function jo mobile mega menu ko open karega
	const handleMegaMenuOpen = () => {
		setMobileMegaMenuOpen(true);
	};

	// JSX return ho raha hai
	return (
		<div className='flex gap-1 lg:hidden items-center -ms-1'>
			{/* Logo ka link jo home page `/` par le jayega */}
			<Link
				to='/'
				className='shrink-0'
			>
				{/* Mini Logo image, jo `/media/app/mini-logo.svg` se load ho rahi hai */}
				<img
					src={toAbsoluteUrl('/media/app/mini-logo.svg')}
					className='max-h-[25px] w-full'
					alt='mini-logo'
				/>
			</Link>

			{/* Buttons ko wrap karne ke liye ek div */}
			<div className='flex items-center'>
				{/* Sidebar open karne ke liye button */}
				<button
					type='button'
					className='btn btn-icon btn-light btn-clear btn-sm'
					onClick={handleSidebarOpen}
				>
					<KeenIcon icon='menu' />
				</button>

				{/* Agar `megaMenuEnabled` true hai, tab hi ye button dikhayega */}
				{megaMenuEnabled && (
					<button
						type='button'
						className='btn btn-icon btn-light btn-clear btn-sm'
						onClick={handleMegaMenuOpen}
					>
						{/* Mega menu button ke andar ek `burger-menu-2` icon */}
						<KeenIcon icon='burger-menu-2' />
					</button>
				)}
			</div>
		</div>
	);
};

// Component ko export kar rahe hain taki isko dusre components me use kiya ja sake
export { HeaderLogo };

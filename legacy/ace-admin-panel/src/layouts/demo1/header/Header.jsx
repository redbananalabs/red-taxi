/** @format */

// `clsx` ek utility hai jo conditional classnames ko manage karne ke liye use hoti hai
import clsx from 'clsx';

// `useEffect` ek React ka hook hai jo side-effects handle karne ke liye use hota hai
import { useEffect } from 'react';

// `Container` ek custom component hai jo header ka layout define karta hai
// import { Container } from '@/components/container';

// `MegaMenu` ek navigation menu hai jo header me dikhai deta hai
import { MegaMenu } from '../mega-menu';

// `HeaderLogo` aur `HeaderTopbar` header ke andar ke components hain
import { HeaderLogo, HeaderTopbar } from './';

// `Breadcrumbs` ek navigation indicator hai, aur `useDemo1Layout` ek custom hook hai
import { Breadcrumbs, useDemo1Layout } from '../';

// `useLocation` React Router se aata hai, jo current page ka URL (`pathname`) fetch karta hai
import { useLocation } from 'react-router';

// Header component define kiya gaya hai
const Header = () => {
	// `useDemo1Layout` ek custom hook hai jo header ke layout properties provide karta hai
	const { headerSticky } = useDemo1Layout();

	// `useLocation` ka use karke hum current page ka path (`pathname`) le rahe hain
	const { pathname } = useLocation();

	// `useEffect` ka use header ke sticky behavior ko handle karne ke liye ho raha hai
	useEffect(() => {
		if (headerSticky) {
			// Agar `headerSticky` true hai, toh body attribute set ho jayega
			document.body.setAttribute('data-sticky-header', 'on');
		} else {
			// Agar `headerSticky` false hai, toh attribute remove kar diya jayega
			document.body.removeAttribute('data-sticky-header');
		}
	}, [headerSticky]); // Dependency array me `headerSticky`, jisse jab bhi yeh change ho, effect trigger ho

	// Header ka JSX return ho raha hai
	return (
		<header
			className={clsx(
				'header fixed top-0 z-10 start-0 end-0 flex items-stretch shrink-0 bg-[--tw-page-bg] dark:bg-[--tw-page-bg-dark]',
				headerSticky && 'shadow-sm' // Agar `headerSticky` true ho, toh shadow apply hoga
			)}
		>
			{/* Container component jo flexbox layout maintain karega */}
			<div className='pe-[1.875rem] ps-[1.875rem] ms-auto me-auto max-w-[1850px] w-full flex justify-between items-stretch lg:gap-4'>
				{/* Header ka logo */}
				<HeaderLogo />

				{/* Agar pathname `/account` include karta hai toh `Breadcrumbs` dikhaye, warna `MegaMenu` */}
				{pathname.includes('/profile') ? <Breadcrumbs /> : <MegaMenu />}

				{/* Header ka topbar (search, user icon, etc. ho sakte hain) */}
				<HeaderTopbar />
			</div>
		</header>
	);
};

// Header component export kiya gaya hai taki isko doosre components me use kiya ja sake
export { Header };

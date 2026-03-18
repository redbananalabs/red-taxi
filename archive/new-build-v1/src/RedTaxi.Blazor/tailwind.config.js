/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './Components/**/*.{razor,html,cshtml}',
    './wwwroot/**/*.{html,js}'
  ],
  darkMode: 'class',
  theme: {
    extend: {
      colors: {
        base: '#0B0D11',
        surface: '#12151B',
        card: '#1A1E27',
        elevated: '#242934',
        hover: '#2E3440',
        brand: {
          300: '#FF6B6B',
          500: '#FF2D2D',
          600: '#E62626',
        },
        primary: '#F1F2F4',
        secondary: '#9CA3AF',
        muted: '#6B7280',
        status: {
          available: '#34D399',
          'on-job': '#FBBF24',
          dispatched: '#A78BFA',
          offline: '#FF6B6B',
          'on-break': '#38BDF8',
        },
        booking: {
          unallocated: '#FBBF24',
          allocated: '#A78BFA',
          accepted: '#34D399',
          completed: '#38BDF8',
          cancelled: '#FF6B6B',
        }
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
        mono: ['JetBrains Mono', 'Cascadia Code', 'monospace'],
      },
      borderRadius: {
        card: '4px',
        btn: '6px',
        modal: '8px',
      }
    }
  },
  plugins: []
};

/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './src/pages/**/*.{js,ts,jsx,tsx}',    // Include all files in src/pages
    './src/components/**/*.{js,ts,jsx,tsx}', // Include all files in src/components
    './src/app/**/*.{js,ts,jsx,tsx}',      // Include all files in src/app (if you're using the app directory in Next.js 13+)
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}
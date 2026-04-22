/** @type {import('tailwindcss').Config} */
module.exports = {
  darkMode: "class",
  content: [
    "./_includes/**/*.html",
    "./_layouts/**/*.html",
    "./assets/js/**/*.js",
    "../docs/**/*.{html,md}",
    "!../docs/_site/**",
    "!../docs/vendor/**",
    "!../docs/node_modules/**",
  ],
  theme: {
    extend: {
      colors: {
        // Theme colors
        theme: {
          dark: "#090a0b", // coolblack
          grey: "#353535", // spacegrey
          light: "#ffffff", // snowwhite
        },
        // Brand colors
        brand: {
          primary: "#ff5100", // orangered
          accent: "#f2cb05", // greatgold
          secondary: "#389092", // greenblue
        },
      },
      spacing: {
        "content-width": "920px",
      },
      maxWidth: {
        content: "920px",
      },
      fontSize: {
        xs: "0.75rem",
        sm: "0.875rem",
        base: "1rem",
        lg: "1.125rem",
        xl: "1.25rem",
        "2xl": "1.5rem",
        "3xl": "1.875rem",
        "4xl": "2.25rem",
      },
    },
  },
  plugins: [require("@tailwindcss/typography")],
};

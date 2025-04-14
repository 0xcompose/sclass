import { defineConfig } from "eslint/config"
import eslint from "@eslint/js"
import tseslint from "typescript-eslint"

export default defineConfig([
	// { files: ["**/*.{js,mjs,cjs,ts}"] },
	// {
	// 	files: ["**/*.{js,mjs,cjs,ts}"],
	// 	languageOptions: { globals: globals.browser },
	// },
	// {
	// 	files: ["**/*.{js,mjs,cjs,ts}"],
	// 	plugins: { js },
	// 	extends: ["js/recommended"],
	// },
	eslint.configs.recommended,
	{
		ignores: ["bin", "node_modules"],
	},
	tseslint.configs.recommendedTypeChecked,
	{
		languageOptions: {
			parserOptions: {
				projectService: true,
				tsconfigRootDir: import.meta.dirname,
			},
		},
		ignores: ["bin", "node_modules"],
	},
])

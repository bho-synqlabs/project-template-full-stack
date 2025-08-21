import tseslint from 'typescript-eslint';
import reactX from 'eslint-plugin-react-x';
import reactDom from 'eslint-plugin-react-dom';
import { globalIgnores } from 'eslint/config';

export default tseslint.config([
	globalIgnores(['dist']),
	{
		files: ['**/*.{ts,tsx}'],
		extends: [
			...tseslint.configs.recommendedTypeChecked,
			reactX.configs['recommended-typescript'], // Enable lint rules for React
			reactDom.configs.recommended, // Enable lint rules for React DOM
		],
		languageOptions: {
			parserOptions: {
				project: ['./tsconfig.node.json', './tsconfig.app.json'],
				tsconfigRootDir: import.meta.dirname,
			},
		},
		rules: {
			'check-file/filename-naming-convention': [
				'error',
				{
					'**/*.{ts,tsx}': 'KEBAB_CASE',
				},
				{
					// ignore the middle extensions of the filename to support filename like bable.config.js or smoke.spec.ts
					ignoreMiddleExtensions: true,
				},
			],
			'check-file/folder-naming-convention': [
				'error',
				{
					// all folders within src (except __tests__)should be named in kebab-case
					'src/**/!(__tests__)': 'KEBAB_CASE',
				},
			],
		},
	},
]);

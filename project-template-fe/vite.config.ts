import react from '@vitejs/plugin-react-swc';
import { resolve } from 'path';
import { defineConfig } from 'vite';

export default defineConfig({
	base: './',
	plugins: [react()],
	server: {
		port: 3000,
	},
	preview: {
		port: 3000,
	},

	optimizeDeps: { exclude: ['fsevents'] },
	build: {
		rollupOptions: {
			external: ['fs/promises'],
			output: {
				experimentalMinChunkSize: 3500,
			},
		},
	},
	resolve: {
		alias: {
			'@': resolve(__dirname, './src'),
		},
	},
});

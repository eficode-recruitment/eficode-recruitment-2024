import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react({
    jsxRuntime: 'classic',
  })],
  server: {
    host: process.env.HOST || '0.0.0.0',
    port: process.env.PORT || 8000,
  },
  envDir: '../',
});

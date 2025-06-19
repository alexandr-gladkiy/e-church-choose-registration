import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

export default defineConfig({
  plugins: [vue()],
  server: {
    port: 3002,
    open: true,
    proxy: {
      '/api': {
        target: process.env.BACKEND_API_URL || 'http://backend-api:4000',
        changeOrigin: true
      }
    }
  }
}) 
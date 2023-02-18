import { defineConfig } from 'vite';
import glslify from 'rollup-plugin-glslify';

export default defineConfig({
  base: "/base_url/",
  plugins: [glslify()]
});
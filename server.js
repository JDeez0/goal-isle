const http = require('http');
const fs = require('fs');
const path = require('path');

const PORT = 3003;
const BUILD_DIR = path.join(__dirname, 'build', 'web');

console.log(`Starting server on port ${PORT}`);
console.log(`Serving files from: ${BUILD_DIR}`);

// MIME types for common file extensions
const MIME_TYPES = {
  '.html': 'text/html',
  '.js': 'application/javascript',
  '.css': 'text/css',
  '.json': 'application/json',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.gif': 'image/gif',
  '.svg': 'image/svg+xml',
  '.ico': 'image/x-icon',
  '.woff': 'font/woff',
  '.woff2': 'font/woff2',
  '.ttf': 'font/ttf',
  '.otf': 'font/otf',
  '.eot': 'application/vnd.ms-fontobject'
};

function getMimeType(filePath) {
  const ext = path.extname(filePath).toLowerCase();
  return MIME_TYPES[ext] || 'application/octet-stream';
}

const server = http.createServer((req, res) => {
  console.log(`Request: ${req.method} ${req.url}`);
  
  // Add CORS headers
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
  
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    res.writeHead(200);
    res.end();
    return;
  }
  
  let filePath = path.join(BUILD_DIR, req.url === '/' ? 'index.html' : req.url);
  
  // Check if file exists
  fs.access(filePath, fs.constants.F_OK, (err) => {
    if (err) {
      // File doesn't exist, serve index.html for SPA routing
      filePath = path.join(BUILD_DIR, 'index.html');
    }
    
    fs.readFile(filePath, (err, content) => {
      if (err) {
        console.error(`Error reading file ${filePath}:`, err);
        res.writeHead(500);
        res.end('Internal Server Error');
        return;
      }
      
      const mimeType = getMimeType(filePath);
      res.setHeader('Content-Type', mimeType);
      
      // Add cache control for static assets
      if (req.url.includes('/assets/') || req.url.includes('/canvaskit/')) {
        res.setHeader('Cache-Control', 'public, max-age=31536000'); // 1 year
      }
      
      res.writeHead(200);
      res.end(content);
      console.log(`Served: ${filePath} (${mimeType})`);
    });
  });
});

server.listen(PORT, '0.0.0.0', () => {
  console.log(`✅ Flutter web app is running at:`);
  console.log(`   Local:    http://localhost:${PORT}`);
  console.log(`   Network:  http://0.0.0.0:${PORT}`);
  console.log(`\n🚀 Open one of these URLs in your browser to view the app!`);
});

// Handle server errors
server.on('error', (err) => {
  console.error('❌ Server error:', err);
  if (err.code === 'EADDRINUSE') {
    console.error(`Port ${PORT} is already in use. Try a different port.`);
  }
});
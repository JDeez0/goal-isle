#!/bin/bash

# Goal Isle Flutter Web App Launcher
# This script finds the best way to serve your Flutter web app

set -e

echo "🚀 Goal Isle App Launcher"
echo "=========================="

# Navigate to project directory
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"

echo "📂 Project directory: $PROJECT_DIR"

# Check if build exists
if [ ! -d "build/web" ]; then
    echo "❌ Build directory not found. Building Flutter web app..."
    if command -v /home/jasper/flutter/bin/flutter >/dev/null 2>&1; then
        /home/jasper/flutter/bin/flutter build web --no-tree-shake-icons
    else
        echo "❌ Flutter not found. Please build the app first with: flutter build web"
        exit 1
    fi
fi

echo "✅ Build directory found"

# Function to check if port is available
check_port() {
    local port=$1
    if ss -tuln 2>/dev/null | grep -q ":$port "; then
        return 1
    else
        return 0
    fi
}

# Find available port
find_available_port() {
    local start_port=$1
    local port=$start_port
    while ! check_port $port; do
        ((port++))
        if [ $port -gt $((start_port + 100)) ]; then
            echo "❌ No available ports found in range $start_port-$((start_port + 100))"
            exit 1
        fi
    done
    echo $port
}

echo ""
echo "🔍 Checking available serving options..."

# Option 1: Try Node.js serve (most reliable according to research)
if command -v node >/dev/null 2>&1 && command -v npm >/dev/null 2>&1; then
    echo "✅ Node.js found - this is the recommended option"
    
    # Check if serve is installed
    if ! command -v serve >/dev/null 2>&1; then
        echo "📦 Installing 'serve' package..."
        npm install -g serve
    fi
    
    if command -v serve >/dev/null 2>&1; then
        PORT=$(find_available_port 3000)
        echo ""
        echo "🎯 Starting Node.js serve on port $PORT..."
        echo "📱 Your app will be available at:"
        echo "   🌐 http://localhost:$PORT"
        echo "   🌐 http://127.0.0.1:$PORT"
        echo ""
        echo "Press Ctrl+C to stop the server"
        echo ""
        
        cd build/web
        serve -s . -p $PORT --no-clipboard
        exit 0
    fi
fi

# Option 2: Try custom Node.js server
if command -v node >/dev/null 2>&1; then
    echo "✅ Node.js found - using custom server"
    PORT=$(find_available_port 3003)
    
    # Create a simple server script
    cat > temp_server.js << EOF
const http = require('http');
const fs = require('fs');
const path = require('path');
const PORT = $PORT;
const BUILD_DIR = path.join(__dirname, 'build', 'web');

const MIME_TYPES = {
  '.html': 'text/html', '.js': 'application/javascript', '.css': 'text/css',
  '.json': 'application/json', '.png': 'image/png', '.jpg': 'image/jpeg',
  '.gif': 'image/gif', '.svg': 'image/svg+xml', '.ico': 'image/x-icon',
  '.woff': 'font/woff', '.woff2': 'font/woff2'
};

function getMimeType(filePath) {
  const ext = path.extname(filePath).toLowerCase();
  return MIME_TYPES[ext] || 'application/octet-stream';
}

const server = http.createServer((req, res) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  let filePath = path.join(BUILD_DIR, req.url === '/' ? 'index.html' : req.url);
  
  fs.access(filePath, fs.constants.F_OK, (err) => {
    if (err) filePath = path.join(BUILD_DIR, 'index.html');
    
    fs.readFile(filePath, (err, content) => {
      if (err) {
        res.writeHead(500);
        res.end('Internal Server Error');
        return;
      }
      res.setHeader('Content-Type', getMimeType(filePath));
      res.writeHead(200);
      res.end(content);
    });
  });
});

server.listen(PORT, '0.0.0.0', () => {
  console.log('✅ Flutter web app is running at:');
  console.log('   🌐 http://localhost:' + PORT);
  console.log('   🌐 http://127.0.0.1:' + PORT);
});
EOF
    
    echo ""
    echo "🎯 Starting custom Node.js server on port $PORT..."
    echo "📱 Your app will be available at:"
    echo "   🌐 http://localhost:$PORT"
    echo "   🌐 http://127.0.0.1:$PORT"
    echo ""
    echo "Press Ctrl+C to stop the server"
    echo ""
    
    node temp_server.js
    rm -f temp_server.js
    exit 0
fi

# Option 3: Try Python server
if command -v python3 >/dev/null 2>&1; then
    echo "✅ Python3 found - using Python server"
    PORT=$(find_available_port 3004)
    
    echo ""
    echo "🎯 Starting Python server on port $PORT..."
    echo "📱 Your app will be available at:"
    echo "   🌐 http://localhost:$PORT"
    echo "   🌐 http://127.0.0.1:$PORT"
    echo ""
    echo "Press Ctrl+C to stop the server"
    echo ""
    
    python3 serve.py
    exit 0
fi

# Option 4: Try Flutter's built-in server
if command -v /home/jasper/flutter/bin/flutter >/dev/null 2>&1; then
    echo "✅ Flutter found - using Flutter's built-in server"
    PORT=$(find_available_port 3005)
    
    echo ""
    echo "🎯 Starting Flutter web server on port $PORT..."
    echo "📱 Your app will be available at:"
    echo "   🌐 http://localhost:$PORT"
    echo "   🌐 http://127.0.0.1:$PORT"
    echo ""
    echo "Press Ctrl+C to stop the server"
    echo ""
    
    /home/jasper/flutter/bin/flutter run -d web-server --web-hostname=0.0.0.0 --web-port=$PORT
    exit 0
fi

echo "❌ No suitable server found!"
echo "Please install one of the following:"
echo "  - Node.js (recommended): https://nodejs.org/"
echo "  - Python 3"
echo "  - Flutter SDK"
exit 1
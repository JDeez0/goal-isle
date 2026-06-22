#!/usr/bin/env python3
"""
Simple HTTP server for Flutter web apps with SPA routing support.
Based on Python's built-in http.server but with SPA routing for Flutter.
"""

import http.server
import socketserver
import os
import sys
from pathlib import Path

PORT = 3004
DIRECTORY = Path(__file__).parent / "build" / "web"

class SPAHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    """Custom handler to serve index.html for all non-file routes (SPA routing)"""
    
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=str(DIRECTORY), **kwargs)
    
    def end_headers(self):
        # Add CORS headers for development
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        super().end_headers()
    
    def do_GET(self):
        # Check if the requested file exists
        file_path = DIRECTORY / self.path.lstrip('/')
        
        # If it's a directory, try index.html
        if file_path.is_dir():
            file_path = file_path / "index.html"
        
        # If file doesn't exist and it's not an asset, serve index.html (SPA routing)
        if not file_path.exists() and not self.path.startswith('/assets/') and not self.path.startswith('/canvaskit/'):
            self.path = '/index.html'
        
        # Call the parent handler
        super().do_GET()
    
    def do_OPTIONS(self):
        # Handle CORS preflight requests
        self.send_response(200)
        self.end_headers()

def main():
    print(f"Starting Python HTTP server...")
    print(f"Serving directory: {DIRECTORY}")
    print(f"Port: {PORT}")
    
    if not DIRECTORY.exists():
        print(f"❌ Error: Directory {DIRECTORY} does not exist!")
        print("Make sure you've run 'flutter build web' first.")
        sys.exit(1)
    
    try:
        with socketserver.TCPServer(("", PORT), SPAHTTPRequestHandler) as httpd:
            print(f"\n✅ Flutter web app is running at:")
            print(f"   Local:    http://localhost:{PORT}")
            print(f"   Network:  http://0.0.0.0:{PORT}")
            print(f"\n🚀 Open one of these URLs in your browser to view the app!")
            print(f"\nPress Ctrl+C to stop the server\n")
            
            httpd.serve_forever()
    except KeyboardInterrupt:
        print(f"\n👋 Server stopped")
    except OSError as e:
        if e.errno == 48:  # Address already in use
            print(f"❌ Port {PORT} is already in use. Try a different port.")
        else:
            print(f"❌ Server error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
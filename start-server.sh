#!/bin/bash

# IndiBindi Web Server Startup Script
# This script starts both the Flutter web server and ngrok tunnel

echo "🚀 Starting IndiBindi Web Server..."

# Kill any existing processes on port 8080
lsof -ti:8080 | xargs kill -9 2>/dev/null

# Kill any existing ngrok processes
pkill -f ngrok 2>/dev/null

sleep 2

echo "📦 Building and starting Flutter web server (release mode)..."

# Start Flutter web server in background
cd "/Users/pengwin/VS Projects/indibindi5"
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080 --release &
FLUTTER_PID=$!

# Wait for Flutter server to start
sleep 10

echo "🌐 Starting ngrok tunnel..."

# Start ngrok
ngrok http 8080

# When ngrok is closed, also stop Flutter
kill $FLUTTER_PID 2>/dev/null
echo "👋 Servers stopped."

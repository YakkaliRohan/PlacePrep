#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "================================================="
echo "   🎯 Starting PlacePrep 2.0 (Python + Dart)     "
echo "================================================="

# 1. Start Python FastAPI backend in the background
echo "1️⃣ Starting Python FastAPI backend on port 8000..."
cd "$DIR/backend"
source venv/bin/activate
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload &
BACKEND_PID=$!

echo "   Backend PID: $BACKEND_PID"
echo "   API Base: http://127.0.0.1:8000"
echo "   Swagger Docs: http://127.0.0.1:8000/api/docs"
echo ""

# 2. Trap SIGINT/SIGTERM to cleanly kill backend on exit
cleanup() {
    echo ""
    echo "Stopping PlacePrep servers..."
    kill $BACKEND_PID 2>/dev/null
    exit 0
}
trap cleanup SIGINT SIGTERM

# 3. Launch Flutter Web (with --no-devtools to prevent AppInspector WipError desync)
echo "2️⃣ Starting Dart/Flutter Web frontend..."
cd "$DIR/frontend"
/Users/rohanyakkali/flutter/bin/flutter run -d chrome --no-devtools --web-port 3000

# Wait for background processes
wait $BACKEND_PID

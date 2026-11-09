#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "================================================="
echo "   🚀 PlacePrep 2.0 (Fast Production Mode)       "
echo "================================================="

# 1. Start Python backend if not already running on port 8000
if lsof -i :8000 >/dev/null 2>&1; then
    echo "1️⃣ Python FastAPI backend already running on port 8000."
    BACKEND_PID=""
else
    echo "1️⃣ Starting Python FastAPI backend on port 8000..."
    cd "$DIR/backend"
    source venv/bin/activate
    uvicorn app.main:app --host 0.0.0.0 --port 8000 &
    BACKEND_PID=$!
fi

# Determine free web port (3000, 3001, etc.)
WEB_PORT=3000
if lsof -i :3000 >/dev/null 2>&1; then
    WEB_PORT=3001
fi

# 2. Cleanup trap
cleanup() {
    echo ""
    echo "Stopping servers..."
    [ -n "$BACKEND_PID" ] && kill $BACKEND_PID 2>/dev/null
    [ -n "$WEB_PID" ] && kill $WEB_PID 2>/dev/null
    exit 0
}
trap cleanup SIGINT SIGTERM

# 3. Serve precompiled Flutter Web build
echo "2️⃣ Serving precompiled Flutter Web app on http://localhost:$WEB_PORT..."
cd "$DIR/frontend/build/web"
python3 -m http.server $WEB_PORT &
WEB_PID=$!

echo ""
echo "✅ PlacePrep running!"
echo "   🌐 Web App:      http://localhost:$WEB_PORT"
echo "   ⚡ API Server:   http://127.0.0.1:8000"
echo "   📖 Swagger Docs: http://127.0.0.1:8000/api/docs"
echo ""

sleep 1
open "http://localhost:$WEB_PORT" 2>/dev/null || true

wait
